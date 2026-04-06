# EzyBill Flutter Migration: LCO Payment, Access Control & Master Data

> **Source Analysis Date:** 2026-03-26
> **Android Source Root:** `com.itp.ezybill.androidapp`
> **REST API Reference:** `REST_API_V2_SERVICE_DOCUMENT.md`

---

## Section 1: LCO Payment Screens

### 1.1 LCO Payment Fragment (`LCO_Payment_Fragment.java`)

#### Purpose
Allows MSO/operator staff to record payments received from LCO (Local Cable Operator) dealers. The screen handles both cash and bank/cheque payments and optionally supports adjustment entries (credit/debit).

#### Transport Protocol
Uses legacy **SOAP** (`ksoap2`) — NOT REST. Flutter migration must replace with REST calls.

| SOAP Method | Action |
|-------------|--------|
| `getlcoadvanceamountdue` | Fetch LCO advance balance and due amount by LCO code |
| `lcopaymentfunc` | Save/submit the LCO payment record |

#### Two-Phase UI Workflow

**Phase 1 — LCO Search Panel** (`lcocode_layout`, visible by default)
- `lcocode_et` — EditText: LCO code input (required, validated non-empty before search)
- `search_btn` — Button: triggers `LcoCode_Search` async task
- On successful search: Phase 1 panel is hidden (`GONE`), Phase 2 result panel is shown

**Phase 2 — Payment Entry Panel** (`result_layout`, hidden initially)
- `advancepaymetn_tv` — TextView: displays advance amount returned from server
- `due_tv` — TextView: displays due amount returned from server
- `amount_et` — EditText: pre-filled with the due amount; editable by user
- `receipt_et` — EditText: receipt number (optional if AUTO_RECEIPT_NUMBER=1)
- `remarks_et` — EditText: remarks (mandatory — validated non-empty before save)
- `paymentmode_sp` — Spinner: `["CASH", "BANK"]`
- `isAdjustment_chkbox` — CheckBox: if checked, shows the credit/debit selector
- `credit_debit_sp` — Spinner (visible only when adjustment checked): `["CREDIT", "DEBIT"]`; CREDIT = `int_credit_debit=0`, DEBIT = `int_credit_debit=1`
- `bank_ll` — LinearLayout (visible only when BANK selected): contains cheque fields
  - `chequenum_et` — Cheque/DD number (required for BANK mode)
  - `bank_et` — Bank name (required for BANK mode)
  - `branch_et` — Branch name (required for BANK mode)
  - `chequedate` — Button: opens DatePickerDialog; validates cheque date must NOT be before today; stores format `yyyy-MM-dd`
- `isAccepted_chkbox` — CheckBox (BANK mode only): marks cheque as accepted (`accept = "1"`)
- `savepayment_btn` — Button: triggers `Lcopaymentfunc` async task
- `backtosearch_tv` — Underlined TextView link: resets view back to Phase 1

#### LCO Search API Call — `getlcoadvanceamountdue`

**Request model** (`LCOcode_Search_Model`):
| Field | Java Type | SOAP Type | Source |
|-------|-----------|-----------|--------|
| `authToken` | String | STRING | `LoginActivity.authToken` |
| `employee_id` | int | INTEGER | `LoginActivity.employeeId` |
| `lco_code` | String | STRING | User input |

**Response fields parsed from SOAP string** (statusCode=0):
| Field | Java Type | Description |
|-------|-----------|-------------|
| `statusCode` | int | 0=success, 1=not found, 2=server error |
| `statusMessage` | String | Error message text |
| `employee_id` | int | LCO employee ID (stored for payment call) |
| `dealer_id` | String | LCO dealer ID |
| `billing_id` | String | LCO billing ID (used as `lco_billing_id` in payment) |
| `advance` | String | Current advance balance amount |
| `due` | String | Current due amount (pre-filled into amount field) |
| `bill_amount` | String | Total bill amount |
| `tds_deduction` | String | TDS deduction amount |

#### LCO Payment API Call — `lcopaymentfunc`

**Request model** (`LcoPayment_Model`):
| Field | Java Type | Source/Logic |
|-------|-----------|--------------|
| `authToken` | String | `LoginActivity.authToken` |
| `lco_employee_id` | String | From search response `employee_id` |
| `lco_billing_id` | String | From search response `billing_id` |
| `receipt_number` | String | User input |
| `amount` | String | User input (pre-filled with due) |
| `mode` | String | `"1"` = CASH, `"2"` = BANK |
| `adjust_flag` | String | `"1"` if adjustment checkbox checked, else `"0"` |
| `dabit_credit` | String | `"0"` = CREDIT, `"1"` = DEBIT (only when `adjust_flag="1"`) |
| `accept` | String | `"1"` if accepted checkbox checked AND mode=BANK |
| `chequeddnumber` | String | Cheque/DD number (BANK mode only) |
| `chequeDate` | String | Date in `yyyy-MM-dd` format (BANK mode only) |
| `bank` | String | Bank name (BANK mode only) |
| `branch` | String | Branch name (BANK mode only) |
| `remarks` | String | Mandatory remarks |

**Response** (statusCode=0): Shows success dialog → navigates to `MainActivity`.
**Response** (statusCode=1): Shows failure dialog with `statusMessage`.
**Response** (statusCode=2): Shows "Contact Support" toast.

#### Validation Rules
1. LCO code must not be empty before searching
2. Amount must not be empty or zero before saving
3. Remarks are mandatory
4. BANK mode: cheque number, bank name, branch, and cheque date are all mandatory
5. Cheque date must not be earlier than today (DatePickerDialog validation)

#### Flutter Migration Notes
- Replace SOAP with REST endpoint. Check REST API doc for `lcopaymentRest` equivalent.
- The search-then-pay two-phase pattern maps to a single screen with two visible states controlled by a boolean `_searchComplete` flag.
- Use `DateTime` and date pickers from `showDatePicker()`.
- LCO code search result should be stored in a local state/provider object.

---

### 1.2 LCO Topup Fragment (`LcoTopupFragment.java`)

#### Purpose
Allows an LCO user to top up their wallet balance via an online payment gateway. This is the entry point — it captures the amount and launches a WebView-based payment flow.

#### Transport Protocol
None directly — delegates to `Payment_Webview_Frag` via bundle. The actual payment is handled inside a WebView (payment gateway page).

