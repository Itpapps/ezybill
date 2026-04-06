# Android Business Logic: STB Operations, Complaints, Login, Dashboard & Core Screens

> Extracted line-by-line from the Android EzyBill source. Every validation, business rule, config flag check, and restriction is documented below for Flutter replication.

---

## 1. STB / Box Operations (`Box_Operations_Fragment`)

### 1.1 Bundle Parameters Received
The fragment receives these parameters from the calling screen (customer search list):
- `custId` (String, parsed to int)
- `custName` (String)
- `sNo` (serial number)
- `vcNo` (VC number)
- `boxNo` (box number)
- `macAdd` (MAC address)
- `stockId` (String, parsed to int)
- `devId` (device ID, parsed to int)
- `stockStatus` (String, parsed to int: 1=Active, 2=Deactive)
- `backSetupId` (backend setup ID, parsed to int)
- `reqOrigin` (request origin string)
- `is_temp_deactivated` (int, 0 or 1)
- `resellerid` (int, default 0)

### 1.2 STB Status Display Logic
```
if (stat_stb == 1):
    Status text = "ACTIVE"
    Activate button: DISABLED (greyed out)
    Deactivate button: ENABLED
    Reactivate button: ENABLED

if (stat_stb == 2):
    if (is_temp_deactivated == 0):
        Status text = "DE-ACTIVE"
    else:
        Activate button text changes to "Temporary Activate STB"
        Status text = "TEMPORARY DE-ACTIVE"
    Deactivate button: DISABLED
    Reactivate button: DISABLED
    Activate button: ENABLED
```

### 1.3 Button Visibility (Config Flag Gating)
| Button | Config Flag | Condition |
|--------|------------|-----------|
| Deactivate | `LoginActivity.int_stb_deactivation` | `== 1` -> VISIBLE, else INVISIBLE |
| Reactivate | `LoginActivity.int_stb_reactivation` | `== 1` -> VISIBLE, else INVISIBLE |
| Activate | `LoginActivity.int_stb_activation` | `== 1` -> VISIBLE, else INVISIBLE |

**Flutter must replicate:** These three flags come from `getaccesscontrollRest` (access control API). Default value for all three is `1`.

### 1.4 Deactivation Flow

#### Pre-checks
1. Internet connectivity check (`isNetworkAvailable()`)
2. If no network: shows alert "Please turn on Wifi or Data Network"
3. If network OK: opens deactivation dialog (`showDialog()`)

#### Deactivation Dialog
- Spinner for reason selection (populated by `ReasonValues` SOAP call)
- EditText for remarks
- "Deactivate" button and "Close" button

#### Remarks Suffix Logic (CRITICAL)
```
if (remarks field is empty):
    str_remarks = "Box Deactivation from Android app"
else:
    str_remarks = userText + ". Box Deactivation from Android app"
```
**Flutter equivalent:** Always append `.Box Deactivation from Android app` (or Flutter equivalent suffix).

#### Reason Loading (`ReasonValues` AsyncTask) -- SOAP: `getDeactivateReasons`
- Sends: `authToken` only
- Response: array of `reasonList` objects, each with:
  - `reasonId` (int)
  - `reasonName` (string)
  - `global_reason` (int, default 0 on parse error)
  - `disable_for_dpo` (int, default 0 on parse error)

#### Reason ID 17 Exclusion (ACTIVE CODE)
The active (uncommented) code filters out reason ID 17:
```java
// First pass: count items with id==17
for each reason:
    if (id == 17): items_length++

// Second pass: create array excluding id==17
items = new Reason_val[listLength - items_length]
for each reason:
    if (id == 17): skip
    else: add to items array
```
**Flutter must replicate:** Exclude any deactivation reason with `reasonId == 17` from the dropdown.

#### Commented-Out Advanced Filtering (NOT ACTIVE but shows intended logic)
The commented code shows additional filtering that WAS planned:
- `global_reason == 1`: Only show reasons where global_reason is 1
- `disable_for_dpo == 0` AND `is_direct_lco_from_search == 1` AND `id != 17`: Show
- `is_direct_lco_from_search == 0` AND `id != 17`: Show
**Status:** This code is commented out. The active code only excludes ID 17. However, the REST V2 API may handle this server-side. Verify with backend.

#### Deactivate Box SOAP Call (`DeactivateSTB`)
Parameters sent in `deactivateBox` complex object:
| Field | Value |
|-------|-------|
| `authToken` | `LoginActivity.authToken` |
| `serialNumber` | `str_stbNo` |
| `vcNumber` | `str_vcNo` |
| `boxNumber` | `str_boxNumber` |
| `macAddress` | `str_macAddress` |
| `stockId` | `int_stockId` |
| `deviceId` | `int_deviceId` |
| `backEndSetupId` | `int_backendSetupId` |
| `reasonId` | selected `reasonId` from spinner |
| `remarks` | `str_remarks` (with suffix) |
| `customer_id` | `int_custId` |
| `dealer_id` | `LoginActivity.dealerId` |
| `reseller_id` | `reselleerid` (from bundle) |
| `from_mobileapp` | **`1` (hardcoded)** |

