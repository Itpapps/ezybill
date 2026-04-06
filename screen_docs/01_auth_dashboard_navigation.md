# EzyBill Flutter Migration — Screen Doc 01: Auth, Dashboard & Navigation

> **Source files analyzed:**
> - `ACT_LoginActivity.java` — Cloud/device authentication (SOAP only, skip in Flutter)
> - `CloudAuthentication.java` — Legacy SMS-key registration screen (SOAP only, skip in Flutter)
> - `LoginActivity.java` — Primary login screen (REST V2 via Volley)
> - `ApplicationIntroActivity.java` — First-run intro screen
> - `MainActivity.java` — Navigation drawer host
> - `Dashboard_Fragment.java` — Dashboard stats and quick actions
> - `StatusActivity.java` — LCO payment return status screen
> - `About_Fragment.java` — About Us fragment
> - `AboutActivityMarquee.java` — Auto-scrolling marquee widget (utility class)
> - `PrivacyPolicy_Fragment.java` — Privacy policy fragment
> - `EzyBillConstants.java` — SharedPreferences key constants
>
> **REST API Reference:** `REST_API_V2_SERVICE_DOCUMENT.md`
>
> **Coverage:** Only V2 REST endpoints (Volley/OkHttp). All SOAP/ksoap2 calls in
> `ACT_LoginActivity` and `CloudAuthentication` are legacy and have no Flutter equivalents
> in the V2 API layer. They are documented here for completeness but must NOT be
> re-implemented in Flutter.

---

## Table of Contents

