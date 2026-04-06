# 06 - Package & Service Operations

**Category:** Package Management
**Source files analyzed:**
- `activities_fragments/Package_Operations_Fragment.java`
- `activities_fragments/FragActive_plan.java`
- `activities_fragments/Frag_deact_pack.java`
- `activities_fragments/RenewFragment.java`
- `activities_fragments/NewCust_AddPackage_Activity.java`
- Model classes: `PackageModel`, `packageInfo`, `customerpackageList`, `customerPacakgesInfo`, `caspackageInfo`, `caspackageList`, `RenewalModel`, `activateService`, `deactivateService`, `Channelservice`, `Channelvalues`, `ShowPackages`, `Deactpacklist`
- Adapters: `Packageadapter`, `RenewalAdapter`, `RenewalSelectedAdapter`, `ShowPackagesAdapter`, `ChannelAdapter`

---

## Overview

Package & Service Operations is a hub fragment that exposes three child operations for a specific STB (Set-Top Box). The entry fragment receives the customer context from its caller and gates each child screen behind server-side access-control flags. All V2 REST calls use HTTP POST to `{baseUrl}/LcoRestServices/{endpoint}`.

Navigation hierarchy:
```
Package_Operations_Fragment (hub)
├── FragActive_plan          (add/activate new packages)
├── Frag_deact_pack          (deactivate existing packages)
└── RenewFragment            (renew expired services)

NewCust_AddPackage_Activity  (separate activity - used during new customer creation only)
```

---

## Screen 1: Package Operations Hub

### 1.1 Screen Identity

| Property | Value |
|----------|-------|
| **Label / ActionBar Title** | "Package Operations" |
| **Layout file** | `package_operations_new_multi` |
| **Fragment class** | `Package_Operations_Fragment` |
| **Purpose** | Hub screen showing three operation buttons for an STB; routes to the correct child fragment |
| **Category** | Package Management |

### 1.2 Incoming Navigation Context (Bundle Arguments)

| Parameter | Type | Source | Description |
|-----------|------|--------|-------------|
| `custName` | String | Customer list | Customer display name |
| `custId` | String (parsed to int) | Customer list | Alternate customer ID (`altCustId`) |
| `boxNo` | String | STB list | STB serial / box number |
| `devId` | String (parsed to int) | STB list | Device ID |
| `stockId` | String (parsed to int) | STB list | Stock ID |
| `resellerid` | int | STB list | Reseller ID |
| `isexpired` | int | STB list | 1 = at least one service is expired |
| `reqOrigin` | String | Caller | Origin fragment name |
| `pending_amount` | double | STB list | Outstanding dues amount |

### 1.3 UI Elements

| Element | Type | Description |
|---------|------|-------------|
| `packoper_tv_custname` | TextView | Customer name (truncated at 18 chars with line break if longer than 20 chars) |
| `packoper_tv_custid` | TextView | Customer ID |
| `packoper_tv_boxid` | TextView | STB box number |
| `packoper_tv_dueamount` | TextView | Due amount prefixed with currency symbol (e.g. ₹ 250.0) |
| `packoper_btn_activ_multiple` | LinearLayout (button) | "Activate Package" button |
| `packoper_btn_deactiv_multiple` | LinearLayout (button) | "Deactivate Package" button |
| `packoper_btn_renew` | LinearLayout (button) | "Renew Services" button |

### 1.4 Visibility Rules

| Control | Condition to Show |
|---------|-------------------|
| `btn_packActive1` (Activate) | `LoginActivity.int_stb_activation == 1` |
| `btn_packDeActive1` (Deactivate) | `LoginActivity.int_stb_deactivation == 1` |
| `packoper_btn_renew` (Renew) | `isexpired == 1` AND `patch_information` equals one of `"1.4.13.2"`, `"1.4.13.3"`, `"1.4.13.4"` |

> **Flutter note:** `int_stb_activation` and `int_stb_deactivation` are sourced from the `getaccesscontrollRest` API at login. `patch_information` is returned from `validateLogin`. The Renew button should be conditionally visible using these stored values.

### 1.5 Actions & Navigation

| Action | Navigates To | Context Passed |
|--------|-------------|----------------|
| Tap Activate | `FragActive_plan` | `custId`, `boxNo`, `custDevId`, `custStockId`, `resellerid` |
| Tap Deactivate | `Frag_deact_pack` | `custId`, `boxNo`, `custDevId`, `custStockId`, `resellerid` |
| Tap Renew | `RenewFragment` | `custId`, `boxNo`, `custDevId`, `custStockId`, `resellerid` |

### 1.6 API Calls

None. This is a purely navigational hub; it makes no API calls of its own.

---

## Screen 2: Package Activation (FragActive_plan)

### 2.1 Screen Identity

| Property | Value |
|----------|-------|
| **Label / ActionBar Title** | "Package Activation" |
| **Layout file** | `fragment_frag_active_plan` |
| **Fragment class** | `FragActive_plan` |
| **Purpose** | Displays all packages not yet assigned to this STB, segmented into four categories. The operator selects packages across categories, previews the bill, and submits activation. |
| **Category** | Package Activation |

### 2.2 UI Elements

