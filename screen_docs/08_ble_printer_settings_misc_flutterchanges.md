# 08 - BLE Printer, Settings & Misc: Flutter Gap Analysis

> **Spec:** `screen_docs/08_ble_printer_settings_misc.md`
> **Generated:** 2026-03-26
> **Status:** Read-only analysis -- no code was modified

---

## Summary

The spec covers 17 major sections. The Flutter codebase has **partial coverage** of session management and settings, but is **missing the majority of features**: Bluetooth printing, receipt formats, barcode scanning, signature capture, GPS/maps integration, app version checking, password change, server URL resolution, and SSL certificate handling. The packages for maps (`google_maps_flutter`, `geolocator`) and scanner (`mobile_scanner`) are declared in `pubspec.yaml` but have **zero usage** in the actual Dart code.

---

## 1. BLE Printer System

**Spec sections:** 1.1 - 1.11 (Architecture, discovery, pairing, RFCOMM, BluetoothChatService, ESC/POS commands, N910Util)

**Flutter status:** COMPLETELY MISSING

| Item | Required | Current State |
|------|----------|---------------|
| Bluetooth package in pubspec | `flutter_bluetooth_serial` or `flutter_blue_plus` | NOT present |
| Bluetooth discovery screen | Equivalent of `DeviceListActivity` | NOT implemented |
| Paired device list screen | Equivalent of `PairedDeviceList` | NOT implemented |
| BLE chat service | `BluetoothChatService` with connection states (NONE/LISTEN/CONNECTING/CONNECTED) | NOT implemented |
| RFCOMM socket connection | `createInsecureRfcommSocket` on channel 1 | NOT implemented |
| Device persistence | `mytextfile.txt` with `<MAC>@<NAME>` format | NOT implemented |
| Bluetooth MAC in SharedPrefs | `vidslogin` -> `bluetoothmac` key | NOT implemented |
| N910Util (Newland POS) | Method channel to native Android SDK | NOT implemented |
| ESC/POS font commands | `bufLinear` byte array (indices 1-16) | NOT implemented |
| Connection state handler | MESSAGE_STATE_CHANGE, MESSAGE_DEVICE_NAME, MESSAGE_TOAST | NOT implemented |

**Priority:** HIGH -- Printing is core business functionality for receipt generation after payment.

**Changes required:**
- Add `flutter_blue_plus` (or `flutter_bluetooth_serial`) to `pubspec.yaml`
- Create `lib/presentation/screens/bluetooth/` with: device_discovery_screen.dart, paired_device_list_screen.dart
- Create `lib/core/services/bluetooth_print_service.dart` implementing connection states, RFCOMM socket, write methods
- Create `lib/core/services/esc_pos_commands.dart` for font/command byte arrays
- Store selected printer MAC in SharedPreferences under key `bluetoothmac`
- Store `<MAC>@<NAME>` in app documents directory file (via `path_provider`)

---

## 2. Receipt Print Formats (All 9 Formats)

**Spec sections:** 2.1 - 2.5, 3.1 - 3.4

**Flutter status:** COMPLETELY MISSING

| Format | Spec Method | Status |
|--------|-------------|--------|
| DEFAULT Payment Receipt (58mm/80mm) | `write2()` | NOT implemented |
| FORMAT1 Payment Receipt (Cheque) | `write1()` | NOT implemented |
| Legacy Payment Receipt (ESC/POS) | `write()` | NOT implemented |
| Payment History Receipt | `PaymentHistory_write()` | NOT implemented |
| Invoice History Receipt | `InvoiceHistory_write()` | NOT implemented |
| Employee Collection Report | `write_reports()` | NOT implemented |
| Collection Report | `write_reportscollection()` | NOT implemented |
| Miniday Report | `write_miniday_reports()` | NOT implemented |
| Services/Packages Report | `write_servicesreports()` | NOT implemented |

**Priority:** HIGH -- Directly tied to BLE printer; receipts are required after every payment.

**Changes required:**
- Create `lib/core/services/receipt_formatter.dart` with all 9 print format methods
- Implement printer model detection logic (see section 3 below)
- Implement string formatting utilities: `fixedLengthString`, `fixedLengthString_leftalign`, `fixedLengthString_Rightalign`
- Implement receipt date formatting: `"DDD MMM DD YYYY HH:MM:SS"`
- Implement pagination for batch reports (flush every 15 rows with 3-second delay)
- Line separator widths: 32 dots for 58mm, 40 dashes for 80mm