#### UI Elements
| Widget | ID | Description |
|--------|----|-------------|
| `tv_lco_name` | `tv_lco_name` | TextView: displays `LoginActivity.user` (logged-in LCO name) |
| `tv_wallet_name` | `tv_wallet_amount` | TextView: displays current wallet balance formatted as `{CURRENCY_CODE} {Dashboard_Fragment.lco_deposit_amount}` |
| `lcopayments_amount` | `lcopayments_amount` | EditText: amount to top up; uses gothic font |
| `btn_paynow` | `btn_paynow` | Button: validates amount > 0.0 and navigates to WebView payment fragment |

#### Data Dependencies
| Source | Field | Usage |
|--------|-------|-------|
| `LoginActivity.user` | Static String | Displays LCO name |
| `Dashboard_Fragment.lco_deposit_amount` | Static String/double | Displays current wallet balance |
| `EzyBillConstants.RUPEES_SIGN` | Static String | Currency symbol prefix (from `LoginActivity.CURRENCY_CODE`) |

#### Workflow
1. Screen loads — shows LCO name and current wallet balance
2. User enters amount (must be > 0.0; validated with `Float.parseFloat`, default 0.0 on parse failure)
3. User taps "Pay Now" → amount passed as Bundle key `"gzs"` to `Payment_Webview_Frag`
4. `Payment_Webview_Frag` loads the payment gateway in a WebView

#### Device-Specific Behavior
- If `MainActivity.DeviceModel == "N910"` (Newland POS device): sets layer type to `LAYER_TYPE_SOFTWARE` to avoid GPU rendering issues.

#### Flutter Migration Notes
- Wallet balance comes from a prior dashboard API call (`lco_deposit_amountRest` or `dashBoardDetailsRest`). Store in app state/provider.
- "Pay Now" should navigate to an in-app WebView screen (`flutter_inappwebview` or `webview_flutter`), passing the amount.
- The `allow_top_up` login flag (int) controls whether this menu item is visible. If `allow_top_up == 0`, hide the top-up option entirely.

---

### 1.3 LCO Wallet History (`LcoWalletHistory.java`)

#### Purpose
Displays the LCO's wallet transaction history for a given date range. Acts as a results display fragment; data is passed in via Bundle (pre-fetched by the caller fragment/activity).

#### Transport Protocol
No direct API call — data arrives via `getArguments().getParcelableArrayList("lcowalletres")`. The calling screen uses REST endpoint `getlcowalletRest`.

#### REST API — `getlcowalletRest`
- **Endpoint:** `POST /LcoRestServices/getlcowalletRest`
- **Payload:**

| Field | Type | Description |
|-------|------|-------------|
| `start_date` | String | From-date filter |
| `end_date` | String | To-date filter |
| `dealer_id` | int | LCO dealer ID from login |

- **Response:** `status_code`, `status_msg`, `paymentresult` (array of wallet transaction records)

#### Bundle Arguments Received
| Key | Type | Description |
|-----|------|-------------|
| `"lcowalletres"` | `ArrayList<Lcowalletmodel>` (Parcelable) | List of wallet transactions |
| `"fromDate"` | String | Start date of the search range |
| `"toDate"` | String | End date of the search range |

#### UI Elements
| Widget | Description |
|--------|-------------|
| `payment_total_counts` | TextView — shows `"Total Count: {n}"` |
| `lv_payments` | ListView — renders each `Lcowalletmodel` via `LcowalletAdapter` |

#### Row Layout — `Lcowalletmodel` Fields (from `Lcowalletmodel.java`)
Each row in the list corresponds to one `Lcowalletmodel` object. All fields are `String` type:

| Field Name | Display Meaning |
|------------|-----------------|
| `deposite_amount` | Deposit/transaction amount |
| `Deposit_Date` | Date of the deposit |
| `business_name` | LCO business name (payer) |
| `payment_mode` | Payment mode (CASH/BANK/etc.) |
| `cheque_ddnumber` | Cheque or DD number (blank for cash) |
| `bank` | Bank name (blank for cash) |
| `branch` | Branch name (blank for cash) |
| `instrument_date` | Cheque/instrument date |
| `credit_amount` | Credit amount for this record |
| `debit_amount` | Debit amount for this record |
| `transaction_no` | Transaction reference number |
| `receipt_no` | Receipt number |
| `Remarks` | Remarks entered at time of payment |
| `Deposited_By` | Name of person who made the deposit |

#### Flutter Migration Notes
- `LcoWalletHistory` is a pure display screen; fetch data before navigation using the `getlcowalletRest` REST endpoint.
- Use a `ListView.builder` or `DataTable` widget with the 14 columns above.
- Show total count in a header widget.
- Date range filters (fromDate, toDate) should be passed from the search screen using `showDateRangePicker()`.

---

### 1.4 Employee Collection Details Fragment (`Employee_Collection_Details_Fragment.java`)

#### Purpose
Displays a report of payment collections made by an employee across customers. Supports printing the collection report (either via Bluetooth thermal printer or the built-in Newland N910 POS printer) and viewing collection locations on a map.

#### Data Source
Data arrives via Bundle: `getArguments().getParcelableArrayList("EmpcollResultList")` as `ArrayList<Empcustomercollection>`.

#### UI Elements
| Widget | Description |
|--------|-------------|
| RecyclerView (`employee_collection_recyclerView`) | Displays each collection record via `Employee_Collection_Details_Adapter` |
| `print_btn` (LinearLayout) | Triggers print flow |
| `viewmaps_img` (ImageView) | Opens `MapsActivity` with the collection locations; hidden on N910 device |

#### `Empcustomercollection` Record Fields (used in print report)
| Getter | Description |
|--------|-------------|
| `getCustomer_name()` | Customer name (truncated to 10 chars for print, 12-char column) |
| `getPaid_amount()` | Amount paid (8-char column) |
| `getPaid_on()` | Date paid on (first 10 chars used = `yyyy-MM-dd`, 10-char column) |

#### Print Report Columns (thermal receipt format)
```
Name        Amount     Paidon
```
- Name: left-aligned, 12 chars (truncated)
- Amount: left-aligned, 8 chars
- PaidOn: right-aligned, 10 chars