#### Deactivation Response Handling
- Parses: `statusCode`, `statusMessage`, `is_temp_deactivated`
- `statusCode == 0`: Success
  - If `is_temp_deactivated == 0`: shows "DE-ACTIVE"
  - If `is_temp_deactivated == 1`: shows "TEMPORARY DE-ACTIVE", changes activate button text to "Temporary Activate STB"
  - Enables activate button, disables deactivate + reactivate
- `statusCode == 1`: Shows `statusMessage + ". Please contact our support team."` titled "Deactivation Failed!"
- `statusCode >= 2`: Shows `statusMessage + ". Please contact our support team."` titled "Activation Failed!" (copy-paste error in Android -- use "Deactivation Failed" in Flutter)

### 1.5 Reactivation Flow

#### Pre-checks
1. Internet connectivity check
2. Confirmation dialog: "Are you sure to REACTIVATE this STB?" with OK/Cancel

#### Reactivate Box SOAP Call (`ReactivateSTB`)
Parameters sent in `reactivateBox` complex object:
| Field | Value |
|-------|-------|
| `authToken` | `LoginActivity.authToken` |
| `serialNumber` | `str_stbNo` |
| `boxNumber` | `str_boxNumber` |
| `macAddress` | `str_macAddress` |
| `stockId` | `int_stockId` |
| `deviceId` | `int_deviceId` |
| `backEndSetupId` | `int_backendSetupId` |
| `reinitialize` | **`1` (hardcoded)** |

**Note:** `vcNumber` is NOT sent for reactivation (unlike deactivation). `customer_id`, `dealer_id`, `reseller_id`, `reasonId`, `remarks`, `from_mobileapp` are also NOT sent.

#### Response Handling
- `statusCode == 0`: "STB reactivated successfully"
- `statusCode == 1`: `statusMessage + ". Please contact our support team."` -- "Reactivation Failed!"
- `statusCode >= 2`: Same pattern -- "Reactivation Failed!"

### 1.6 Temporary Activation Flow

#### Trigger Condition
When `stat_stb == 2` AND `is_temp_deactivated == 1`, the activate button text becomes "Temporary Activate STB". Clicking it triggers `TempActivatingPackage` **immediately with NO confirmation dialog**.

**CRITICAL Flutter rule:** Temporary activation fires immediately on tap. No confirmation popup. This is different from regular activation (which shows a confirmation) and reactivation (which also shows a confirmation).

#### Temp Activate SOAP Call (`TempActivatingPackage`)
Parameters sent in `activateService` complex object:
| Field | Value |
|-------|-------|
| `authToken` | `LoginActivity.authToken` |
| `customerId` | `int_custId` |
| `access_key` | `""` (empty string) |
| `stockId` | `int_stockId` |

**Note:** Only `customerId` and `stockId` are the meaningful params. Minimal payload compared to deactivation.

#### Response Handling
- `statusCode == 0`: "STB activated successfully" -- pops back stack
- `statusCode == 1`: `statusMessage` -- "Activation aborted!"
- `statusCode >= 2`: `statusMessage` -- "Activation aborted!"

### 1.7 Regular Activation Flow
When `stat_stb == 2` AND `is_temp_deactivated == 0`, clicking activate shows confirmation dialog: "You will be redirected to Package Activation operation. Do you want to continue?" then navigates to `FragActive_plan` fragment with bundle:
- `custId`: int_custId
- `boxNo`: str_boxNumber
- `custDevId`: int_deviceId
- `custStockId`: int_stockId
- `actt`: 1

This redirects to the package activation screen, not a direct API call.

---

## 2. STB Pair/Unpair (`StbPairUnpair`)

### 2.1 Tab Visibility (Config Flag Gating)
```
if (LoginActivity.stb_unpairing == 1):
    Show unpair tab, hide pair tab initially
    Unpair tab text: blue color (active)

if (LoginActivity.stb_pairing == 1):
    Show pair tab, hide unpair tab
    Pair tab text: blue color (active)

if (stb_pairing == 0): Hide pair tab entirely (ll_pair1 GONE, ll_pair GONE, v1 GONE)
if (stb_unpairing == 0): Hide unpair tab entirely (ll_unpair1 GONE, ll_unpair GONE, v2 GONE)
```

**Flutter must replicate:** Both `stb_pairing` and `stb_unpairing` flags from login response control visibility. If both are 1, pair tab shows first. The nav menu item "Pair/Unpair" only appears if `stb_pairing == 1 || stb_unpairing == 1`.

### 2.2 STB Pair Flow

#### Validation
- Both serial number AND VC number must be non-empty (length >= 1)
- Error: "Please enter Serial/VC number"

#### Confirmation Dialog
"Are You sure, You want to Pair Serial number - {serial} with VC Number - {vc} ?"

#### SOAP Call (`StbPairInfo1`)
Property name: `getPairedInfo`
| Field | Value |
|-------|-------|
| `authToken` | `LoginActivity.authToken` |
| `serialNumber` | text from `ed_pairserial` |
| `vcNumber` | text from `ed_pairvc` |

#### Response
- `statusCode == 0`: Clear fields, show success, navigate to MainActivity(frgToLoad=0) (dashboard)
- `statusCode == 1`: Clear fields, show "Fail!!"
- `statusCode >= 2`: Show "Contact Support!!"