| Element | ID / Type | Description |
|---------|-----------|-------------|
| Category tab - Base | `tv_selectbasepackage` (TextView) | Highlights blue when active; filters `baseListView` |
| Category tab - Add-On | `tv_addon` (TextView) | Highlights blue when active; filters `addOnListView` |
| Category tab - A-La-Carte | `tv_alacarte` (TextView) | Highlights blue when active; filters `alakarteListView` |
| Category tab - Broadcaster | `tv_broadcaster` (TextView) | Highlights blue when active; filters `broadcastListView` |
| Base package list | `list` (ListView) | Packages from `packageList_base` SOAP response; adapter: `Packageadapter` |
| Add-On package list | `list1` (ListView) | Packages from `packageList_addon`; adapter: `Packageadapter` |
| A-La-Carte list | `list2` (ListView) | Packages from `packageList_ala`; adapter: `Packageadapter` |
| Broadcaster list | `list3` (ListView) | Packages from `packageList_broadcaster`; adapter: `Packageadapter` |
| Search bar | `inputSearch` (SearchView) | Live-filters the active list by package name; shows `noDataFound` when empty |
| No-data placeholder | `noDataFound` (TextView) | Shown when list is empty |
| Active services info | `ll_deact` (LinearLayout) | Shown if `deactivate_customerservices` count > 0; opens a popup showing currently active services per STB (product name, start/end date, pricing type) |
| Save button | `btn_savee` (TextView acting as Button) | Triggers confirmation dialog with selected packages |

#### Per-Package Row Fields (Packageadapter / `row_pack_act` layout)

| Field | Source | Description |
|-------|--------|-------------|
| Package name | `PackageModel.packageName` | Package display name |
| Validity | `PackageModel.validity` | e.g. "1 Monthly", "1 Yearly" |
| Price | `PackageModel.base_price` | Base price in rupees |
| Channel count | `sd_channels_count + hd_channels_count` | Total channels in the package |
| Checkbox | `PackageModel.isSelected` | Multi-select; tapping toggles selection |
| Channel list button | `ll_actpacchaneeels` | Tapping invokes `getchannellist` AsyncTask (channel list SOAP) |

### 2.3 Data Load: Unassigned Packages

**Trigger:** Fragment `onCreateView` immediately calls `new GetUnAssaignedPackages().execute()`

**Android implementation:** SOAP via ksoap2 using property key `"unassigned"` from `PropertyReader`.
**Flutter equivalent V2 REST API:**

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getUnassignedPackages_splitRest` |
| **Auth** | JWT token header + `authtoken` in payload |

**Request Parameters:**

| Parameter | Type | Source | Description |
|-----------|------|--------|-------------|
| `authToken` | String | `LoginActivity.authToken` | Session auth token |
| `customerId` | int | bundle `custId` | Customer ID |
| `boxNumber` | String | bundle `boxNo` | STB serial number |

**Response Structure (SOAP property names → REST equivalents):**

| SOAP Property Name | REST Equivalent | Type | Description |
|--------------------|-----------------|------|-------------|
| `packageList_base` | `packageList_base` array | Object[] | Base packages not yet assigned |
| `packageList_addon` | `packageList_addon` array | Object[] | Add-on packages not yet assigned |
| `packageList_ala` | `packageList_ala` array | Object[] | A-La-Carte packages not yet assigned |
| `packageList_broadcaster` | `packageList_broadcaster` array | Object[] | Broadcaster packages not yet assigned |
| `deactivate_customerservices` | `deactivate_customerservices` array | Object[] | Currently active services on this STB (for reference display) |

**Package Object Fields (all four list types use the same fields):**

| Field | Java Name | Type | Description |
|-------|-----------|------|-------------|
| `product_id` | `packageId` | int | Product/package ID |
| `pname` | `packageName` | String | Package display name |
| `pricing_structure_type` | `pricingStructureType` | int | 1 = One-time, 2 = Recurring |
| `base_price` | `base_price` | double | Base price before tax |
| `sd_channels_count` | `sd_channels_count` | int | Number of SD channels |
| `hd_channels_count` | `hd_channels_count` | int | Number of HD channels |
| `monthly_or_yearly` | `monthly_or_yearly` | String | Billing cycle label |
| `validity` | `validity` | String | Validity string (e.g. "1 Monthly") |
| `validity_days` | `validity_days` | int | Numeric validity count |

**Currently Active Service Object Fields (`deactivate_customerservices`):**

| Field | Java Name | Type | Description |
|-------|-----------|------|-------------|
| `service_start_date` | `service_start_date` | String | Service activation date |
| `service_end_date` | `service_end_date` | String | Service expiry date |
| `product_name` | `product_name` | String | Package name |
| `pricing_struct_type` | `pricing_struct_type` | String | Pricing type label |

**Status codes:**

| `statusCode` | Meaning | UI Action |
|-------------|---------|-----------|
| 0 | Success | Populate all four ListViews |
| 1 | No unassigned packages found | AlertDialog: "All packages are active" |
| >= 2 | Error | AlertDialog with error message |

### 2.4 Date Calculation Logic

When a package is selected, the Android code computes start and end dates locally:

| Validity String Length | Calendar Operation | End Date Adjustment |
|------------------------|-------------------|---------------------|
| 7 characters (e.g. "1 Years") | `c.add(Calendar.YEAR, validity_days)` | Subtract 1 day from computed end |
| 8 characters (e.g. "1 Months") | `c.add(Calendar.MONTH, validity_days)` | Subtract 1 day from computed end |
| Any other length | `c.add(Calendar.DATE, validity_days)` | Subtract 1 day from computed end |

> **Flutter note:** These dates are computed locally from `today` (device date) + validity. Start date = today (formatted `dd-MM-yyyy`). End date = today + validity period - 1 day. These are passed to the bill details display only; they are not sent to the activation API.

### 2.5 Selection Summary Dialog (Pre-Activation Confirmation)

Triggered when the operator taps "Save" (`btn_savee`). The `AllinOneSave()` method iterates all four `packageArrayList`s collecting checked items.

**Dialog content (layout `row_activate_selected`):**

| Element | Description |
|---------|-------------|
| `list_selectedac` (ListView) | Selected packages; adapter: `ShowPackagesAdapter` |
| `totalamount` (TextView) | Sum of `base_price` across all selected packages |
| `ll_shares` (LinearLayout) | Initially hidden; shown after "Get Bill" is tapped |
| `tv_lcoshare` / `tv_msoshare` | LCO share and MSO share amounts (from bill details API) |
| `ll_ncf` | NCF (Network Capacity Fee) row; hidden if `ncf_total_amount <= 0` |
| `tv_ncfname` / `tv_ncfvalue` | NCF display name and amount |
| `ll_encf` | Extended NCF row; hidden if `encf_total_amount <= 0` |
| `tv_encfname` / `tv_encfvalue` | ENCF display name and amount |
| `getbill_btn_act` (Button) | "Get Bill" — fetches bill details; hides itself after success |
| `packactivation_btn_cancel` (Button) | Cancel / dismiss dialog |
| `packactivation_btn_act` (Button) | "Activate" — hidden until "Get Bill" succeeds; triggers final confirmation |

**ShowPackages row fields (per selected package):**

| Field | Description |
|-------|-------------|
| `packname` | Package name |
| `totalamount` | Base price (as String) |
| `startdate` | Computed start date (dd-MM-yyyy, max 10 chars) |
| `enddate` | Computed end date (dd-MM-yyyy, max 10 chars) |
| `pricingstructuretype` | int: 1 = one-time, 2 = recurring |

### 2.6 Get Bill Details API

**Trigger:** Operator taps "Get Bill" button inside the confirmation dialog.

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getbilldetailsRest` |
| **Method** | POST (Volley `StringRequest`) |
| **Base URL** | `LoginActivity.URL.replace("/wsController","") + PropertyReader.getProperty("getbill")` |
| **Auth** | `authtoken` in POST body |

