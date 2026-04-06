import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/bluetooth_print_service.dart';
import '../../../core/theme/app_colors.dart';

/// Scans for nearby Bluetooth LE devices and allows the user to connect to a
/// thermal printer.
///
/// Shows device name, MAC address, and signal strength (RSSI) for each
/// discovered device. Handles Bluetooth and Location permission requests.
class DeviceDiscoveryScreen extends ConsumerStatefulWidget {
  const DeviceDiscoveryScreen({super.key});

  @override
  ConsumerState<DeviceDiscoveryScreen> createState() =>
      _DeviceDiscoveryScreenState();
}

class _DeviceDiscoveryScreenState extends ConsumerState<DeviceDiscoveryScreen> {
  bool _permissionGranted = false;
  bool _checkingPermissions = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPermissions());
  }

  // ── Permissions ────────────────────────────────────────────────────────

  Future<void> _checkPermissions() async {
    setState(() => _checkingPermissions = true);

    // Android 12+ requires BLUETOOTH_SCAN and BLUETOOTH_CONNECT.
    // Older Android requires ACCESS_FINE_LOCATION for BLE scanning.
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final allGranted = statuses.values.every(
        (s) => s.isGranted || s.isLimited);

    setState(() {
      _permissionGranted = allGranted;
      _checkingPermissions = false;
    });

    if (allGranted) {
      _startScan();
    }
  }

  void _startScan() {
    ref
        .read(bluetoothPrintProvider.notifier)
        .startScan(timeout: const Duration(seconds: 12));
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
      Navigator.of(context).pop(true);
    }
  }

  // ── UI ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final btState = ref.watch(bluetoothPrintProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Scan for Devices',
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
        actions: [
          if (_permissionGranted && !btState.isScanning)
            IconButton(
              onPressed: _startScan,
              icon: const Icon(LucideIcons.refreshCw, size: 20),
              tooltip: 'Rescan',
            ),
        ],
      ),
      body: _buildBody(btState),
    );
  }

  Widget _buildBody(BluetoothPrintState btState) {
    if (_checkingPermissions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_permissionGranted) {
      return _buildPermissionDenied();
    }

    return Column(
      children: [
        // Scanning indicator
        if (btState.isScanning)
          Container(
            width: double.infinity,
            color: AppColors.primaryLight,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Scanning for nearby devices...',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

        // Error banner
        if (btState.connectionState == BtConnectionState.error &&
            btState.errorMessage != null)
          Container(
            width: double.infinity,
            color: AppColors.dangerBg,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              btState.errorMessage!,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: AppColors.danger,
              ),
            ),
          ),

        // Device list
        Expanded(
          child: btState.discoveredDevices.isEmpty
              ? _buildEmptyState(btState.isScanning)
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: btState.discoveredDevices.length,
                  itemBuilder: (context, index) {
                    final device = btState.discoveredDevices[index];
                    return _DeviceCard(
                      device: device,
                      isConnecting: btState.connectionState ==
                          BtConnectionState.connecting,
                      isCurrentDevice:
                          btState.connectedDevice?.address == device.address,
                      onConnect: () => _connectToDevice(device),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(LucideIcons.shieldOff,
                  size: 36, color: AppColors.danger),
            ),
            const SizedBox(height: 16),
            const Text(
              'Permissions Required',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bluetooth and Location permissions are required to scan for nearby printers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _checkPermissions,
              icon: const Icon(LucideIcons.shield, size: 16),
              label: const Text('Grant Permissions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text(
                'Open Settings',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isScanning) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isScanning ? LucideIcons.radio : LucideIcons.bluetoothOff,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isScanning ? 'Searching...' : 'No Devices Found',
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isScanning
                ? 'Looking for nearby Bluetooth printers'
                : 'Make sure your printer is turned on and nearby',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (!isScanning) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _startScan,
              icon: const Icon(LucideIcons.search, size: 16),
              label: const Text('Scan Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Device card
// ─────────────────────────────────────────────────────────────────────────────

class _DeviceCard extends StatelessWidget {
  final BtDevice device;
  final bool isConnecting;
  final bool isCurrentDevice;
  final VoidCallback onConnect;

  const _DeviceCard({
    required this.device,
    required this.isConnecting,
    required this.isCurrentDevice,
    required this.onConnect,
  });

  /// Map RSSI value to a signal icon.
  IconData _signalIcon(int rssi) {
    if (rssi >= -50) return LucideIcons.signal;
    if (rssi >= -70) return LucideIcons.signal;
    return LucideIcons.signalLow;
  }

  Color _signalColor(int rssi) {
    if (rssi >= -50) return AppColors.success;
    if (rssi >= -70) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        device.name.isNotEmpty ? device.name : 'Unknown Device';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentDevice ? AppColors.success : AppColors.border,
          width: isCurrentDevice ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Signal icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.printer,
                size: 22,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),

            // Device info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
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
                  if (device.rssi != 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _signalIcon(device.rssi),
                          size: 12,
                          color: _signalColor(device.rssi),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${device.rssi} dBm',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: _signalColor(device.rssi),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Connect button
            if (isCurrentDevice)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Connected',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              )
            else
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: isConnecting ? null : onConnect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: isConnecting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text('Connect'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