#### Print Modes
| Device | Print Method |
|--------|-------------|
| Newland N910 | `payswiff_print()` — uses `N910Util` / `Printer` SDK; GBK encoding |
| Other Android devices | Bluetooth — navigates to `Bluetooth_Fragment` with `offline_report=2` |

#### Map Integration
Passes the full `empCollection_responseArrayList` to `MapsActivity` via intent extra `"empcollection_reports"`.

#### Flutter Migration Notes
- Fetch collection data before navigating to this screen (from the employee collection REST endpoint).
- Replace Bluetooth print with a platform channel or a Bluetooth printing plugin.
- N910 print SDK is hardware-specific — exclude from Flutter unless targeting N910 hardware.
- Map view should use `google_maps_flutter` with markers for each collection location.

---

## Section 2: Access Control & Login Response

### 2.1 Authentication Flow Overview

The app uses a **two-step authentication**:

1. **Cloud Auth** (`CloudAuthResponse`) — validates the device/subscription with the BMS server; returns `ipAddress` which becomes the SOAP endpoint URL.
2. **Login** (`LoginResponse` / `validateLogin` REST endpoint) — authenticates with username/password against the operator's server; returns the session token and all config flags.

### 2.2 CloudAuthResponse Fields

**Class:** `api/CloudAuthResponse.java`
**Used for:** Initial device/subscription authentication against the BMS (central) server.

| Field | Java Type | Description |
|-------|-----------|-------------|
| `statusCode` | int | 0=success, non-zero=failure |
| `statusMessage` | String | Error or success message |
| `ipAddress` | String | The operator's server URL — stored in SharedPreferences as `LOGIN_URL`; used as SOAP endpoint `URL` in all subsequent SOAP calls |
| `employeeId` | String | BMS-level employee ID |
| `appThemeColor` | int | App theme color code — stored in SharedPreferences `APP_THEME_COLOR` |
| `appDashboard` | int | Dashboard layout variant — stored in SharedPreferences `APP_DASHBOARD` |
| `appLogoPath` | String | URL/path to app logo image — stored in SharedPreferences `APP_LOGO_PATH` |
| `enableAadhar` | int | Whether Aadhaar-based features are enabled — stored in SharedPreferences `ENABLE_AADHAAR`; default 0 |

### 2.3 LoginResponse Fields — Complete Reference

**Class:** `api/LoginResponse.java`
**Endpoint:** `POST /LcoRestServices/validateLogin`
**Request:** `UserName`, `PassWord`, `mobile_no`, `imei`

All fields below are parsed from the semicolon-delimited SOAP response string (legacy format) and from the REST JSON response in the Flutter migration.

#### Session Identity Fields
| Field | Java Type | Default | Static Variable in LoginActivity | Description |
|-------|-----------|---------|----------------------------------|-------------|
| `statusCode` | int | — | — | 0=login success, ≥1=failure |
| `statusMessage` | String | — | — | Error or success message |
| `authToken` | String | — | `LoginActivity.authToken` | Session token used in all subsequent API calls |
| `employeeId` | int | — | `LoginActivity.employeeId` | Logged-in employee's ID |
| `employeeName` | String | — | `LoginActivity.user` | Display name of logged-in employee |
| `dealerId` | int | — | `LoginActivity.dealerId` | Dealer/LCO's dealer ID |
| `userType` | String | — | `LoginActivity.userType` | User role type string (e.g., `"LCO"`, `"MSO"`, `"EMPLOYEE"`) |
| `business_name` | String | — | `LoginActivity.business_name` | LCO/MSO business name |
| `employeeParentId` | String | — | `LoginActivity.employeeParentId` | Parent entity ID (used in access control API) |
| `employeeParentType` | String | — | `LoginActivity.employeeParentType` | Parent entity type (used in access control API) |
| `deposit_amount` | double | 0.0 | `LoginActivity.deposit_amount` | LCO's wallet/deposit balance |

#### Location Default Fields
| Field | Java Type | Default | Static Variable | Description |
|-------|-----------|---------|-----------------|-------------|
| `defaultCountry` | String | — | `LoginActivity.defaultcountry` | Default country code for new customer forms |
| `defaultState` | int | — | `LoginActivity.defaultstate` | Default state ID for new customer forms |
| `defaultDistrict` | int | — | `LoginActivity.defaultdistrict` | Default district ID for new customer forms |
| `defaultCity` | int | — | `LoginActivity.defaultcity` | Default city ID for new customer forms |