**Request Parameters:**

| Parameter | Type | Source | Description |
|-----------|------|--------|-------------|
| `authtoken` | String | `LoginActivity.authToken` | Session auth token |
| `dealer_id` | int | `LoginActivity.dealerId` | Dealer ID |
| `employee_id` | int | `resellerid` | Reseller/employee ID |
| `customer_id` | int | `customerId` | Customer ID |
| `package_id` | String | `totalstrs` | Comma-separated package IDs collected from all selected packages |
| `serial_number` | String | `boxNumber` | STB serial number |

**Response Fields:**

| JSON Field | Type | Description |
|-----------|------|-------------|
| `status_code` | int | 0 = success, 1 = failure |
| `status_msg` | String | Human-readable message |
| `basePrice` | JSON Object | Nested object with bill breakdown |
| `basePrice.lco_share` | double | LCO operator share of the bill |
| `basePrice.mso_share` | double | MSO (Multi-System Operator) share |
| `basePrice.total_amount` | double | Grand total bill amount |
| `basePrice.ncf_display_name` | String | NCF label (e.g. "Network Capacity Fee") |
| `basePrice.ncf_total_amount` | double | NCF component amount |
| `basePrice.encf_display_name` | String | ENCF label |
| `basePrice.encf_total_amount` | double | ENCF component amount |

> **Backend config values visible here:**
> The full V2 REST API doc shows `getbilldetailsRest` also returns `enum_add_on_after_base`, `ENABLE_PRORATA_DISCOUNT`, `arr_act_package_details`. The Android app currently only reads the `basePrice` sub-object. Flutter should read all fields.

**Status codes:**

| `status_code` | UI Action |
|--------------|-----------|
| 0 | Show `ll_shares`, hide "Get Bill" button, show "Activate" button, populate share/NCF views |
| 1 | AlertDialog with `status_msg` |

### 2.7 Activate Service API (Final Step)

**Trigger:** Operator taps "Yes" in the final "Are you sure?" confirmation.

**Android implementation:** SOAP via ksoap2 using property key `"acser"`.
**Flutter equivalent V2 REST API:**

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/activateServiceRest` |
| **Auth** | JWT token header + `authtoken` in payload |

**Request Parameters (from `activateService` class):**

| Parameter | Java Field | Type | Value in Code | Description |
|-----------|-----------|------|---------------|-------------|
| `authToken` | `authToken` | String | `LoginActivity.authToken` | Session auth token |
| `customerDeviceId` | `customerDeviceId` | int | bundle `custDevId` | Customer device ID |
| `customerId` | `customerId` | int | bundle `custId` | Customer ID |
| `productId` | `productId` | String | `totalstrs` (comma-separated) | Selected package IDs |
| `quantity` | `quantity` | int | hardcoded `1` | Quantity (always 1 in mobile app) |
| `dateType` | `dateType` | int | hardcoded `0` | Date type (0 = default) |
| `pricingStructureType` | `pricingStructureType` | int | hardcoded `1` | Pricing structure type |
| `validityDays` | `validityDays` | int | hardcoded `1` | Validity days (default) |
| `stockId` | `stockId` | int | bundle `custStockId` | Stock ID |
| `fromMobileApp` | `fromMobileApp` | int | hardcoded `1` | Flag: always 1 for mobile |
| `dealer_id` | `dealer_id` | int | `LoginActivity.dealerId` | Dealer ID |
| `reseller_id` | `reseller_id` | int | bundle `resellerid` | Reseller ID |
| `login_employee_id` | `login_employee_id` | int | `LoginActivity.employeeId` | Employee ID |

> **Note on `dateType`:** The Android code hardcodes `dateType = 0`. The `NewCust_AddPackage_Activity` exposes a spinner with "Year", "Month", "Day" for one-time packages, and only "Year" for recurring. In Flutter, `dateType` should be determined by the activation cycle selection: Month=1, Year=2, Day=3. The `recurringServiceEdit` flag (from `validateLogin`) controls whether the cycle spinner is shown.

**Response:**

| `statusCode` | UI Action |
|-------------|-----------|
| 0 | AlertDialog "Activation Successful" + `statusMessage` (HTML stripped); navigate to MainActivity dashboard |
| 1 | AlertDialog "Activation Failed" with `statusMessage` |
| >= 2 | AlertDialog "Activation Failed" with `statusMessage` |

> If `actt == 1` (box activation context), success message is "Box Activated Successfully" and restarts `MainActivity`.

### 2.8 Channel List API (Per-Package Channel View)

**Trigger:** Tapping the channel count button on any package row in `Packageadapter`.

**Android implementation:** SOAP via ksoap2 using property key `"chlist"`.
**Flutter equivalent V2 REST API:**

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/channel_listRest` |
| **Auth** | JWT token header + `authtoken` in payload |