1. [App Startup and Device Authentication Flow](#1-app-startup-and-device-authentication-flow)
2. [Screen: Cloud Authentication (Legacy — Do Not Port)](#2-screen-cloud-authentication-legacy--do-not-port)
3. [Screen: LoginActivity — User Login](#3-screen-loginactivity--user-login)
4. [Screen: ApplicationIntroActivity — First-Run Intro](#4-screen-applicationintroactivity--first-run-intro)
5. [Screen: MainActivity — Navigation Drawer Host](#5-screen-mainactivity--navigation-drawer-host)
6. [Screen: Dashboard_Fragment — Main Dashboard](#6-screen-dashboard_fragment--main-dashboard)
7. [Screen: StatusActivity — LCO Payment Return Status](#7-screen-statusactivity--lco-payment-return-status)
8. [Screen: About_Fragment — About Us](#8-screen-about_fragment--about-us)
9. [Screen: PrivacyPolicy_Fragment — Privacy Policy](#9-screen-privacypolicy_fragment--privacy-policy)
10. [SharedPreferences Reference](#10-sharedpreferences-reference)
11. [Global Static State (LoginActivity static fields)](#11-global-static-state-loginactivity-static-fields)
12. [Theming System](#12-theming-system)
13. [Runtime Permissions Required](#13-runtime-permissions-required)

---

## 1. App Startup and Device Authentication Flow

### 1.1 Overall Startup Sequence

```
App Launch
   |
   v
ACT_LoginActivity  (SOAP — LEGACY, DO NOT PORT)
   |
   | statusCode == 0 from SOAP BMS cloud auth
   v
LoginActivity  <---- START HERE in Flutter (REST V2)
   |
   | Login success (REST validateLogin)
   v
getaccesscontrollRest  (REST V2 — Volley POST)
   |
   | success (status_code == 0 or 1)
   v
ApplicationIntroActivity
   |
   | First run AND userType == "RESELLER" AND MIA agreement conditions?
   |   YES --> Show MIA agreement dialog OR open LCO portal in browser
   |   NO  --> proceed
   v
MainActivity  (frgToLoad=0 intent extra)
   |
   v
Dashboard_Fragment (position 0 in nav drawer)
```

### 1.2 Flutter Startup Recommendation

- Skip `ACT_LoginActivity` and `CloudAuthentication` entirely.
- Flutter entry point: show `LoginScreen` directly.
- After successful `validateLogin`, immediately call `getaccesscontrollRest`.
- Use `shared_preferences` to persist auth token, employee ID, server URL, theme, logo path.
- Check `hasRunBefore_appIntro` SharedPreference to decide whether to show the intro screen.

---

## 2. Screen: Cloud Authentication (Legacy — Do Not Port)

**Source:** `CloudAuthentication.java`, `ACT_LoginActivity.java`

### 2.1 Purpose

These two activities perform a SOAP-based device registration against a BMS cloud server using a hardcoded SMS key (`ACTP` + `ecd00001` for production) and the device IMEI (suffixed with `produc` for production). This is a licensing/activation check that runs before login.

### 2.2 Why to Skip in Flutter

Both classes use `ksoap2` SOAP exclusively. The V2 REST API document confirms all endpoints have REST implementations. The Flutter app should receive a pre-configured server URL from the backend team and bypass this cloud check. The SOAP BMS cloud service returns:

| Field | Type | Purpose | Stored In |
|-------|------|---------|-----------|
| `statusCode` | int | 0 = registered/valid | — |
| `ipAddress` | String | Server base URL | `SharedPrefs: login_url` |
| `employeeId` | String | Pre-seeded employee ID | `SharedPrefs: emp_id` |
| `appThemeColor` | int | 1–5 theme number | `SharedPrefs: appThemeColor` |
| `appDashboard` | int | 1=default, other=theme2 | `SharedPrefs: appDashboard` |
| `appLogoPath` | String | URL to dealer logo | `SharedPrefs: appLogoPath` |

These values are read back by `LoginActivity.onCreate()` from `bmsSharedPref`. In Flutter, seed these values directly from your build configuration or a remote config endpoint.

### 2.3 Root Device Check

Both activities check for rooted devices using `RootBeer` library:
- `rootBeer.isRooted()` or `rootBeer.detectTestKeys()` → show alert, close app.
- Flutter equivalent: use `flutter_jailbreak_detection` package.

---

## 3. Screen: LoginActivity — User Login

**Source:** `LoginActivity.java`
**Flutter Route:** `/login`

### 3.1 Screen Identity

| Property | Value |
|----------|-------|
| Title | "EzyBill" (app name, no explicit title shown) |
| Purpose | Authenticate user with username + password against the V2 REST API |
| Category | Authentication |
| Layout file | `logins_new_1.xml` |
| Font | `gothic_0.TTF` (custom asset font applied to all text views) |

### 3.2 UI Elements

| Element | Type | ID | Label / Hint | Notes |
|---------|------|----|-------------|-------|
| Logo image | ImageView | `login_img_logo` | — | Downloaded from `LOGIN_URL` + `APP_LOGO_PATH`; fallback to `ic_launcher` drawable |
| "Login" label | TextView | `tv_login` | "Login" | Custom font |
| Username | EditText | `login_et_username` | Username | Pre-filled from SharedPrefs `vidslogin/username` if Remember Me was checked |
| Password | EditText | `login_et_password` | Password | Secure text entry |
| Remember Me | CheckBox | `cb_rememberMe` | "Remember Me" | Saves username to SharedPrefs `vidslogin` |
| Login button | Button | `btn_login` | "LOGIN" | Triggers permission checks then REST calls |
| Copyright | TextView | `login_tv_copyright` | "itpworld.com, All Rights Reserved" | Custom font |

### 3.3 Actions and Workflows

#### Login Button Tap — Permission Gate Chain
Before firing the API, the button checks permissions in this exact order. If any is missing, the rationale Snackbar or system dialog is shown and the chain stops:

1. `READ_PHONE_STATE` — needed for device IMEI
2. `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` — shows a prominent disclosure dialog (`prominentdisclosure.xml`) before requesting
3. `READ_CONTACTS`
4. `CAMERA`
5. `BLUETOOTH_CONNECT` (Android 12+ / API 31+)

After all permissions granted:
- Device identifier: Android <= 9 uses `TelephonyManager.getDeviceId()` (IMEI); Android >= 10 uses `Settings.Secure.ANDROID_ID`.
- Client-side validation: both fields must be non-empty → AlertDialog "Empty Fields!"
- Network check: if offline → AlertDialog "No internet connection!" with "Settings" button
- If all pass: executes `appVersionCheck` AsyncTask (SOAP BMS), then on success `LoginAsyncTask` (SOAP). **In Flutter, skip version check and call REST `validateLogin` directly.**

#### Navigation After Successful Login

```
LoginActivity.onPostExecute (statusCode == 0)
  -> extract all response fields into static variables
  -> save username to SharedPrefs (if Remember Me checked)
  -> call getaccesscontrol() [REST V2 Volley]
      -> on success: startActivity(ApplicationIntroActivity)
      -> on failure: startActivity(ApplicationIntroActivity) [still proceeds]
```

### 3.4 API Calls

#### Call 1 (SOAP — DO NOT PORT): App Version Check
Uses `ksoap2` SOAP. Skip in Flutter.

#### Call 2 (SOAP — DO NOT PORT): SOAP Login
The primary login still uses SOAP via `ksoap2` with `ValidateLoginInfo` complex type. Skip in Flutter and use REST endpoint below.

#### Call 3 (REST V2 — PORT THIS): validateLogin

| Property | Value |
|----------|-------|
| Method | POST |
| Endpoint | `POST /LcoRestServices/validateLogin` |
| Library | Volley `StringRequest` |
| Auth | None (public endpoint) |
| Timeout | 70,000 ms (WiFi), 50,000 ms (mobile) |

**Request Parameters (form-encoded POST body):**

| Parameter | Type | Required | Source |
|-----------|------|----------|--------|
| `UserName` | String | Yes | `userName` EditText |
| `PassWord` | String | Yes | `userPassword` EditText |
| `mobile_no` | String | No | Not sent in current Android code |
| `imei` | String | No | `Settings.Secure.ANDROID_ID` (Android 10+) or `TelephonyManager.getDeviceId()` |

#### Call 4 (REST V2 — PORT THIS): getaccesscontrollRest

| Property | Value |
|----------|-------|
| Method | POST |
| Endpoint | `POST /LcoRestServices/getaccesscontrollRest` (URL built from `PropertyReader.getProperty("acccntrl")` → base URL without `/wsController` suffix) |
| Library | Volley `StringRequest` |
| Auth | `authtoken` in POST body |
| Timeout | 100,000 ms |

**Request Parameters:**

| Parameter | Type | Source |
|-----------|------|--------|
| `authtoken` | String | `LoginActivity.authToken` |
| `dealer_id` | String | `String.valueOf(LoginActivity.dealerId)` |
| `userstype` | String | `LoginActivity.userType` |
| `employeeParentType` | String | `LoginActivity.employeeParentType` |
| `employeeParentId` | String | `LoginActivity.employeeParentId` |

### 3.5 Validation Rules

| Rule | Condition | Error Shown |
|------|-----------|-------------|
| Empty fields | Either `userName` or `userPassword` is blank | AlertDialog "Empty Fields!" — "Username and Password fields should not be empty." |
| No internet | `activeNetworkInfo` null or not connected | AlertDialog "No internet connection!" with "Settings" / "Cancel" buttons |
| Login failed | `statusCode >= 1` | AlertDialog "Login Failed!" with `statusMessage` from response |
| Server error | Response is null | AlertDialog "Server connectivity error!" — "Please contact our support team." |
| App update required | Version check returns `statusCode == 1` | AlertDialog "Update Application!" with "Update" button → Play Store |

### 3.6 Response Handling — validateLogin

All fields below are extracted from the SOAP response string by substring parsing in the Android code. The REST V2 `validateLogin` returns equivalent JSON fields. Parse as JSON in Flutter.

**statusCode == 0 (success):** Extract and store as static variables:

| Response Field | Static Variable | Type | Default | Purpose |
|----------------|-----------------|------|---------|---------|
| `employeeId` | `LoginActivity.employeeId` | int | — | Used in all subsequent API calls |
| `employeeName` | `LoginActivity.user` | String | — | Shown in nav drawer header |
| `business_name` | `LoginActivity.business_name` | String | — | Business display name |
| `dealerId` | `LoginActivity.dealerId` | int | — | Used in all subsequent API calls |
| `userType` | `LoginActivity.userType` | String | — | Controls menu structure. Values: `RESELLER`, `DEALER`, `ADMIN`, `SERVICE`, `DISTRIBUTOR`, `SUBDISTRIBUTOR`, `EMPLOYEE` |
| `token` | `LoginActivity.authToken` | String | — | JWT — sent in all subsequent requests |
| `useCRF` | `LoginActivity.useCRF` | int | — | CAF/CRF form toggle |
| `useCAF` | `LoginActivity.useCAF` | String | — | CAF usage flag |
| `deposit_amount` | `LoginActivity.deposit_amount` | double | — | LCO wallet balance shown on dashboard |
| `useLastName` | `LoginActivity.useLastName` | int | — | Show/hide last name field in customer forms |
| `useDiscount` | `LoginActivity.useDiscount` | int | — | Show/hide discount field |
| `useDataFromMasterTable` | `LoginActivity.useDataFromMasterTable` | int | — | Data source toggle |
| `useMandatoryForHotel` | `LoginActivity.useMandatoryForHotel` | int | — | Hotel-specific mandatory fields |
| `useAccountNumber` | `LoginActivity.useAccountNumber` | int | — | Show/hide account number field |
| `lco_billtype` | `LoginActivity.lco_billtype` | int | — | LCO billing type |
| `customer_billtype` | `LoginActivity.customerbilltype` | int | 0 | Customer billing type |
| `lcoMobileNo` | `LoginActivity.lcoMobileNo` | int | — | LCO mobile contact |
| `employeeParentId` | `LoginActivity.employeeParentId` | String | — | Parent employee ID |
| `employeeParentType` | `LoginActivity.employeeParentType` | String | — | Parent type (DISTRIBUTOR, SUBDISTRIBUTOR, etc.) |
| `is_direct_lco` | `LoginActivity.is_direct_lco` | int | 0 | 0=indirect, 1=direct. Controls LCO wallet visibility |
| `AUTO_RECEIPT_NUMBER` | `LoginActivity.AUTO_RECEIPT_NUMBER` | int | 1 | Auto-generate receipt numbers |
| `allow_top_up` | `LoginActivity.allow_top_up` | int | 1 | 1=show LCO top-up option in toolbar |
| `show_caf_mobile_validation` | `LoginActivity.show_caf_mobile_validation` | int | 0 | 1=show OTP validation during CAF creation |
| `CURRENCY_CODE` | `LoginActivity.CURRENCY_CODE` | String | "₹" | Currency symbol used throughout app |
| `patch_information` | `LoginActivity.patch_information` | String | "1.4.13.2" | Feature flag string. Values seen: "1.4.13.2", "1.4.13.3", "1.4.13.4" — controls LCO wallet history visibility |
| `stb_pairing` | `LoginActivity.stb_pairing` | int | 0 | 1=show Pair/Unpair menu item |
| `stb_unpairing` | `LoginActivity.stb_unpairing` | int | 0 | 1=show Pair/Unpair menu item |
| `recurringServiceEdit` | `LoginActivity.recurringService` | int | — | Controls recurring service edit UI |
| `appMenuFormat` | `LoginActivity.menuType` | String | "" | "DEFAULT" or other string. Controls which nav_drawer_items array to use |
| `useLcoDeposit` | `LoginActivity.userLcoDeposit` | int | — | LCO deposit flag |
| `defaultCountry` | `LoginActivity.defaultcountry` | String | — | Pre-selected country in forms |
| `defaultState` | `LoginActivity.defaultstate` | int | — | Pre-selected state |
| `defaultDistrict` | `LoginActivity.defaultdistrict` | int | — | Pre-selected district |
| `defaultCity` | `LoginActivity.defaultcity` | int | — | Pre-selected city |
| `freezecustomerparamsinapp` | `LoginActivity.freezecustomerparamsinapp` | int | 0 | 1=freeze customer edit fields in app |
| `blockpayment` | `LoginActivity.hidemakepayment` | int | 0 | 1=hide Make Payment button |
| `show_mia_agreement_upload` | `LoginActivity.show_mia_agreement_upload` | int | 0 | MIA agreement upload feature flag |
| `accept_terms_condtions` | `LoginActivity.accept_terms_condtions` | int | 0 | 0=terms not accepted yet |
| `agreement_details_count` | `LoginActivity.agreement_details_count` | int | 0 | Count of uploaded MIA documents |
| `access_distributor_wise` | `LoginActivity.access_distributor_wise` | int | 0 | 1=distributor-level access control enabled |
| `username` | `LoginActivity.login_username` | String | — | Display name for nav drawer header |
| `email` | `LoginActivity.login_email` | String | — | Email for nav drawer header. If value is "anyType{}" show "NA" |

**From `getaccesscontrollRest` (statusCode == 0):** Override these after login:

| Response Field | Static Variable | Type | Default | Purpose |
|----------------|-----------------|------|---------|---------|
| `int_bulk_payment` | `LoginActivity.int_bulk_payment` | int | 1 | 1=show Payments menu item and Quick Pay button |
| `invoice_page_access` | `LoginActivity.invoice_page_access` | int | 1 | Controls invoice page visibility |
| `payment_hist_page_access` | `LoginActivity.payment_hist_page_access` | int | 1 | Controls payment history visibility |
| `access_for_complaints` | `LoginActivity.access_for_complaints` | int | 1 | 1=show Complaints menu item |
| `int_stb_activation` | `LoginActivity.int_stb_activation` | int | 1 | 1=show Box Operations / activation |
| `int_stb_deactivation` | `LoginActivity.int_stb_deactivation` | int | 1 | 1=show Box Operations / deactivation |
| `int_stb_reactivation` | `LoginActivity.int_stb_reactivation` | int | 1 | 1=show Box Operations / reactivation |
| `int_payment_transaction_report_access` | `LoginActivity.pgtransaction` | int | 0 | PG transaction report access |

**Note on status_code convention:** The REST V2 document notes that the server uses `status_code: 0` for errors in `error_res()`. However, the Android code for `getaccesscontrollRest` treats `statusCode == 0` as success and `statusCode == 1` as failure. The `validateLogin` response uses the same convention. Always verify the actual server response for each endpoint.

### 3.7 Also Stored in SharedPreferences During Login

The following are written to SharedPreferences and read on subsequent app launches:

| SharedPref File | Key | Value |
|-----------------|-----|-------|
| `vidslogin` | `username` | The typed username (only if Remember Me checked) |

### 3.8 Logo Loading

The logo is fetched from `LOGIN_URL` + `APP_LOGO_PATH` (from cloud auth SharedPrefs) via an async `DownloadImageTask`. If the fetch fails, the fallback drawable is `ic_launcher` (or `mainlogo` for `com.actlco.digital` build variant). In Flutter, use `CachedNetworkImage` with asset fallback.

---

## 4. Screen: ApplicationIntroActivity — First-Run Intro

**Source:** `ApplicationIntroActivity.java`
**Flutter Route:** `/intro`

### 4.1 Screen Identity

| Property | Value |
|----------|-------|
| Title | No title bar |
| Purpose | One-time intro slideshow shown on first app use. On subsequent launches it immediately navigates to MainActivity. |
| Category | Onboarding |
| Layout | `app_intro_activity.xml` |

### 4.2 First-Run Detection

| SharedPref File | Key | Value |
|-----------------|-----|-------|
| `hasRunBefore_appIntro` | `hasRun_appIntro` | `false` (default) → show intro; `true` → skip to MainActivity |

### 4.3 UI Elements

| Element | Type | ID | Label | Notes |
|---------|------|----|-------|-------|
| Intro content | Custom layout | `app_intro_activity` | Images describing navigation | Only shown on first run |
| OK button | Button | `appintro_btn_ok` | "OK" / "Got it" | Saves `hasRun_appIntro = true` and navigates to MainActivity |

### 4.4 Actions and Workflows

**On first run:**

1. Check `LoginActivity.userType` (NOTE: `"RESELLERsssssssssssssssss"` in the condition — this is deliberately misspelled/dead code. This branch will never trigger for real RESELLER users. Treat as dead code in Flutter.)
2. For all other user types (or RESELLER since the string doesn't match): show `app_intro_activity` layout.
3. Button "OK" tap:
   - Write `hasRun_appIntro = true` to SharedPrefs
   - `startActivity(MainActivity)` with `putExtra("frgToLoad", 0)`
   - `finish()`

**On subsequent runs:**
- Immediately `startActivity(MainActivity)` with `putExtra("frgToLoad", 0)` without showing any UI.

### 4.5 MIA Agreement Dialog (Dead Code Branch)

The MIA agreement dialog block checks `userType.equals("RESELLERsssssssssssssssss")` — this string will never match a real user type. This feature is intentionally disabled. Do not port.

### 4.6 Theme Application

Reads `APP_THEME` from `LoginActivity.APP_THEME` static field and applies the appropriate theme before `setContentView`. See [Theming System](#12-theming-system).

---

## 5. Screen: MainActivity — Navigation Drawer Host

**Source:** `MainActivity.java`
**Flutter Equivalent:** Scaffold with Drawer

### 5.1 Screen Identity

| Property | Value |
|----------|-------|
| Purpose | Host activity. Holds all fragments in `frame_container`. Navigation drawer provides app-wide navigation. |
| Layout | `activity_main_new.xml` |
| Category | Navigation shell |

### 5.2 Toolbar UI Elements

| Element | Type | ID | Label / Action | Notes |
|---------|------|----|----------------|-------|
| Hamburger icon | ActionBarDrawerToggle | — | Opens/closes navigation drawer | — |
| Logo image | ImageView | `toolbar_logo` | Dealer logo | Tap navigates to Dashboard (position 0) if not already there |
| Scan icon | ImageView | `img_scan` | QR/Barcode scanner | Navigates to `ScannerFrag` with `origin = "searchCustomer"`. Hidden for device model "N910" |
| Bluetooth icon | ImageView | `bluetooth_logo` | Bluetooth printer pairing | Navigates to `ActivityDevice`. Hidden for device model "N910" |
| Logout | Overflow menu item | `action_logout` | "Logout" | Shows confirm dialog → `LoginActivity` with `EXIT=true` → `finishAffinity()` |
| Privacy Policy | Overflow menu item | `action_privacypolicy` | "Privacy Policy" | Navigates to `PrivacyPolicy_Fragment` |
| LCO Top-Up | Overflow menu item | `action_lcopayment` | "Top Up" | Only visible if `userType == "RESELLER"` AND `allow_top_up == 1` AND `is_direct_lco == 0`. Navigates to `LcoTopupFragment` after confirm dialog |
| LCO Payment History | Overflow menu item | `action_lcopaymenthist` | Payment History | Only visible if `userType == "RESELLER"` AND `allow_top_up == 1` AND `is_direct_lco == 0` AND `patch_information` is one of `"1.4.13.2"`, `"1.4.13.3"`, `"1.4.13.4"`. Navigates to `Report_EmpCollect_Fragment` |
| About Us | Overflow menu item | `action_aboutus` | "About Us" | Navigates to `About_Fragment` |

### 5.3 Nav Drawer Header

| Element | Source |
|---------|--------|
| Header image (`navheaderimage`) | Same logo downloaded from `LoginActivity.logo_img` |
| Username (`navheader_username`) | `LoginActivity.login_username` |
| Email (`navheader_email`) | `LoginActivity.login_email`. If value is `"anyType{}"` display `"NA"` |

### 5.4 Navigation Drawer Menu Structure

The menu items are determined by two factors:
1. **User Role:** `isDistributor` = true if `userType` is `DISTRIBUTOR` or `SUBDISTRIBUTOR`, OR `employeeParentType` is `DISTRIBUTOR` or `SUBDISTRIBUTOR`
2. **Menu format:** `LoginActivity.menuType` — `"DEFAULT"` uses one string array, any other value (including `"FORMAT1"`) uses an alternate array

#### 5.4.1 Distributor Menu (isDistributor = true)

Array source: `R.array.nav_drawer_items_distributor` (menuType == "DEFAULT") or `R.array.nav_drawer_items_distributor1` (all other values)

| Position | Label (Index) | Icon | Fragment/Action | Visibility Condition |
|----------|--------------|------|-----------------|----------------------|
| 0 | Dashboard | `navi_dashboard` | `Dashboard_Fragment` | Always |
| 1 | Search Customer | `navi_searchcustomer` | `SearchCustomer_Fragment` (origin="searchCustomer") | Always |
| 2 | New Customer | `addnav` | `STB_Check_Fragment_Old` (from=0) | Always |
| 3 | Box Operations | `compnav` | `SearchCustomer_Fragment` (origin="boxMgmt") | `int_stb_activation==1` OR `int_stb_deactivation==1` OR `int_stb_reactivation==1` |
| 4 | Package Operations | `boxnav` | `SearchCustomer_Fragment` (origin="packageMgmt") | `int_stb_activation==1` OR `int_stb_deactivation==1` |
| 5 | Payments | `packnav` | `SearchCustomer_Fragment` (origin="payments") | `int_bulk_payment==1` |
| 6 | LCO Payment | `paynav` | `LCO_Payment_Fragment` | `LCO_PAYMENT==1` (from `LoginActivity.LCO_PAYMENT`) |

#### 5.4.2 Non-Distributor Menu (isDistributor = false)

Array source: `R.array.nav_drawer_items` (menuType == "DEFAULT") or `R.array.nav_drawer_items1` (all other values)

| Position | Label (Index) | Icon | Fragment/Action | Visibility Condition |
|----------|--------------|------|-----------------|----------------------|
| 0 | Dashboard | `navi_dashboard` | `Dashboard_Fragment` | Always |
| 1 | Search Customer | `navi_searchcustomer` | `SearchCustomer_Fragment` (origin="searchCustomer") | Always |
| 2 | New Customer | `addnav` | `STB_Check_Fragment_Old` (from=0) | Always |
| 3 | Complaints | `compnav` | `SearchCustomer_Fragment` (origin="complaintMgmt") | `access_for_complaints==1` |
| 4 | Box Operations | `boxnav` | `SearchCustomer_Fragment` (origin="boxMgmt") | `int_stb_activation==1` OR `int_stb_deactivation==1` OR `int_stb_reactivation==1` |
| 5 | Package Operations | `packnav` | `SearchCustomer_Fragment` (origin="packageMgmt") | `int_stb_activation==1` OR `int_stb_deactivation==1` |
| 6 | Payments | `paynav` | `SearchCustomer_Fragment` (origin="payments") | `int_bulk_payment==1` |
| 7 | LCO Payment | `paynav` | `LCO_Payment_Fragment` | `LCO_PAYMENT==1` |
| 8 | Reports | `reports` | `Reports_frag` | Always |
| 9 | Pair/Unpair | `pairunpainav` | (Pair/Unpair fragment) | `stb_pairing==1` OR `stb_unpairing==1` |

#### 5.4.3 Fragment Navigation via `displayView(position)`

The `displayView()` method routes drawer item positions to fragments. Because menu items are conditionally added, the positions are dynamic. Use the access-flag conditions above to determine actual array index, not hardcoded positions.

Key routing logic for `displayView`:
- **Position 0:** Always `Dashboard_Fragment`. Bundle: `theme_2 = (APP_DASHBOARD != 1)`
- **Position 1:** Always `SearchCustomer_Fragment` with `origin = "searchCustomer"`
- **Position 2:** Always `STB_Check_Fragment_Old` with `from = 0`
- **Position 3:** Distributor → `SearchCustomer_Fragment` (origin="boxMgmt"); Non-distributor → `SearchCustomer_Fragment` (origin="complaintMgmt")
- **Position 4:** Distributor → `SearchCustomer_Fragment` (origin="packageMgmt"); Non-distributor → `SearchCustomer_Fragment` (origin="boxMgmt")
- **Position 5+:** Complex branching based on `isDistributor`, `int_bulk_payment`, `LCOpayment` flags

#### 5.4.4 Flutter Drawer Implementation Notes

In Flutter, build the drawer item list dynamically at runtime using the access flags. Use a list of `DrawerMenuItem` objects with `title`, `icon`, `route`, and `origin` properties. Conditionally include each item based on flags from the login and access-control responses.

### 5.5 Device Model Handling

```dart
// Android: MainActivity.DeviceModel = Build.MODEL, DeviceName = Build.MANUFACTURER
// If DeviceModel == "N910": hide bluetooth_logo and img_scan
```

In Flutter, read `Platform.operatingSystem` and conditionally show/hide Bluetooth and scan icons.

---

## 6. Screen: Dashboard_Fragment — Main Dashboard

**Source:** `Dashboard_Fragment.java`
**Flutter Route:** Home screen (default after login)
**Layout:** `dashboard_new_digi.xml`

### 6.1 Screen Identity

| Property | Value |
|----------|-------|
| Purpose | Display summary statistics and quick action shortcuts for the logged-in LCO/dealer |
| Category | Dashboard |
| Theme variant | Controlled by `APP_DASHBOARD` flag: `== 1` → default theme; `!= 1` → theme_2 |

### 6.2 UI Sections and Elements

#### Section A: LCO Wallet (Conditional)

| Element | Type | ID | Label | Visibility Condition |
|---------|------|----|-------|----------------------|
| LCO wallet card | LinearLayout | `ll_lcowallet` | — | Hidden for DEALER, ADMIN, SERVICE, DISTRIBUTOR, SUBDISTRIBUTOR. Shown for RESELLER/EMPLOYEE when `is_direct_lco == 0` |
| LCO balance text | TextView | `tv_lcoaount` | "Rs.{amount}" | Populated from `lco_deposit_amount` REST call |
| Refresh/Update button | Button | `btn_lco` | "Update" | Triggers `getdepostslco` SOAP task (DO NOT PORT — use REST `lco_deposit_amountRest`) |
| Open payment history | LinearLayout | `ll_open` | — | Visible for RESELLER, EMPLOYEE, SERVICE when `patch_information` is "1.4.13.2", "1.4.13.3", or "1.4.13.4" |

#### Section B: Stat Cards (Details Panel)

All cards are inside `ll_detailslayout` and `ll_details` (made visible after successful dashboard API response).

| View ID | Label / Section Header | Maps To API Field | Data Type |
|---------|------------------------|-------------------|-----------|
| `totalstb` (and `totalstb1`) | "Total STBs" | `totalStbs` | int |
| `activestb` (and `activestb1`) | "Assigned STBs" | `totalAssignedStbs` | int |
| `deactivestb` (and `deactivestb1`) | "Unassigned STBs" | `totalUnAssignedStbs` | int |
| `comp` (and `comp1`) | "Total Complaints" | `totalComplaints` | int |
| `activatestb` (and `activatestb1`) | "Active Customers" | `totalActiveCustomers` | int |
| `deactivatestb` (and `deactivatestb1`) | "Deactive Customers" | `totalDeactiveCustomers` | int |

**Note:** `totalCurrentMonthBill` is parsed into `int_complaint_closed` but the UI binding is commented out — this field is fetched but not currently displayed. `totalPaidCustomers` and `totalUnPaidCustomers` are also parsed but their display is commented out. Include these in the Flutter model for future use.

**Additional API response fields available but not currently displayed:**

| API Field | Type | Notes |
|-----------|------|-------|
| `totalCurrentMonthBill` | double | Mapped to `int_complaint_closed` variable — UI commented out |
| `totalPaidCustomers` | int | Parsed, UI commented out |
| `totalUnPaidCustomers` | int | Parsed, UI commented out |
| `totalDueAmount` | double | Available in REST V2 response |
| `outStandingAmount` | double | Available in REST V2 response |
| `msoShare` | — | Available in REST V2 response |
| `totalCurrentMonthMsoShare` | — | Available in REST V2 response |
| `currentMonthOutstanding` | — | Available in REST V2 response |
| `currentMonthLCOBill` | — | Available in REST V2 response |
| `lcocurrentmonthdueamount` | — | Available in REST V2 response |
| `lov_emp_grp_customers` | — | Available in REST V2 response |
| `gettotalPaidCustomers` | — | Available in REST V2 response |
| `gettotalUnPaidCustomers` | — | Available in REST V2 response |

#### Section C: Quick Action Buttons

| View ID | Label | Navigation Target | Visibility Condition |
|---------|-------|-------------------|----------------------|
| `pay` | "Quick Pay" | `SearchCustomer_Fragment` (origin="payments") | `int_bulk_payment == 1` (VISIBLE); else INVISIBLE |
| `customersearch` | "Search Customer" | `SearchCustomer_Fragment` (origin="searchCustomer") | Always visible |
| `newcustomer` | "New Customer" | `STB_Check_Fragment_Old` (from=0) | Always visible |
| `packageoperations` | "Package Operations" | `SearchCustomer_Fragment` (origin="packageMgmt") | `int_stb_activation==1` OR `int_stb_deactivation==1` (VISIBLE); else INVISIBLE |
| `complaintoperations` | "Complaints" | `SearchCustomer_Fragment` (origin="complaintMgmt") | `access_for_complaints==1` (VISIBLE); else INVISIBLE |
| `stboperations` | "STB Operations" | `SearchCustomer_Fragment` (origin="boxMgmt") | `int_stb_activation==1` OR `int_stb_deactivation==1` OR `int_stb_reactivation==1` (VISIBLE); else INVISIBLE |

#### Section D: Text Links

| View ID | Label | Navigation Target |
|---------|-------|-------------------|
| `tv_allcomplaints` | "All Complaints" | `OpenComplaints_frag` |
| `tv_expiredserviceslist` | "Expired Services" | Triggers `expiredcount()` → shows popup list dialog |
| `tv_refresh` (label) | "Refresh" / section header | — |
| `btn_details` | "Details" / expand | Triggers `DashboardDetails` task if online; else shows No-Internet dialog |

#### Section E: Section Labels (Static, No API)

| View ID | Label |
|---------|-------|
| `tv_dahs` | "Dashboard" (bold) |
| `tv_quickactions` | "Quick Actions" (bold) |
| `tv_details` | "Details" (bold) |
| `tv_refresh` | "Refresh" (bold) |

### 6.3 API Calls

#### Call 1 (SOAP — DO NOT PORT): DashboardDetails

Uses `ksoap2` SOAP with `dashBoard` complex type sending `authToken`. In Flutter, use the REST equivalent below.

**REST V2 Equivalent:**

| Property | Value |
|----------|-------|
| Method | POST |
| Endpoint | `POST /LcoRestServices/dashBoardDetailsRest` |
| Auth | JWT token in header + `authtoken` in body |
| Trigger | `btn_details` tap if network available |

**Request Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `use_lco_deposits` | String | `LoginActivity.userLcoDeposit` (as String) |
| `lco_billtype` | String | `LoginActivity.lco_billtype` (as String) |

**Response Mapping:**

| JSON Field | UI Target | Notes |
|------------|-----------|-------|
| `totalStbs` | `totalstb` TextView | |
| `totalAssignedStbs` | `activestb` TextView | Label: "Assigned STBs" |
| `totalUnAssignedStbs` | `deactivestb` TextView | Label: "Unassigned STBs" |
| `totalComplaints` | `comp` TextView | |
| `totalActiveCustomers` | `activatestb` TextView | |
| `totalDeactiveCustomers` | `deactivatestb` TextView | |
| `totalCurrentMonthBill` | Not displayed (parsed only) | |
| `totalPaidCustomers` | Not displayed (parsed only) | |
| `totalUnPaidCustomers` | Not displayed (parsed only) | |

#### Call 2 (SOAP — DO NOT PORT): getdepostslco (LCO Wallet Balance)

Uses `ksoap2` SOAP. In Flutter, use the REST equivalent.

**REST V2 Equivalent:**

| Property | Value |
|----------|-------|
| Method | POST |
| Endpoint | `POST /LcoRestServices/lco_deposit_amountRest` |
| Auth | JWT token |
| Trigger | Automatic on fragment load if `userType == "RESELLER"` AND `is_direct_lco == 0`, OR `userType == "EMPLOYEE"` AND `is_direct_lco == 0`. Also triggered by `btn_lco` tap. |

**Request Parameters:** None (uses JWT-derived employee/dealer context)

**Response Fields:**

| Field | UI Target |
|-------|-----------|
| `lco_deposit_amount` | `tv_lcoaount` — formatted as `"{CURRENCY_CODE} {amount}"` |
| `customerCount` | Not displayed |

#### Call 3 (REST V2 — PORT THIS): getExpiryServicesDateWiseCount

| Property | Value |
|----------|-------|
| Method | POST |
| Endpoint | `{BASE_URL}/LcoRestServices/getExpiryServicesDateWiseCount` (URL built as `LoginActivity.URL.replace("/wsController","")` + property `"gesdwc"`) |
| Library | Volley `StringRequest` |
| Auth | `authtoken` + `dealer_id` in POST body |
| Trigger | `tv_expiredserviceslist` tap |
| Timeout | Default Volley (+ retry policy set in code) |

**Request Parameters:**

| Parameter | Type | Source |
|-----------|------|--------|
| `authtoken` | String | `LoginActivity.authToken` |
| `dealer_id` | String | `String.valueOf(LoginActivity.dealerId)` |

**Response Handling:**

| JSON Field | Type | Usage |
|------------|------|-------|
| `status_code` | int | 0 = success, 1 = show error toast |
| `status_msg` | String | Error message |
| `getExpiryServicesList` | JSON Array | Each item: `{ "date": String, "stb_count": String }` |

On success: shows an `AlertDialog` with a custom layout containing a `ListView`. Each list row shows `date` and `stb_count` from the array. In Flutter, show a `showModalBottomSheet` or `AlertDialog` with a `ListView.builder`.

### 6.4 Back Press Handling

In Dashboard_Fragment, back press shows a dialog:
- Title: "Are you sure?"
- Message: "Press 'Logout' to close the application."
- Buttons: "Logout" (→ LoginActivity, finish all), "Cancel"

In Flutter, implement `WillPopScope` or `PopScope` with the same dialog.

### 6.5 Error States

| Condition | Dialog |
|-----------|--------|
| No network when tapping "Details" | AlertDialog "No internet connection!" |
| `statusCode == 1` from dashboard API | AlertDialog "Details not found!" + message |
| `statusCode >= 2` from dashboard API | AlertDialog "Details not found!" + message |
| `statusCode == 1` from LCO wallet | AlertDialog "Lco Wallet!" + message |
| Response is null from any call | AlertDialog "Server connectivity error!" |

---

## 7. Screen: StatusActivity — LCO Payment Return Status

**Source:** `StatusActivity.java`
**Flutter Route:** `/lco-payment-status` (returned to after Billdesk payment gateway)

### 7.1 Screen Identity

| Property | Value |
|----------|-------|
| Title | None (no title bar — `FEATURE_NO_TITLE`) |
| Purpose | Receives the payment gateway return status from Billdesk (via intent bundle), posts the payment to the EzyBill server, and navigates to MainActivity on success |
| Category | Payment result |
| Layout | `activity_status.xml` |

### 7.2 UI Elements

| Element | Type | ID | Notes |
|---------|------|----|-------|
| Status text | TextView | `status` | Displays the raw status string from the payment gateway |

### 7.3 Actions and Workflows

1. Receives intent extra `"status"` (String, pipe-delimited).
2. Displays full status string on `status` TextView.
3. If `stat.contains("-Success")` → call `lcoPayment()` REST API.
4. On `statuscode == 0`: navigate to `MainActivity`.
5. On `statuscode == 1`: show AlertDialog with `statusmessage`.

### 7.4 API Call: lcoPayment

| Property | Value |
|----------|-------|
| Method | POST |
| Endpoint | `{BASE_URL}/employeeRestServices/lcoPayment` (where BASE_URL = `LoginActivity.URL.replace("/wsController","")`) |
| Library | Volley `StringRequest` |
| Auth | `authToken` in POST body |
| Timeout | 10,000 ms, default retry policy |

**Request Parameters:**

| Parameter | Type | Source |
|-----------|------|--------|
| `authToken` | String | `LoginActivity.authToken` |
| `paidAmount` | String | `BilldeskPaymentActivity.amt` (amount set before launching Billdesk) |
| `dealer_id` | String | `String.valueOf(LoginActivity.dealerId)` |
| `employee_id` | String | `String.valueOf(LoginActivity.employeeId)` |
| `transaction_id` | String | `LcoTopupFragment.tokennumber` (Billdesk transaction ID) |

**Response Fields:**

| Field | Type | Handling |
|-------|------|---------|
| `status_code` | int | 0 = success → navigate to MainActivity; 1 = show error dialog |
| `status_msg` | String | Shown in error dialog title " Failed " |

### 7.5 Flutter Implementation Notes

- This screen is typically the return URL handler after Billdesk WebView payment.
- In Flutter, use a deep-link or WebView `onNavigationRequest` callback to detect the return URL containing "-Success".
- Pass `paidAmount` and `tokennumber` via route arguments.

---

## 8. Screen: About_Fragment — About Us

**Source:** `About_Fragment.java`, `AboutActivityMarquee.java`
**Flutter Route:** navigated to from overflow menu "About Us"

### 8.1 Screen Identity

| Property | Value |
|----------|-------|
| Purpose | Display application information |
| Layout | `aboutus_fragment.xml` |
| Category | Information |

### 8.2 UI Elements

| Element | Type | ID | Notes |
|---------|------|----|-------|
| Marquee text | `AboutActivityMarquee` (custom TextView) | `aboutmarquee` | Auto-scrolling vertically. Used for EzyBill default build. Hidden for `com.actlco.digital` build. |
| WebView | WebView | `webview_act` | Only shown for `com.actlco.digital` build variant; loads `https://www.actcorp.in/` |

### 8.3 Marquee Widget (`AboutActivityMarquee`)

The marquee is a custom `AppCompatTextView` that auto-scrolls its content vertically:
- Scroll interval: 65ms per 1-pixel step
- Loops: scrolls back to top (-75px) when reaching the bottom
- User touch: pauses auto-scroll while pressed
- Methods: `pauseMarquee()`, `resumeMarquee()`, `stopMarquee()`

In Flutter, implement using `SingleChildScrollView` with `AutoScrollController` or a simple `AnimationController`-driven `ScrollController`.

### 8.4 Build Variant Behavior

| Build Variant | Marquee | WebView |
|---------------|---------|---------|
| `com.itp.ezybill.androidapp` | Visible | Hidden |
| `com.actlco.digital` | Hidden | Visible (loads `https://www.actcorp.in/`) |

---

## 9. Screen: PrivacyPolicy_Fragment — Privacy Policy

**Source:** `PrivacyPolicy_Fragment.java`
**Flutter Route:** navigated to from overflow menu "Privacy Policy"

### 9.1 Screen Identity

| Property | Value |
|----------|-------|
| Purpose | Display the privacy policy via WebView |
| Layout | `privacypolicy.xml` |
| Category | Legal/Information |

### 9.2 UI Elements

| Element | Type | ID | Notes |
|---------|------|----|-------|
| WebView | WebView | `webview` | JavaScript enabled. Error shown as Toast. |

### 9.3 Build Variant Behavior

| Build Variant | URL Loaded |
|---------------|-----------|
| `com.itp.ezybill.androidapp` | `http://www.itpworld.com/news/itp-software-india-pvt-ltd-privacy-policy` |
| `com.actlco.digital` | `https://www.actcorp.in/` |

### 9.4 Flutter Implementation

Use `webview_flutter` package. Wrap in a `Scaffold` with a `AppBar`. Handle `onPageError` by showing a `SnackBar`.

---

## 10. SharedPreferences Reference

### 10.1 File: `bmsSharedPref` (EzyBillConstants.BMS_SHARED_PREF)

Written by `ACT_LoginActivity` / `CloudAuthentication` (cloud auth). Read by `LoginActivity` on startup.

| Key | Constant | Type | Purpose |
|-----|----------|------|---------|
| `smsKey` | `EzyBillConstants.SMSKEY` | String | Legacy SMS registration key |
| `bmsAuth` | `EzyBillConstants.BMSAUTH` | Boolean | Whether cloud auth has completed |
| `login_url` | `EzyBillConstants.LOGIN_URL` | String | Server base URL (e.g., `http://server/wsController`) |
| `emp_id` | `EzyBillConstants.EMP_ID` | String | Pre-seeded employee ID from cloud auth |
| `appThemeColor` | `EzyBillConstants.APP_THEME_COLOR` | int | 1–5 theme variant |
| `appDashboard` | `EzyBillConstants.APP_DASHBOARD` | int | 1=default dashboard, other=theme2 |
| `enableAadhar` | `EzyBillConstants.ENABLE_AADHAAR` | int | Aadhaar feature toggle |
| `appLogoPath` | `EzyBillConstants.APP_LOGO_PATH` | String | URL to dealer logo image |

**Flutter equivalent:** Use `shared_preferences` package. On first install, seed `login_url` from your build config. Or fetch from a config endpoint.

### 10.2 File: `vidslogin` (LoginActivity.SPF_NAME)

| Key | Value |
|-----|-------|
| `username` | Last typed username (written only if "Remember Me" was checked) |

### 10.3 File: `hasRunBefore_appIntro`

| Key | Value |
|-----|-------|
| `hasRun_appIntro` | Boolean — `true` if intro has been shown |

### 10.4 File: `aadhaardetails`

| Key | Value |
|-----|-------|
| `aadhaardata` | Aadhaar data string (read in LoginActivity but not used in current displayed UI) |

---

## 11. Global Static State (LoginActivity static fields)

In Flutter, replace `LoginActivity` static fields with a provider/riverpod/bloc `AppSession` model stored in app state. All fields below must be accessible globally after login.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `URL` | String | `""` | Server base URL (e.g., `http://server/wsController`) |
| `authToken` | String | — | JWT token for all authenticated requests |
| `user` | String | — | Employee display name |
| `business_name` | String | — | Business name |
| `dealerId` | int | — | Dealer ID |
| `employeeId` | int | — | Employee ID |
| `userType` | String | — | Role: RESELLER, DEALER, ADMIN, SERVICE, DISTRIBUTOR, SUBDISTRIBUTOR, EMPLOYEE |
| `useCRF` | int | — | CRF form flag |
| `useCAF` | String | — | CAF usage |
| `deposit_amount` | double | — | LCO wallet initial balance (from login response) |
| `lco_deposit_amount` | double | — | Live LCO wallet balance (from Dashboard REST call, in `Dashboard_Fragment`) |
| `useLastName` | int | — | Show last name field |
| `useDiscount` | int | — | Show discount field |
| `useDataFromMasterTable` | int | — | Data source flag |
| `useMandatoryForHotel` | int | — | Hotel mandatory fields |
| `useAccountNumber` | int | — | Account number field |
| `lco_billtype` | int | — | LCO bill type |
| `customerbilltype` | int | 0 | Customer bill type |
| `lcoMobileNo` | int | — | LCO mobile |
| `employeeParentId` | String | — | Parent ID |
| `employeeParentType` | String | — | Parent type |
| `is_direct_lco` | int | 0 | 0=indirect, 1=direct LCO |
| `AUTO_RECEIPT_NUMBER` | int | 1 | Auto receipt numbering |
| `allow_top_up` | int | 1 | LCO top-up feature enabled |
| `show_caf_mobile_validation` | int | 0 | OTP validation on CAF |
| `CURRENCY_CODE` | String | "₹" | Currency symbol |
| `patch_information` | String | "1.4.13.2" | Feature version string |
| `stb_pairing` | int | 0 | Pair/unpair menu visibility |
| `stb_unpairing` | int | 0 | Pair/unpair menu visibility |
| `recurringService` | int | — | Recurring service edit access |
| `menuType` | String | `""` | "DEFAULT" or "" — controls nav_drawer_items variant |
| `userLcoDeposit` | int | — | LCO deposit feature flag |
| `defaultcountry` | String | — | Default country for forms |
| `defaultstate` | int | — | Default state |
| `defaultdistrict` | int | — | Default district |
| `defaultcity` | int | — | Default city |
| `freezecustomerparamsinapp` | int | 0 | Lock customer edit fields |
| `hidemakepayment` | int | 0 | Hide Make Payment button |
| `show_mia_agreement_upload` | int | 0 | MIA upload feature flag |
| `accept_terms_condtions` | int | 0 | Terms accepted flag |
| `agreement_details_count` | int | 0 | MIA document count |
| `access_distributor_wise` | int | 0 | Distributor-wise access |
| `login_username` | String | — | Display username |
| `login_email` | String | — | Display email |
| `logo_img` | String | — | Logo URL |
| `APP_THEME` | int | 1 | 1–5 theme variant |
| `APP_DASHBOARD` | int | 1 | Dashboard theme variant |
| `ENABLE_AADHAAR` | int | 0 | Aadhaar feature toggle |
| `LCO_PAYMENT` | int | 0 | LCO payment menu visibility |
| `imeiNo` | String | — | Device identifier |
| `int_bulk_payment` | int | 1 | From access control — payment feature |
| `invoice_page_access` | int | 1 | From access control |
| `payment_hist_page_access` | int | 1 | From access control |
| `access_for_complaints` | int | 1 | From access control — complaints feature |
| `int_stb_activation` | int | 1 | From access control |
| `int_stb_deactivation` | int | 1 | From access control |
| `int_stb_reactivation` | int | 1 | From access control |
| `pgtransaction` | int | 0 | PG transaction report access |

---

## 12. Theming System

The app supports 5 color themes controlled by `APP_THEME` (int 1–5) stored in SharedPrefs and set from the cloud auth response. Theme is applied to every Activity and Fragment on `onCreate()` before `setContentView()`.

| APP_THEME Value | Theme Name | ThemeUtils Constant |
|-----------------|------------|---------------------|
| 1 | Default (Blue/standard) | `ThemeUtils.DEFAULT` |
| 2 | Red | `ThemeUtils.THEME_RED` |
| 3 | Green | `ThemeUtils.THEME_GREEN` |
| 4 | Blue | `ThemeUtils.THEME_BLUE` |
| 5 | Purple | `ThemeUtils.THEME_PURPLE` |

**Flutter implementation:** Use `ThemeData` with `MaterialApp.theme`. Store selected theme in a `ThemeProvider`. Apply on app startup from persisted preference.

Additionally, `APP_DASHBOARD` controls which dashboard layout variant is displayed:
- `APP_DASHBOARD == 1` → `theme_2 = false` → default grid layout
- `APP_DASHBOARD != 1` → `theme_2 = true` → alternate layout

---

## 13. Runtime Permissions Required

The following permissions are requested in `LoginActivity` before allowing the login API call:

| Permission | Android Constant | Purpose |
|------------|-----------------|---------|
| Phone State | `READ_PHONE_STATE` | Read device IMEI (Android <= 9) or ANDROID_ID |
| Fine Location | `ACCESS_FINE_LOCATION` | GPS for customer location features. Prominent disclosure dialog shown first. |
| Coarse Location | `ACCESS_COARSE_LOCATION` | Fallback location |
| Contacts | `READ_CONTACTS` | Contact-based search |
| Camera | `CAMERA` | QR/barcode scanning |
| Bluetooth Connect | `BLUETOOTH_CONNECT` | API 31+ (Android 12+) for Bluetooth printer pairing |
| Write External Storage | `WRITE_EXTERNAL_STORAGE` | PDF/report saving (code commented out in current version) |
| Manage External Storage | `MANAGE_EXTERNAL_STORAGE` | Android 11+ file management |

**Flutter equivalents:** Use `permission_handler` package. Request permissions before their respective features are used rather than all at login.

**Location permission:** In Android, a prominent disclosure dialog (`R.layout.prominentdisclosure`) is shown explaining location usage before the system permission request. Implement the same UX in Flutter using a custom dialog before `Geolocator.requestPermission()`.

---

## Appendix A: URL Construction Pattern

The Android app builds REST URLs by manipulating the base SOAP URL:

```java
// Base URL from SharedPrefs (set by cloud auth SOAP response)
String wsControllerUrl = LoginActivity.URL;  // e.g., "http://server/wsController"

// REST base URL (strip /wsController)
String restBaseUrl = wsControllerUrl.replace("/wsController", "");
// e.g., "http://server"

// Specific REST endpoints
String accessControlUrl = restBaseUrl + PropertyReader.getProperty("acccntrl");
// PropertyReader reads from assets/config.properties file
String expiredServicesUrl = restBaseUrl + PropertyReader.getProperty("gesdwc");
String lcoPaymentUrl = restBaseUrl + "/employeeRestServices/lcoPayment";
```

In Flutter, store the server base URL (without any path suffix) in `AppConfig` and build all endpoint URLs from it using a centralized `ApiService` class.

---

## Appendix B: Access Control Decision Tree (Flutter Auth Guard)

```
User logs in successfully
         |
         v
  Call getaccesscontrollRest
         |
         v
  Store all access flags in AppSession:
    - int_bulk_payment
    - access_for_complaints
    - int_stb_activation / deactivation / reactivation
    - invoice_page_access
    - payment_hist_page_access
    - pgtransaction
         |
         v
  Build drawer items dynamically:
    isDistributor = (userType in {DISTRIBUTOR, SUBDISTRIBUTOR})
                  OR (employeeParentType in {DISTRIBUTOR, SUBDISTRIBUTOR})
         |
    YES  |                          NO
    -----+-----                 ----+----
    |                              |
    Distributor Menu               Non-Distributor Menu
    (always: Dashboard,            (always: Dashboard,
     Search, New Customer)          Search, New Customer)
    (conditional:                  (conditional:
     BoxOps, PackOps,               Complaints (access_for_complaints),
     Payments, LCO Pay)             BoxOps, PackOps, Payments, LCO Pay,
                                    Reports, PairUnpair)
```

---

*Document version: 1.0 — Generated 2026-03-26*
*Based on Android source branch: 16kbisssuefix*