---

## 3. Printer Model Detection

**Spec section:** 1.7

**Flutter status:** COMPLETELY MISSING

| Detection Rule | Status |
|----------------|--------|
| Device name starts with `ANTHERMAL` -> 58mm, 32-dot separator | NOT implemented |
| Device name starts with `97BT-` -> 80mm, 40-dash separator | NOT implemented |
| Default/unknown -> treated as 58mm | NOT implemented |

**Priority:** HIGH -- Required for correct receipt formatting.

**Changes required:**
- In the receipt formatter service, detect printer model from first 5 characters of connected device name
- Apply correct line separator width and centering per model

---

## 4. Barcode Scanner

**Spec section:** 4.1 - 4.6

**Flutter status:** Package declared but NOT used.

| Item | Required | Current State |
|------|----------|---------------|
| `mobile_scanner` in pubspec | Yes | PRESENT in pubspec.yaml (v7.2.0) |
| Scanner screen/widget | `ScannerFrag` equivalent | NOT implemented -- zero imports of `mobile_scanner` in any Dart file |
| Scan flow | Scan barcode -> search customer by `boxNumber` | NOT implemented |
| Customer search by box number | REST call with `boxNumber` param from scanned value | NOT implemented (API constant `customerDetailsCount` exists but no scanner integration) |
| Camera permission handling | Runtime `CAMERA` permission | NOT implemented for scanner |

**Priority:** MEDIUM -- Scanner is a convenience feature for STB box lookup.

**Changes required:**
- Create `lib/presentation/screens/scanner/barcode_scanner_screen.dart`
- Use `MobileScanner` widget with `BarcodeFormat.all`
- On scan: call `getCustomerDetailsCountRest` with `boxNumber = scannedValue`
- Navigate to customer search results on success
- Pass `origin` parameter to track calling screen
- Handle `permission_handler` for camera access

---

## 5. Signature Capture

**Spec section:** 5.1 - 5.4

**Flutter status:** COMPLETELY MISSING

| Item | Required | Current State |
|------|----------|---------------|
| Signature capture widget | `CustomPainter` + `GestureDetector` | NOT implemented |
| Customer creation signature | 600x320 bitmap, returned as bytes | NOT implemented |
| Payment gateway signature | Save to `signature.bmp`, submit to PNSOl SDK | NOT implemented |
| Clear/Save/Cancel buttons | Per spec | NOT implemented |
| Stroke config | Width 5.0, black, anti-alias, round joins | NOT implemented |

**Priority:** MEDIUM -- Required for new customer creation and payment gateway card transactions.

**Changes required:**
- Create `lib/presentation/widgets/signature_pad.dart` with `CustomPainter` implementation
- Implement touch event handling (ACTION_DOWN -> moveTo, ACTION_MOVE -> lineTo with dirty rect)
- Implement clear, save (as PNG bytes), cancel actions
- For payment gateway: save to app documents directory as `signature.bmp` (PNG compressed at 45% quality)
- Integration point: new customer screen and payment transaction flow

---

## 6. GPS / Google Maps

**Spec sections:** 6.1 - 6.4

**Flutter status:** Packages declared but NOT used. Employee tracking screen exists but shows only a placeholder.

| Item | Required | Current State |
|------|----------|---------------|
| `google_maps_flutter` in pubspec | Yes | PRESENT (v2.12.1) -- but zero imports in Dart code |
| `geolocator` in pubspec | Yes | PRESENT (v14.0.2) -- but zero imports in Dart code |
| Employee collection map (MapsActivity) | Markers + red polyline for collection route | NOT implemented (placeholder only in `employee_tracking_screen.dart`) |
| Employee track info map (MapActivity_Fragment) | Date range query + route display | NOT implemented |
| Route display (Route activity) | Google Directions API + blue polyline | NOT implemented |
| Customer location update (MapsFragmentlocupdate) | GPS -> update customer lat/lng via REST | NOT implemented |
| Google Maps API key configuration | Required in AndroidManifest.xml / AppDelegate | NOT configured (placeholder message in UI says "when Google Maps API key is configured") |

**File:** `lib/presentation/screens/employees/employee_tracking_screen.dart` -- exists but only shows a static placeholder icon with text "Google Maps Integration - Map will be displayed here when Google Maps API key is configured". No actual `GoogleMap` widget is used.

**Priority:** MEDIUM -- Employee tracking and customer location update are operational features.