#### Feature Flag Fields — Full Exhaustive List
| Field | Java Type | Default | Static Variable | Behavior Effect |
|-------|-----------|---------|-----------------|-----------------|
| `useCRF` | int | 0 | `LoginActivity.useCRF` | If 1: enable Customer Registration Form (CRF) flow |
| `useCAF` | String | — | `LoginActivity.useCAF` | If not empty/0: enable Customer Activation Form (CAF) |
| `useLastName` | int | 0 | `LoginActivity.useLastName` | If 1: show last name field in customer creation form |
| `useDiscount` | int | 0 | `LoginActivity.useDiscount` | If 1: enable discount field in payment/billing screens |
| `useDataFromMasterTable` | int | 0 | `LoginActivity.useDataFromMasterTable` | If 1: load location/type data from master tables via API instead of hardcoded defaults |
| `useMandatoryForHotel` | int | 0 | `LoginActivity.useMandatoryForHotel` | If 1: make hotel-specific fields mandatory in customer form |
| `useAccountNumber` | int | 0 | `LoginActivity.useAccountNumber` | If 1: show account number field in customer form |
| `freezecustomerparamsinapp` | int | 0 | `LoginActivity.freezecustomerparamsinapp` | If 1: make customer fields read-only in edit mode (prevent changes from app) |
| `blockpayment` | int | 0 | `LoginActivity.hidemakepayment` | If 1: hide/block the "Make Payment" option entirely |
| `lco_billtype` | int | 0 | `LoginActivity.lco_billtype` | LCO billing type identifier (passed to dashboard and report APIs) |
| `use_lco_deposits` | String/int | — | `LoginActivity.userLcoDeposit` | Also mapped as `useLcoDeposit`; if 1: show LCO wallet/deposit features |
| `customer_billtype` | int | 0 | `LoginActivity.customerbilltype` | Customer billing type; affects which bill format to display |
| `AUTO_RECEIPT_NUMBER` | int | 1 | `LoginActivity.AUTO_RECEIPT_NUMBER` | If 1: auto-generate receipt numbers (hide manual receipt entry field); if 0: require manual input |
| `CURRENCY_CODE` | String | `"₹"` | `LoginActivity.CURRENCY_CODE` | Currency symbol displayed throughout the app; also exposed as `EzyBillConstants.RUPEES_SIGN` |
| `allow_top_up` | int | 1 | `LoginActivity.allow_top_up` | If 1: show LCO wallet top-up menu/button; if 0: hide wallet top-up feature |
| `show_caf_mobile_validation` | int | 0 | `LoginActivity.show_caf_mobile_validation` | If 1: show OTP mobile validation popup during new CAF (customer) creation |
| `stb_pairing` | int | 0 | `LoginActivity.stb_pairing` | If 1: enable STB pairing feature in STB management |
| `stb_unpairing` | int | 0 | `LoginActivity.stb_unpairing` | If 1: enable STB unpairing feature in STB management |
| `show_mia_agreement_upload` | int | 0 | `LoginActivity.show_mia_agreement_upload` | If 1: show MIA (Minimum Infrastructure Agreement) document upload section |
| `show_serial_vc` | int | — | — | If 1: show serial number and VC number fields (mentioned in REST API doc; not parsed in current Android code — likely newer field) |
| `show_service_extension` | int | — | — | If 1: show service extension option (mentioned in REST API doc; newer field) |
| `edit_quantity` | int | — | — | If 1: allow editing package quantity; if 0: quantity is fixed |
| `enable_box_wise_payment` | int | — | — | If 1: allow payments to be applied at individual STB box level |
| `baid_label` | String | — | — | Custom label text for the "BAID" (Billing Account ID) field throughout the app |
| `is_direct_lco` | int | 0 | `LoginActivity.is_direct_lco` | If 1: user is a direct LCO (not under a distributor); affects billing and menu access |
| `access_distributor_wise` | int | 0 | `LoginActivity.access_distributor_wise` | If 1: filter/scope data display to distributor-assigned customers only |
| `is_unpaidlco` | int | — | — | If 1: LCO has unpaid dues; may trigger warning or payment prompts |
| `appMenuFormat` | String | `""` | `LoginActivity.menuType` | Controls which menu layout/format to render (operator-customized menu structure) |
| `invoicepaymentsearchlimit` | int | — | — | Maximum number of records returned in invoice/payment search results |
| `lcoMobileNo` | int | — | `LoginActivity.lcoMobileNo` | LCO's registered mobile number flag |
| `patch_information` | String | `"1.4.13.2"` | `LoginActivity.patch_information` | Server patch version string; shown in app info or used for version-gated features |
| `recurringServiceEdit` | int | — | `LoginActivity.recurringService` | If 1: allow editing recurring service parameters |
| `showLcoComplaint` | int | — | — | If 1: show LCO complaint management section |
| `lcoCode` | String | — | — | LCO's own code identifier |
| `lcoLocation` | String | — | — | LCO's location name |
| `userNotifications` | — | — | — | Notification messages list |
| `notifyCount` | int | — | — | Count of pending notifications |
| `note_duration` | int | — | — | Duration to display notification banner |
| `accept_terms_condtions` | int | 0 | `LoginActivity.accept_terms_condtions` | If 1: user must accept T&C before proceeding |
| `agreement_details_count` | int | 0 | `LoginActivity.agreement_details_count` | Count of pending agreement documents to accept |
| `user_image` | String | — | — | URL of the user's profile image |
| `config_values_array` | JSON Array | — | — | See Section 4 below |

#### `config_values_array` — Structure and Usage
This is a JSON array returned from `validateLogin` containing dynamic key-value configuration pairs. Each element in the array is an object with at minimum:
- A key identifier (e.g., config name)
- A value (string or int)

The array is used to pass additional operator-level configuration that doesn't fit the fixed response fields. In Flutter, parse this into a `Map<String, dynamic>` and store in the session provider. Exact keys used depend on the operator's server configuration.

### 2.4 Access Control Flags — `getaccesscontrollRest`

**Endpoint:** `POST /LcoRestServices/getaccesscontrollRest`
**Called:** After successful login (before navigating to main screen)
**Request Payload:**

| Field | Source |
|-------|--------|
| `employeeParentType` | `LoginActivity.employeeParentType` |
| `dealer_id` | `LoginActivity.dealerId` |
| `userstype` | `LoginActivity.userType` |
| `employeeParentId` | `LoginActivity.employeeParentId` |
| `authToken` | `LoginActivity.authToken` |

**Response Access Control Flags:**

| Flag | Java Type | Default | Static Variable | UI Effect |
|------|-----------|---------|-----------------|-----------|
| `report` | — | — | — | Controls access to report section |
| `int_bulk_payment` | int | 1 | `LoginActivity.int_bulk_payment` | If 0: hide bulk payment option |
| `invoice_page_access` | int | 1 | `LoginActivity.invoice_page_access` | If 0: hide invoice listing page |
| `payment_hist_page_access` | int | 1 | `LoginActivity.payment_hist_page_access` | If 0: hide payment history page |
| `access_for_complaints` | int | 1 | `LoginActivity.access_for_complaints` | If 0: hide complaints management section |
| `int_stb_activation` | int | 1 | `LoginActivity.int_stb_activation` | If 0: hide STB activation option |
| `int_stb_deactivation` | int | 1 | `LoginActivity.int_stb_deactivation` | If 0: hide STB deactivation option |
| `int_stb_reactivation` | int | 1 | `LoginActivity.int_stb_reactivation` | If 0: hide STB reactivation option |

**Note:** All flags default to `1` (access granted) in `LoginActivity` static initializers. If the server returns 0, the feature is hidden/blocked. This is a deny-by-exception model — features are shown by default unless the server explicitly disables them.

### 2.5 SharedPreferences Storage After Login

The app uses two SharedPreferences stores:

#### Store 1: `"bmsSharedPref"` (`EzyBillConstants.BMS_SHARED_PREF`)
Used for cloud auth / device-level persistence (survives across login sessions):

