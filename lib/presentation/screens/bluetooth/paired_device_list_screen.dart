import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Bluetooth Printer Screen
//
// Standalone StatefulWidget — NO Riverpod in build().
// Calls PrintBluetoothThermal directly (same as user's reference code).
// Null-safe theme access (fallback to AppColors.light if extension missing).
// ─────────────────────────────────────────────────────────────────────────────

class PairedDeviceListScreen extends StatefulWidget {
  const PairedDeviceListScreen({super.key});

  @override
  State<PairedDeviceListScreen> createState() => _PairedDeviceListScreenState();
}

class _PairedDeviceListScreenState extends State<PairedDeviceListScreen>
    with WidgetsBindingObserver {
  // ── State ─────────────────────────────────────────────────────────────────
  List<BluetoothInfo> _devices = [];
  bool _loading = true;
  String? _error;
  String? _savedMac;
  String? _savedName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Auto-refresh when returning from System BT Settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_loading) _loadDevices();
      });
    }
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState((){
        _savedMac = prefs.getString('bluetoothmac');
        _savedName = prefs.getString('bluetoothname');
      });
    }

    // 1. Request permissions (Android only)
    if (Platform.isAndroid) {
      try {
        final results = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ].request();

        final allGranted = results.values.every((s) => s.isGranted);
        if (!allGranted) {
          if (!mounted) return;
          final permDenied =
              results.values.any((s) => s.isPermanentlyDenied);
          setState(() {
            _loading = false;
            _error = permDenied
                ? 'Bluetooth permission permanently denied.\nTap below to open App Settings.'
                : 'Bluetooth permission required to show paired devices.';
          });
          return;
        }
      } catch (e) {
        debugPrint('[BT Screen] Permission error: $e');
        // Continue — let the device list call handle it
      }
    }

    // 2. Load paired devices
    await _loadDevices();
  }

  Future<void> _loadDevices() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final List<BluetoothInfo> bonded =
          await PrintBluetoothThermal.pairedBluetooths;
      if (!mounted) return;
      setState(() {
        _devices = bonded.where((d) => d.macAdress.isNotEmpty).toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint('[BT Screen] Load devices error: $e');
      if (!mounted) return;
      setState(() {
        _devices = [];
        _loading = false;
        final msg = e.toString().toLowerCase();
        if (msg.contains('permission') || msg.contains('security')) {
          _error =
              'Bluetooth permission required.\nPlease grant it in App Settings.';
        } else {
          _error = 'Could not load paired devices.\nMake sure Bluetooth is on.';
        }
      });
    }
  }

  // ── Save / Forget ──────────────────────────────────────────────────────────
  Future<void> _saveDevice(BluetoothInfo device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bluetoothmac',device.macAdress);
    final name = device.name.isNotEmpty? device.name:'Printer';
    await prefs.setString('bluetoothname',name);
    if(!mounted)return;
    setState((){
      _savedMac = device.macAdress;
      _savedName = name;
    });
    _showSnack('Saved: $name',isError:false);
  }
  Future<void> _forgetDevice() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bluetoothmac');
    await prefs.remove('bluetoothname');
    if(!mounted)return;
    setState((){
      _savedMac = null;
      _savedName = null;
    });
    _showSnack('Saved Printer Removed',isError:false);
  }

  Future<void> _openSystemBluetooth() async {
    try {
      if (Platform.isAndroid) {
        await launchUrl(
          Uri.parse(
              'intent:#Intent;action=android.settings.BLUETOOTH_SETTINGS;end'),
          mode: LaunchMode.externalApplication,
        );
      } else if (Platform.isIOS) {
        await launchUrl(Uri.parse('App-prefs:Bluetooth'));
      }
    } catch (_) {
      if (mounted) {
        _showSnack(
          'Open Bluetooth in phone Settings to pair new devices',
          isError: false,
        );
      }
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: isError ? c.red : c.green,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
      ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Null-safe theme access — fallback to light colors if extension missing
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(
          'Bluetooth Printer',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.ink,
          ),
        ),
        backgroundColor: c.card,
        foregroundColor: c.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (!_loading)
            IconButton(
              icon: Icon(Icons.refresh_rounded, size: 22, color: c.ink60),
              tooltip: 'Refresh',
              onPressed: _loadDevices,
            ),
        ],
      ),
      body: _buildBody(c),
      bottomNavigationBar: _buildBottomBar(c),
    );
  }

  Widget _buildBody(AppColors c) {
    if (_loading) return _buildLoading(c);
    if (_error != null && _devices.isEmpty) return _buildErrorState(c);
    return _buildList(c);
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  Widget _buildLoading(AppColors c) {
    return Container(
      color: c.bg,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: c.red,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Checking Bluetooth...',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: c.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please wait',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: c.ink40,
            ),
          ),
        ],
      ),
    );
  }

  // ── Error / Permission denied ─────────────────────────────────────────────

  Widget _buildErrorState(AppColors c) {
    final isPermanent = _error?.contains('permanently') ?? false;
    return Container(
      color: c.bg,
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: c.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.bluetooth_disabled, size: 36, color: c.red),
          ),
          const SizedBox(height: 16),
          Text(
            isPermanent ? 'Permission Required' : 'Bluetooth Issue',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: c.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'An error occurred.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: c.ink40,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isPermanent ? _openSystemBluetooth : _init,
              icon: Icon(
                isPermanent ? Icons.settings : Icons.refresh_rounded,
                size: 18,
              ),
              label: Text(
                isPermanent ? 'Open App Settings' : 'Try Again',
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Device List ───────────────────────────────────────────────────────────

  Widget _buildList(AppColors c) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Connected banner
         _buildSavedBanner(c),

        // Error banner (non-blocking — list still shows)
        if (_error != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.red.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 16, color: c.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(
                        fontFamily: 'DM Sans', fontSize: 13, color: c.red),
                  ),
                ),
              ],
            ),
          ),

        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: c.blue.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 15, color: c.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Only paired devices are shown. '
                  'Tap "Scan for New Devices" to pair via System Bluetooth Settings.',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: c.blue,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'PAIRED DEVICES',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c.ink40,
              letterSpacing: 0.8,
            ),
          ),
        ),

        // Devices or empty
        if (_devices.isEmpty)
          _buildEmpty(c)
        else
          ..._devices.map((d) => _buildDeviceTile(d, c)),
      ],
    );
  }

  Widget _buildSavedBanner(AppColors c) {
    if (_savedMac == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: c.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Default Printer',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: c.green)),
                Text(_savedName ?? '',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.ink)),
              ],
            ),
          ),
          TextButton(
            onPressed: _forgetDevice,
            child: Text('Forget',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: c.red,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.ink10),
      ),
      child: Column(
        children: [
          Icon(Icons.print_outlined,
              size: 40, color: c.red.withValues(alpha: 0.5)),
          const SizedBox(height: 14),
          Text('No Paired Printers',
              style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: c.ink)),
          const SizedBox(height: 8),
          Text(
            'Pair your thermal printer in System Bluetooth\nSettings, then tap Refresh.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: c.ink40,
                height: 1.5),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _openSystemBluetooth,
            icon: Icon(Icons.bluetooth_rounded, size: 16, color: c.red),
            label: Text('Open Bluetooth Settings',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(BluetoothInfo device, AppColors c) {
  final isSaved = _savedMac == device.macAdress;
    final name =
        device.name.isNotEmpty ? device.name : 'Unknown Device';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSaved ? c.green : c.ink10,
          width: isSaved ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSaved
                ? c.green.withValues(alpha: 0.1)
                : c.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.print_rounded,
            size: 20,
            color: isSaved ? c.green : c.red,
          ),
        ),
        title: Text(name,
            style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.ink)),
        subtitle: Text(device.macAdress,
            style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: c.ink40)),
        trailing: isSaved
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Saved ✓',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: c.green)),
              )
            : SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: () => _saveDevice(device),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14),
                    minimumSize: Size.zero,
                    textStyle: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Save'),
                ),
              ),
      ),
    );
  }

  Widget _buildBottomBar(AppColors c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: c.card,
        border: Border(top: BorderSide(color: c.ink10)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _openSystemBluetooth,
          icon: const Icon(Icons.bluetooth_searching_rounded, size: 18),
          label: const Text(
            'Scan for New Devices',
            style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: c.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