### 2.3 STB Unpair Flow

#### Validation
- Serial number must be non-empty (length >= 1)
- Error: "Please enter Serial number"

#### Confirmation Dialog
"Are You sure, You want to UnPair Serial number - {serial} ?"

#### SOAP Call (`StbUnpair1`)
Property name: `getUnPairedInfo`
| Field | Value |
|-------|-------|
| `authToken` | `LoginActivity.authToken` |
| `serialNumber` | text from `ed_unpairvcserial` |

**Note:** Unpair sends ONLY `serialNumber`. No `vcNumber`.

#### Response
- Same pattern as pair: 0=success(navigate to dashboard), 1=fail, >=2=contact support

### 2.4 Barcode Scanner Integration
No barcode scanner in `StbPairUnpair` itself. However, `MainActivity` has barcode scanner (`ScannerFrag`) accessible from toolbar icon. The scanner is used for customer search, not directly for pair/unpair. STB pair/unpair fields are manual entry only.

---

## 3. Complaints

### 3.1 Create Complaint (`Complaint_NewComplint_Fragment`)

#### Bundle Parameters
- `custId` (int)
- `reseller_id` (int, default 0)
- `custname` (String)

#### On Load
1. Load complaint categories via SOAP (`ComplaintCategoriesList`)
2. If `patch_information` is "1.4.13.2", "1.4.13.3", or "1.4.13.4": also load employee list (`emplistcategory()` REST call)

#### Category Loading (SOAP -- `complaintCategoriesRest` equivalent)
- Sends: `authToken`
- Returns: array of `complaintCategories` with `categoryId` and `categoryName`
- Populates `spin_complaintCat` spinner

#### Category Selection Handler
When a category is selected:
1. Sets complaint description EditText to `CategoriesName`
2. Resets `selstateid = 0`
3. If `patch_information` is "1.4.13.2"/"1.4.13.3"/"1.4.13.4": calls `complaintsubcategory()` REST endpoint

#### Subcategory Loading (REST -- `getComplaintsubCategory`)
- **URL:** `{baseUrl}/getComplaintsubCategory` (from property `cscate`)
- **Method:** POST
- **Params:**
  - `authtoken`: LoginActivity.authToken
  - `complaintcategory`: selected `CategoriesIdValue`
  - `dealer_id`: LoginActivity.dealerId
- **Response:** JSON with `status_code`, `status_msg`, `complaintSubCategories` (JSON array)
  - Each subcategory: `complaint_category_id`, `complaint_category_name`
- **status_code 0:** Populate subcategory spinner, make visible
- **status_code 1:** Toast "No subcategories found for selected category", hide subcategory layout

#### Subcategory Selection
- When subcategory selected (selstateid > 0): sets complaint description to subcategory name
- `selstateid` stores the selected subcategory ID

#### Employee List Loading (REST -- `getLcoEmployeeList`)
- **URL:** `{baseUrl}/getLcoEmployeeList` (from property `glel`)
- **Method:** POST
- **Params:**
  - `authtoken`: LoginActivity.authToken
  - `dealer_id`: LoginActivity.dealerId
  - `employee_id`: `reseller_id` (from bundle, NOT LoginActivity.employeeId)
- **Response:** JSON with `status_code`, `status_msg`, `lcoEmployeelist` (JSON array)
  - Each employee: `lco_employee_id`, `lco_employee_name`
- Adds "select" as first item with ID 0
- **status_code 0:** Populate employee spinner, make visible
- **status_code 1:** Toast "No employee details found", hide employee layout, set `selempid = 0`

#### Gating for subcategory + employee list
**CRITICAL:** Both subcategory and employee list features are ONLY available when:
```
patch_information == "1.4.13.2" OR "1.4.13.3" OR "1.4.13.4"
```
This is a server version gate. Flutter must check the `patch_information` value from login.

#### Complaint Description Suffix (CRITICAL)
```java
str_entercomplaint = et_entercomplint.getText().toString() + ".Complaint Created from Android app";
```
**Flutter must replicate:** Always append `.Complaint Created from Android app` to the complaint description before sending.

#### Submit Validation
- Complaint description must not be empty
- Internet connectivity check

#### Create Complaint SOAP Call (`NewComplaint`)
Property name: `newCompInfo`
| Field | Value |
|-------|-------|
| `customerId` | `altCustId` |
| `authToken` | `LoginActivity.authToken` |
| `complaint` | `str_entercomplaint` (with suffix) |
| `category` | `selstateid > 0 ? selstateid : CategoriesIdValue` |
| `error` | `ErrorId` (from error spinner, if used) |
| `assignedTo` | `selempid` (selected employee, 0 if none) |

**Category selection logic:** If a subcategory is selected (`selstateid > 0`), use subcategory ID. Otherwise use the main category ID.

#### Response Handling
- `statusCode == 0`:
  - If patch_information is "1.4.13.2"/"1.4.13.3"/"1.4.13.4": extracts `ticketNumber` from response
  - Shows success dialog with Category, Complaint text, and Ticket Number (if available)
  - Pops back stack