| Key Constant | Key String | Type | Value Stored |
|--------------|------------|------|--------------|
| `EzyBillConstants.LOGIN_URL` | `"login_url"` | String | Operator server URL (from `CloudAuthResponse.ipAddress`) |
| `EzyBillConstants.EMP_ID` | `"emp_id"` | String | Employee ID from cloud auth |
| `EzyBillConstants.APP_THEME_COLOR` | `"appThemeColor"` | int | App theme color code |
| `EzyBillConstants.APP_DASHBOARD` | `"appDashboard"` | int | Dashboard layout variant |
| `EzyBillConstants.APP_LOGO_PATH` | `"appLogoPath"` | String | Logo image URL/path |
| `EzyBillConstants.ENABLE_AADHAAR` | `"enableAadhar"` | int | Aadhaar feature flag |

#### Store 2: `"vidslogin"` (SPF_NAME)
Used for remembering login credentials (only if "Remember Me" checked):

| Key | Type | Value |
|-----|------|-------|
| `"username"` | String | Last used username (cleared if Remember Me unchecked) |

#### Store 3: `"aadhaardetails"`
| Key | Type | Value |
|-----|------|-------|
| `"aadhaardata"` | String | Saved Aadhaar data (purpose unclear from this file alone) |

**Important:** All other session data (authToken, employeeId, dealerId, all config flags) are stored as **static in-memory variables** in `LoginActivity` — NOT in SharedPreferences. They are lost on app kill and re-read from `LoginActivity.*` static fields throughout the app.

**Flutter Migration:** Replace `LoginActivity` static fields with a proper state management solution (e.g., `Provider`, `Riverpod`, or `Bloc`). Persist the session token and critical config flags to `SharedPreferences` or `flutter_secure_storage` so they survive hot restarts.

---

## Section 3: Master Data Models

This section documents every field in every master data model class. These are the exact field names, types, and SOAP property names required for REST response parsing in Flutter.

### 3.1 Request/Authentication Models (SOAP Request Classes)

These implement `KvmSerializable` — they represent **outbound request payloads** for SOAP calls. In Flutter (REST), these become request body objects.

#### `ValidateLoginInfo` — Login Request
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `UserName` | `"UserName"` | String | Login username |
| 1 | `PassWord` | `"PassWord"` | String | Login password |
| 2 | `employeeId` | `"employeeId"` | int | Employee ID (pre-auth, may be 0) |
| 3 | `imei` | `"imei"` | String | Device IMEI number |

#### `Validateauth` — SMS/OTP Authentication Request
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `smsCode` | `"smsCode"` | String | OTP/SMS code received |
| 1 | `imei` | `"imei"` | String | Device IMEI |
| 2 | `appTypeId` | `"appTypeId"` | int | App type identifier |
| 3 | `imeivalidNo` | `"imeiValidNumber"` | int | IMEI validation number |

#### `validateAuthenticationInfo` — Duplicate of `Validateauth`
Identical structure to `Validateauth`. Both classes exist in codebase. Flutter should use a single `AuthRequest` model.

| Index | Java Field | SOAP Name | Java Type |
|-------|-----------|-----------|-----------|
| 0 | `smsCode` | `"smsCode"` | String |
| 1 | `imei` | `"imei"` | String |
| 2 | `appTypeId` | `"appTypeId"` | int |
| 3 | `imeivalidNo` | `"imeiValidNumber"` | int |

#### `dashBoard` — Dashboard Data Request
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `authToken` | `"authToken"` | String | Session token |

#### `getIds` — Generic ID List Request
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `authToken` | `"authToken"` | String | Session token |

#### `getGroupsInfo` — Groups Request
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `authToken` | `"authToken"` | String | Session token |
| 1 | `serialNumber` | `"serialNumber"` | String | STB serial number filter |

#### `getServerTerminology` — Server Terminology Labels Request
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `authToken` | `"authToken"` | String | Session token |

#### `lcoLocationsInfo` — LCO Locations Request
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `authToken` | `"authToken"` | String | Session token |

#### `Getlcodeposit` — Get LCO Deposit Request
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `authToken` | `"authToken"` | String | Session token |
| 1 | `dealer_id` | `"dealer_id"` | int | Dealer ID |

**Note:** Bug in original code — `setProperty` for index 0 falls through to index 1 (missing `break`). In Flutter, implement correctly.

#### `checkBoxInfo` — STB/Box Check Request
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `boxNumber` | `"boxNumber"` | String | STB serial/box number |
| 1 | `authToken` | `"authToken"` | String | Session token |

#### `LCOcode_Search_Model` — LCO Code Search Request
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `authToken` | `"authToken"` | String | Session token |
| 1 | `employee_id` | `"employee_id"` | int | Employee ID |
| 2 | `lco_code` | `"lco_code"` | String | LCO code to search |

---

### 3.2 Response/List Item Models

These implement `KvmSerializable` and often `Parcelable` — they represent **response data rows**.

#### `idList` — Generic ID-Name Pair (Parcelable)
Used wherever the server returns a list of ID/name pairs (e.g., payment modes, complaint categories).

| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `id` | `"id"` | int | Numeric identifier |
| 1 | `name` | `"name"` | String | Display name |

**Flutter model:**
```dart
class IdItem {
  final int id;
  final String name;
}
```

#### `groupList` — Package/Subscription Group Item
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `groupId` | `"groupId"` | int | Group identifier |
| 1 | `groupName` | `"groupName"` | String | Group display name |

**Flutter model:**
```dart
class GroupItem {
  final int groupId;
  final String groupName;
}
```

#### `lcoLocationsList` — LCO Location Item
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `locationId` | `"locationId"` | int | Location identifier |
| 1 | `locationName` | `"locationName"` | String | Location display name |
| 2 | `lcoCode` | `"lcoCode"` | String | LCO code for this location |

---

### 3.3 Countries Master Data

#### `countriesInfo` — Request (auth-only)
| Index | Java Field | SOAP Name | Java Type |
|-------|-----------|-----------|-----------|
| 0 | `authToken` | `"authToken"` | String |

#### `countriesList` — Response Row (Parcelable)
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `iso` | `"iso"` | String | ISO 2-letter country code (e.g., `"IN"`) — used as foreign key in states request |
| 1 | `name` | `"name"` | String | Country full name (e.g., `"India"`) |
| 2 | `numcode` | `"numcode"` | int | Numeric country code (e.g., `356`) |

**Flutter model:**
```dart
class Country {
  final String iso;       // PK, used as FK in states
  final String name;
  final int numcode;
}
```

---