**Changes required:**
- Configure Google Maps API key in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/AppDelegate.swift`
- Replace placeholder in `employee_tracking_screen.dart` with actual `GoogleMap` widget
- Implement `getEmployeeTrackInfo` REST API call (date range + employee ID)
- Display markers (green first, azure subsequent) with polylines
- Create customer location update flow using `geolocator` for current position + `updateCustomerLocation` REST endpoint (API constant already defined)
- Implement Google Directions API integration for route drawing
- Handle `ACCESS_FINE_LOCATION` permission via `permission_handler`

---

## 7. SharedPreferences Keys

**Spec sections:** 9, 10.1 - 10.4

**Flutter status:** PARTIALLY implemented. Core auth keys exist but BMS/config keys are missing.

### Keys that ARE implemented (in `app_constants.dart`):
| Spec Key | Flutter Key | Status |
|----------|-------------|--------|
| auth_token | `prefKeyToken` = `'auth_token'` | PRESENT |
| jwt_token | `prefKeyJwtToken` = `'jwt_token'` | PRESENT |
| dealer_id | `prefKeyDealerId` = `'dealer_id'` | PRESENT |
| employee_id | `prefKeyEmployeeId` = `'employee_id'` | PRESENT |
| user_type | `prefKeyUserType` = `'user_type'` | PRESENT |
| employee_name | `prefKeyEmployeeName` = `'employee_name'` | PRESENT |
| first_name, last_name, email, phone | Various prefKey* | PRESENT |
| lco_code, business_name | Various prefKey* | PRESENT |
| is_logged_in | `prefKeyIsLoggedIn` = `'is_logged_in'` | PRESENT |
| login_response_json | `prefKeyLoginResponse` = `'login_response_json'` | PRESENT |

### Keys that are MISSING (from `bmsSharedPref` and `vidslogin`):
| Android Key | Android Pref File | Type | Status |
|-------------|-------------------|------|--------|
| `login_url` | `bmsSharedPref` | String | MISSING -- server URL not stored |
| `emp_id` | `bmsSharedPref` | String | MISSING (separate from `employee_id`) |
| `appThemeColor` | `bmsSharedPref` | int (1-5) | MISSING |
| `appDashboard` | `bmsSharedPref` | int | MISSING |
| `enableAadhar` | `bmsSharedPref` | int | MISSING |
| `appLogoPath` | `bmsSharedPref` | String | MISSING |
| `smsKey` | `bmsSharedPref` | String | MISSING |
| `bmsAuth` | `bmsSharedPref` | String | MISSING |
| `username` | `vidslogin` | String | MISSING (remember-me feature) |
| `bluetoothmac` | `vidslogin` | String | MISSING |

**Priority:** MEDIUM -- Several missing keys support features (theming, Aadhaar, logo) that affect UX and configuration.

**Changes required:**
- Add all missing key constants to `app_constants.dart`
- Add getters/setters for each in `auth_local_datasource.dart` or a new `config_local_datasource.dart`
- Implement "Remember Me" feature storing `username` key

---

## 8. Session Management

**Spec section:** 11.1 - 11.4

**Flutter status:** PARTIALLY implemented.

| Item | Required | Current State |
|------|----------|---------------|
| Auth token in memory | Singleton/provider | PRESENT -- `DioClient.setTokens()` + `_jwtToken`/`_authToken` in memory |
| Auth token persistence | `flutter_secure_storage` | PRESENT -- JWT and auth tokens stored via `FlutterSecureStorage` |
| dealer_id, employee_id | In-memory + SharedPrefs | PRESENT in `AuthLocalDatasource` |
| 60+ static session variables from LoginActivity | `AuthState` class or provider | MOSTLY MISSING -- only ~12 of 60+ fields are stored |
| Logout flow | Clear tokens + navigate to login | PRESENT -- `clearAll()` in `AuthLocalDatasource` + logout in `authProvider` |
| Remember Me | Save/load username from SharedPrefs | MISSING |

### Missing session variables (from spec section 11.2):
These Android `LoginActivity` statics have no Flutter equivalent:
- `CURRENCY_CODE`, `APP_THEME`, `APP_DASHBOARD`, `ENABLE_AADHAAR`
- `LCO_PAYMENT`, `is_direct_lco`, `AUTO_RECEIPT_NUMBER`
- `allow_top_up`, `stb_pairing`, `stb_unpairing`, `pgtransaction`
- `useCRF`, `useCAF`, `useLastName`, `useDiscount`
- `freezecustomerparamsinapp`, `hidemakepayment`
- `int_bulk_payment`, `invoice_page_access`, `payment_hist_page_access`
- `access_for_complaints`, `int_stb_activation`, `int_stb_deactivation`, `int_stb_reactivation`
- `defaultcountry`, `defaultstate`, `defaultdistrict`, `defaultcity`
- `deposit_amount`, `lco_billtype`, `customerbilltype`
- `imeiNo`, `ipAddress`, `mobilenumber`, `menuType`, `patch_information`
- `show_caf_mobile_validation`, `show_mia_agreement_upload`, `accept_terms_condtions`
- `agreement_details_count`, `access_distributor_wise`, `userLcoDeposit`

**Priority:** HIGH -- Access control flags (e.g., `hidemakepayment`, `access_for_complaints`) control which features are visible to users. Without them, the app cannot enforce role-based access.

**Changes required:**
- Expand `AuthLocalDatasource` (or create a new `SessionState` provider) to hold all ~60 session variables
- Parse these from the login API response (they come from `getAccessControl` REST endpoint, which IS defined in `api_constants.dart`)
- Persist configuration flags to SharedPreferences for offline access

---

## 9. Server URL Configuration (Two-Stage BMS -> REST Resolution)

**Spec section:** 15.1 - 15.4

**Flutter status:** HARDCODED URL instead of dynamic resolution.

| Item | Required | Current State |
|------|----------|---------------|
| Stage 1: `getServerIp` call to BMS | Dealer ID -> server URL lookup | NOT implemented |
| Stage 2: URL loaded from SharedPrefs at login | `login_url` key | NOT implemented |
| Dynamic URL in ApiConstants | Configurable base URL | HARDCODED as `http://183.83.216.66:8882/v2_release/index.php` in `api_constants.dart` |
| URL derivation: strip `/wsController` for REST | `URL.replace("/wsController", "")` | NOT needed (Flutter uses REST-native URL) |