- `statusCode == 1`: "Complaint registration Failed!" + statusMessage
- `statusCode >= 2`: "Complaint registration Failed!" + statusMessage + "Contact Support"

### 3.2 Complaint Operations (`Complaint_Operations_Fragment`)

Simple navigation fragment. Two actions:
1. **New Complaint**: Navigates to `Complaint_NewComplint_Fragment` with `custId`, `reseller_id`, `custName`
2. **Update Complaint**: Calls `comp_search` SOAP to get customer's complaint list

#### Complaint List SOAP Call
Property name: `compListInfo`
- `altCustomerId`: customer ID
- `authToken`: auth token

Response parses `customerComplaintList` array with fields:
- `customer_id`, `customnumber`, `customer_name`, `group_name`
- `complaint_id`, `tkt_number`, `description`, `complaintTime`, `status`
- `assigned_name`, `assigned_employee_id` (default 0 on parse error)

### 3.3 Close/Update Complaint

**Not found in the files read.** The `ComplaintHistory_Close_Fragment` is a **read-only view** showing closed complaint details (custName, ticketNumber, complaint, status). It has no API calls -- just displays data from bundle.

The actual close/update complaint functionality would be in a different fragment (likely `Complaint_Close_Fragment` or similar). The complaint close API (`closeComplaintRest`) with status spinner, mandatory comment, and service employee is not present in the files provided.

**For Flutter:** Refer to the REST V2 API documentation for close complaint params. The comment suffix pattern would be: `.Complaint Status Change From Android app`.

### 3.4 Complaint Dashboard (`ComplaintDashboard`)

#### API Call (Retrofit)
```java
api.gettotalcomplist(LoginActivity.authToken, LoginActivity.dealerId, LoginActivity.employeeId)
```
- Uses Retrofit (not SOAP, not Volley)
- Response: `totalcomprreq` with `status_code`, `status_msg`, and list of `OpenComplaintsModel`

#### Pagination
- `rowSize = 5` (5 items per page)
- Creates page buttons dynamically
- Highlights current page button

#### Display
- Shows total count: "Total Complaints - {count}"
- Uses `OpenComplaintsAdapter` for list items

### 3.5 Complaint Status Color Mapping
Not explicitly in the files read. The `OpenComplaintsAdapter` would contain the color mapping. Based on standard EzyBill patterns, expected mapping:
- Open: Red
- In Progress: Orange/Yellow
- Assigned: Blue
- Resolved: Green
- Closed: Grey

### 3.6 TEAMLEAD Filter Logic
Not found in the complaint fragments read. May be in `OpenComplaints_frag` (not in the files list).

### 3.7 Complaint Access Gating
- Dashboard quick action: `LoginActivity.access_for_complaints == 1` -> visible
- Nav drawer menu item: `LoginActivity.access_for_complaints == 1` -> included
- `showLcoComplaint`: Not found as a separate flag in the code read. `access_for_complaints` is the primary gate.

---

## 4. Login (`LoginActivity`)

### 4.1 Login Flow Sequence
1. **App Version Check** (SOAP to BMS server via `appVersionCheck`)
   - Sends: `appVersionName`, `appVersionCode`, `appTypeId` (hardcoded `2`), `appclientname` ("")
   - `statusCode == 0`: Proceed to login
   - `statusCode == 1`: Force update dialog -> Play Store
   - **DO NOT PORT:** This uses BMS server SOAP. Flutter should use its own version check mechanism.

2. **SOAP Login** (`LoginAsyncTask`)
   - Sends: `UserName`, `PassWord`, `employeeId` (from SharedPreferences), `imei`
   - Uses `SSLConection.allowAllSSL()` if URL starts with "https"
   - **DO NOT PORT the SSL bypass.** Flutter should use proper certificate handling.

3. **Response Parsing** (via `LoginResponse` class) -> stores in static variables
4. **Navigate** to `ApplicationIntroActivity` (which loads `MainActivity`)

**Note:** `getaccesscontrol()` REST method exists but is NOT called in the active login flow. The code calls `startActivity(new Intent(LoginActivity.this, ApplicationIntroActivity.class))` directly after parsing login response. The access control call is defined but only invoked if you uncomment the call.

### 4.2 Login Validations
- Username AND password must not be empty
- Network must be available
- All permissions must be granted: READ_PHONE_STATE, LOCATION, CONTACTS, CAMERA, BLUETOOTH (Android 12+)
- IMEI: Uses `getDeviceId()` for Android <= P, `ANDROID_ID` for newer

### 4.3 All Config Flags Parsed from Login Response