**Request Parameters (from `Channelservice` class):**

| Parameter | Java Field | Type | Source | Description |
|-----------|-----------|------|--------|-------------|
| `authToken` | `authToken` | String | `LoginActivity.authToken` | Session token |
| `product_id` | `product_id` | int | `packageModel.getPackageId()` | The product being viewed |
| `dealer_id` | `dealer_id` | int | `LoginActivity.dealerId` | Dealer ID |

**Response (`channel_details` array items — `Channelvalues` class):**

| JSON Field | Java Field | Type | Description |
|-----------|-----------|------|-------------|
| `channel_id` | `channel_id` | int | Channel ID |
| `channel_name` | `channel_name` | String | Channel display name |
| `channel_language` | `channel_language` | String | Language of the channel |
| `channel_logo` | `channel_logo` | String | Logo URL or identifier |
| `channel_price` | `channel_price` | double | Individual channel price |

**Channel list dialog display:**
- Title: Package name + base price
- "Total Channels: N" header
- `ListView` with `ChannelAdapter` showing each channel name, language, logo, price

**Status codes:**

| `statusCode` | UI Action |
|-------------|-----------|
| 0 | Show dialog with channel list |
| 1 | AlertDialog "Channels Loading Failed" |
| 2 | Toast: "Contact Support" |
| > 2 | AlertDialog "Activation Failed" (error path) |

---

## Screen 3: Package Deactivation (Frag_deact_pack)

### 3.1 Screen Identity

| Property | Value |
|----------|-------|
| **Label / ActionBar Title** | "Package Deactivation" |
| **Layout file** | `fragment_frag_deact_pack` |
| **Fragment class** | `Frag_deact_pack` |
| **Purpose** | Shows all currently active packages for the STB split into four category tabs. Operator selects packages to deactivate, picks a reason, enters remarks, and confirms. |
| **Category** | Package Deactivation |

### 3.2 UI Elements

| Element | ID / Type | Description |
|---------|-----------|-------------|
| Category tab - Base | `tv_deselectbasepackage` (TextView) | Filters `list_deactpackages` |
| Category tab - Add-On | `tv_deaddon` (TextView) | Filters `list1` |
| Category tab - A-La-Carte | `tv_dealacarte` (TextView) | Filters `list2` |
| Category tab - Broadcaster | `tv_debraod` (TextView) | Filters `list3` |
| Base packages list | `list_deactpackages` (ListView) | Active base packages; adapter: `DeactivateAdapter` |
| Add-On packages list | `list1` (ListView) | Active add-on packages; adapter: `DeactivateAdapter` |
| A-La-Carte list | `list2` (ListView) | Active a-la-carte packages; adapter: `DeactivateAdapter` |
| Broadcaster list | `list3` (ListView) | Active broadcaster packages; adapter: `DeactivateAdapter` |
| Reason spinner | `packdeactivation_spin_cycle` (Spinner) | Populated from SOAP `deres` endpoint; filtered to exclude global reasons (IDs 21, 17, or `global_reason==1`) |
| Remarks input | `packdeactivation_et_quant` (EditText) | Free-text remarks (mandatory) |
| Remarks label | `packdeactivation_tv_remarks` (TextView) | "Remarks *:" |
| Save button | `save_btn_deact` (TextView acting as Button) | Triggers confirmation dialog |

### 3.3 Data Load on Open

Two SOAP calls are triggered in `onCreateView`:

1. **`GetUnAssaignedPackages().execute()`** — loads currently **active** packages for this STB (same SOAP property key `"custpacksp"`)
2. **`ReasonValues().execute()`** — loads deactivation reason list (SOAP property key `"deres"`)

**Flutter V2 equivalents:**

