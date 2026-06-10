import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/bluetooth_print_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// "Add / Select Printer" screen — shows all bonded (paired) Bluetooth devices.
///
/// Classic Bluetooth thermal printers use SPP/RFCOMM and CANNOT be discovered
/// via BLE scanning (flutter_blue_plus). The correct flow is:
///   1. User pairs the printer in Android System Bluetooth Settings.
///   2. User returns here and taps the device to connect.
///   3. App connects via [PrintBluetoothThermal] and persists the choice.
///
/// This screen uses [WidgetsBindingObserver] to auto-refresh the bonded device
/// list when the user returns from System Bluetooth Settings.
class DeviceDiscoveryScreen extends ConsumerStatefulWidget {
  const DeviceDiscoveryScreen({super.key});

  @override
  ConsumerState<DeviceDiscoveryScreen> createState() =>
      _DeviceDiscoveryScreenState();
}

class _DeviceDiscoveryScreenState extends ConsumerState<DeviceDiscoveryScreen>
    with WidgetsBindingObserver {
  List<BtDevice> _bondedDevices = [];
  bool _loading = true;
  String? _loadError;
  bool _permissionsGranted = false;

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

  /// Auto-refresh when user returns from System Bluetooth Settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _permissionsGranted) {
      _loadBondedDevices();
    }
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    await _checkPermissions();
    if (_permissionsGranted) {
      await _loadBondedDevices();
    }
  }

  // ── Permissions ───────────────────────────────────────────────────────────

  Future<void> _checkPermissions() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _loadError = null;
    });

    final granted =
        await ref.read(bluetoothPrintProvider.notifier).requestPermissions();

    if (!mounted) return;
    setState(() => _permissionsGranted = granted);

    if (!granted) {
      setState(() {
        _loadError =
            'Bluetooth permissions are required.\nPlease grant them in App Settings.';
        _loading = false;
      });
    }
  }

  // ── Load bonded devices ───────────────────────────────────────────────────

  Future<void> _loadBondedDevices() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final devices =
          await ref.read(bluetoothPrintProvider.notifier).getBondedDevices();

      if (!mounted) return;
      setState(() {
        _bondedDevices = devices;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Failed to load paired devices: ${e.toString()}';
        _loading = false;
      });
    }
  }

  // ── Connect ───────────────────────────────────────────────────────────────

  Future<void> _connectToDevice(BtDevice device) async {
    await ref.read(bluetoothPrintProvider.notifier).connectToDevice(device);

    if (!mounted) return;
    final btState = ref.read(bluetoothPrintProvider);

    if (btState.isConnected) {
      _showSnackBar('Connected to ${device.name}', isError: false);
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.of(context).pop();
    } else if (btState.errorMessage != null) {
      _showSnackBar(btState.errorMessage!, isError: true);
    }
  }

  // ── Open system Bluetooth settings ────────────────────────────────────────

  Future<void> _openSystemBluetooth() async {
    // The app will auto-refresh via didChangeAppLifecycleState when user returns
    await openAppSettings();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    final c = Theme.of(context).extension<AppColors>()!;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? LucideIcons.alertCircle : LucideIcons.checkCircle2,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? c.red : c.green,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final btState = ref.watch(bluetoothPrintProvider);
    final c = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(
          'Select Printer',
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
          IconButton(
            onPressed: _loading ? null : _loadBondedDevices,
            icon: _loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.ink40,
                    ),
                  )
                : Icon(LucideIcons.refreshCw, size: 20, color: c.ink60),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(btState, c),
      bottomNavigationBar: _buildBottomBar(c),
    );
  }

  Widget _buildBody(BluetoothPrintState btState, AppColors c) {
    // ── Permission denied ──────────────────────────────────────────────────
    if (_loadError != null && !_permissionsGranted) {
      return _buildPermissionDeniedState(c);
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // ── How it works banner ──────────────────────────────────────────
        _buildInfoBanner(c),
        const SizedBox(height: 20),

        // ── Connection status banner ─────────────────────────────────────
        if (btState.connectionState == BtConnectionState.connecting)
          _buildConnectingBanner(c),

        if (btState.connectionState == BtConnectionState.error &&
            btState.errorMessage != null) ...[
          _buildErrorBanner(c, btState.errorMessage!),
          const SizedBox(height: 12),
        ],

        // ── Section label ────────────────────────────────────────────────
        _SectionLabel(title: 'Paired Devices', c: c),
        const SizedBox(height: 4),
        Text(
          'Tap any device below to connect as your printer',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            color: c.ink40,
          ),
        ),
        const SizedBox(height: 14),

        // ── Device list or empty state ───────────────────────────────────
        if (_loading)
          _buildLoadingState(c)
        else if (_bondedDevices.isEmpty)
          _buildEmptyState(c)
        else
          ..._bondedDevices.map(
            (device) => _DeviceCard(
              device: device,
              isConnected:
                  btState.connectedDevice?.address == device.address,
              isConnecting:
                  btState.connectionState == BtConnectionState.connecting,
              c: c,
              onConnect: () => _connectToDevice(device),
            ),
          ),

        const SizedBox(height: 24),

        // ── Open system settings hint ────────────────────────────────────
        _buildSystemSettingsTile(c),
      ],
    );
  }

  // ── Sub-widgets ────────────────────────────────────────────────────────────

  Widget _buildInfoBanner(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: c.blue.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, size: 16, color: c.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Thermal printers use Classic Bluetooth. First pair your printer '
              'in Android Bluetooth Settings, then select it here to connect.',
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
    );
  }

  Widget _buildConnectingBanner(AppColors c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: c.amber),
          ),
          const SizedBox(width: 10),
          Text(
            'Connecting to printer...',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: c.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(AppColors c, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.alertCircle, size: 16, color: c.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: c.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          CircularProgressIndicator(color: c.red),
          const SizedBox(height: 16),
          Text(
            'Loading paired devices...',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: c.ink40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: c.ink10),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: c.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(LucideIcons.printer, size: 30, color: c.red),
          ),
          const SizedBox(height: 14),
          Text(
            'No Paired Printers Found',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: c.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'To pair a new printer:\n'
            '1. Tap "Open Bluetooth Settings" below\n'
            '2. Pair your thermal printer\n'
            '3. Return here — the list will auto-refresh',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: c.ink40,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _openSystemBluetooth,
            icon: const Icon(LucideIcons.bluetooth, size: 16),
            label: const Text('Open Bluetooth Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              textStyle: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettingsTile(AppColors c) {
    return GestureDetector(
      onTap: _openSystemBluetooth,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.ink05,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(LucideIcons.bluetooth, size: 18, color: c.red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pair a New Printer',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Opens System Bluetooth Settings to pair a new device',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: c.ink40,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: c.ink20),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedState(AppColors c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: c.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(LucideIcons.shieldOff, size: 36, color: c.red),
            ),
            const SizedBox(height: 16),
            Text(
              'Permission Required',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: c.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _loadError ?? 'Bluetooth permissions are required.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                color: c.ink40,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await openAppSettings();
              },
              icon: const Icon(LucideIcons.settings2, size: 16),
              label: const Text('Open App Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _init,
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w600,
                  color: c.red,
                ),
              ),
            ),
          ],
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
        boxShadow: AppShadow.card,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: _openSystemBluetooth,
          icon: Icon(LucideIcons.bluetooth, size: 18, color: c.red),
          label: Text(
            'Open System Bluetooth Settings',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.red,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: c.red.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final AppColors c;
  const _SectionLabel({required this.title, required this.c});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: c.ink40,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final BtDevice device;
  final bool isConnected;
  final bool isConnecting;
  final AppColors c;
  final VoidCallback onConnect;

  const _DeviceCard({
    required this.device,
    required this.isConnected,
    required this.isConnecting,
    required this.c,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isConnected ? c.green : c.ink10,
          width: isConnected ? 2 : 1,
        ),
        boxShadow: AppShadow.card,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isConnected
                ? c.green.withValues(alpha: 0.1)
                : c.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            LucideIcons.printer,
            size: 22,
            color: isConnected ? c.green : c.red,
          ),
        ),
        title: Text(
          device.name.isNotEmpty ? device.name : 'Unknown Device',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: c.ink,
          ),
        ),
        subtitle: Text(
          device.address,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            color: c.ink40,
          ),
        ),
        trailing: isConnected
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: c.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: c.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Connected',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: c.green,
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: isConnecting ? null : onConnect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.red,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: c.red.withValues(alpha: 0.45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: isConnecting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Connect'),
                ),
              ),
      ),
    );
  }
}