| Static Variable | Source Field | Default | Type |
|----------------|-------------|---------|------|
| `employeeId` | `getEmployeeId()` | from SharedPrefs | int |
| `user` | `getEmployeeName()` | - | String |
| `business_name` | `getBusiness_name()` | - | String |
| `dealerId` | `getDealerId()` | - | int |
| `userType` | `getUserType()` | - | String |
| `authToken` | `getAuthToken()` | - | String |
| `useCRF` | `getUseCRF()` | - | int |
| `useCAF` | `getUseCAF()` | - | String |
| `deposit_amount` | `getDeposit_amount()` | - | double |
| `useLastName` | `getUseLastName()` | - | int |
| `useDiscount` | `getUseDiscount()` | - | int |
| `useDataFromMasterTable` | `getUseDataFromMasterTable()` | - | int |
| `useMandatoryForHotel` | `getUseMandatoryForHotel()` | - | int |
| `useAccountNumber` | `getUseAccountNumber()` | - | int |
| `lco_billtype` | `getLco_billtype()` | - | int |
| `customerbilltype` | `getCustomer_bill_type()` | - | int |
| `lcoMobileNo` | `getLcoMobileNo()` | - | int |
| `employeeParentId` | `getEmployeeParentId()` | - | String |
| `employeeParentType` | `getEmployeeParentType()` | - | String |
| `is_direct_lco` | `getIs_direct_lco()` | `0` | int |
| `AUTO_RECEIPT_NUMBER` | `getAutoReceipt()` | `1` | int |
| `allow_top_up` | `getAllow_top_up()` | `1` | int |
| `show_caf_mobile_validation` | `getShow_caf_mobile_validation()` | `0` | int |
| `CURRENCY_CODE` | `getCURRENCY_CODE()` | `"₹"` | String |
| `patch_information` | raw parse from response | `"1.4.13.2"` | String |
| `stb_pairing` | raw parse from response | `0` | int |
| `stb_unpairing` | raw parse from response | `0` | int |
| `recurringService` | `recurringServiceEdit` field | - | int |
| `menuType` | `appMenuFormat` field | `""` | String |
| `userLcoDeposit` | `useLcoDeposit` field | - | int |
| `defaultcountry` | `getDefaultCountry()` | - | String |
| `defaultstate` | `getDefaultState()` | - | int |
| `defaultdistrict` | `getDefaultDistrict()` | - | int |
| `defaultcity` | `getDefaultCity()` | - | int |
| `freezecustomerparamsinapp` | `getFreezecustomerparamsinapp()` | `0` | int |
| `hidemakepayment` | `blockpayment` field | `0` | int |
| `show_mia_agreement_upload` | field of same name | `0` | int |
| `accept_terms_condtions` | field of same name | `0` | int |
| `agreement_details_count` | field of same name | `0` | int |
| `access_distributor_wise` | field of same name | `0` | int |
| `login_username` | `username` field | - | String |
| `login_email` | `email` field | - | String |

### 4.4 Access Control REST Call (`getaccesscontrol`)

**URL:** `{baseUrl}/getaccesscontrollRest` (from property `acccntrl`)
**Method:** POST
**Params:**
- `authtoken`: LoginActivity.authToken
- `dealer_id`: LoginActivity.dealerId
- `userstype`: LoginActivity.userType
- `employeeParentType`: employeeParentType
- `employeeParentId`: employeeParentId

**Response parsing (INVERTED status codes):**
- `status_code == 0`: Parse all access flags:

| Flag | JSON Key | Default |
|------|----------|---------|
| `int_bulk_payment` | `int_bulk_payment` | `1` |
| `pgtransaction` | `int_payment_transaction_report_access` | `0` |
| `invoice_page_access` | `invoice_page_access` | `1` |
| `payment_hist_page_access` | `payment_hist_page_access` | `1` |
| `access_for_complaints` | `access_for_complaints` | `1` |
| `int_stb_activation` | `int_stb_activation` | `1` |
| `int_stb_deactivation` | `int_stb_deactivation` | `1` |
| `int_stb_reactivation` | `int_stb_reactivation` | `1` |

- `status_code == 1`: Shows error but STILL navigates to main activity
- On Volley error: STILL navigates to main activity (graceful degradation)

**Flutter must call this after login** and store all flags. Note all defaults are permissive (1) except `pgtransaction` (0).

### 4.5 Session Storage

**SharedPreferences (`bmsSharedPref`):**
- `emp_id`: employee ID (persisted across sessions)
- `login_url`: server URL
- `appLogoPath`: logo image URL
- `appThemeColor`: theme number (1-5)
- `appDashboard`: dashboard type (1 or 2)
- `enableAadhar`: aadhaar feature flag

**SharedPreferences (`vidslogin`):**
- `username`: saved for "Remember Me"

**Static variables:** Everything else is stored as static fields on `LoginActivity` class (lost on process death).

**Flutter equivalent:** Use SharedPreferences/secure storage for auth token, user profile, and all config flags.

### 4.6 SSL Bypass
```java
if (URL.substring(0, 5).equalsIgnoreCase("https")) {
    SSLConection.allowAllSSL();
}
```
**DO NOT PORT.** This is a security vulnerability. Flutter should use proper SSL/TLS.

---

## 5. Navigation (`MainActivity`)

### 5.1 Distributor vs Non-Distributor Detection
```java
isDistributor = LoginActivity.userType.equalsIgnoreCase("DISTRIBUTOR")
    || LoginActivity.userType.equalsIgnoreCase("SUBDISTRIBUTOR")
    || LoginActivity.employeeParentType.equalsIgnoreCase("SUBDISTRIBUTOR")
    || LoginActivity.employeeParentType.equalsIgnoreCase("DISTRIBUTOR");
```