**Priority:** LOW -- The Flutter app uses REST V2 API directly with a known URL. The two-stage SOAP-based BMS URL resolution was specific to the Android SOAP architecture. However, if multi-tenant/multi-server support is needed, this must be revisited.

**Changes required:**
- If multi-dealer server support is needed: implement a dealer-ID-based URL lookup (REST equivalent of `getServerIp`)
- Store resolved URL in SharedPreferences under `login_url`
- Make `ApiConstants.baseUrl` dynamic (read from SharedPrefs or a provider)

---

## 10. SSL Certificate Handling (SSLConection Equivalent)

**Spec reference:** Implied by Android `SSLConection` class

**Flutter status:** MISSING

| Item | Required | Current State |
|------|----------|---------------|
| `badCertificateCallback` in Dio | Trust self-signed certs (if server uses them) | NOT implemented -- no SSL/TLS configuration found in `dio_client.dart` |
| Custom `SecurityContext` | For pinned or self-signed certificates | NOT implemented |

**Priority:** LOW -- The hardcoded URL uses HTTP (not HTTPS), so SSL handling is not immediately needed. If the server migrates to HTTPS with self-signed certificates, this becomes HIGH priority.

**Changes required:**
- If needed: configure `Dio` with `HttpClientAdapter` that sets `badCertificateCallback` to accept the server's certificate
- Or use certificate pinning for production security

---

## 11. App Version Check

**Spec section:** 14.1 - 14.2

**Flutter status:** COMPLETELY MISSING

| Item | Required | Current State |
|------|----------|---------------|
| Version check API call before login | `appVersionCheck` -> statusCode 0/1/3 | NOT implemented |
| `package_info_plus` package | Get app version name/code | NOT in pubspec.yaml |
| Force update dialog | Non-dismissible dialog linking to Play Store | NOT implemented |
| "Server is busy" handling | statusCode == 3 -> close app | NOT implemented |

The `AppConstants.appVersion` is hardcoded as `'1.0.0'` but is only used for display, not for server-side validation.

**Priority:** HIGH -- Without version checking, users can run outdated app versions that may be incompatible with the server API.

**Changes required:**
- Add `package_info_plus` to `pubspec.yaml`
- Create version check service that calls BMS version check endpoint (REST equivalent)
- Call before login; on statusCode == 1, show non-dismissible update dialog with Play Store / App Store link
- On statusCode == 3, show "Server is busy" and close app

---

## 12. Password Change

**Spec section:** 16.1