**Active Packages for Deactivation:**

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getCustomerPackages_splitRest` |
| **Request** | `authToken`, `customerId`, `boxNumber` |
| **Response** | `packageList_base`, `packageList_addon`, `packageList_ala`, `packageList_broadcaster` |

Each package in the response populates `customerpackageList` objects with these fields:

| Field | Java Name | Type | Description |
|-------|-----------|------|-------------|
| `customerName` | `customerName` | String | Customer name |
| `startDate` | `startDate` | String | Service start date |
| `endDate` | `endDate` | String | Service end date |
| `packageId` | `packageId` | int | Product ID |
| `productName` | `productName` | String | Package name |
| `serviceId` | `serviceId` | int | Customer service ID (used in deactivation) |
| `base_price` | `base_price` | double | Package price |
| `sd_channels_count` | `sd_channels_count` | int | SD channel count |
| `hd_channels_count` | `hd_channels_count` | int | HD channel count |
| `monthly_or_yearly` | `monthly_or_yearly` | String | Billing cycle |
| `validity` | `validity` | String | Validity string |
| `quantity` | `quantity` | int | Quantity |
| `pricing_structure_type` | `pricing_structure_type` | int | 1 = one-time, 2 = recurring |

**Deactivation Reasons:**

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getDeactiveReasonsRest` |
| **Note (Android)** | Uses SOAP with property key `"deres"` |
| **V2 REST** | `POST /LcoRestServices/getDeactiveReasonsRest` (see section 6.5) |
| **Request** | `authToken` (and optionally `showforlco`, `stockId`) |
| **Response** | `reasonList` array |

**Reason filtering applied in Android:** Reasons with `id == 21`, `id == 17`, or `global_reason == 1` are excluded from the spinner. This is business logic that must be preserved in Flutter.

**Reason object fields:**

| Field | Java Name | Type | Description |
|-------|-----------|------|-------------|
| `reasonId` | `reasonId` | int | Reason ID (sent in deactivation request) |
| `reasonName` | `reasonName` | String | Display label |
| `global_reason` | `global_reason` | int | 1 = global reason (excluded from spinner) |

### 3.4 Selection and Validation

The `selectedpackages()` method iterates all four adapters' `getSelectedFlags()` boolean arrays to collect:
- `serviceId` (customer service ID) per selected package — comma-joined into `totalstrs`
- `productName` per selected package — comma-joined into `totalnames`
- `base_price` per selected package — summed into `totalamt`
- `startDate` per package
- `endDate` per package
- `pricing_structure_type` per package

**Validation rules:**

| Rule | Error Shown |
|------|-------------|
| No packages selected | Toast: "No Packages selected" (returns false, dialog not shown) |
| Remarks field empty | AlertDialog: "Remarks should not be empty." |
| No internet connection | AlertDialog: "Please turn on Wifi or Data Network" |

### 3.5 Deactivation Confirmation Dialog

Layout: `row_deact_reasons`

| Element | Description |
|---------|-------------|
| `list_selecteddeac` (ListView) | Selected packages with name and price; adapter: `ShowPackagesAdapter` |
| `totalamount` (TextView) | Sum of base prices |
| `packdeactivation_btn_cancel` | Dismiss dialog |
| `packdeactivation_btn_deact` | Opens "Are you sure?" AlertDialog, then submits deactivation |

### 3.6 Deactivate Service API

**Android implementation:** SOAP via ksoap2 using property key `"deactser"`.
**Flutter equivalent V2 REST API:**

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/deactivateServiceRest` |
| **Auth** | JWT token header + `authtoken` in payload |

**Request Parameters (from `deactivateService` class):**

| Parameter | Java Field | Type | Source | Description |
|-----------|-----------|------|--------|-------------|
| `authToken` | `authToken` | String | `LoginActivity.authToken` | Session token |
| `customerId` | `customerId` | int | bundle `custId` | Customer ID |
| `serviceId` | `serviceId` | String | `totalstrs` (comma-separated `serviceId` values) | Customer service IDs to deactivate |
| `reasonId` | `reasonId` | int | Selected spinner item | Deactivation reason ID |
| `remarks` | `remarks` | String | `et_remarks.getText() + ".Deactivation From Android App"` | Remarks with app suffix appended |
| `stock_id` | `stock_id` | int | bundle `custStockId` | Stock ID |
| `dealer_id` | `dealer_id` | int | `LoginActivity.dealerId` | Dealer ID |
| `reseller_id` | `reseller_id` | int | bundle `resellerid` | Reseller ID |
| `login_employee_id` | `login_employee_id` | int | `LoginActivity.employeeId` | Employee ID |
| `fromMobileApp` | `fromMobileApp` | int | hardcoded `1` | Mobile app flag |

> **Important:** The `remarks` field in Android always appends `".Deactivation From Android App"` to the user-entered text. Flutter should similarly append a suffix such as `".Deactivation From Flutter App"`.

**Response:**

| `statusCode` | UI Action |
|-------------|-----------|
| 0 | AlertDialog "Product deactivated successfully"; pop fragment back stack |
| 1 | AlertDialog "Package deactivation failed" with `statusMessage` |
| >= 2 | AlertDialog "Package deactivation failed. Please Check and enter valid details" |
| null response | AlertDialog "Server connectivity error!" |

---

## Screen 4: Renew Services (RenewFragment)

### 4.1 Screen Identity

| Property | Value |
|----------|-------|
| **Label** | (no explicit ActionBar title set; inherits from parent) |
| **Layout file** | `fragment_renew` |
| **Fragment class** | `RenewFragment` |
| **Purpose** | Fetches and displays a list of expired or expiring services for the customer. The operator selects services to renew and submits a bulk renewal. |
| **Category** | Service Renewal |
| **Visibility gate** | Only accessible when `isexpired == 1` and `patch_information` is `"1.4.13.2"`, `"1.4.13.3"`, or `"1.4.13.4"` |

### 4.2 URL Construction

```java
String Urll = LoginActivity.URL.replace("/wsController", "");
String url  = Urll + "/LcoRestServices/getRenewServicesList";   // GET list
String url2 = Urll + "/LcoRestServices/renewServicesList";      // POST renewal
```

### 4.3 UI Elements

| Element | ID / Type | Description |
|---------|-----------|-------------|
| Renewal list | `lv_renewal` (ListView) | Expired service items; adapter: `RenewalAdapter` |
| Total count | `renewal_total_counts` (TextView) | Shows "Total Packages - N" |
| Save button | `btn_renewal_save` (Button) | Opens selection summary dialog |

#### Per-Service Row (RenewalAdapter / `row_renewal` layout)

| Element | Source Field | Description |
|---------|-------------|-------------|
| Package name | `RenewalModel.pname` | Service/package name |
| Base price | `RenewalModel.base_price` | Price per renewal cycle |
| Checkbox | `RenewalModel.isSelected` | Boolean toggle per row |

### 4.4 Get Renewable Services API

**Trigger:** Called immediately in `onCreateView` via `getrenewlist()`.

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getRenewServicesList` |
| **Method** | HTTP POST (Volley `StringRequest`) |
| **Auth** | `authtoken` in body |