### 5.2 Menu Arrays
- **Distributor:** `nav_drawer_items_distributor` (DEFAULT) or `nav_drawer_items_distributor1` (FORMAT1)
- **Non-Distributor:** `nav_drawer_items` (DEFAULT) or `nav_drawer_items1` (other)

Menu type determined by `LoginActivity.menuType` (from `appMenuFormat` login response field).

### 5.3 Conditional Menu Items

#### Non-Distributor Menu
| Position | Item | Condition |
|----------|------|-----------|
| 0 | Dashboard | Always |
| 1 | Search Customer | Always |
| 2 | New Customer (STB Check) | Always |
| 3 | Complaint Operations | `access_for_complaints == 1` |
| 4 | Box Operations | `int_stb_activation == 1 \|\| int_stb_deactivation == 1 \|\| int_stb_reactivation == 1` |
| 5 | Package Operations | `int_stb_activation == 1 \|\| int_stb_deactivation == 1` |
| 6 | Payments | `int_bulk_payment == 1` |
| 7 | LCO Payment | `LCO_PAYMENT == 1` |
| 8 | Reports | Always |
| 9 | Pair/Unpair | `stb_pairing == 1 \|\| stb_unpairing == 1` |

#### Distributor Menu
| Position | Item | Condition |
|----------|------|-----------|
| 0 | Dashboard | Always |
| 1 | Search Customer | Always |
| 2 | New Customer | Always |
| 3 | Box Operations | `int_stb_activation == 1 \|\| int_stb_deactivation == 1 \|\| int_stb_reactivation == 1` |
| 4 | Package Operations | `int_stb_activation == 1 \|\| int_stb_deactivation == 1` |
| 5 | Payments | `int_bulk_payment == 1` |
| 6 | LCO Payment | `LCO_PAYMENT == 1` |

**Key difference:** Distributors do NOT have Complaint Operations, Reports, or Pair/Unpair in the nav drawer.

### 5.4 Position-to-Fragment Routing (displayView)

The `displayView(position)` method uses the **position in the navDrawerItems list** (which is dynamic based on which items are included). The switch-case is complex because items can be skipped.

For non-distributor:
- Position 0: `Dashboard_Fragment`
- Position 1: `SearchCustomer_Fragment` (origin="searchCustomer")
- Position 2: `STB_Check_Fragment_Old` (new customer)
- Position 3: If distributor -> boxMgmt search; else -> complaintMgmt search
- Position 4: If distributor -> packageMgmt; else -> boxMgmt search
- Position 5: If distributor -> payments/LCO payment; else -> packageMgmt
- Position 6-9: Complex cascading based on which items were included

### 5.5 Top-Up Menu Visibility
```java
if (LoginActivity.userType.equalsIgnoreCase("RESELLER")) {
    if (LoginActivity.allow_top_up == 1 && LoginActivity.is_direct_lco == 0) {
        register.setVisible(true);  // Top-up action
        if (patch_information is "1.4.13.2"/"1.4.13.3"/"1.4.13.4") {
            wallet.setVisible(true);  // Wallet history
        }
    }
}
```

---

## 6. Dashboard (`Dashboard_Fragment`)

### 6.1 API Calls on Load
1. **Dashboard Details** (SOAP `dashBoardDetailsRest`): Loaded on click of refresh/details button (NOT automatic on load)
2. **LCO Deposit Amount** (SOAP `lco_deposit_amountRest`): Auto-loaded if user is RESELLER or EMPLOYEE with `is_direct_lco == 0`
3. **Expired Services** (REST `getExpiryServicesDayWiseCount`): On click of expired services link

### 6.2 Dashboard SOAP Call
Property name: `dashInfo`
- `authToken`: LoginActivity.authToken

#### Response Fields Mapped to UI:
| API Field | UI Element | Variable |
|-----------|-----------|----------|
| `totalStbs` | `totalstb` TextView | `int_stb_total` |
| `totalAssignedStbs` | `activestb` TextView | `int_stb_assign` |
| `totalUnAssignedStbs` | `deactivestb` TextView | `int_stb_unassign` |
| `totalComplaints` | `comp` TextView | `int_complint_total` |
| `totalCurrentMonthBill` | (not displayed) | `int_complaint_closed` (misnomer) |
| `totalActiveCustomers` | `activatestb` TextView | `int_stbs_active` |
| `totalPaidCustomers` | (not displayed) | `getpaidcustomers` |
| `totalUnPaidCustomers` | (not displayed) | `getunpaidcustomers` |
| `totalDeactiveCustomers` | `deactivatestb` TextView | `int_stbs_deactive` |

**Note:** Despite variable names like "stb", the labels in the UI may differ. The mapping shows actual API fields.

### 6.3 LCO Wallet Visibility Rules
```java
// Hide wallet for these user types
if (userType == "DEALER" || "ADMIN" || "SERVICE" || "DISTRIBUTOR" || "SUBDISTRIBUTOR"):
    ll_lcowallet = GONE
    ll_open = INVISIBLE

// Show wallet for others (RESELLER, EMPLOYEE)
else:
    if (is_direct_lco == 0):
        ll_lcowallet = VISIBLE
        tv_lcoaount = "Rs." + LoginActivity.deposit_amount
    else:
        ll_lcowallet = GONE
```