### 3.4 States Master Data

#### `statesInfo` — Request
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `authToken` | `"authToken"` | String | Session token |
| 1 | `countryCode` | `"countryCode"` | String | ISO country code (foreign key) |

#### `statesList` — Response Row (Parcelable)
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `id` | `"id"` | int | State numeric ID — PK, used as FK in districts/cities |
| 1 | `name` | `"name"` | String | State name |
| 2 | `country_code` | `"country_code"` | String | Parent country ISO code |
| 3 | `abbrev` | `"abbrev"` | String | State abbreviation |

**Flutter model:**
```dart
class State {
  final int id;           // PK, used as FK
  final String name;
  final String countryCode;
  final String abbrev;
}
```

---

### 3.5 Districts Master Data

#### `districtInfo` — Request
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `stateId` | `"stateId"` | int | Parent state ID |
| 1 | `authToken` | `"authToken"` | String | Session token |

#### `districtList` — Response Row (Parcelable)
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `id` | `"id"` | int | District numeric ID — PK, used as FK in cities/mandals |
| 1 | `name` | `"name"` | String | District name |
| 2 | `iso` | `"iso"` | String | District ISO/code |
| 3 | `state_id` | `"state_id"` | int | Parent state ID (FK) |

**Flutter model:**
```dart
class District {
  final int id;           // PK, used as FK
  final String name;
  final String iso;
  final int stateId;
}
```

---

### 3.6 Cities Master Data

#### `citiesInfo` — Request
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `stateId` | `"stateId"` | int | Parent state ID |
| 1 | `authToken` | `"authToken"` | String | Session token |
| 2 | `boxNumber` | `"boxNumber"` | String | STB box number (context-specific filter) |

#### `citiesList` — Response Row (Parcelable)
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `location_id` | `"location_id"` | int | City/locality numeric ID — PK |
| 1 | `location_name` | `"location_name"` | String | City/locality name |
| 2 | `state_id` | `"state_id"` | int | Parent state ID (FK) |
| 3 | `dealer_id` | `"dealer_id"` | int | Associated dealer ID |
| 4 | `location_code` | `"location_code"` | int | Numeric location code |

**Flutter model:**
```dart
class City {
  final int locationId;    // PK
  final String locationName;
  final int stateId;       // FK → State.id
  final int dealerId;
  final int locationCode;
}
```

---

### 3.7 Mandals Master Data

#### `MandalInfo` — Request
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `districtId` | `"districtId"` | int | Parent district ID |
| 1 | `authToken` | `"authToken"` | String | Session token |

#### `MandalList` — Response Row (Parcelable)
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `district_id` | `"district_id"` | int | Parent district ID (FK) |
| 1 | `mandal_id` | `"mandal_id"` | int | Mandal/sub-district numeric ID — PK |
| 2 | `mandal_name` | `"mandal_name"` | String | Mandal name |

**Flutter model:**
```dart
class Mandal {
  final int districtId;    // FK → District.id
  final int mandalId;      // PK
  final String mandalName;
}
```

---

### 3.8 Genders Master Data

#### `gendersList` — Response Row (Parcelable)
No separate request class — uses `authToken`-only request.

| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `id` | `"id"` | int | Gender numeric ID |
| 1 | `name` | `"name"` | String | Gender label (e.g., `"Male"`, `"Female"`, `"Other"`) |

**Flutter model:**
```dart
class Gender {
  final int id;
  final String name;
}
```

---

### 3.9 Customer Types Master Data

#### `customerTypesInfo` — Request
| Index | Java Field | SOAP Name | Java Type |
|-------|-----------|-----------|-----------|
| 0 | `authToken` | `"authToken"` | String |

#### `customerTypeList` — Response Row
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `customer_type_id` | `"customer_type_id"` | int | Customer type numeric ID — PK |
| 1 | `customer_type` | `"customer_type"` | String | Customer type label (e.g., `"Residential"`, `"Commercial"`) |
| 2 | `is_commercial_multi_box` | `"is_commercial_multi_box"` | int | 1 = this type supports multiple STB boxes (commercial multi-box); 0 = single box |

**Flutter model:**
```dart
class CustomerType {
  final int customerTypeId;      // PK
  final String customerType;
  final int isCommercialMultiBox; // 1 = multi-box allowed
}
```

#### `customerTypeTypesRequest` — Sub-type Request
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `authToken` | `"authToken"` | String | Session token |
| 1 | `resellerId` | `"resellerId"` | int | Reseller/dealer ID |
| 2 | `customerTypeId` | `"customerTypeId"` | int | Parent customer type ID |

#### `customerTypeTypesInfoList` — Sub-type Response Row
| Index | Java Field | SOAP Name | Java Type | Description |
|-------|-----------|-----------|-----------|-------------|
| 0 | `customerTypeTypesId` | `"customerTypeTypesId"` | int | Sub-type numeric ID — PK |
| 1 | `name` | `"name"` | String | Sub-type display name |

---

### 3.10 STB/Box Models

#### `AssignedStbModel` — STB Detail Record (GSON)
Used with Retrofit/GSON (REST). All fields are `String`.

| Field | `@SerializedName` | Description |
|-------|-------------------|-------------|
| `serial_number` | `"serial_number"` | STB serial number |
| `vc_number` | `"vc_number"` | Viewing card number |
| `is_active` | `"is_active"` | `"1"` = active, `"0"` = inactive |
| `activate_date` | `"activate_date"` | Date STB was activated |
| `is_assigned` | `"is_assigned"` | `"1"` = assigned to customer, `"0"` = unassigned |
| `assigned_date` | `"assigned_date"` | Date assigned to customer |
| `customer_name` | `"customer_name"` | Name of assigned customer |
| `cas` | `"cas"` | CAS (Conditional Access System) name/type |
| `installation_address` | `"installation_address"` | Installation location address |

#### `ExpiredCountModel` — Expiry Count Record (Parcelable)
Used for dashboard expiry summary bar charts.

| Field | Java Type | Description |
|-------|-----------|-------------|
| `service_end_date` | String | Date when services expire |
| `stb_count` | String | Number of STBs expiring on that date |

---

## Section 4: Global App Config Values (CRITICAL — Flutter Migration Reference)

This section provides the definitive reference for every server-driven configuration flag. These must all be stored in Flutter's session state on login and used consistently across the app.

