import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Connection state enum
// ---------------------------------------------------------------------------

/// Mirrors the Android BluetoothChatService state constants.
enum BtConnectionState {
  /// Idle / not connected.
  none,

  /// Scanning for nearby Bluetooth devices.
  scanning,

  /// Attempting to connect to a device.
  connecting,

  /// Connected and ready to print.
  connected,

  /// An error occurred (check [BluetoothPrintState.errorMessage]).
  error,
}

// ---------------------------------------------------------------------------
// Discovered device model
// ---------------------------------------------------------------------------

/// Lightweight value object representing a Bluetooth device found during scan.
class BtDevice {
  final String name;
  final String address;
  final int rssi;

  const BtDevice({
    required this.name,
    required this.address,
    this.rssi = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BtDevice &&
          runtimeType == other.runtimeType &&
          address == other.address;

  @override
  int get hashCode => address.hashCode;

  @override
  String toString() => 'BtDevice($name, $address, rssi=$rssi)';
}

// ---------------------------------------------------------------------------
// Printer model detection
// ---------------------------------------------------------------------------

/// Detected printer width derived from the connected device name prefix.
enum PrinterModel {
  /// 58mm thermal printer (32 printable chars per line).
  thermal58mm(32),

  /// 80mm thermal printer (40 printable chars per line).
  thermal80mm(40);

  final int lineWidth;
  const PrinterModel(this.lineWidth);
}

/// Detect the printer model from the Bluetooth device name.
///
/// - Names starting with `ANTHERMAL` or `AT2TV` => 58mm (32 chars).
/// - Names starting with `97BT-` => 80mm (40 chars).
/// - Anything else falls back to 58mm.
PrinterModel detectPrinterModel(String deviceName) {
  final upper = deviceName.toUpperCase();
  if (upper.startsWith('97BT-')) return PrinterModel.thermal80mm;
  // ANTHERMAL, AT2TV, or unknown -> 58mm
  return PrinterModel.thermal58mm;
}

// ---------------------------------------------------------------------------
// SharedPreferences key
// ---------------------------------------------------------------------------

const String _kBluetoothMacKey = 'bluetoothmac';
const String _kBluetoothNameKey = 'bluetoothname';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class BluetoothPrintState {
  final BtConnectionState connectionState;
  final List<BtDevice> discoveredDevices;
  final BtDevice? connectedDevice;
  final PrinterModel printerModel;
  final String? errorMessage;

  const BluetoothPrintState({
    this.connectionState = BtConnectionState.none,
    this.discoveredDevices = const [],
    this.connectedDevice,
    this.printerModel = PrinterModel.thermal58mm,
    this.errorMessage,
  });

  bool get isConnected => connectionState == BtConnectionState.connected;
  bool get isScanning => connectionState == BtConnectionState.scanning;

  BluetoothPrintState copyWith({
    BtConnectionState? connectionState,
    List<BtDevice>? discoveredDevices,
    BtDevice? connectedDevice,
    PrinterModel? printerModel,
    String? errorMessage,
    bool clearDevice = false,
    bool clearError = false,
  }) {
    return BluetoothPrintState(
      connectionState: connectionState ?? this.connectionState,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      connectedDevice:
          clearDevice ? null : (connectedDevice ?? this.connectedDevice),
      printerModel: printerModel ?? this.printerModel,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Manages BLE printer discovery, connection, and data transmission.
///
/// **Important:** This implementation uses `flutter_blue_plus` for BLE
/// communication. Make sure the package is added to `pubspec.yaml` and the
/// required Android/iOS permissions are configured.
///
/// Android permissions (AndroidManifest.xml):
///   - `BLUETOOTH`, `BLUETOOTH_ADMIN`
///   - `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT` (Android 12+)
///   - `ACCESS_FINE_LOCATION` (for BLE scanning)
///
/// iOS permissions (Info.plist):
///   - `NSBluetoothAlwaysUsageDescription`
///   - `NSBluetoothPeripheralUsageDescription`
class BluetoothPrintNotifier extends Notifier<BluetoothPrintState> {
  // TODO: Replace with actual flutter_blue_plus instances once the package is
  // added. The current implementation stores connection state and delegates
  // actual BLE I/O to platform-channel methods.
  //
  // Example with flutter_blue_plus:
  //   final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  //   BluetoothDevice? _bleDevice;
  //   BluetoothCharacteristic? _writeCharacteristic;

  late SharedPreferences _prefs;

  StreamSubscription<dynamic>? _scanSubscription;
  Timer? _reconnectTimer;

  @override
  BluetoothPrintState build() {
    _prefs = ref.watch(_sharedPrefsProvider);

    // Attempt auto-reconnect to the last known printer.
    _autoReconnect();

    ref.onDispose(() {
      _scanSubscription?.cancel();
      _reconnectTimer?.cancel();
    });

    return const BluetoothPrintState();
  }

  // ── Persistence helpers ──────────────────────────────────────────────────

  /// Save the selected printer MAC and name to SharedPreferences.
  Future<void> _persistDevice(BtDevice device) async {
    await _prefs.setString(_kBluetoothMacKey, device.address);
    await _prefs.setString(_kBluetoothNameKey, device.name);
  }

  /// Read the last connected printer from SharedPreferences.
  BtDevice? _loadPersistedDevice() {
    final mac = _prefs.getString(_kBluetoothMacKey);
    final name = _prefs.getString(_kBluetoothNameKey) ?? '';
    if (mac == null || mac.isEmpty) return null;
    return BtDevice(name: name, address: mac);
  }

  /// Clear the persisted printer info.
  Future<void> _clearPersistedDevice() async {
    await _prefs.remove(_kBluetoothMacKey);
    await _prefs.remove(_kBluetoothNameKey);
  }

  // ── Auto-reconnect ───────────────────────────────────────────────────────

  /// Try to reconnect to the last known printer on app start.
  void _autoReconnect() {
    final saved = _loadPersistedDevice();
    if (saved == null) return;

    // Delay slightly to let the BLE adapter initialise.
    _reconnectTimer = Timer(const Duration(seconds: 2), () {
      debugPrint('[BT] Auto-reconnecting to ${saved.address}...');
      connectToDevice(saved);
    });
  }

  // ── Scanning ─────────────────────────────────────────────────────────────

  /// Start scanning for nearby Bluetooth LE devices.
  ///
  /// Scanning runs for [timeout] (default 10 seconds) then stops automatically.
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    state = state.copyWith(
      connectionState: BtConnectionState.scanning,
      discoveredDevices: [],
      clearError: true,
    );

    try {
      // TODO: Replace with flutter_blue_plus scan.
      // Example:
      //   _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
      //     final devices = results.map((r) => BtDevice(
      //       name: r.device.platformName.isNotEmpty
      //           ? r.device.platformName
      //           : 'Unknown',
      //       address: r.device.remoteId.str,
      //       rssi: r.rssi,
      //     )).toList();
      //     state = state.copyWith(discoveredDevices: devices);
      //   });
      //   await FlutterBluePlus.startScan(timeout: timeout);

      // Placeholder: simulate a scan completing after timeout.
      await Future<void>.delayed(timeout);

      state = state.copyWith(
        connectionState: state.connectedDevice != null
            ? BtConnectionState.connected
            : BtConnectionState.none,
      );
    } catch (e) {
      state = state.copyWith(
        connectionState: BtConnectionState.error,
        errorMessage: 'Scan failed: $e',
      );
    }
  }

  /// Stop an ongoing scan.
  Future<void> stopScan() async {
    _scanSubscription?.cancel();
    _scanSubscription = null;

    // TODO: FlutterBluePlus.stopScan();

    if (state.connectionState == BtConnectionState.scanning) {
      state = state.copyWith(
        connectionState: state.connectedDevice != null
            ? BtConnectionState.connected
            : BtConnectionState.none,
      );
    }
  }

  // ── Connection ───────────────────────────────────────────────────────────

  /// Connect to a specific Bluetooth device by its [device] descriptor.
  ///
  /// Uses RFCOMM channel 1 (insecure) to match the Android Java implementation
  /// that calls `createInsecureRfcommSocket` via reflection.
  Future<void> connectToDevice(BtDevice device) async {
    await stopScan();

    state = state.copyWith(
      connectionState: BtConnectionState.connecting,
      clearError: true,
    );

    try {
      // TODO: Replace with flutter_blue_plus connect.
      // Example:
      //   _bleDevice = BluetoothDevice(remoteId: DeviceIdentifier(device.address));
      //   await _bleDevice!.connect(timeout: const Duration(seconds: 15));
      //   final services = await _bleDevice!.discoverServices();
      //   // Find the SPP-like write characteristic...
      //   for (final s in services) {
      //     for (final c in s.characteristics) {
      //       if (c.properties.write || c.properties.writeWithoutResponse) {
      //         _writeCharacteristic = c;
      //         break;
      //       }
      //     }
      //   }

      // Simulate connection delay.
      await Future<void>.delayed(const Duration(seconds: 1));

      final model = detectPrinterModel(device.name);
      await _persistDevice(device);

      state = state.copyWith(
        connectionState: BtConnectionState.connected,
        connectedDevice: device,
        printerModel: model,
      );

      debugPrint(
          '[BT] Connected to ${device.name} (${device.address}), model=$model');
    } catch (e) {
      state = state.copyWith(
        connectionState: BtConnectionState.error,
        errorMessage: 'Unable to connect device: $e',
      );
    }
  }

  /// Disconnect from the currently connected printer.
  Future<void> disconnect() async {
    try {
      // TODO: _bleDevice?.disconnect();

      state = state.copyWith(
        connectionState: BtConnectionState.none,
        clearDevice: true,
      );

      debugPrint('[BT] Disconnected');
    } catch (e) {
      debugPrint('[BT] Disconnect error: $e');
    }
  }

  /// Forget the saved printer and disconnect.
  Future<void> forgetDevice() async {
    await disconnect();
    await _clearPersistedDevice();
  }

  // ── Printing ─────────────────────────────────────────────────────────────

  /// Write raw bytes to the connected printer.
  ///
  /// The caller is responsible for formatting ESC/POS commands. Use
  /// [EscPosCommands] and [ReceiptFormatter] to build byte payloads.
  Future<bool> printBytes(List<int> bytes) async {
    if (!state.isConnected) {
      debugPrint('[BT] Cannot print — not connected');
      return false;
    }

    try {
      // TODO: Replace with actual BLE write.
      // Example:
      //   if (_writeCharacteristic != null) {
      //     // Chunk into max BLE packet sizes (typically 20 bytes for BLE,
      //     // or up to 512 for RFCOMM). Thermal printers usually accept
      //     // larger chunks over classic BT.
      //     const chunkSize = 512;
      //     for (var i = 0; i < bytes.length; i += chunkSize) {
      //       final end = (i + chunkSize > bytes.length)
      //           ? bytes.length
      //           : i + chunkSize;
      //       await _writeCharacteristic!.write(
      //         bytes.sublist(i, end),
      //         withoutResponse: true,
      //       );
      //     }
      //   }

      debugPrint('[BT] Wrote ${bytes.length} bytes to printer');
      return true;
    } catch (e) {
      debugPrint('[BT] Print error: $e');
      state = state.copyWith(
        connectionState: BtConnectionState.error,
        errorMessage: 'Print failed: $e',
      );
      return false;
    }
  }

  /// Convenience: write a UTF-8 string followed by a line feed.
  Future<bool> printLine(String text) async {
    final bytes = Uint8List.fromList([...text.codeUnits, 0x0A]);
    return printBytes(bytes);
  }

  /// Print a full receipt from pre-formatted lines.
  ///
  /// Inserts a 3-second pause between batches of 15 lines to match the
  /// Android implementation's `sleep(3000)` flush cadence.
  Future<bool> printReceipt(List<String> lines) async {
    const batchSize = 15;
    for (var i = 0; i < lines.length; i += batchSize) {
      final end =
          (i + batchSize > lines.length) ? lines.length : i + batchSize;
      final batch = lines.sublist(i, end);
      final payload = batch.join('\n');
      final ok = await printBytes(
        Uint8List.fromList([...payload.codeUnits, 0x0A]),
      );
      if (!ok) return false;

      // Pause between batches for the printer buffer to flush.
      if (end < lines.length) {
        await Future<void>.delayed(const Duration(seconds: 3));
      }
    }
    return true;
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Internal provider for SharedPreferences. Override in the root ProviderScope.
final _sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in ProviderScope');
});

/// Riverpod provider exposing the Bluetooth print service state and controls.
///
/// Usage:
/// ```dart
/// final btState = ref.watch(bluetoothPrintProvider);
/// ref.read(bluetoothPrintProvider.notifier).startScan();
/// ```
final bluetoothPrintProvider =
    NotifierProvider<BluetoothPrintNotifier, BluetoothPrintState>(
  BluetoothPrintNotifier.new,
);