### 6.4 LCO Deposit SOAP Call
Property name: `activSerInfo`
- `authToken`: LoginActivity.authToken
- `dealer_id`: LoginActivity.dealerId

Response: `lco_deposit_amount` field -> displayed as `{CURRENCY_SIGN} {amount}`

### 6.5 Quick Action Visibility
| Action | Condition |
|--------|-----------|
| Quick Pay | `LoginActivity.int_bulk_payment == 1` |
| Package Operations | `LoginActivity.int_stb_activation == 1 \|\| LoginActivity.int_stb_deactivation == 1` |
| Complaint Operations | `LoginActivity.access_for_complaints == 1` |
| STB Operations | `LoginActivity.int_stb_activation == 1 \|\| LoginActivity.int_stb_deactivation == 1 \|\| LoginActivity.int_stb_reactivation == 1` |
| Customer Search | Always visible |
| New Customer | Always visible |

### 6.6 Open Complaints Link Visibility
```java
if (userType == "RESELLER" || "EMPLOYEE" || "SERVICE"):
    if (patch_information is "1.4.13.2"/"1.4.13.3"/"1.4.13.4"):
        ll_open = VISIBLE
    else:
        ll_open = GONE
```

### 6.7 Expired Services Popup (REST)
**URL:** `{baseUrl}/getExpiryServicesDayWiseCount` (from property `gesdwc`)
**Method:** POST
**Params:**
- `authtoken`: LoginActivity.authToken
- `dealer_id`: LoginActivity.dealerId

**Response:**
- `status_code == 0`: Parse `getExpiryServicesList` JSON array
  - Each item: `date`, `stb_count`
  - Shows in popup dialog with ListView
- `status_code == 1`: Toast statusMessage

---

## 7. Search Customer (`SearchCustomer_Fragment`)

### 7.1 Search Fields
- Customer CRF/ID (`et_custId`)
- Customer Name (`et_custName`)
- Mobile Number (`et_mobileNo`)
- VC/Serial Number (`et_boxNo`)
- LCO Customer ID (`lco_no`)

### 7.2 Validations
1. At least one field must be non-empty
2. If searching by name: minimum 3 characters required
3. Internet connectivity check

### 7.3 SOAP Call (getCustomerDetailsCount)
Property name: `count`
| Field | Value |
|-------|-------|
| `authToken` | LoginActivity.authToken |
| `customerNumber` | et_custId text |
| `customerName` | et_custName text |
| `mobileNumber` | et_mobileNo text |
| `boxNumber` | et_boxNo text |
| `lcoCustomerId` | lco_no text |

### 7.4 Response Handling
- `statusCode == 0`:
  - Extracts `customerCount` from response
  - If `customerCount >= 10000`: Shows warning "Large Count!" and does NOT proceed
  - Otherwise: navigates to `CustomerSearchList_Fragment` with all search params + request origin
- `statusCode == 1`: "Customers not found!"
- `statusCode >= 2`: "Customers not found!"

### 7.5 Request Origins
The `request_origin` string determines where navigation goes after selecting a customer:
- `"searchCustomer"` -> Customer details
- `"payments"` -> Payment screen
- `"boxMgmt"` -> Box/STB operations
- `"packageMgmt"` -> Package operations
- `"complaintMgmt"` -> Complaint operations
- `"stb_Map_custID"` -> STB mapping (carries `stbNo` in bundle)

---

## 8. Reports

### 8.1 Mini Day Report (`MiniDayReport_Fragment`)

#### SOAP Call
Property name: `activSerInfo`
| Field | Value |
|-------|-------|
| `authToken` | LoginActivity.authToken |
| `dealer_id` | LoginActivity.dealerId |
| `date` | Current date in `yyyy-MM-dd` format |

#### Response Parsing
Array of `Dailyreport_details`:
- `cust_count` (int)
- `total` (double)
- `payment_mode` (String)

#### Display
- ListView with payment mode, count, total per mode
- Grand total calculated client-side: `sum of all total values`
- Displayed as: `{CURRENCY_SIGN} {formatted total (2 decimal places)}`

#### Print
- Checks `status == 1` (successful report load) before allowing print
- Two paths:
  - N910 device: Direct thermal print via `N910Util`
  - Other devices: Bluetooth printer via `Bluetooth_Fragment`
- Print format:
  ```
  --------------------------------
       MINIDAY REPORT
  --------------------------------
  {date}
  --------------------------------
  MODE      COUNT      AMOUNT
  --------------------------------
  {mode}    {count}    {amount}
  --------------------------------
  TOTAL AMOUNT         {total}
  --------------------------------
  ```

### 8.2 Employee Collection Report (`Report_EmpCollect_Fragment`)

#### Date Handling
- Start date and end date default to today
- Date format: `yyyy-MM-dd` for API, `dd-MM-yyyy` for display
- **Validation:**
  - Start date must not be greater than current date
  - End date must not be greater than start date
  - End date must not be greater than current date
  - On invalid: resets both dates to today with toast message