**Request Parameters:**

| Parameter | Type | Source | Description |
|-----------|------|--------|-------------|
| `authtoken` | String | `LoginActivity.authToken` | Session auth token |
| `dealer_id` | String | `LoginActivity.dealerId` | Dealer ID |
| `customer_id` | String | bundle `custId` | Customer ID |

**Response:**

| JSON Field | Type | Description |
|-----------|------|-------------|
| `status_code` | int | 0 = success, 1 = failure |
| `status_msg` | String | Human-readable message |
| `getRenewServices` | JSON Array | Array of renewable service objects |

**`getRenewServices` item fields (`RenewalModel`):**

| JSON Field | Java Field | Type | Description |
|-----------|-----------|------|-------------|
| `customer_service_id` | `customer_service_id` | String | Customer's active service record ID |
| `product_id` | `product_id` | String | Product/package ID |
| `base_price` | `base_price` | String | Package price |
| `pname` | `pname` | String | Package display name |

**Status codes:**

| `status_code` | UI Action |
|--------------|-----------|
| 0 | Populate `lv_renewal` with packages; show total count |
| 1 | AlertDialog "Failed to get renewal packages" with `status_msg` |

### 4.5 Renewal Selection and Summary

The `selectedsave()` method iterates `RenewalAdapter.getSelectedFlags()` boolean array and:
- Collects `customer_service_id` → comma-joined → `totalstrs`
- Collects `product_id` → comma-joined → `totalpids`
- Collects `pname` → `totalnames`
- Sums `base_price` → `totalamt` (formatted to 2 decimal places)
- Builds `showPackagesArrayList` for preview dialog

**Validation:**

| Rule | Action |
|------|--------|
| No packages selected | Toast: "No Packages selected"; returns false; dialog not shown |
| At least one selected | Toast: "Selected: {ids}"; opens summary dialog |

### 4.6 Renewal Summary Dialog

Layout: `row_selectedrenewal`

| Element | Description |
|---------|-------------|
| `list_selectedac` (ListView) | Selected packages; adapter: `RenewalSelectedAdapter` |
| `totalamount` (TextView) | Sum of base prices with currency symbol |
| `packactivation_btn_cancel` (Button) | Dismiss dialog |
| `packactivation_btn_act` (Button) | Opens "Are you sure you want to Renew packages?" AlertDialog |

### 4.7 Renew Services API