**Flutter status:** COMPLETELY MISSING

| Item | Required | Current State |
|------|----------|---------------|
| Password change screen | Old password + new password fields | NOT implemented |
| Password change API call | REST equivalent of `passwordChange` SOAP method | NOT implemented (no API constant defined in `api_constants.dart`) |
| Settings screen link | Button/tile to navigate to password change | NOT present in `settings_screen.dart` |

**Priority:** MEDIUM -- Users need ability to change their passwords from within the app.

**Changes required:**
- Add password change REST endpoint to `api_constants.dart`
- Create `lib/presentation/screens/settings/change_password_screen.dart`
- Add a "Change Password" tile to `settings_screen.dart`
- Implement API call with `authToken`, `oldPassword`, `newPassword`

---

## 13. Payment Gateway Account Activation

**Spec section:** 8.1

**Flutter status:** COMPLETELY MISSING

| Item | Required | Current State |
|------|----------|---------------|
| Account activation screen | 12-char merchant key input | NOT implemented |
| PNSOl SDK integration | Android-only payment SDK | NOT implemented |
| `PARTNER_KEY` constant | `"724BF3E4A636"` | NOT defined |
| AccountValidator check | `isAccountActivated()` before card payment | NOT implemented |

**Priority:** LOW -- PNSOl is Android-native. If card payments are needed, consider Razorpay/PayU Flutter SDK instead, or implement via method channel.

**Changes required:**
- Decide: method channel to PNSOl Android SDK, or migrate to a cross-platform payment gateway (Razorpay, PayU)
- If keeping PNSOl: create method channel bridge + activation screen
- If replacing: integrate chosen Flutter payment SDK

---

## 14. DetectSession (Cross-Fragment Communication)

**Spec section:** 13

**Flutter status:** NOT NEEDED (architecture difference)

The Android `DetectSession` pattern (static callback bus) is replaced by Riverpod providers in Flutter. The Flutter app already uses `flutter_riverpod` for state management.

**Priority:** N/A -- No action needed. Riverpod providers handle this pattern.

---

## 15. Application Class (EzybillApplication)

**Spec section:** 12

**Flutter status:** NOT NEEDED (architecture difference)

The Volley request queue singleton is replaced by `DioClient` in Flutter. MultiDex is not needed.

**Priority:** N/A -- No action needed. `DioClient` already serves this purpose.

---

## 16. Server Terminology

**Spec section:** 15.4

**Flutter status:** MISSING

| Item | Required | Current State |
|------|----------|---------------|
| `getServerTerminology` API call | Fetch custom UI labels after login | NOT implemented |
| Dynamic label substitution | e.g., "Customer" -> "Subscriber" | NOT implemented |

**Priority:** LOW -- Cosmetic feature; can be deferred.

**Changes required:**
- Add terminology REST endpoint to `api_constants.dart`
- Create terminology provider that fetches and caches label overrides
- Apply overrides to UI strings throughout the app

---

## Priority Summary

| Priority | Count | Items |
|----------|-------|-------|
| **HIGH** | 5 | BLE Printer System, Receipt Print Formats, Printer Model Detection, Session Management (access control flags), App Version Check |
| **MEDIUM** | 5 | Barcode Scanner, Signature Capture, GPS/Maps, SharedPreferences Keys, Password Change |
| **LOW** | 4 | Server URL Configuration, SSL Certificate Handling, Payment Gateway Activation, Server Terminology |
| **N/A** | 2 | DetectSession, Application Class (architecture differences -- no action needed) |

---

## Files Referenced

| Flutter File | Relevance |
|---|---|
| `lib/presentation/screens/settings/settings_screen.dart` | Settings UI -- missing printer, password change, theme settings |
| `lib/core/constants/app_constants.dart` | SharedPreferences keys -- missing BMS/config keys |
| `lib/core/constants/api_constants.dart` | API endpoints -- missing version check, password change, terminology endpoints |
| `lib/core/network/dio_client.dart` | Network layer -- missing SSL handling |
| `lib/data/datasources/local/auth_local_datasource.dart` | Local storage -- missing 50+ session variables |
| `lib/main.dart` | App entry -- no version check, no BMS URL resolution |
| `lib/presentation/screens/employees/employee_tracking_screen.dart` | Map placeholder only -- no actual Google Maps integration |
| `pubspec.yaml` | Has `google_maps_flutter`, `geolocator`, `mobile_scanner` declared but UNUSED; missing Bluetooth package |
