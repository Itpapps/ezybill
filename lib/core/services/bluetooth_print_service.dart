import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../application/providers/core_providers.dart';

// ---------------------------------------------------------------------------
// Connection state enum
// ---------------------------------------------------------------------------

enum BtConnectionState {
  none,
  connecting,
  connected,
  error,
}

// ---------------------------------------------------------------------------
// Permission status result — never throws
// ---------------------------------------------------------------------------

enum BtPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}

// ---------------------------------------------------------------------------
// Device model
// ---------------------------------------------------------------------------

class BtDevice {
  final String name;
  final String address;

  const BtDevice({required this.name, required this.address});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BtDevice && address == other.address;

  @override
  int get hashCode => address.hashCode;

  @override
  String toString() => 'BtDevice($name, $address)';
}

// ---------------------------------------------------------------------------
// Printer model
// ---------------------------------------------------------------------------

enum PrinterModel {
  thermal58mm(32),
  thermal80mm(40);

  final int lineWidth;
  const PrinterModel(this.lineWidth);
}

PrinterModel detectPrinterModel(String deviceName) {
  if (deviceName.toUpperCase().startsWith('97BT-')) {
    return PrinterModel.thermal80mm;
  }
  return PrinterModel.thermal58mm;
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class BluetoothPrintState {
  final BtConnectionState connectionState;
  final BtDevice? connectedDevice;
  final PrinterModel printerModel;
  final String? errorMessage;

  const BluetoothPrintState({
    this.connectionState = BtConnectionState.none,
    this.connectedDevice,
    this.printerModel = PrinterModel.thermal58mm,
    this.errorMessage,
  });

  bool get isConnected => connectionState == BtConnectionState.connected;

  BluetoothPrintState copyWith({
    BtConnectionState? connectionState,
    BtDevice? connectedDevice,
    PrinterModel? printerModel,
    String? errorMessage,
    bool clearDevice = false,
    bool clearError = false,
  }) {
    return BluetoothPrintState(
      connectionState: connectionState ?? this.connectionState,
      connectedDevice:
          clearDevice ? null : (connectedDevice ?? this.connectedDevice),
      printerModel: printerModel ?? this.printerModel,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier — production-grade, crash-proof design
// ---------------------------------------------------------------------------

/// Production Bluetooth print notifier.
///
/// Design principles:
/// - `build()` is PURE SYNCHRONOUS — cannot crash, cannot fail.
/// - SharedPreferences accessed via `ref.read()` only (never watched).
/// - No Timers or async work in `build()`.
/// - All platform calls wrapped in try/catch with typed error handling.
/// - Permissions are checked silently first; only requested if not granted.
/// - `openAppSettings()` is NEVER called automatically — only exposed as a
///   method for the UI to call when the user explicitly taps a button.
class BluetoothPrintNotifier extends Notifier<BluetoothPrintState> {
  // ── SharedPreferences keys ──────────────────────────────────────────────
  static const String _kMacKey = 'bluetoothmac';
  static const String _kNameKey = 'bluetoothname';

  // ── build — MUST be synchronous and infallible ──────────────────────────

  @override
  BluetoothPrintState build() {
    // Pure initial state. No async, no watchers, no side effects.
    // This guarantees the provider can NEVER enter an error state at startup.
    return const BluetoothPrintState();
  }

  // ── Permission helpers ────────────────────────────────────────────────────

  /// Check current Bluetooth permission status WITHOUT requesting. Never throws.
  /// Only checks the two BT permissions needed for classic printer operations.
  /// Location is excluded — our manifest uses neverForLocation flag.
  Future<BtPermissionStatus> checkPermissions() async {
    if (!Platform.isAndroid) return BtPermissionStatus.granted;
    try {
      final scan = await Permission.bluetoothScan.status;
      final connect = await Permission.bluetoothConnect.status;

      if (scan.isPermanentlyDenied || connect.isPermanentlyDenied) {
        return BtPermissionStatus.permanentlyDenied;
      }
      if (scan.isGranted && connect.isGranted) {
        return BtPermissionStatus.granted;
      }
      return BtPermissionStatus.denied;
    } catch (e) {
      debugPrint('[BT] checkPermissions error: $e');
      // If we can't check, assume granted and let the platform call fail gracefully.
      return BtPermissionStatus.granted;
    }
  }

  /// Request Bluetooth permissions only. Returns true if all granted. Never throws.
  /// Does NOT include locationWhenInUse — handled at registration.
  /// Does NOT open app settings automatically.
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return true;
    try {
      final results = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      return results.values.every((s) => s.isGranted);
    } catch (e) {
      debugPrint('[BT] Permission request error: $e');
      return false;
    }
  }

  /// Open the system App Settings page (for permission management).
  Future<void> openAppSettingsPage() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('[BT] openAppSettings error: $e');
    }
  }

  /// Open the Android Bluetooth Settings page so the user can pair new devices.
  /// Falls back to openAppSettings if the intent fails.
  Future<void> openBluetoothSettings() async {
    if (!Platform.isAndroid) return;
    try {
      const platform = MethodChannel('com.ezybill/settings');
      await platform.invokeMethod('openBluetoothSettings');
    } catch (e) {
      debugPrint('[BT] MethodChannel openBluetoothSettings failed: $e');
      // Fallback: try intent via url_launcher-style approach
      try {
        // Fallback to app settings if platform channel not available
        await openAppSettings();
      } catch (e2) {
        debugPrint('[BT] Fallback openAppSettings also failed: $e2');
      }
    }
  }

  // ── SharedPreferences (read lazily, never watch) ──────────────────────────

  void _saveDevice(BtDevice device) {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      prefs.setString(_kMacKey, device.address);
      prefs.setString(_kNameKey, device.name);
    } catch (e) {
      debugPrint('[BT] Save prefs error: $e');
    }
  }

  BtDevice? _loadSavedDevice() {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final mac = prefs.getString(_kMacKey);
      final name = prefs.getString(_kNameKey) ?? '';
      if (mac == null || mac.isEmpty) return null;
      return BtDevice(name: name, address: mac);
    } catch (e) {
      debugPrint('[BT] Load prefs error: $e');
      return null;
    }
  }

  void _clearSavedDevice() {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      prefs.remove(_kMacKey);
      prefs.remove(_kNameKey);
    } catch (e) {
      debugPrint('[BT] Clear prefs error: $e');
    }
  }

  // ── MAC address normalization ─────────────────────────────────────────────

  String _formatMac(String mac) {
    if (mac.contains(':') && mac.length == 17) return mac.toUpperCase();
    final cleaned = mac.replaceAll(RegExp(r'[:\s\-]'), '').toUpperCase();
    if (cleaned.length == 12) {
      return cleaned
          .replaceAllMapped(RegExp(r'.{2}'), (m) => '${m.group(0)}:')
          .substring(0, 17);
    }
    return mac;
  }

  // ── Bluetooth enabled check ───────────────────────────────────────────────

  /// Returns true if Bluetooth adapter is enabled. Never throws.
  Future<bool> isBluetoothEnabled() async {
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (e) {
      debugPrint('[BT] bluetoothEnabled check error: $e');
      return false;
    }
  }

  // ── Get bonded devices ────────────────────────────────────────────────────

  /// Returns bonded devices. Requires permissions to be already granted.
  /// Never throws — returns empty list on any error.
  Future<List<BtDevice>> getBondedDevices() async {
    try {
      final List<BluetoothInfo> bonded =
          await PrintBluetoothThermal.pairedBluetooths;
      return bonded
          .where((i) => i.macAdress.isNotEmpty)
          .map((i) => BtDevice(
                name: i.name.isNotEmpty ? i.name : 'Unknown Device',
                address: i.macAdress,
              ))
          .toList();
    } catch (e) {
      debugPrint('[BT] getBondedDevices error: $e');
      return [];
    }
  }

  // ── Connect ───────────────────────────────────────────────────────────────

  Future<void> connectToDevice(BtDevice device) async {
    state = state.copyWith(
      connectionState: BtConnectionState.connecting,
      clearError: true,
    );

    try {
      // Permissions MUST be granted before connecting
      final granted = await requestPermissions();
      if (!granted) {
        state = state.copyWith(
          connectionState: BtConnectionState.error,
          errorMessage:
              'Bluetooth permission denied. Tap "Open App Settings" to grant it.',
        );
        return;
      }

      // Disconnect any existing session cleanly
      try {
        final already = await PrintBluetoothThermal.connectionStatus;
        if (already) {
          await PrintBluetoothThermal.disconnect;
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      } catch (_) {}

      final mac = _formatMac(device.address);
      debugPrint('[BT] Connecting to $mac...');

      final connectResult = await PrintBluetoothThermal.connect(
        macPrinterAddress: mac,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => false,
      );

      // Poll for actual connection (up to 6 × 300ms = 1.8s)
      bool connected = false;
      for (int i = 0; i < 6; i++) {
        try {
          connected = await PrintBluetoothThermal.connectionStatus;
        } catch (_) {
          connected = false;
        }
        if (connected) break;
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }

      if (!connectResult || !connected) {
        state = state.copyWith(
          connectionState: BtConnectionState.error,
          errorMessage:
              'Could not connect to "${device.name}". Make sure the printer is on and nearby.',
        );
        return;
      }

      final model = detectPrinterModel(device.name);
      _saveDevice(device);

      state = state.copyWith(
        connectionState: BtConnectionState.connected,
        connectedDevice: device,
        printerModel: model,
        clearError: true,
      );
      debugPrint('[BT] Connected → ${device.name} ($mac)');
    } on TimeoutException {
      state = state.copyWith(
        connectionState: BtConnectionState.error,
        errorMessage:
            'Connection timed out. Make sure the printer is powered on.',
      );
    } catch (e) {
      state = state.copyWith(
        connectionState: BtConnectionState.error,
        errorMessage: 'Unable to connect: ${_friendlyError(e)}',
      );
    }
  }

  // ── Auto-reconnect (call explicitly, e.g. from registration screen) ───────

  Future<void> tryAutoReconnect() async {
    final saved = _loadSavedDevice();
    if (saved == null) return;
    try {
      final btEnabled = await isBluetoothEnabled();
      if (!btEnabled) return;
      final perms = await checkPermissions();
      if (perms != BtPermissionStatus.granted) return;
      debugPrint('[BT] Auto-reconnecting to ${saved.address}...');
      await connectToDevice(saved);
    } catch (e) {
      debugPrint('[BT] Auto-reconnect failed: $e');
    }
  }

  // ── Disconnect ────────────────────────────────────────────────────────────

  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
    } catch (e) {
      debugPrint('[BT] Disconnect error: $e');
    }
    state = state.copyWith(
      connectionState: BtConnectionState.none,
      clearDevice: true,
      clearError: true,
    );
  }

  Future<void> forgetDevice() async {
    await disconnect();
    _clearSavedDevice();
  }

  // ── Printing ──────────────────────────────────────────────────────────────

  /// Print a full receipt from pre-formatted text lines.
  ///
  /// Sends all content in one write call (most reliable for thermal printers).
  Future<bool> printReceipt(List<String> lines) async {
    if (!state.isConnected) return false;

    try {
      // Verify connection is still alive
      bool connected = false;
      try {
        connected = await PrintBluetoothThermal.connectionStatus;
      } catch (_) {
        connected = false;
      }

      if (!connected) {
        // Try once to reconnect
        final saved = state.connectedDevice ?? _loadSavedDevice();
        if (saved != null) {
          await connectToDevice(saved);
          connected = state.isConnected;
        }
        if (!connected) {
          state = state.copyWith(
            connectionState: BtConnectionState.error,
            errorMessage: 'Printer disconnected. Please reconnect.',
            clearDevice: true,
          );
          return false;
        }
      }

      await Future<void>.delayed(const Duration(milliseconds: 600));

      // Build full byte buffer
      final List<int> byteList = [];
      byteList.addAll(utf8.encode('\n'));
      for (final line in lines) {
        byteList.addAll(utf8.encode('$line\n'));
      }
      // Paper feed — 3 blank lines
      byteList.addAll(utf8.encode('\n\n\n'));

      await Future<void>.delayed(const Duration(milliseconds: 300));

      // The plugin's Kotlin side casts the argument to java.util.List,
      // so we MUST send List<int> (not Uint8List which becomes byte[]).
      const btChannel = MethodChannel('groons.web.app/print');
      final result = await btChannel.invokeMethod<bool>('writebytes', byteList) ?? false;
      debugPrint('[BT] printReceipt result=$result (${byteList.length} bytes)');
      return result;
    } catch (e) {
      debugPrint('[BT] printReceipt error: $e');
      state = state.copyWith(
        connectionState: BtConnectionState.error,
        errorMessage: 'Print failed: ${_friendlyError(e)}',
      );
      return false;
    }
  }

  // ── Error helpers ─────────────────────────────────────────────────────────

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('permission') || msg.contains('security')) {
      return 'Bluetooth permission denied. Grant it in App Settings.';
    }
    if (msg.contains('timeout')) {
      return 'Connection timed out. Make sure the printer is on and nearby.';
    }
    if (msg.contains('socket') || msg.contains('rfcomm')) {
      return 'Could not open printer connection. Toggle printer power and retry.';
    }
    if (msg.contains('bonded') || msg.contains('paired')) {
      return 'Printer not paired. Pair via System Bluetooth Settings first.';
    }
    if (Platform.isAndroid && msg.contains('null')) {
      return 'Bluetooth adapter error. Restart Bluetooth and try again.';
    }
    return e.toString().replaceAll('Exception: ', '');
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final bluetoothPrintProvider =
    NotifierProvider<BluetoothPrintNotifier, BluetoothPrintState>(
  BluetoothPrintNotifier.new,
);