**Trigger:** Operator confirms "Yes" in the final AlertDialog.

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/renewServicesList` |
| **Method** | HTTP POST (Volley `StringRequest`) |
| **Auth** | `authtoken` in body |

**Request Parameters:**

| Parameter | Type | Source | Description |
|-----------|------|--------|-------------|
| `authtoken` | String | `LoginActivity.authToken` | Session auth token |
| `dealer_id` | String | `LoginActivity.dealerId` | Dealer ID |
| `customer_id` | String | bundle `custId` | Customer ID |
| `customer_service_id` | String | `totalstrs` | Comma-separated customer service IDs to renew |
| `product_ids` | String | `totalpids` | Comma-separated product IDs corresponding to services |

**Response:**

| JSON Field | Type | Description |
|-----------|------|-------------|
| `status_code` | int | 0 = success, 1 = failure |
| `status_msg` | String | Result message |

**Status codes:**

| `status_code` | UI Action |
|--------------|-----------|
| 0 | AlertDialog "Success" with `status_msg`; pop fragment back stack on OK |
| 1 | AlertDialog "Failed to get renewal packages" with `status_msg`; pop back stack on OK |
| Network error | Toast "Failed." |

---

## Screen 5: New Customer Add Package (NewCust_AddPackage_Activity)

### 5.1 Screen Identity

| Property | Value |
|----------|-------|
| **Label** | "Select a package" (set on `addnewpack_tv_title`) |
| **Activity class** | `NewCust_AddPackage_Activity` |
| **Layout file** | `newcust_packageactiv_fragment` |
| **Purpose** | Standalone activity used exclusively during new customer creation. Displays all available CAS (Conditional Access System) packages. Operator selects a package, enters quantity and optionally validity days, then returns to the parent activity with the selected values. |
| **Category** | New Customer Package Assignment |

### 5.2 UI Elements

| Element | ID / Type | Description |
|---------|-----------|-------------|
| Title | `addnewpack_tv_title` (TextView) | "Select a package" |
| Package list | `gridView` (ListView) | All CAS packages loaded from API |
| Product ID / selection display | `newcust_packactivation_spin_product` (EditText showing "Select") | Display of selected package; was previously a Spinner, now replaced with searchable EditText + custom list |
| Activation cycle | `newcust_packactivation_spin_cycle` (Spinner) | "Year" / "Month" / "Day" for one-time (`pricing_structure_type == 1`); "Year" only for recurring (type 2) |
| Quantity | `newcust_packactivation_et_quant` (EditText) | Required integer quantity |
| Validity days | `newcust_packactivation_et_validdays` (EditText) | Enabled only when "Day" cycle is selected; disabled otherwise |
| Validity days container | `ll_validitydays` (LinearLayout) | Hidden unless "Day" is selected in cycle spinner |
| Quantity label | `newcust_packactivation_lbl_quant` (TextView) | "Quantity *:" |
| Add button | `newcust_packactivation_btn_add` (Button) | Validates and returns selected values to parent |

### 5.3 Package Load API

**Android implementation:** SOAP via ksoap2 using property key `"caspck"`.
**Flutter equivalent V2 REST API:**

| Property | Value |
|----------|-------|
| **Endpoint** | `POST /LcoRestServices/getCasPackagesRest` |
| **Auth** | JWT token header + `authtoken` in payload |

**Request Parameters (from `caspackageInfo` class):**

| Parameter | Java Field | Type | Source | Description |
|-----------|-----------|------|--------|-------------|
| `authToken` | `authToken` | String | `LoginActivity.authToken` | Session token |
| `boxNumber` | `boxNumber` | String | Intent extra `"boxNumber"` | STB serial number |

**Response (`caspackageList` array items — `caspackageList` class):**

| Field | Java Name | Type | Description |
|-------|-----------|------|-------------|
| `product_id` | `packageId` | int | Package/product ID |
| `pname` | `packageName` | String | Package display name |
| `pricing_structure_type` | `pricingStructureType` | int | 1 = one-time, 2 = recurring |

**Status codes:**

| `statusCode` | UI Action |
|-------------|-----------|
| 0 | Populate package list; configure cycle spinner based on `pricingStructureType` |
| Otherwise | Toast: "Server is busy or Un reachable" |

### 5.4 Activation Cycle Spinner Logic

| `pricing_structure_type` | Spinner Options | `dateType` value sent |
|--------------------------|----------------|-----------------------|
| 1 (One-time) | Year, Month, Day | Year=2, Month=1, Day=3 |
| 2 (Recurring) | Year only | 2 |

When "Day" is selected: `ll_validitydays` becomes visible, `et_validdays` is enabled, user must enter a number.

### 5.5 Validation Rules

| Rule | Error Shown |
|------|-------------|
| Quantity field empty | AlertDialog "Quantity should not be empty." |
| "Day" cycle selected AND validity days empty | AlertDialog "Validity days should not be empty." |
| Validity days empty (non-Day cycle) | Default: `validity_days = 1` |

### 5.6 Return Values to Parent Activity (Intent Extras)

| Extra Key | Type | Description |
|-----------|------|-------------|
| `selProductId` | int | Selected package product ID |
| `selProductName` | String | Selected package name |
| `selQuantity` | int | Quantity entered |
| `selActiveCycle` | String | "Year" / "Month" / "Day" |
| `selValidDays` | int | Validity days (default 1) |
| `selPricingType` | int | `pricing_structure_type` value |

---

## Backend Configuration Values

These values are returned at login (`validateLogin`) or from `getbilldetailsRest` and affect package operation behavior:

| Config Key | Source API | Meaning | Effect on Package Operations |
|------------|-----------|---------|------------------------------|
| `recurringServiceEdit` | `validateLogin` response | int; controls whether recurring service cycle can be changed | If 1, show full cycle spinner (Year/Month/Day); if 0, show Year only regardless of `pricing_structure_type` |
| `show_service_extension` | `validateLogin` response | Whether the "extend service" option is visible | Shows or hides extension option in package list |
| `enum_add_on_after_base` | `getbilldetailsRest` response | Enum controlling whether add-ons can be added without a base pack | Validation during package selection |
| `ENABLE_PRORATA_DISCOUNT` | `getbilldetailsRest` response | Boolean-like flag; enables pro-rata discount calculation | Affects bill amount shown in confirmation dialog |
| `int_stb_activation` | `getaccesscontrollRest` | 1 = employee can activate packages | Show/hide Activate button on hub screen |
| `int_stb_deactivation` | `getaccesscontrollRest` | 1 = employee can deactivate packages | Show/hide Deactivate button on hub screen |
| `patch_information` | `validateLogin` response | Version string (e.g. "1.4.13.2") | Renew button only visible on specific patch versions |

---

## Complete API Call Summary

| # | Operation | Endpoint | Method | Key Request Fields | Key Response Fields |
|---|-----------|----------|--------|--------------------|---------------------|
| 1 | Load available packages | `getUnassignedPackages_splitRest` | POST | `customerId`, `boxNumber` | `packageList_base`, `packageList_addon`, `packageList_ala`, `packageList_broadcaster`, `deactivate_customerservices` |
| 2 | Load channel list | `channel_listRest` | POST | `product_id`, `dealer_id` | `channel_details[]` |
| 3 | Calculate bill before activation | `getbilldetailsRest` | POST | `customer_id`, `package_id`, `serial_number`, `employee_id`, `dealer_id` | `basePrice.lco_share`, `basePrice.mso_share`, `basePrice.total_amount`, `basePrice.ncf_total_amount`, `basePrice.encf_total_amount` |
| 4 | Activate packages | `activateServiceRest` | POST | `customerId`, `productId`, `customerDeviceId`, `dateType`, `pricingStructureType`, `validityDays`, `stockId`, `dealer_id`, `reseller_id`, `login_employee_id`, `fromMobileApp` | `status_code`, `status_msg` |
| 5 | Load active packages for deactivation | `getCustomerPackages_splitRest` | POST | `customerId`, `boxNumber` | `packageList_base`, `packageList_addon`, `packageList_ala`, `packageList_broadcaster` |
| 6 | Load deactivation reasons | `getDeactiveReasonsRest` | POST | `authToken` (+ optional `showforlco`, `stockId`) | `reasonList[]` |
| 7 | Deactivate packages | `deactivateServiceRest` | POST | `customerId`, `serviceId`, `reasonId`, `remarks`, `stock_id`, `dealer_id`, `reseller_id`, `login_employee_id`, `fromMobileApp` | `status_code`, `status_msg` |
| 8 | Load expired services for renewal | `getRenewServicesList` | POST | `customer_id`, `dealer_id` | `getRenewServices[]` |
| 9 | Submit renewal | `renewServicesList` | POST | `customer_id`, `customer_service_id`, `product_ids`, `dealer_id` | `status_code`, `status_msg` |
| 10 | Load CAS packages (new customer) | `getCasPackagesRest` | POST | `authToken`, `boxNumber` | `caspackageList[]` |

---

## Data Model Reference

### PackageModel Fields (Unassigned package for activation)

| Field | Type | Description |
|-------|------|-------------|
| `packageId` | int | product_id from server |
| `packageName` | String | pname |
| `pricingStructureType` | int | 1=one-time, 2=recurring |
| `base_price` | double | Price before tax |
| `sd_channels_count` | int | SD channel count |
| `hd_channels_count` | int | HD channel count |
| `monthly_or_yearly` | String | Billing cycle label |
| `validity` | String | Validity string (e.g. "1 Monthly") |
| `validity_days` | int | Numeric part of validity |
| `isSelected` | boolean | UI selection state (local only) |

### customerpackageList Fields (Active package for deactivation)

| Field | Type | Description |
|-------|------|-------------|
| `serviceId` | int | Customer service ID (used in deactivation `serviceId` param) |
| `packageId` | int | Product ID |
| `productName` | String | Package name |
| `startDate` | String | Service start date |
| `endDate` | String | Service end date |
| `base_price` | double | Price |
| `sd_channels_count` | int | SD count |
| `hd_channels_count` | int | HD count |
| `monthly_or_yearly` | String | Cycle |
| `validity` | String | Validity string |
| `quantity` | int | Quantity |
| `pricing_structure_type` | int | Type |

### RenewalModel Fields (Expired service for renewal)

| Field | Type | Description |
|-------|------|-------------|
| `customer_service_id` | String | Customer service record ID |
| `product_id` | String | Package product ID |
| `base_price` | String | Package price |
| `pname` | String | Package name |
| `isSelected` | boolean | UI selection state |

### ShowPackages Fields (Confirmation dialog display)

| Field | Type | Description |
|-------|------|-------------|
| `packname` | String | Package name |
| `totalamount` | String | Amount as string |
| `startdate` | String | Computed start date (dd-MM-yyyy) |
| `enddate` | String | Computed end date (dd-MM-yyyy) |
| `pricingstructuretype` | int | 1=one-time, 2=recurring |

### Channelvalues Fields (Channel list in package)

| Field | Type | Description |
|-------|------|-------------|
| `channel_id` | int | Channel ID |
| `channel_name` | String | Channel name |
| `channel_language` | String | Language |
| `channel_logo` | String | Logo path/URL |
| `channel_price` | double | Channel price |

### Deactpacklist Fields (Currently active services shown as reference)

| Field | Type | Description |
|-------|------|-------------|
| `service_start_date` | String | Service start date |
| `service_end_date` | String | Service end date |
| `product_name` | String | Package name |
| `pricing_struct_type` | String | Pricing type label |
| `quantity` | int | Quantity |

---

## Flutter Migration Notes

1. **SOAP → REST:** All operations in this module use legacy ksoap2 SOAP calls in Android. Every call has a V2 REST equivalent as documented above. Do not implement SOAP in Flutter.

2. **Multi-select pattern:** Both activation and deactivation use a checkbox-based multi-select across four category tabs. The selection state must be maintained across tab switches (store selection in a shared list/set, not per-tab adapter).

3. **Date computation:** Start and end dates for newly activated packages are computed locally using device date + `validity` / `validity_days`. This is for display only in the confirmation dialog; the server does its own date computation on activation.

4. **`totalstrs` format:** All multi-select operations send selected IDs as a comma-separated string (no trailing comma). Build this in Flutter using `List.join(',')`.

5. **Bill flow before activation:** The "Get Bill" step is mandatory before the "Activate" button appears. The flow is: select packages → tap Save → see summary → tap "Get Bill" → see share breakdown → tap "Activate" → confirm → API call.

6. **Remarks append:** Deactivation remarks must append `".Deactivation From Flutter App"` (or equivalent) as the Android app appends `".Deactivation From Android App"`.

7. **Reason filtering:** Deactivation reason items with `id == 21`, `id == 17`, or `global_reason == 1` are excluded from the dropdown. Apply this filter client-side after fetching.

8. **Access control flags:** Store `int_stb_activation` and `int_stb_deactivation` (from `getaccesscontrollRest`) in app state and use them to conditionally render action buttons.

9. **Renew button gating:** The Renew button uses both `isexpired == 1` (from STB details) AND a `patch_information` string check. In Flutter, both conditions must be true; consider removing the patch_information check and driving this purely from `isexpired` unless the backend explicitly controls renewal availability.

10. **`fromMobileApp` flag:** Always send `fromMobileApp = 1` (int) in activation and deactivation API calls.