#### Two Modes (based on `fromreport` bundle param)
- `fromreport == 1`: Employee collection SOAP report
- `fromreport == 0`: LCO wallet REST report

#### SOAP Call (Employee Collection)
Property name: `collectInfo`
| Field | Value |
|-------|-------|
| `authToken` | LoginActivity.authToken |
| `fromDate` | formatted start date |
| `toDate` | formatted end date |
| `imei` | LoginActivity.imeiNo |
| `dealer_id` | LoginActivity.dealerId |

Response: array of `collectionList`:
- `employee_id` (int)
- `name` (String)
- `Amt` (Double)

Navigates to `Reports_Emp_Collection_List_Fragment` with `collResultList`, `fromDate`, `toDate`.

#### LCO Wallet REST Call
**URL:** `{baseUrl}/getLcoWalletReport` (from property `getlw`)
**Method:** POST
**Params:**
- `authtoken`: LoginActivity.authToken
- `dealer_id`: LoginActivity.dealerId
- `start_date`: formatted start date
- `end_date`: formatted end date

**Response:** JSON with `getLcoWalletReport` array:
- `Deposit_Date`, `business_name`, `payment_mode`, `cheque_ddnumber`
- `bank`, `branch`, `instrument_date`, `credit_amount`, `debit_amount`
- `transaction_no`, `receipt_no`, `Remarks`, `Deposited_By`, `deposite_amount`

### 8.3 Employee Collection List (`Reports_Emp_Collection_List_Fragment`)

#### Display
- ListView of employee names with amounts
- Grand total calculated: `sum of all Amt values`
- Displayed as: `{CURRENCY_SIGN} {totalPrice}`

#### Drill-down
On clicking an employee row:
- Calls `EmpCustomerCollectionDetails` SOAP
- Property name: `detailsInfo`
  - `authToken`, `fromDate`, `toDate`, `dealer_id`
  - Note: `imei` is commented out
- Response: `collectionList` array with:
  - `customer_id`, `customer_name`, `paid_amount`, `paid_on`, `payment_mode`, `payment_id`
- Navigates to `Employee_Collection_Details_Fragment`

#### Print Format (Collection Report)
```
--------------------------------
    COLLECTION  REPORT
--------------------------------
{date}
--------------------------------
NAME                AMOUNT
--------------------------------
{name (left-aligned 17)}  {amount (right-aligned 10)}
--------------------------------
TOTAL AMOUNT       {total}
--------------------------------
```

---

## Summary of SOAP vs REST Usage

| Feature | Protocol | Port to Flutter? |
|---------|----------|-----------------|
| App Version Check | SOAP (BMS server) | **DO NOT PORT** |
| Login (validateLogin) | SOAP | Port as REST V2 |
| Access Control | REST (Volley) | **PORT** |
| Dashboard Details | SOAP | Port as REST V2 |
| LCO Deposit Amount | SOAP | Port as REST V2 |
| Expired Services Count | REST (Volley) | **PORT** |
| Deactivate Reasons | SOAP | Port as REST V2 |
| Deactivate Box | SOAP | Port as REST V2 |
| Reactivate Box | SOAP | Port as REST V2 |
| Temp Activate | SOAP | Port as REST V2 |
| STB Pair | SOAP | Port as REST V2 |
| STB Unpair | SOAP | Port as REST V2 |
| Complaint Categories | SOAP | Port as REST V2 |
| Complaint Subcategories | REST (Volley) | **PORT** |
| LCO Employee List | REST (Volley) | **PORT** |
| Create Complaint | SOAP | Port as REST V2 |
| Get Customer Complaints | SOAP | Port as REST V2 |
| Complaint Dashboard | Retrofit | **PORT** |
| Customer Search Count | SOAP | Port as REST V2 |
| Mini Day Report | SOAP | Port as REST V2 |
| Employee Collection | SOAP | Port as REST V2 |
| LCO Wallet Report | REST (Volley) | **PORT** |
| Employee Customer Details | SOAP | Port as REST V2 |

---

## Critical Business Rules for Flutter

1. **Deactivation remarks suffix:** Always append `. Box Deactivation from Android app` (change to Flutter equivalent)
2. **Complaint description suffix:** Always append `.Complaint Created from Android app`
3. **Reason ID 17 exclusion:** Filter out deactivation reasons with ID 17
4. **`from_mobileapp = 1`:** Hardcoded in deactivation request
5. **`reinitialize = 1`:** Hardcoded in reactivation request
6. **Temporary activation:** NO confirmation dialog, fires immediately
7. **Subcategory + employee list:** Only available when `patch_information` is "1.4.13.2"/"1.4.13.3"/"1.4.13.4"
8. **Category vs subcategory ID:** Use subcategory ID if selected, otherwise main category
9. **LCO wallet:** Hidden for DEALER/ADMIN/SERVICE/DISTRIBUTOR/SUBDISTRIBUTOR AND for direct LCOs
10. **Customer search:** Minimum 3 chars for name search, max 10000 results warning
11. **Date validation in reports:** Start <= today, end >= start, end <= today
12. **All access flags default to 1 (permissive)** except `pgtransaction` (0) -- if API fails, allow access
13. **Access control failure is non-blocking:** Even on error, user proceeds to main screen
