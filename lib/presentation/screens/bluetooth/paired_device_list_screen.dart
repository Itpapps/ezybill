import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/services/bluetooth_print_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../router/route_names.dart';

/// Displays already-paired Bluetooth devices and the currently connected
/// printer. Allows the user to connect, disconnect, or navigate to the
/// full discovery screen to find new devices.
class PairedDeviceListScreen extends ConsumerStatefulWidget {
  const PairedDeviceListScreen({super.key});

  @override
  ConsumerState<PairedDeviceListScreen> createState() =>
      _PairedDeviceListScreenState();
}

class _PairedDeviceListScreenState
    extends ConsumerState<PairedDeviceListScreen> {
  // In a real implementation, this would come from flutter_blue_plus's
  // bonded device list. For now we maintain a local list that includes
  // any previously-connected device stored in SharedPreferences.
  List<BtDevice> _pairedDevices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPairedDevices());
  }

  Future<void> _loadPairedDevices() async {
    setState(() => _loading = true);

    // TODO: Replace with flutter_blue_plus bonded devices.
    // Example:
    //   final bondedDevices = await FlutterBluePlus.bondedDevices;
    //   _pairedDevices = bondedDevices.map((d) => BtDevice(
    //     name: d.platformName,
    //     address: d.remoteId.str,
    //   )).toList();

    // For now, if there is a connected device, show it.
    final btState = ref.read(bluetoothPrintProvider);
    if (btState.connectedDevice != null) {
      _pairedDevices = [btState.connectedDevice!];
    }

    setState(() => _loading = false);
  }

  Future<void> _connectToDevice(BtDevice device) async {
    await ref.read(bluetoothPrintProvider.notifier).connectToDevice(device);

    if (!mounted) return;
    final state = ref.read(bluetoothPrintProvider);
    if (state.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.name}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _disconnectDevice() async {
    await ref.read(bluetoothPrintProvider.notifier).disconnect();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Printer disconnected'),
        backgroundColor: AppColors.textSecondary,
      ),
    );
  }

  Future<void> _forgetDevice() async {
    await ref.read(bluetoothPrintProvider.notifier).forgetDevice();
    setState(() => _pairedDevices = []);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Printer removed'),
        backgroundColor: AppColors.textSecondary,
      ),
    );
  }

  void _navigateToDiscovery() async {
    final result = await context.push<bool>(RouteNames.bluetoothDiscovery);
    if (result == true) {
      _loadPairedDevices();
    }
  }

  @override
  Widget build(BuildContext context) {
    final btState = ref.watch(bluetoothPrintProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Bluetooth Printer',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(btState),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildContent(BluetoothPrintState btState) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Current printer section ─────────────────────────────────────
        if (btState.connectedDevice != null) ...[
          const _SectionHeader(title: 'Current Printer'),
          const SizedBox(height: 12),
          _ConnectedPrinterCard(
            device: btState.connectedDevice!,
            printerModel: btState.printerModel,
            onDisconnect: _disconnectDevice,
            onForget: _forgetDevice,
          ),
          const SizedBox(height: 24),
        ],

        // ── Paired devices section ──────────────────────────────────────
        const _SectionHeader(title: 'Paired Devices'),
        const SizedBox(height: 12),

        if (_pairedDevices.isEmpty)
          _buildNoPairedDevices()
        else
          ..._pairedDevices.map(
            (device) => _PairedDeviceCard(
              device: device,
              isConnected: btState.connectedDevice?.address == device.address,
              isConnecting:
                  btState.connectionState == BtConnectionState.connecting,
              onConnect: () => _connectToDevice(device),
            ),
          ),

        // ── Error message ───────────────────────────────────────────────
        if (btState.connectionState == BtConnectionState.error &&
            btState.errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.dangerBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.alertCircle,
                    size: 16, color: AppColors.danger),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    btState.errorMessage!,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNoPairedDevices() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(LucideIcons.printer,
                size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          const Text(
            'No Paired Printers',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Scan for nearby printers to get started',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: _navigateToDiscovery,
          icon: const Icon(LucideIcons.search, size: 18),
          label: const Text('Scan for New Devices'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _ConnectedPrinterCard extends StatelessWidget {
  final BtDevice device;
  final PrinterModel printerModel;
  final VoidCallback onDisconnect;
  final VoidCallback onForget;

  const _ConnectedPrinterCard({
    required this.device,
    required this.printerModel,
    required this.onDisconnect,
    required this.onForget,
  });

  @override
  Widget build(BuildContext context) {
    final modelLabel = printerModel == PrinterModel.thermal80mm
        ? '80mm (40 chars)'
        : '58mm (32 chars)';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.printer,
                      size: 22, color: AppColors.success),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              device.name.isNotEmpty
                                  ? device.name
                                  : 'Printer',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        device.address,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Detected: $modelLabel',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDisconnect,
                    icon: const Icon(LucideIcons.unplug, size: 14),
                    label: const Text('Disconnect'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onForget,
                    icon: const Icon(LucideIcons.trash2, size: 14),
                    label: const Text('Forget'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PairedDeviceCard extends StatelessWidget {
  final BtDevice device;
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onConnect;

  const _PairedDeviceCard({
    required this.device,
    required this.isConnected,
    required this.isConnecting,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isConnected ? AppColors.successBg : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            LucideIcons.printer,
            size: 20,
            color: isConnected ? AppColors.success : AppColors.primary,
          ),
        ),
        title: Text(
          device.name.isNotEmpty ? device.name : 'Unknown',
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          device.address,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        trailing: isConnected
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Active',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: isConnecting ? null : onConnect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    textStyle: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Connect'),
                ),
              ),
      ),
    );
  }
}