### 4.1 Master Config Table

| Flag Name | Source | Java Type | Default | Flutter Type | Behavior When Enabled (=1 or non-empty) |
|-----------|--------|-----------|---------|--------------|------------------------------------------|
| `useCRF` | `validateLogin` | int | 0 | `int` | Show Customer Registration Form flow; affects new customer creation screen |
| `useCAF` | `validateLogin` | String | `""` | `String` | Non-empty = show Customer Activation Form; content may indicate CAF type |
| `useLastName` | `validateLogin` | int | 0 | `int` | Show "Last Name" field in customer form |
| `useDiscount` | `validateLogin` | int | 0 | `int` | Show discount input field in billing/payment screens |
| `useDataFromMasterTable` | `validateLogin` | int | 0 | `int` | Fetch location dropdowns (country/state/district/city) from server API; if 0 use hardcoded or cached data |
| `useMandatoryForHotel` | `validateLogin` | int | 0 | `int` | Make additional fields mandatory for hotel/commercial customer type |
| `useAccountNumber` | `validateLogin` | int | 0 | `int` | Show "Account Number" field in customer creation/edit |
| `freezecustomerparamsinapp` | `validateLogin` | int | 0 | `int` | Make all customer profile fields read-only in the app (edit blocked) |
| `blockpayment` | `validateLogin` | int | 0 | `int` | Hide/disable "Make Payment" button throughout the app |
| `appMenuFormat` | `validateLogin` | String | `""` | `String` | Operator-defined menu layout identifier; controls which menu tabs/items appear |
| `invoicepaymentsearchlimit` | `validateLogin` | int | — | `int` | Max records in invoice/payment search results pagination |
| `lco_billtype` | `validateLogin` | int | 0 | `int` | LCO billing type: passed to `dashBoardDetailsRest` and report APIs; affects which bill calculation is shown |
| `use_lco_deposits` / `useLcoDeposit` | `validateLogin` | int | 0 | `int` | Show LCO wallet/deposit balance on dashboard; enable wallet-related screens |
| `customer_billtype` | `validateLogin` | int | 0 | `int` | Customer billing type identifier; affects customer bill display format |
| `AUTO_RECEIPT_NUMBER` | `validateLogin` | int | 1 | `int` | 1 = auto-generate receipt number (hide manual receipt field); 0 = user must enter receipt number manually |
| `CURRENCY_CODE` | `validateLogin` | String | `"₹"` | `String` | Currency symbol prefix used across all monetary displays; default Indian Rupee |
| `allow_top_up` | `validateLogin` | int | 1 | `int` | 1 = show wallet top-up menu/button; 0 = hide entire wallet top-up feature |
| `show_caf_mobile_validation` | `validateLogin` | int | 0 | `int` | 1 = trigger OTP mobile validation popup when creating new customer via CAF |
| `stb_pairing` | `validateLogin` | int | 0 | `int` | 1 = show STB pairing option in STB management screen |
| `stb_unpairing` | `validateLogin` | int | 0 | `int` | 1 = show STB unpairing option in STB management screen |
| `show_mia_agreement_upload` | `validateLogin` | int | 0 | `int` | 1 = show MIA document upload UI section |
| `show_serial_vc` | `validateLogin` (REST) | int | — | `int` | 1 = show serial number and VC number columns in STB list |
| `show_service_extension` | `validateLogin` (REST) | int | — | `int` | 1 = show "Extend Service" option in customer service list |
| `edit_quantity` | `validateLogin` (REST) | int | — | `int` | 1 = allow changing package quantity during service activation/renewal |
| `enable_box_wise_payment` | `validateLogin` (REST) | int | — | `int` | 1 = enable STB-level (box-wise) payment allocation |
| `baid_label` | `validateLogin` (REST) | String | — | `String` | Custom label to replace the default "BAID" text in the UI |
| `is_direct_lco` | `validateLogin` | int | 0 | `int` | 1 = user is a direct LCO (affects billing flow, may bypass distributor menus) |
| `access_distributor_wise` | `validateLogin` | int | 0 | `int` | 1 = scope all data queries to distributor-assigned customers only |
| `is_unpaidlco` | `validateLogin` (REST) | int | — | `int` | 1 = LCO has unpaid dues; may show warning banner or block certain actions |
| `patch_information` | `validateLogin` | String | `"1.4.13.2"` | `String` | Server patch version; shown in about screen; may gate version-specific features |
| `recurringServiceEdit` | `validateLogin` | int | — | `int` | 1 = allow editing recurring service end dates or params |
| `showLcoComplaint` | `validateLogin` | int | — | `int` | 1 = show complaint management tab/section |
| `accept_terms_condtions` | `validateLogin` | int | 0 | `int` | 1 = force T&C acceptance screen before main app loads |
| `agreement_details_count` | `validateLogin` | int | 0 | `int` | Count of unsigned agreement documents; show document signing flow if > 0 |
| `config_values_array` | `validateLogin` (REST) | JSON Array | `[]` | `List<Map>` | Dynamic key-value config pairs; parse into a map for runtime feature gating |
| `int_bulk_payment` | `getaccesscontrollRest` | int | 1 | `int` | 0 = hide bulk payment feature |
| `invoice_page_access` | `getaccesscontrollRest` | int | 1 | `int` | 0 = hide invoice listing page |
| `payment_hist_page_access` | `getaccesscontrollRest` | int | 1 | `int` | 0 = hide payment history page |
| `access_for_complaints` | `getaccesscontrollRest` | int | 1 | `int` | 0 = hide complaints section |
| `int_stb_activation` | `getaccesscontrollRest` | int | 1 | `int` | 0 = hide STB activation option |
| `int_stb_deactivation` | `getaccesscontrollRest` | int | 1 | `int` | 0 = hide STB deactivation option |
| `int_stb_reactivation` | `getaccesscontrollRest` | int | 1 | `int` | 0 = hide STB reactivation option |

### 4.2 Suggested Flutter Session Model

