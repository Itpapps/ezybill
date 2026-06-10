# Production-Ready BLE Printer Implementation Plan

## Summary

After reading all docs and checking the full codebase, here's the exact state and what needs to be fixed:

### Current Problems
1. **AndroidManifest.xml** — No Bluetooth permissions at all (`BLUETOOTH`, `BLUETOOTH_ADMIN`, `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`, `ACCESS_FINE_LOCATION` missing)
2. **iOS Info.plist** — No `NSBluetoothAlwaysUsageDescription` or `NSBluetoothPeripheralUsageDescription`
3. **Registration screen** — No permission requests on startup
4. **Settings screen** — The "Bluetooth Printer" tile has `// TODO: navigate to paired device screen` — navigation is **NOT wired**
5. **bluetooth_print_service.dart** — All BLE operations are **stubs/placeholders** using simulated delays. No actual flutter_blue_plus calls
6. **paired_device_list_screen.dart** — Shows bonded devices but reads from state only (no real bonded device enumeration)
7. **device_discovery_screen.dart** — Starts scan but it's a simulated `Future.delayed`, discovers nothing real
8. **payment_receipt_screen.dart** — Print button shows `AppToast.show("BLE print coming soon")` — not wired to actual printer
9. **Router** — `bluetoothPrinter` route is nested inside `home` branch, so navigating from settings tab crashes or uses wrong navigator
10. **`_sharedPrefsProvider`** — Throws `UnimplementedError` unless overridden in ProviderScope (may crash on init)

## User Review Required

> [!IMPORTANT]
> The `flutter_blue_plus` package is already in pubspec.yaml at v1.35.2. The `permission_handler` is also present at v12.0.1. No new packages need to be installed.

> [!WARNING]
> **Breaking change in router**: The `bluetoothPrinter` and `bluetoothDiscovery` routes must be moved to use `parentNavigatorKey: _rootNavigatorKey` so they push above the shell and are accessible from any tab (especially Settings). This is the core navigation bug — navigating from the Settings tab to a route nested under the Home branch causes GoRouter to throw an assertion fail.

> [!CAUTION]
> `flutter_blue_plus` v1.35.2 uses **classic Bluetooth** (RFCOMM) for thermal printers, not BLE GATT. Thermal printers use SPP (Serial Port Profile) over classic Bluetooth. The `flutter_blue_plus` package since v1.0 dropped classic BT support. We need to use `flutter_bluetooth_serial` OR use the `flutter_blue_plus` bonded devices API with classic BT workarounds. **Decision: Use `flutter_blue_plus` bonded device list (for showing paired devices) + Android SPP via platform method channel for actual data transmission.** This is the same pattern the Android app uses (`createInsecureRfcommSocket`). However, for simplicity and production quality, we'll use **`flutter_blue_plus` for scanning/discovery** while actual print data goes via the `print_bluetooth_thermal` package which handles classic BT/SPP correctly.

> [!IMPORTANT]
> **Package change needed**: Add `print_bluetooth_thermal: ^1.0.9` or `blue_thermal_printer: ^1.1.3` to pubspec.yaml. These packages are purpose-built for thermal printer SPP connections and handle the `createInsecureRfcommSocket` pattern correctly. We'll use `blue_thermal_printer` for Android/iOS thermal printing via classic BT.

## Proposed Changes

---

### Phase 1: Platform Permissions (Android + iOS)

#### [MODIFY] AndroidManifest.xml
Add all required Bluetooth permissions:
- `BLUETOOTH` (legacy, API < 31)
- `BLUETOOTH_ADMIN` (legacy, API < 31)  
- `BLUETOOTH_SCAN` with `usesPermissionFlags="neverForLocation"` (API 31+)
- `BLUETOOTH_CONNECT` (API 31+)
- `ACCESS_FINE_LOCATION` (needed for BLE scan on older Android)
- `ACCESS_COARSE_LOCATION`

#### [MODIFY] ios/Runner/Info.plist
Add:
- `NSBluetoothAlwaysUsageDescription` — "EzyBill needs Bluetooth to print payment receipts on thermal printers."
- `NSBluetoothPeripheralUsageDescription` — "EzyBill needs Bluetooth to connect to your thermal printer."
- `NSLocationWhenInUseUsageDescription` — "EzyBill needs Location for Bluetooth scanning."

---

### Phase 2: Add Thermal Printer Package

#### [MODIFY] pubspec.yaml
Add `blue_thermal_printer: ^1.1.3` — this package wraps classic Bluetooth (SPP/RFCOMM) correctly for Android + iOS thermal printers.

Keep `flutter_blue_plus` for:
- Showing bonded device list (needed on some Android versions)
- BLE scanning discovery for initial device pairing

---

### Phase 3: Fix Router Navigation

#### [MODIFY] app_router.dart
Move `bluetoothPrinter` and `bluetoothDiscovery` routes to **root-level routes** with `parentNavigatorKey: _rootNavigatorKey` (same as `newCustomer`, `paymentWebview`). 

