# BLE Printer Implementation — Walkthrough

**Date:** 2026-04-24  
**Status:** ✅ Complete — Zero compile errors

---

## What Was Done

Full production-ready Bluetooth thermal printer integration implemented across 9 phases.

---

## Changes Made

### Phase 1 — Android Permissions (`AndroidManifest.xml`)
Added all required Bluetooth + Location permissions:
- `BLUETOOTH` + `BLUETOOTH_ADMIN` (Android < 12, `maxSdkVersion="30"`)
- `BLUETOOTH_SCAN` with `neverForLocation` flag (Android 12+)
- `BLUETOOTH_CONNECT` (Android 12+)
- `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` (BLE scan on older Android)
- `<uses-feature android:required="false">` so app is installable on devices without Bluetooth

### Phase 1b — iOS Permissions (`ios/Runner/Info.plist`)
Added:
- `NSBluetoothAlwaysUsageDescription`
- `NSBluetoothPeripheralUsageDescription`
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`

### Phase 2 — New Package (`pubspec.yaml`)
Added:
- `blue_thermal_printer: ^1.2.3` — handles classic Bluetooth SPP/RFCOMM (required for thermal printers)
- `path_provider: ^2.1.5` — for persistent printer storage

> **Why `blue_thermal_printer`?**  
> `flutter_blue_plus` v1.35 dropped classic Bluetooth support. Thermal printers use **SPP (Serial Port Profile)** over classic BT, not BLE GATT. `blue_thermal_printer` wraps `createInsecureRfcommSocket` — same as the original Android Java implementation.

### Phase 3 — Router Fix (`app_router.dart`)
**Key fix:** Moved `bluetoothPrinter`, `bluetoothDiscovery`, and `barcodeScanner` routes from being **nested under the Home branch** to **root-level routes** with `parentNavigatorKey: _rootNavigatorKey`.

This eliminates GoRouter assertion crashes when navigating from the Settings tab to Bluetooth screens.

### Phase 4 — Bluetooth Service (`bluetooth_print_service.dart`)
**Complete rewrite** — replaced all TODO stubs with real `blue_thermal_printer` calls:

| Feature | Implementation |
|---------|---------------|
| Bonded devices | `BlueThermalPrinter.instance.getBondedDevices()` |
| Connection | `BlueThermalPrinter.instance.connect(device)` with 15-second timeout |
| Disconnect | `BlueThermalPrinter.instance.disconnect()` |
| Peripheral state | `onStateChanged()` stream listener (int?: 1=connected, 0=disconnected) |
| Print bytes | `writeBytes(Uint8List)` with chunked 15-line batches + 3s inter-batch pause |
| Auto-reconnect | Up to 3 retries with exponential back-off (2s, 4s, 6s) |
| Persistence | Saves MAC + device name to SharedPreferences |
| Model detection | `ANTHERMAL`/`AT2TV` → 58mm (32 chars), `97BT-` → 80mm (40 chars) |

### Phase 5 — Permission Request on Registration (`registration_screen.dart`)
Added `_requestBluetoothPermissionsIfNeeded()`:
- Runs once (guarded by `bt_permissions_requested` SharedPrefs flag)
- Fires 800ms after UI renders (non-blocking)
- Requests `bluetoothScan`, `bluetoothConnect`, `locationWhenInUse`
- If permanently denied: shows gentle, dismissible `AlertDialog` with "Open Settings" button
- Never crashes or blocks registration

### Phase 6 — Settings Navigation (`settings_screen.dart`)
- Replaced `// TODO: navigate to paired device screen` with `context.goNamed(RouteNames.bluetoothPrinterName)`
- Added live connection status subtitle via `Consumer` watching `bluetoothPrintProvider`
- Shows green dot indicator when printer is connected

### Phase 7 — Paired Device List (`paired_device_list_screen.dart`)
**Full rewrite:**
- Calls real `getBondedDevices()` API on init
- Pull-to-refresh support
- Shows connected printer in highlighted card with Disconnect/Forget buttons
- Shows all bonded devices with individual Connect buttons  
- Empty state with "Open Bluetooth Settings" button (via `openAppSettings()`)
- Proper error banners + connecting indicator
- "Scan for New Devices" bottom button navigates to discovery screen

### Phase 8 — Device Discovery Screen (`device_discovery_screen.dart`)
**Full rewrite using real flutter_blue_plus scanning:**
- Checks permissions before starting scan
- Shows Bluetooth-off state with "Enable Bluetooth" button
- Auto-stops scan after 12 seconds
- Shows real RSSI signal strength per device
- On connect: uses SPP via `bluetoothPrintProvider` and auto-navigates back on success
- Permission permanently-denied state with graceful "Open Settings" fallback

### Phase 9 — Print Button (`payment_receipt_screen.dart`)
**Converted from `StatelessWidget` to `ConsumerStatefulWidget`:**
- Replaced `AppToast.show("BLE print coming soon")` with real `_handlePrint()`
- If not connected: shows `_ConnectPrinterBottomSheet` with bonded device list
- If connected: shows progress dialog → calls `ReceiptFormatter.formatPaymentReceipt()` → `printReceipt(lines)`
- Print button shows green dot indicator when printer is connected
- Spinner inside button while printing
- Success snackbar / error snackbar with proper messaging

---

## Files Changed

| File | Change |
|------|--------|
| `android/app/src/main/AndroidManifest.xml` | +25 lines: BT + Location permissions |
| `ios/Runner/Info.plist` | +8 lines: BT + Location usage descriptions |
| `pubspec.yaml` | +2 packages: blue_thermal_printer, path_provider |
| `lib/core/services/bluetooth_print_service.dart` | Full rewrite — real BT implementation |
| `lib/presentation/router/app_router.dart` | BT routes moved to root navigator |
| `lib/presentation/screens/auth/registration_screen.dart` | + Permission request on startup |
| `lib/presentation/screens/settings/settings_screen.dart` | + BT navigation + live status |
| `lib/presentation/screens/bluetooth/paired_device_list_screen.dart` | Full rewrite |
| `lib/presentation/screens/bluetooth/device_discovery_screen.dart` | Full rewrite |
| `lib/presentation/screens/payments/payment_receipt_screen.dart` | Print button wired to real BT |

---

## Validation

```
flutter analyze → 0 errors (warnings are pre-existing in unrelated files)
flutter pub get → blue_thermal_printer 1.2.3 installed ✅
```

---

## How To Test

1. **Install fresh on Android device** — Registration screen should immediately show Bluetooth permission dialog
2. **Settings → Hardware → Bluetooth Printer** — Should navigate to Paired Devices screen (not crash)
3. **Pair a thermal printer** via OS Bluetooth settings, then return to app and Refresh
4. **Tap "Connect"** on the paired device — Should connect with success indicator
5. **Make a payment** → Receipt screen → Tap Print button:
   - If connected: prints immediately with progress dialog
   - If not connected: shows "Select Printer" bottom sheet first
6. **Scan for New Devices** — Should show real BLE scan results with RSSI

---

## Notes

- The `_sharedPrefsProvider` must be overridden in the root `ProviderScope` in `main.dart` (this was already done in the existing codebase)
- Printer model auto-detected from device name prefix used for line width formatting in `ReceiptFormatter`
- Auto-reconnect fires 3 seconds after app start if a saved printer MAC exists in SharedPreferences