```dart
class AppSession {
  // Identity
  final String authToken;
  final int employeeId;
  final String employeeName;
  final String businessName;
  final int dealerId;
  final String userType;
  final String employeeParentId;
  final String employeeParentType;
  final double depositAmount;

  // Location defaults (for new customer forms)
  final String defaultCountry;
  final int defaultState;
  final int defaultDistrict;
  final int defaultCity;

  // Customer form flags
  final int useCRF;
  final String useCAF;
  final int useLastName;
  final int useDiscount;
  final int useDataFromMasterTable;
  final int useMandatoryForHotel;
  final int useAccountNumber;
  final int freezecustomerparamsinapp;
  final int showCafMobileValidation;

  // Billing/payment flags
  final int autoReceiptNumber;       // AUTO_RECEIPT_NUMBER
  final String currencyCode;         // CURRENCY_CODE, default "₹"
  final int blockpayment;
  final int lcoBilltype;
  final int useLcoDeposit;
  final int customerBilltype;
  final int enableBoxWisePayment;
  final int intBulkPayment;          // from getaccesscontrollRest

  // STB flags
  final int stbPairing;
  final int stbUnpairing;
  final int showSerialVc;
  final int intStbActivation;        // from getaccesscontrollRest
  final int intStbDeactivation;      // from getaccesscontrollRest
  final int intStbReactivation;      // from getaccesscontrollRest

  // Wallet/topup flags
  final int allowTopUp;
  final int isDirectLco;
  final int isUnpaidLco;

  // Page access flags (from getaccesscontrollRest)
  final int invoicePageAccess;
  final int paymentHistPageAccess;
  final int accessForComplaints;

  // UI/display flags
  final String appMenuFormat;
  final String baidLabel;
  final int editQuantity;
  final int showServiceExtension;
  final int showMiaAgreementUpload;
  final int accessDistributorWise;
  final int invoicePaymentSearchLimit;
  final int showLcoComplaint;
  final int recurringServiceEdit;

  // Onboarding/agreement
  final int acceptTermsConditions;
  final int agreementDetailsCount;

  // Misc
  final String patchInformation;
  final List<Map<String, dynamic>> configValuesArray;
  final int lcoMobileNo;
}
```

### 4.3 Config Evaluation Quick Reference

| Screen / Feature | Controlling Flag(s) |
|-----------------|---------------------|
| New Customer — Last Name field | `useLastName == 1` |
| New Customer — Account Number field | `useAccountNumber == 1` |
| New Customer — CAF section | `useCAF` is non-empty / non-zero |
| New Customer — CRF flow | `useCRF == 1` |
| New Customer — Mandatory hotel fields | `useMandatoryForHotel == 1` |
| New Customer — Mobile OTP popup | `showCafMobileValidation == 1` |
| Customer Edit — Read-only mode | `freezecustomerparamsinapp == 1` |
| Payment — Hide "Make Payment" | `blockpayment == 1` (= `hidemakepayment == 1`) |
| Payment — Auto receipt number | `autoReceiptNumber == 1` |
| Payment — Discount field | `useDiscount == 1` |
| Payment — Box-wise payment | `enableBoxWisePayment == 1` |
| Payment — Bulk payment | `intBulkPayment == 1` |
| Invoice page | `invoicePageAccess == 1` |
| Payment history page | `paymentHistPageAccess == 1` |
| Complaints section | `accessForComplaints == 1` |
| STB Activation | `intStbActivation == 1` |
| STB Deactivation | `intStbDeactivation == 1` |
| STB Reactivation | `intStbReactivation == 1` |
| STB Pairing | `stbPairing == 1` |
| STB Unpairing | `stbUnpairing == 1` |
| STB Serial / VC display | `showSerialVc == 1` |
| Wallet Top-Up menu | `allowTopUp == 1` |
| LCO Wallet/Deposit feature | `useLcoDeposit == 1` |
| Dashboard — LCO deposit mode | `lcoBilltype` and `useLcoDeposit` passed to dashboard API |
| Location dropdowns via API | `useDataFromMasterTable == 1` |
| Service Extension option | `showServiceExtension == 1` |
| Edit package quantity | `editQuantity == 1` |
| MIA Agreement upload | `showMiaAgreementUpload == 1` |
| T&C acceptance screen | `acceptTermsConditions == 1` |
| Agreement signing flow | `agreementDetailsCount > 0` |
| Distributor-scoped data | `accessDistributorWise == 1` |
| Direct LCO billing mode | `isDirectLco == 1` |
| Unpaid LCO warning | `isUnpaidLco == 1` |
| Recurring service edit | `recurringServiceEdit == 1` |
| Complaints for LCO | `showLcoComplaint == 1` |
| Currency symbol everywhere | `currencyCode` (default `"₹"`) |
| Custom BAID label | `baidLabel` (replace default "BAID" text) |
| Search results limit | `invoicePaymentSearchLimit` |
| Menu layout variant | `appMenuFormat` |

---

## Appendix: SOAP → REST Endpoint Mapping

| Feature | Android SOAP Method | Flutter REST Endpoint |
|---------|--------------------|-----------------------|
| Login | `validatelogin` (SOAP) | `POST /LcoRestServices/validateLogin` |
| Access Control | SOAP-based `getaccesscontrollRest` | `POST /LcoRestServices/getaccesscontrollRest` |
| Dashboard | `getDashBoardDetails` (SOAP) | `POST /LcoRestServices/dashBoardDetailsRest` |
| LCO Deposit Amount | SOAP | `POST /LcoRestServices/lco_deposit_amountRest` |
| LCO Wallet History | REST (Volley) `getlcowalletRest` | `POST /LcoRestServices/getlcowalletRest` |
| LCO Advance/Due Search | `getlcoadvanceamountdue` (SOAP) | Check REST API doc for equivalent |
| LCO Payment Save | `lcopaymentfunc` (SOAP) | Check REST API doc for equivalent |
| Countries | SOAP | Likely available via master data REST endpoint |
| States | SOAP | Likely available via master data REST endpoint |
| Districts | SOAP | Likely available via master data REST endpoint |
| Cities | SOAP | Likely available via master data REST endpoint |
| Mandals | SOAP | Likely available via master data REST endpoint |
| Genders | SOAP | Likely available via master data REST endpoint |
| Customer Types | SOAP | Likely available via master data REST endpoint |
| Groups | SOAP `getGroups` | Likely available via REST |

**Note:** LCO payment SOAP endpoints (`getlcoadvanceamountdue`, `lcopaymentfunc`) were not found in the REST API document at time of analysis. Verify with server team whether REST equivalents exist or if SOAP must be maintained via HTTP XML calls during migration.