This ensures they can be navigated to from **any tab** (especially Settings) without GoRouter assertion failures.

Also update `barcodeScanner` the same way.

---

### Phase 4: Fix Bluetooth Service (Real Implementation)

#### [MODIFY] bluetooth_print_service.dart
Replace all TODO stubs with real `blue_thermal_printer` calls:

```
BluetoothPrintNotifier:
  - startScan(): Use BluetoothPrint.instance.startScan() → real device discovery
  - stopScan(): BluetoothPrint.instance.stopScan()
  - connectToDevice(): BluetoothPrint.instance.connect(device) — RFCOMM
  - disconnect(): BluetoothPrint.instance.disconnect()
  - printBytes(): BluetoothPrint.instance.writeBytes(bytes) in chunks
  - getBondedDevices(): BluetoothPrint.instance.getBondedDevices()
  
Error handling:
  - All exceptions caught, state set to BtConnectionState.error
  - Meaningful error messages displayed
  - Auto-reconnect with exponential backoff (max 3 retries)
```

---

### Phase 5: Fix Permission Flow on Registration Screen

#### [MODIFY] registration_screen.dart
Add at the end of `initState()` (after `_loadDeviceId()`):

```dart
// Request Bluetooth permissions on first run
_requestBluetoothPermissions();
```

New method `_requestBluetoothPermissions()`:
- Uses `permission_handler` to request `bluetoothScan`, `bluetoothConnect`, `locationWhenInUse`
- On Android < 12: requests `bluetooth`, `bluetoothAdmin`, `locationWhenInUse`
- Does NOT block registration; just fires the system prompts early
- Handles `PermanentlyDenied` gracefully (shows a dismissible info dialog explaining how to grant from Settings — no force)
- Called only once using a SharedPreferences flag `'bt_permissions_requested'`

---

### Phase 6: Fix Settings Screen Navigation

#### [MODIFY] settings_screen.dart
Wire the Bluetooth Printer tile to navigate correctly:

```dart
onTap: () => context.goNamed(RouteNames.bluetoothPrinterName),
```

Also update the subtitle to show current connection status from `bluetoothPrintProvider`:
- "Not Connected" → when no device
- Device name → when connected (e.g., "ANTHERMAL")

Convert `SettingsScreen` from `ConsumerWidget` to `ConsumerStatefulWidget` (or use `Consumer`) to watch `bluetoothPrintProvider`.

---

### Phase 7: Fix Paired Device List Screen

#### [MODIFY] paired_device_list_screen.dart
Replace the TODO stub in `_loadPairedDevices()` with real bonded device enumeration:

```dart
// Real implementation:
final bondedDevices = await ref.read(bluetoothPrintProvider.notifier).getBondedDevices();
_pairedDevices = bondedDevices;
```

Add proper empty state: "No Bluetooth devices paired yet. Go to System Settings → Bluetooth and pair your printer first."

Add a "System Settings" button that opens OS Bluetooth settings via `permission_handler`'s `openAppSettings()`.

---

### Phase 8: Fix Device Discovery Screen

#### [MODIFY] device_discovery_screen.dart  
Permission check logic — improve for Android 11 and below:
- Check Android SDK version via `device_info_plus`
- Android >= 12 (S): request `bluetoothScan` + `bluetoothConnect`
- Android < 12: request `bluetooth` + `bluetoothAdmin` + `locationWhenInUse`
- iOS: request `bluetooth`

Show proper "Bluetooth is off" error state (check adapter state, not just permissions).

---

### Phase 9: Wire Print Button on Receipt Screen

#### [MODIFY] payment_receipt_screen.dart
Convert to `ConsumerStatefulWidget` to access `bluetoothPrintProvider`.

Replace the stub print button with:

```dart
// If printer connected → print directly
// If not connected → show connect dialog → then print
```

The print dialog:
1. Check `bluetoothPrintProvider.isConnected`
2. If not connected: show BottomSheet "Connect to Bluetooth Printer" with:
   - List of recently used / bonded printers
   - "Go to Printer Settings" button
3. If connected: call `ReceiptFormatter.formatPaymentReceipt(...)` → `bluetoothPrintProvider.notifier.printReceipt(lines)`
4. Show progress indicator during print
5. Show success/error snackbar after

---

## Verification Plan

### Build Tests
```powershell
# Run in Flutter_ezybill directory
flutter analyze
flutter build apk --debug
```

### Manual Verification
1. Fresh install → Registration screen appears first with Bluetooth permission dialog
2. Settings → Hardware → Bluetooth Printer → opens Paired list screen (NOT crash)
3. Paired list shows bonded devices (after pairing one via System Bluetooth settings)
4. Scan button triggers discovery screen with real scan
5. After payment → Print button either prints (if connected) or shows connect dialog
6. No crashes on any flow
