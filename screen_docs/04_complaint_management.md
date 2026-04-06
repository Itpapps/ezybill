# 04 - Complaint Management

> **Source analyzed:** Android `activities_fragments/`, `complexclasses/`, and `adapter/` packages.
> **API reference:** `REST_API_V2_SERVICE_DOCUMENT.md` - Section 5 (Complaints, 9 endpoints).
> **Migration target:** Flutter (V2 REST API only — all legacy SOAP calls must be replaced).

---

## Table of Contents

1. [Module Overview](#1-module-overview)
2. [Screen: Complaint Dashboard](#2-screen-complaint-dashboard)
3. [Screen: Open Complaints List](#3-screen-open-complaints-list)
4. [Screen: Complaint Operations (Customer-Linked)](#4-screen-complaint-operations-customer-linked)
5. [Screen: New Complaint Creation](#5-screen-new-complaint-creation)
6. [Screen: Complaint Search Result List](#6-screen-complaint-search-result-list)
7. [Screen: Update Complaint (ComplaintHistory_Other)](#7-screen-update-complaint-complainthistory_other)
8. [Screen: Closed Complaint Detail (ComplaintHistory_Close)](#8-screen-closed-complaint-detail-complainthistory_close)
9. [Screen: Complaint History (Customer-Linked)](#9-screen-complaint-history-customer-linked)
10. [Data Models Reference](#10-data-models-reference)
11. [Complete V2 REST API Reference](#11-complete-v2-rest-api-reference)
12. [Access Control and Visibility Rules](#12-access-control-and-visibility-rules)
13. [Status Color Mapping](#13-status-color-mapping)
14. [Flutter Migration Notes](#14-flutter-migration-notes)

---

## 1. Module Overview

The Complaint Management module covers the full lifecycle of a customer complaint:

| Stage | Android Class | Purpose |
|-------|--------------|---------|
| Dashboard summary | `ComplaintDashboard` | Shows all complaints paginated, total count |
| Open complaint list | `OpenComplaints_frag` | LCO-wide open complaints, filterable by service employee |
| Customer complaint ops | `Complaint_Operations_Fragment` | Entry point when navigating from a customer record |
| New complaint | `Complaint_NewComplint_Fragment` | Creates a complaint linked to a customer |
| Customer complaint list | `ComplaintSearchResultList_Fragment` | Lists complaints for a specific customer |
| Update complaint | `ComplaintHistory_Other_Fragment` | Change status, add comment, assign employee |
| Closed complaint view | `ComplaintHistory_Close_Fragment` | Read-only view of a closed complaint |
| Complaint history | `ComapliantHistory` | Per-customer complaint history list |

### Entry Points

- **From main menu:** `ComplaintDashboard` and `OpenComplaints_frag` are top-level fragments accessible directly.
- **From customer record:** The flow is `CustomerSearchList_Fragment` → `Complaint_Operations_Fragment` → new/update complaint.

### Access Control Flags (from login response)

| Flag | Source | Effect |
|------|--------|--------|
| `showLcoComplaint` | `validateLogin` response | Controls whether complaint menu items are shown at all |
| `access_for_complaints` | `getaccesscontrollRest` response | Fine-grained permission for complaint operations |
| `patch_information` | `validateLogin` response | Version string; values `1.4.13.2`, `1.4.13.3`, `1.4.13.4` enable subcategory cascade and employee assignment on new complaints, and ticket number display on success |
| `userType` | `validateLogin` response | `TEAMLEAD` requires service employee selection before complaint update |

---

## 2. Screen: Complaint Dashboard

**Android class:** `ComplaintDashboard.java`
**Layout:** `fragment_compalint_dashboard`
**Action bar title:** (none set explicitly — inherits parent)
**Purpose:** Displays a paginated list of all complaints across the LCO, using the `gettotalcomplaintslist` Retrofit endpoint.

### 2.1 UI Elements

| Element | Type | Widget | Description |
|---------|------|--------|-------------|
| Total count label | TextView | `tv_ttlcount` | Shows "Total Complaints - N" |
| Complaint list | ListView | `listview1` | Paginated complaint rows via `OpenComplaintsAdapter` |
| Page navigation | LinearLayout | `linear_scroll` | Dynamically generated page-number buttons |

### 2.2 Pagination Logic

- Page size: **5 rows per page** (`rowSize = 5`).
- Number of page buttons = `ceil(total / 5)`.
- Active page button background: `R.color.btnblue` with white text.
- Inactive buttons: transparent background, `R.color.textclr` text.
- On page button click: `loadList(pageIndex)` slices `openComplaintsModelArrayList` and sets a new `OpenComplaintsAdapter`.

### 2.3 API Call

**Endpoint:** `POST /LcoRestServices/gettotalcomplaintslist`
**Library:** Retrofit2 (`Api.gettotalcomplist`)
**Method key in Api interface:** `@POST("gettotalcomplaintslist")`

#### Request Parameters

| Parameter | Source | Type | Notes |
|-----------|--------|------|-------|
| `authtoken` | `LoginActivity.authToken` | String | JWT token |
| `dealer_id` | `LoginActivity.dealerId` | int | LCO dealer ID |
| `employee_id` | `LoginActivity.employeeId` | int | Logged-in employee |

#### Response Model (`totalcomprreq`)

| JSON Field | Java Field | Type | Description |
|------------|-----------|------|-------------|
| `status_code` | `status_code` | int | `0` = success, `1` = failure |
| `status_msg` | `status_msg` | String | Human-readable message |
| `getDashboardDataList` | `openComplaintsModels` | `List<OpenComplaintsModel>` | Array of complaint objects |

#### Response Handling

| `status_code` | Action |
|--------------|--------|
| `0` | Populate `tv_ttlcount`, render paginated list, show page buttons |
| `1` | Dismiss progress, show AlertDialog with status message |
| Network failure | Toast with `t.getMessage()` |

### 2.4 Data Fields Displayed (per row via `OpenComplaintsAdapter`)

See [Section 3.4](#34-list-row-data-fields) for the full `OpenComplaintsModel` field mapping — the same adapter is used here.

---

## 3. Screen: Open Complaints List

**Android class:** `OpenComplaints_frag.java`
**Layout:** `fragment_open_complaint`
**Action bar title:** (inherited)
**Purpose:** Shows all open complaints for the LCO, with optional service employee filter (TEAMLEAD users). Uses Volley HTTP POST.

### 3.1 UI Elements

| Element | Type | Widget | Description |
|---------|------|--------|-------------|
| Total count label | TextView | `tv_ttlcount` | "Total Complaints - N" |
| Complaint list | ListView | `listview1` | Paginated; 5 per page |
| Page buttons | LinearLayout | `linear_scroll` | Dynamic page-number buttons |
| Service employee filter | Spinner | `complainthistory_spin_seremp` | Hidden by default; shown when TEAMLEAD |
| Service employee container | LinearLayout | `ll_servemp` | Wraps the filter spinner |

### 3.2 Initialization Flow

```
onCreateView()
  └─ isNetworkAvailable()
  └─ getopencomplaints()           ← always called on load
  └─ [if TEAMLEAD] service_emp_list()   ← commented out in current code
  └─ complainthistory_spin_seremp.setOnItemSelectedListener()
        └─ on "select" → selempid = -1, getopencomplaints()
        └─ on employee selected → selempid = employee_id, getopencomplaints()
```

### 3.3 API Call: Get Open Complaints

**Endpoint:** `POST {gcl_property_url}`
**Property key:** `gcl` (resolved via `PropertyReader`, maps to `getComplaintList`)
**Full URL:** `{base_url_without_wsController}{gcl}`
**Library:** Volley `StringRequest`

#### Request Parameters

| Parameter | Source | Type | Notes |
|-----------|--------|------|-------|
| `authtoken` | `LoginActivity.authToken` | String | JWT token |
| `dealer_id` | `LoginActivity.dealerId` | String | LCO dealer ID |
| `users_type` | `LoginActivity.userType` | String | e.g. `DEALER`, `TEAMLEAD` |
| `serviceemployeeid` | `selempid` (default `-1`) | String | `-1` = all employees |

**V2 REST equivalent:** `POST /LcoRestServices/getComplaintList`

#### Response JSON Structure

```json
{
  "status_code": 0,
  "status_msg": "Success",
  "lcoComplaintlist": "[{...}, {...}]"
}
```

#### `lcoComplaintlist` Array Fields

| JSON Field | Model Setter | Type | Description |
|------------|-------------|------|-------------|
| `customer_id` | `setCustomer_id()` | String | Internal customer ID |
| `customer_account_id` | `setCustomer_account_id()` | String | LCO account number |
| `CAF` | `setCAF()` | String | CAF/CRF reference number |
| `simple_complaint_id` | `setSimple_complaint_id()` | String | Internal complaint ID (integer as string) |
| `tkt_number` | `setTkt_number()` | String | Ticket number |
| `description` | `setDescription()` | String | Complaint description text |
| `date` | `setDate()` | String | Complaint creation date |
| `customer_name` | `setCustomer_name()` | String | Customer display name |
| `status` | `setStatus()` | String | Current complaint status |
| `complaint` | `setComplaint()` | String | Complaint type/category text |
| `assigned_name` | `setAssigned_name()` | String | Assigned employee name (nullable) |
| `assigned_employee_id` | `setAssigned_employee_id()` | String | Assigned employee ID (nullable, default `"0"`) |

#### Response Handling

| `status_code` | Action |
|--------------|--------|
| `0` | Build `openComplaintsModelArrayList`, set `tv_ttlcount`, paginate, render list |
| `1` | Hide list, set "Total Complaints - 0", show AlertDialog with `status_msg` |
| Network error | Toast "Failed." |

### 3.4 List Row Data Fields

Rendered by `OpenComplaintsAdapter` (`row_opencomplaints` layout):

| Widget ID | Content | Source Field |
|-----------|---------|-------------|
| `opencomplaints_ticketnum_tv` | "Ticket No. {tkt_number}" | `tkt_number` |
| `opencomplaints_custname_tv` | "Customer Name - {name}" | `customer_name` |
| `opencomplaints_status_tv` | Status string | `status` |
| `igv_bgclr` | Color bar (status-coded) | `status` |
| `opencomplaint_goto_box` | Tap to open detail dialog | — |
| `tv_updatestatus` | "Update" button → opens `ComplaintHistory_Other_Fragment` | — |

**Detail dialog** (on `opencomplaint_goto_box` touch-down, layout `opencomplaints_items`):

| Widget | Content |
|--------|---------|
| `opencomplaints_ticketnum_tv111` | "Ticket No. {tkt_number}" |
| `opencomplaints_desc_tv` | Description (stripped of ".Complaint Created from Android app" suffix) |
| `opencomplaints_lcocustid_tv` | `customer_account_id` |
| `opencomplaints_crf_tv` | `CAF` value |
| `opencomplaint_goto_cancel` | Close dialog |

### 3.5 API Call: Get Service Employee List

**Endpoint:** `POST {gsel_property_url}`
**Property key:** `gsel` (maps to service employee list endpoint)
**Library:** Volley `StringRequest`
**Note:** This call is currently commented out in `OpenComplaints_frag`; it was intended for TEAMLEAD users.

#### Request Parameters

| Parameter | Source | Type |
|-----------|--------|------|
| `authtoken` | `LoginActivity.authToken` | String |
| `dealer_id` | `LoginActivity.dealerId` | String |

#### Response JSON Fields

| Field | Type | Description |
|-------|------|-------------|
| `status_code` | int | `0` = success |
| `status_msg` | String | Message |
| `getServiceEmployeeList` | JSON array | List of service employees |

#### `getServiceEmployeeList` Array Fields

| Field | Type | Description |
|-------|------|-------------|
| `employee_id` | String | Employee ID |
| `first_name` | String | Employee name shown in spinner |

**Spinner default option:** "select" mapped to `selempid = -1`.

---

## 4. Screen: Complaint Operations (Customer-Linked)

**Android class:** `Complaint_Operations_Fragment.java`
**Layout:** `complaints_operations_new`
**Action bar title:** "Complaint Operations"
**Purpose:** Entry-point menu shown after selecting a customer. Offers "New Complaint" or "Update Complaint" (search existing complaints for the customer). Uses SOAP (`getCustomerComplaintList`) — must be migrated to V2 REST.

### 4.1 Incoming Bundle Parameters

| Key | Type | Description |
|-----|------|-------------|
| `custId` | int | Customer `altCustomerId` |
| `reseller_id` | int | Reseller/parent ID |
| `custName` | String | Customer display name |
| `reqOrigin` | String | Source screen identifier |

### 4.2 UI Elements

| Element | Type | Widget | Description |
|---------|------|--------|-------------|
| Customer name | TextView | `complaintoper_tv_custname` | Name truncated at 18 chars with line break |
| Customer ID | TextView | `complaintoper_tv_custid` | `altCustId` |
| New Complaint button | LinearLayout | `complaintoper_btn_newcomp` | Navigates to `Complaint_NewComplint_Fragment` |
| Update Complaint button | LinearLayout | `complaintoper_btn_updatecomp` | Triggers SOAP search for customer complaints |

### 4.3 Name Truncation Logic

If `custName.length() >= 20`:
- Line 1: `custName.substring(0, 18)`
- Line 2: `custName.substring(18, length)`

### 4.4 Workflow: New Complaint Button

```
onClick "New Complaint"
  └─ create Complaint_NewComplint_Fragment
  └─ bundle: custId, reseller_id, custname
  └─ mainActivity.changeFragment(newComplaintFrag, true)
```

### 4.5 Workflow: Update Complaint Button (SOAP - migrate to REST)

**SOAP method key:** `cclist` (property `cclist` in `PropertyReader`)

The SOAP call (`getCustomerComplaintList`) sends:

| SOAP Field | Value |
|-----------|-------|
| `altCustomerId` | `altCustId` |
| `authToken` | `LoginActivity.authToken` |

**V2 REST equivalent:** `POST /LcoRestServices/getCustomerComplaintListRest`

#### V2 REST Request Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `altCustomerId` | int | Customer ID |
| `authToken` | String | JWT token |
| `status` | String | Optional status filter |
| `userType` | String | User type |

#### Response Parsing (SOAP fields mapped to `customerComplaintList`)

| Property Index | Field Name | Type | Description |
|---------------|-----------|------|-------------|
| 0 | `customerId` | int | Internal customer ID |
| 1 | `customNumber` | String | Customer account number |
| 2 | `customerName` | String | Customer name |
| 3 | `group` | String | Group name |
| 4 | `complaintId` | int | Internal complaint ID |
| 5 | `ticketNumber` | String | Ticket number |
| 6 | `complaint` | String | Complaint description |
| 7 | `complaintTime` | String | Creation timestamp |
| 8 | `status` | String | Current status |
| 9 | `assigned_name` | String | Assigned employee name |
| 10 | `assigned_employee_id` | int | Assigned employee ID |

#### Response Status Codes

| Code | Action |
|------|--------|
| `0` | Navigate to `ComplaintSearchResultList_Fragment` with complaint ArrayList |
| `1` | AlertDialog "Complaints not found! No complaints registered for this customer." |
| `>= 2` | AlertDialog same message as code 1 |
| null | AlertDialog "Server connectivity error!" |

---

## 5. Screen: New Complaint Creation

**Android class:** `Complaint_NewComplint_Fragment.java`
**Layout:** `complaints_newcomplaints_new`
**Action bar title:** "New Complaint"
**Purpose:** Creates a new complaint linked to a specific customer. Uses cascading dropdowns: category → subcategory → error type. Optionally assigns an LCO employee.

### 5.1 Incoming Bundle Parameters

| Key | Type | Description |
|-----|------|-------------|
| `custId` | int | Customer `altCustomerId` |
| `reseller_id` | int | Reseller ID (passed to employee list API) |
| `custname` | String | Customer display name |

### 5.2 UI Elements

| Element | Type | Widget | Description |
|---------|------|--------|-------------|
| Customer name label | TextView | `complaint_tv_custname1` | Label "Customer Name" |
| Customer name value | TextView | `complaint_tv_custname` | Displays `custname` (bold) |
| CRF label | TextView | `complaint_tv_crf1` | Label "CRF/CAF" |
| CRF value | TextView | `complaint_tv_crf` | Displays `altCustId` |
| Category spinner | Spinner | `newcomplint_spin_compCat` | Primary category list (SOAP) |
| Subcategory spinner | Spinner | `newcomplint_spin_subcompCat` | Subcategory (REST, shown conditionally) |
| Subcategory container | LinearLayout | `ll_subcategory` | Hidden until category selected |
| Employee spinner | Spinner | `newcomplint_spin_emplist` | LCO employee list (REST, shown conditionally) |
| Employee container | LinearLayout | `ll_employeelist` | Hidden until data loaded |
| Complaint text | EditText | `newComplint_et_complint` | Free-text description (auto-populated from spinner) |
| Register button | Button | `newComplint_btn_register` | Submits complaint |
| Category label | TextView | `tv_compcate` | "Complaint Category" |
| Subcategory label | TextView | `tv_compsubcate` | "Subcategory" |
| New complaint label | TextView | `tv_newcomp` | "Complaint Description" |
| Employee label | TextView | `tv_selemp` | "Assign To Employee" |

### 5.3 Initialization Flow

```
onCreateView()
  └─ isNetworkAvailable()
  └─ if network available:
      └─ new ComplaintCategoriesList().execute()     [SOAP → migrate to REST complaintCategoriesRest]
      └─ if patch_information in {1.4.13.2, 1.4.13.3, 1.4.13.4}:
          └─ emplistcategory()                       [REST: getLcoEmployeeList]
  └─ newcomplint_spin_subcompCat.setOnItemSelectedListener()
      └─ if selstateid > 0: et_entercomplint.setText(selectedSubcategoryName)
  └─ newcomplint_spin_emplist.setOnItemSelectedListener()
      └─ if "select": selempid = 0
      └─ else: selempid = mapped employee ID
  └─ spin_complaintCat.setOnItemSelectedListener()   [set in onPostExecute of ComplaintCategoriesList]
      └─ store CategoriesIdValue, CategoriesName
      └─ et_entercomplint.setText(CategoriesName)
      └─ if patch_information in {1.4.13.2, 1.4.13.3, 1.4.13.4}:
          └─ complaintsubcategory()                  [REST: getComplaintsubCategory]
```

### 5.4 Category Selection and Text Auto-Fill

- When a category is selected from `spin_complaintCat`, its name is automatically written into `et_entercomplint`.
- When a subcategory is then selected from `newcomplint_spin_subcompCat` (and `selstateid > 0`), the subcategory name overwrites `et_entercomplint`.
- When an error type is selected from `spin_complaintErr` (legacy SOAP path, `@SuppressWarnings("unused")`), its description overwrites `et_entercomplint`.

### 5.5 API Calls

#### 5.5.1 Get Complaint Categories (SOAP — migrate to REST)

**SOAP property key:** `ccate`
**V2 REST equivalent:** `POST /LcoRestServices/complaintCategoriesRest`

**SOAP request:**

| Field | Value |
|-------|-------|
| `authToken` | `LoginActivity.authToken` |

**V2 REST request:** No payload parameters needed (uses JWT from header).

**Response fields:**

| Field | Description |
|-------|-------------|
| `complaintCategories` | Array of `{categoryId: int, categoryName: String}` |
| `status_msg` | Message |

#### 5.5.2 Get Complaint Subcategories (REST — already V2 compatible)

**Endpoint:** `POST {cscate_property_url}`
**V2 REST equivalent:** `POST /LcoRestServices/getComplaintsubCategory`
**Library:** Volley `StringRequest`

**Request Parameters:**

| Parameter | Source | Type |
|-----------|--------|------|
| `authtoken` | `LoginActivity.authToken` | String |
| `complaintcategory` | `CategoriesIdValue` | String (int) |
| `dealer_id` | `LoginActivity.dealerId` | String |

**Response JSON:**

```json
{
  "status_code": 0,
  "status_msg": "Success",
  "complaintSubCategories": "[{...}]"
}
```

**`complaintSubCategories` array fields:**

| Field | Type | Description |
|-------|------|-------------|
| `complaint_category_id` | String | Subcategory ID |
| `complaint_category_name` | String | Subcategory display name |

**Response handling:**

| `status_code` | Action |
|--------------|--------|
| `0` | Populate `newcomplint_spin_subcompCat`, show `ll_subcategory` |
| `1` | Toast "No subcategories found", hide `ll_subcategory` |

#### 5.5.3 Get LCO Employee List (REST — already V2 compatible)

**Endpoint:** `POST {glel_property_url}`
**V2 REST equivalent:** (maps to getLcoEmployeeList or similar)
**Library:** Volley `StringRequest`
**Condition:** Only called when `patch_information` is `1.4.13.2`, `1.4.13.3`, or `1.4.13.4`.

**Request Parameters:**

| Parameter | Source | Type |
|-----------|--------|------|
| `authtoken` | `LoginActivity.authToken` | String |
| `dealer_id` | `LoginActivity.dealerId` | String |
| `employee_id` | `reseller_id` | String |

**Response JSON:**

```json
{
  "status_code": 0,
  "status_msg": "Success",
  "lcoEmployeelist": "[{...}]"
}
```

**`lcoEmployeelist` array fields:**

| Field | Type | Description |
|-------|------|-------------|
| `lco_employee_id` | String | Employee ID |
| `lco_employee_name` | String | Employee display name |

**Response handling:**

| `status_code` | Action |
|--------------|--------|
| `0` | Populate `newcomplint_spin_emplist`, show `ll_employeelist`. First option is "select" (ID=0) |
| `1` | Toast "No employee details found", hide `ll_employeelist`, `selempid = 0` |

**Note:** There is a bug in the Android code — the "select" default entry is added inside the loop, causing it to be duplicated. Flutter should add "select" once before the loop.

#### 5.5.4 Get Complaint Errors (SOAP — legacy, not currently wired to UI)

**SOAP property key:** `cerr`
**V2 REST equivalent:** (no direct equivalent documented; use subcategory cascade instead)
**Status:** `@SuppressWarnings("unused")` — the `spin_complaintErr` spinner is commented out. Do not implement in Flutter.

#### 5.5.5 Create Complaint (SOAP — migrate to REST)

**SOAP property key:** `ccrea`
**V2 REST equivalent:** `POST /LcoRestServices/createComplaintRest`

**SOAP request object (`createComplaintInfo`):**

| Field | Source | Type | Description |
|-------|--------|------|-------------|
| `customerId` | `altCustId` | int | Customer ID |
| `authToken` | `LoginActivity.authToken` | String | JWT token |
| `complaint` | `et_entercomplint.getText() + ".Complaint Created from Android app"` | String | Description (with suffix appended) |
| `category` | `selstateid > 0 ? selstateid : CategoriesIdValue` | int | Subcategory ID if selected, else category ID |
| `error` | `ErrorId` (default 0) | int | Error type ID (legacy, usually 0) |
| `assignedTo` | `selempid` | int | Assigned employee ID (0 = unassigned) |

**V2 REST request parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `customerId` | int | Yes | Customer `altCustomerId` |
| `complaint` | String | Yes | Description text (append ".Complaint Created from Android app" suffix) |
| `category` | int | Yes | Category or subcategory ID |
| `error` | int | No | Error type ID (send 0 if unused) |
| `assignedTo` | int | No | Employee ID to assign (0 = unassigned) |

**V2 REST response fields:**

| Field | Type | Description |
|-------|------|-------------|
| `status_code` | int | `0` = success, `1` = failure |
| `status_msg` | String | Message |
| `ticketNumber` | String | Generated ticket number (shown in success dialog) |
| `tkt_number` | String | Alternative ticket number field |
| `requestId` | String | Server-side request ID |
| `assignedTo` | String | Assigned employee |

**Response handling:**

| `status_code` | Action |
|--------------|--------|
| `0` | Show AlertDialog "New Complaint Registered Successfully." with Category, Complaint text, and (if patch >= 1.4.13.2) Ticket No. Then popBackStack. |
| `1` | AlertDialog "Complaint registration Failed!" with `statusMessage` |
| `>= 2` | AlertDialog failure (same structure) |
| null | AlertDialog "Server connectivity error!" |

### 5.6 Validation Rules

| Rule | Condition | Error Dialog |
|------|-----------|-------------|
| Complaint text required | `et_entercomplint.getText().toString().equalsIgnoreCase("")` | "Complaint should not be empty." |
| Network required | `activeNetworkInfo == null` | "No internet connection!" |
| Category required | No explicit validation — `CategoriesIdValue` defaults to 0; a category must be loaded | No explicit guard (API will fail) |

### 5.7 Description Suffix

The Android app appends `.Complaint Created from Android app` to every complaint description before submission. In Flutter, this suffix should be retained for backward compatibility so that the existing display-stripping logic in other screens continues to work.

When displaying complaint descriptions in any screen, strip this suffix:
```dart
desc.replaceAll('.Complaint Created from Android app', '')
```

---

## 6. Screen: Complaint Search Result List

**Android class:** `ComplaintSearchResultList_Fragment.java`
**Layout:** `complaints_list_fragment`
**Action bar title:** "Complaint List"
**Purpose:** Displays the list of complaints fetched for a specific customer (from `Complaint_Operations_Fragment`). Tapping a complaint routes to either update or view based on status.

### 6.1 Incoming Bundle

| Key | Type | Source |
|-----|------|--------|
| `complintList` | `ArrayList<customerComplaintList>` (Parcelable) | From `Complaint_Operations_Fragment` |

### 6.2 UI Elements

| Element | Type | Widget | Description |
|---------|------|--------|-------------|
| Column header | TextView | `complist_tv_title` | "SNo     Ticket No      Status" |
| List | ListView | (ListFragment built-in) | Rows showing serial, ticket, status |

### 6.3 List Row Format

Each row displays:
```
{i+1}     {ticketNumber}     {status}
```
(Using `SimpleAdapter` mapping `complaint_text` to `list_txt_compli_complinttxt`.)

### 6.4 On List Item Click — Routing Logic

| Condition | Destination | Bundle Keys Passed |
|-----------|------------|-------------------|
| `status.equalsIgnoreCase("CLOSED")` | `ComplaintHistory_Close_Fragment` | `custName`, `complaint`, `status`, `complaintId`, `ticketNumber`, `reseller_id` |
| Any other status | `ComplaintHistory_Other_Fragment` | `custName`, `complaint`, `status`, `altCustId`, `complaintId`, `ticketNumber`, `assigned_name`, `assigned_employee_id` |

### 6.5 Data Fields Passed to Next Screen

**For `ComplaintHistory_Close_Fragment`:**

| Bundle Key | Source |
|-----------|--------|
| `custName` | `customerName` |
| `complaint` | `complaint` (description) |
| `status` | `status` |
| `complaintId` | `complaintId` (as String) |
| `ticketNumber` | `ticketNumber` |
| `reseller_id` | `CustomerSearchList_Fragment.resellerid` |

**For `ComplaintHistory_Other_Fragment`:**

| Bundle Key | Source |
|-----------|--------|
| `custName` | `customerName` |
| `complaint` | `complaint` |
| `status` | `status` |
| `altCustId` | `altCustId` |
| `complaintId` | `complaintId` |
| `ticketNumber` | `ticketNumber` |
| `assigned_name` | `assigned_name` |
| `assigned_employee_id` | `assigned_employee_id` |

---

## 7. Screen: Update Complaint (ComplaintHistory_Other)

**Android class:** `ComplaintHistory_Other_Fragment.java`
**Layout:** `complaint_updatecomplaint`
**Action bar title:** "Update Complaint"
**Purpose:** Allows changing a complaint's status and optionally reassigning it to a service employee. Uses SOAP for both fetching statuses and submitting the update — both must be migrated to V2 REST.

### 7.1 Incoming Bundle Parameters

| Key | Type | Description |
|-----|------|-------------|
| `custName` | String | Customer display name |
| `complaint` | String | Complaint description |
| `status` | String | Current status |
| `altCustId` | int | Customer ID |
| `complaintId` | int | Internal complaint ID |
| `ticketNumber` | String | Ticket number |
| `reseller_id` | int | Reseller ID |
| `assigned_name` | String | Currently assigned employee name |
| `assigned_employee_id` | int | Currently assigned employee ID |

### 7.2 UI Elements

| Element | Type | Widget | Description |
|---------|------|--------|-------------|
| Customer name label | TextView | `complainthistoryot_tv_custname1` | "Customer Name" |
| Customer name value | TextView | `complainthistoryot_tv_custname` | Displays `customerName` |
| Ticket number label | TextView | `complainthistoryot_tv_tktno1` | "Ticket No." |
| Ticket number value | TextView | `complainthistoryot_tv_tktno` | Displays `ticketNumber` |
| Complaint label | TextView | `complainthistoryot_tv_complaint1` | "Complaint" |
| Complaint value | TextView | `complainthistoryot_tv_complaint` | Displays `complaint` (strips ".Complaint Created from Android app") |
| Status label | TextView | `complainthistoryot_tv_status1` | "Current Status" |
| Status value | TextView | `complainthistoryot_tv_status` | Displays current `status` |
| Update complaint label | TextView | `tv_updatecomp` | "Update Complaint" section header |
| Status spinner label | TextView | `tv_updatestatus` | "New Status" |
| Status spinner | Spinner | `complainthistory_spin_status` | Loaded from `complaintTypesRest` |
| Comment label | TextView | `complainthistory_lbl_comment` | "Comment" |
| Comment field | EditText | `complainthistory_et_comment` | Free-text mandatory |
| Service employee label | (implicit) | — | Shown for TEAMLEAD |
| Service employee spinner | Spinner | `complainthistory_spin_seremp` | Employee assignment |
| Service employee container | LinearLayout | `ll_servemp` | Hidden unless TEAMLEAD |
| Update button | Button | `complainthistory_btn_update` | Submits update |

### 7.3 Initialization Flow

```
onCreateView()
  └─ Load bundle data into TextViews
  └─ Strip ".Complaint Created from Android app" from complaint display
  └─ if network available:
      └─ new ComplaintTypeList().execute()    [SOAP → migrate to complaintTypesRest]
      └─ [if TEAMLEAD] service_emp_list()    [REST, currently commented out]
  └─ Set spinner selection to match current status
```

### 7.4 Update Button Validation Logic

```
onClick "Update"
  └─ if comment is empty → AlertDialog "Comment should not be empty."
  └─ else if userType == "TEAMLEAD":
      └─ if selempid == -1 → AlertDialog "Please select a Service Employee"
      └─ else → new CloseComplaint().execute()
  └─ else (DEALER/ADMIN):
      └─ new CloseComplaint().execute()
```

### 7.5 API Call: Get Complaint Status Types (SOAP — migrate to REST)

**SOAP property key:** `ctypes`
**V2 REST equivalent:** `POST /LcoRestServices/complaintTypesRest`

**SOAP request:**

| Field | Value |
|-------|-------|
| `authToken` | `LoginActivity.authToken` |

**V2 REST request:** No payload (uses JWT from header).

**Response fields (`complaintStatuses` SOAP / `ticket_closer_categories` REST):**

| Field | Description |
|-------|-------------|
| `value` (SOAP) / `ticket_closer_categories` (REST) | Array of status name strings |
| `status_msg` | Message |

**Spinner pre-selection:** After loading, the spinner automatically selects the item matching the current `status` string passed in the bundle.

### 7.6 API Call: Update/Close Complaint (SOAP — migrate to REST)

**SOAP property key:** `clcomp`
**V2 REST equivalent:** `POST /LcoRestServices/closeComplaintRest`

**SOAP request object (`closeComplaintInfo`):**

| Field | Source | Type | Description |
|-------|--------|------|-------------|
| `authToken` | `LoginActivity.authToken` | String | JWT token |
| `complaintId` | `complaintId` (from bundle) | int | Internal complaint ID |
| `ticketNumber` | `ticketNumber` (from bundle) | String | Ticket number |
| `comment` | `et_comment.getText() + ".Complaint Status Change From Android app"` | String | Comment with suffix |
| `status` | `spin_compStatusType` (selected spinner value) | String | New status |
| `assignedemp` | `selempid` (default `-1`) | int | Assigned employee ID |

**V2 REST request parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `complaintId` | int | Yes | Internal complaint ID |
| `ticketNumber` | String | Yes | Ticket number |
| `comment` | String | Yes | Resolution comment (append ".Complaint Status Change From Android app") |
| `status` | String | Yes | New status value from spinner |
| `assignedemp` | int | No | Employee ID (use `-1` or `0` if unassigned) |
| `closer_ticket_type_id` | int | No | Closure type (V2 only, not in Android) |
| `closer_reason_id` | int | No | Closure reason (V2 only, not in Android) |

**V2 REST response fields:**

| Field | Type | Description |
|-------|------|-------------|
| `status_code` | int | `0` = success, `1` = failure |
| `status_msg` | String | Message |

**Response handling:**

| `status_code` | Action |
|--------------|--------|
| `0` | AlertDialog "Complaint updated successfully." showing `complaintId`, comment, new status. On OK: `popBackStack()` |
| `1` | AlertDialog "Update Failed!" with `statusMessage`. On OK: `popBackStack()` |
| `>= 2` | AlertDialog "Update Failed!" with `statusMessage`. On OK: `popBackStack()` |
| null | AlertDialog "Server connectivity error!" |

### 7.7 API Call: Service Employee List (REST)

**Endpoint:** `POST {gsel_property_url}`
**Property key:** `gsel`
**Condition:** TEAMLEAD user type only (commented out in current code).

Same as described in [Section 3.5](#35-api-call-get-service-employee-list).

### 7.8 Comment Suffix

The Android app appends `.Complaint Status Change From Android app` to all comments submitted from this screen. Retain this suffix in Flutter for consistency with server-side history records.

---

## 8. Screen: Closed Complaint Detail (ComplaintHistory_Close)

**Android class:** `ComplaintHistory_Close_Fragment.java`
**Layout:** `complaint_close`
**Action bar title:** "Closed Complaint"
**Purpose:** Read-only display of a complaint that has status "CLOSED". No API calls are made from this screen.

### 8.1 Incoming Bundle Parameters

| Key | Type | Description |
|-----|------|-------------|
| `custName` | String | Customer name |
| `ticketNumber` | String | Ticket number |
| `complaint` | String | Complaint description |
| `status` | String | Status (always "CLOSED" when this screen is shown) |

### 8.2 UI Elements

| Element | Type | Widget | Content |
|---------|------|--------|---------|
| Customer name | TextView | `complainthistory_tv_custname` | `customerName` |
| Ticket number | TextView | `complainthistory_tv_compid` | `tktNo` |
| Complaint | TextView | `complainthistory_tv_complaint` | `complaint` |
| Status | TextView | `complainthistory_tv_status` | `status` |
| Close button | Button | `complainthistory_btn_close` | Pops back stack (no API call) |

### 8.3 Notes

- This is a pure display screen. All data is passed in the navigation bundle.
- In Flutter, implement as a read-only detail page with a single back navigation button.

---

## 9. Screen: Complaint History (Customer-Linked)

**Android class:** `ComapliantHistory.java`
**Layout:** `fragment_comapliant_history`
**Action bar title:** (inherited)
**Purpose:** Shows the full complaint history for a specific customer. Uses SOAP (`ComplaintHistory`) — must be migrated to V2 REST.

### 9.1 Incoming Bundle Parameters

| Key | Type | Description |
|-----|------|-------------|
| `custId` | int | Customer ID |

### 9.2 UI Elements

| Element | Type | Widget | Description |
|---------|------|--------|-------------|
| Total count | TextView | `complaint_total_counts` | "Total Complaints - N" |
| History list | ListView | `lv_complaints` | Rendered by `ComplaintAdapter` |

### 9.3 List Row Columns (from `ComplaintAdapter`, layout `row_complainthistory`)

| Widget ID | Field | Description |
|-----------|-------|-------------|
| `complainthistory_row_tickt` | `tkt_number` | Ticket number |
| `complainthistory_row__date` | `date` | Complaint date |
| `complainthistory_row_category` | `category` | Category name |
| `complainthistory_row_Complaint` | `description` | Complaint description |
| `complainthistory_row_Status` | `status` | Current status |

### 9.4 API Call: Get Complaint History (SOAP — migrate to REST)

**SOAP property key:** `chist`
**SOAP method name:** `ComplaintHistory`
**V2 REST equivalent:** `POST /LcoRestServices/ComplaintHistoryRest`

**SOAP request object (`Invoicedatas`):**

| Field | Value |
|-------|-------|
| `authToken` | `LoginActivity.authToken` |
| `customer_id` | `customerId` (from bundle) |
| `dealer_id` | `LoginActivity.dealerId` |

**V2 REST request parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `dealer_id` | int | Yes | LCO dealer ID |
| `customer_id` | int | Yes | Customer ID |

**V2 REST response fields:**

| Field | Type | Description |
|-------|------|-------------|
| `status_code` | int | `0` = success |
| `status_msg` | String | Message |
| `complaint_details` | JSON array | Array of complaint history objects |

**`complaint_details` array fields (parsed from SOAP):**

| SOAP Property Key | Model Field | Type | Description |
|------------------|-----------|------|-------------|
| `tkt_number` | `tkt_number` | int | Ticket number |
| `description` | `description` | String | Complaint text |
| `date` | `date` | String | Creation date |
| `status` | `status` | String | Status |
| `category` | `category` | String | Category name |

**Response handling:**

| `status_code` | Action |
|--------------|--------|
| `0` | Bind `ComplaintAdapter` to `lv_complaints`, set total count label, Toast "Complaints Loaded Successfully" |
| `1` | AlertDialog "No complaint records Found". On OK: navigate to `MainActivity` (`frgToLoad = 0`) |
| `>= 2` | AlertDialog with `statusMessage` and "Please Contact customer care" |
| null | AlertDialog "Server connectivity error!" |

---

## 10. Data Models Reference

### 10.1 `complaintList` (SOAP model — per-customer list)

| Field | Type | Description |
|-------|------|-------------|
| `customerId` | int | Internal system customer ID |
| `altCustomerId` | int | LCO-assigned alternate customer ID |
| `customerName` | String | Customer name |
| `ticketNumber` | String | Complaint ticket number |
| `description` | String | Complaint text |
| `created_date` | String | Date complaint was created |
| `status` | String | Current status |

### 10.2 `customerComplaintList` (SOAP model — customer complaint search)

| Field | Type | Description |
|-------|------|-------------|
| `customerId` | int | Internal customer ID |
| `customNumber` | String | Customer account number |
| `customerName` | String | Customer name |
| `group` | String | Group/plan name |
| `complaintId` | int | Internal complaint ID |
| `ticketNumber` | String | Ticket number |
| `complaint` | String | Description |
| `complaintTime` | String | Creation timestamp |
| `status` | String | Current status |
| `assigned_name` | String | Assigned employee name |
| `assigned_employee_id` | int | Assigned employee ID |

### 10.3 `ComplaintHistorymodel` (SOAP model — history)

| Field | Type | Description |
|-------|------|-------------|
| `tkt_number` | int | Ticket number (integer) |
| `description` | String | Complaint description |
| `date` | String | Date |
| `status` | String | Status |
| `category` | String | Category name |

### 10.4 `DashBoardComPlaintModel` (REST model — dashboard)

| Field | Type | Description |
|-------|------|-------------|
| `tkt_number` | String | Ticket number |
| `description` | String | Complaint description |
| `date` | String | Date |
| `customer_name` | String | Customer name |
| `status` | String | Status |

### 10.5 `OpenComplaintsModel` (REST model — open complaints list)

| Field | Type | Description |
|-------|------|-------------|
| `customer_id` | String | Customer ID |
| `customer_account_id` | String | LCO account number |
| `CAF` | String | CAF/CRF number |
| `simple_complaint_id` | String | Internal complaint ID |
| `tkt_number` | String | Ticket number |
| `description` | String | Description text |
| `date` | String | Date |
| `customer_name` | String | Customer name |
| `status` | String | Status |
| `complaint` | String | Complaint type/category |
| `assigned_name` | String | Assigned employee name |
| `assigned_employee_id` | String | Assigned employee ID |

### 10.6 `complaintCategories`

| Field | Type | Description |
|-------|------|-------------|
| `categoryId` | int | Category ID |
| `categoryName` | String | Category name |

### 10.7 `complaintErrors` (legacy — not used in V2 flow)

| Field | Type | Description |
|-------|------|-------------|
| `errorId` | int | Error ID |
| `errorCode` | String | Error code |
| `errorDescription` | String | Error description |

### 10.8 `complaintStatuses`

| Field | Type | Description |
|-------|------|-------------|
| `statusName` | String | Status display value |

### 10.9 `createComplaintInfo` (SOAP request model)

| Field | Type | Description |
|-------|------|-------------|
| `customerId` | int | Customer ID |
| `authToken` | String | Auth token |
| `complaint` | String | Description + suffix |
| `category` | int | Category or subcategory ID |
| `error` | int | Error ID (usually 0) |
| `assignedTo` | int | Employee ID |

### 10.10 `closeComplaintInfo` (SOAP request model)

| Field | Type | Description |
|-------|------|-------------|
| `authToken` | String | Auth token |
| `complaintId` | int | Complaint ID |
| `ticketNumber` | String | Ticket number |
| `comment` | String | Comment + suffix |
| `status` | String | New status |
| `assignedemp` | int | Employee ID |

---

## 11. Complete V2 REST API Reference

All endpoints use base URL: `POST http://itpworld.linkpc.net:81/developers/satyam/ezybmsys/app/index.php/LcoRestServices/{endpoint}`

### 11.1 `getComplaintList`

**Full endpoint:** `POST /LcoRestServices/getComplaintList`
**Used by:** `OpenComplaints_frag`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `authtoken` | String | Yes | JWT token |
| `dealer_id` | int | Yes | LCO dealer ID |
| `users_type` | String | Yes | User type (DEALER, TEAMLEAD, etc.) |
| `serviceemployeeid` | int | No | `-1` for all, else specific employee |

| Response Field | Type | Description |
|---------------|------|-------------|
| `status_code` | int | `0` = success |
| `status_msg` | String | Status message |
| `lcoComplaintlist` | String (JSON array) | Open complaints array |

### 11.2 `gettotalcomplaintslist`

**Full endpoint:** `POST /LcoRestServices/gettotalcomplaintslist`
**Used by:** `ComplaintDashboard` (via Retrofit)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `authtoken` | String | Yes | JWT token |
| `dealer_id` | int | Yes | LCO dealer ID |
| `employee_id` | int | Yes | Logged-in employee ID |

| Response Field | Type | Description |
|---------------|------|-------------|
| `status_code` | int | `0` = success |
| `status_msg` | String | Status message |
| `getDashboardDataList` | JSON array | Dashboard complaint list |

### 11.3 `getCustomerComplaintListRest`

**Full endpoint:** `POST /LcoRestServices/getCustomerComplaintListRest`
**Used by:** `Complaint_Operations_Fragment` (currently via SOAP — migrate)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `altCustomerId` | int | Yes | Customer alternate ID |
| `authToken` | String | Yes | JWT token |
| `status` | String | No | Optional status filter |
| `userType` | String | No | User type |

| Response Field | Type | Description |
|---------------|------|-------------|
| `status_code` | int | `0` = success |
| `status_msg` | String | Status message |
| `customerComplaintList` | JSON array | Complaint objects for customer |

### 11.4 `complaintCategoriesRest`

**Full endpoint:** `POST /LcoRestServices/complaintCategoriesRest`
**Used by:** `Complaint_NewComplint_Fragment` (currently via SOAP — migrate)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| (none) | — | — | Auth handled via JWT header |

| Response Field | Type | Description |
|---------------|------|-------------|
| `complaintCategories` | JSON array | `[{categoryId, categoryName}]` |
| `status_msg` | String | Status message |

### 11.5 `getComplaintsubCategory`

**Full endpoint:** `POST /LcoRestServices/getComplaintsubCategory`
**Used by:** `Complaint_NewComplint_Fragment` (already REST)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `authtoken` | String | Yes | JWT token |
| `complaintcategory` | int | Yes | Parent category ID |
| `dealer_id` | int | Yes | LCO dealer ID |

| Response Field | Type | Description |
|---------------|------|-------------|
| `status_code` | int | `0` = success |
| `status_msg` | String | Status message |
| `complaintSubCategories` | JSON array | `[{complaint_category_id, complaint_category_name}]` |

### 11.6 `createComplaintRest`

**Full endpoint:** `POST /LcoRestServices/createComplaintRest`
**Used by:** `Complaint_NewComplint_Fragment` (currently via SOAP — migrate)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `customerId` | int | Yes | Customer ID |
| `complaint` | String | Yes | Description (include Android suffix) |
| `category` | int | Yes | Category or subcategory ID |
| `error` | int | No | Error ID (0 if unused) |
| `assignedTo` | int | No | Employee ID (0 = unassigned) |

| Response Field | Type | Description |
|---------------|------|-------------|
| `status_code` | int | `0` = success |
| `status_msg` | String | Status message |
| `ticketNumber` | String | Generated ticket number |
| `tkt_number` | String | Alternative ticket number field |
| `requestId` | String | Server request ID |
| `assignedTo` | String | Assigned employee |
| `int_stb_reactivation` | String | STB reactivation flag |

### 11.7 `complaintTypesRest`

**Full endpoint:** `POST /LcoRestServices/complaintTypesRest`
**Used by:** `ComplaintHistory_Other_Fragment` (currently via SOAP — migrate)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| (none) | — | — | Auth handled via JWT header |

| Response Field | Type | Description |
|---------------|------|-------------|
| `ticket_closer_categories` | JSON array | Array of status type objects |
| `status_msg` | String | Status message |

### 11.8 `closeComplaintRest`

**Full endpoint:** `POST /LcoRestServices/closeComplaintRest`
**Used by:** `ComplaintHistory_Other_Fragment` (currently via SOAP — migrate)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `complaintId` | int | Yes | Internal complaint ID |
| `ticketNumber` | String | Yes | Ticket number |
| `comment` | String | Yes | Comment text (include Android suffix) |
| `status` | String | Yes | New status value |
| `assignedemp` | int | No | Employee ID (-1 or 0 = unassigned) |
| `closer_ticket_type_id` | int | No | V2 closure type (not in Android) |
| `closer_reason_id` | int | No | V2 closure reason (not in Android) |

| Response Field | Type | Description |
|---------------|------|-------------|
| `status_code` | int | `0` = success |
| `status_msg` | String | Status message |

### 11.9 `ComplaintHistoryRest`

**Full endpoint:** `POST /LcoRestServices/ComplaintHistoryRest`
**Used by:** `ComapliantHistory` (currently via SOAP — migrate)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `dealer_id` | int | Yes | LCO dealer ID |
| `customer_id` | int | Yes | Customer ID |

| Response Field | Type | Description |
|---------------|------|-------------|
| `status_code` | int | `0` = success |
| `status_msg` | String | Status message |
| `complaint_details` | JSON array | History items |

**`complaint_details` item fields:**

| Field | Type | Description |
|-------|------|-------------|
| `tkt_number` | int | Ticket number |
| `description` | String | Complaint text |
| `date` | String | Date |
| `status` | String | Status |
| `category` | String | Category name |

---

## 12. Access Control and Visibility Rules

### 12.1 `showLcoComplaint` Flag

- Source: `validateLogin` response field `showLcoComplaint`.
- When `showLcoComplaint` is falsy/`"0"`: hide all complaint-related menu items from the main navigation.
- When `showLcoComplaint` is truthy/`"1"`: show `ComplaintDashboard` and `OpenComplaints_frag` in the menu.

### 12.2 `access_for_complaints` Flag

- Source: `getaccesscontrollRest` response field `access_for_complaints`.
- Controls whether the user can perform complaint operations (create/update).
- Flutter should check this flag before enabling complaint action buttons.

### 12.3 `userType` Behavior

| `userType` | Complaint Dashboard | Open Complaints | New Complaint | Update Complaint |
|-----------|-------------------|----------------|--------------|-----------------|
| `DEALER` | Full access | All complaints | Yes | Comment + status change |
| `ADMIN` | Full access | All complaints | Yes | Comment + status change |
| `TEAMLEAD` | Full access | All complaints (service emp filter) | Yes | Must select service employee |
| Others | Subject to `access_for_complaints` | Subject to flag | Subject to flag | Subject to flag |

### 12.4 `patch_information` Version Gating

The following features are gated behind patch versions `1.4.13.2`, `1.4.13.3`, or `1.4.13.4`:

| Feature | Behavior |
|---------|---------|
| Subcategory spinner | Shown after category selection when patch matches |
| LCO employee assignment on new complaint | `ll_employeelist` shown when patch matches |
| Ticket number in success dialog | Shown when patch matches |

In Flutter, these should be standard features (no version gating) since the migration targets V2 REST which fully supports them.

---

## 13. Status Color Mapping

Used in `OpenComplaintsAdapter` for the `igv_bgclr` color bar on each complaint row:

| Status | Hex Color | Color Name |
|--------|-----------|-----------|
| `Assigned` | `#08C889` | Green |
| `resolved` | `#08C889` | Green |
| `inprocess` | `#00BEB7` | Teal |
| `onhold` | `#E67E22` | Orange |
| `closed` | `#E74C3C` | Red |
| (default) | `#0875C8` | Blue |

Status comparison is case-insensitive (`equalsIgnoreCase`).

---

## 14. Flutter Migration Notes

### 14.1 SOAP to REST Migration Summary

Every SOAP call in this module must be replaced with its V2 REST equivalent:

| Android SOAP Property Key | SOAP Method Name | V2 REST Endpoint |
|--------------------------|-----------------|-----------------|
| `cclist` | `getCustomerComplaintList` | `getCustomerComplaintListRest` |
| `ccate` | `getComplaintCategoriesInfo` | `complaintCategoriesRest` |
| `cerr` | `getComplaintErrorsInfo` | **Not needed — use subcategory cascade** |
| `ccrea` | `createComplaintInfo` | `createComplaintRest` |
| `ctypes` | `getComplaintStatusInfo` | `complaintTypesRest` |
| `clcomp` | `closeComplaintInfo` | `closeComplaintRest` |
| `chist` | `ComplaintHistory` | `ComplaintHistoryRest` |

### 14.2 Already REST-Native Calls

| Feature | Property Key | V2 REST Endpoint |
|---------|-------------|-----------------|
| Open complaints list | `gcl` | `getComplaintList` |
| Dashboard complaints | (Retrofit) | `gettotalcomplaintslist` |
| Subcategory cascade | `cscate` | `getComplaintsubCategory` |
| LCO employee list | `glel` | (getLcoEmployeeList equivalent) |
| Service employee list | `gsel` | (getServiceEmployeeList equivalent) |

### 14.3 Description Suffix Handling

| Suffix String | Applied At | Must Strip At |
|--------------|-----------|--------------|
| `.Complaint Created from Android app` | `NewComplaint.onPreExecute()` | All display widgets |
| `.Complaint Status Change From Android app` | `CloseComplaint.doInBackground()` | (server-side stored, rarely displayed in app) |

In Flutter: strip these suffixes before displaying any `description` or `complaint` field.

### 14.4 State Management Requirements

The New Complaint screen requires multi-step state:
1. Categories loaded (list of `{categoryId, categoryName}`)
2. Selected category triggers subcategory API call
3. Subcategories loaded (list of `{complaint_category_id, complaint_category_name}`)
4. Employee list loaded independently
5. User fills description (auto-populated from spinner, editable)
6. Submit triggers create API

Use a provider/bloc with states: `Loading`, `CategoriesLoaded`, `SubcategoriesLoaded`, `Submitting`, `Success`, `Error`.

### 14.5 Pagination

Both `ComplaintDashboard` and `OpenComplaints_frag` use Android-side pagination (5 items per page, dynamic buttons). In Flutter, use a `ListView` with either:
- Client-side pagination using sliced lists and page index state (direct equivalent), or
- Infinite scroll if the API supports offset-based pagination.

The V2 REST API does not currently document offset/limit parameters for complaint lists, so client-side pagination is the correct approach.

### 14.6 Navigation Flow Summary

```
Main Menu
├── Complaint Dashboard (ComplaintDashboard)
│   └── [each row] → Update Complaint (ComplaintHistory_Other_Fragment)
├── Open Complaints (OpenComplaints_frag)
│   └── [each row tap] → Update Complaint (ComplaintHistory_Other_Fragment)
└── Customer Search → Customer Operations
    └── Complaint Operations (Complaint_Operations_Fragment)
        ├── New Complaint (Complaint_NewComplint_Fragment)
        │   └── [success] → popBackStack
        └── Update Complaint → Customer Complaint List (ComplaintSearchResultList_Fragment)
            ├── [CLOSED status] → Closed Complaint Detail (ComplaintHistory_Close_Fragment)
            └── [other status] → Update Complaint (ComplaintHistory_Other_Fragment)
                └── [success/fail] → popBackStack

Customer Detail Screen
└── Complaint History tab (ComapliantHistory)
    └── [read-only list of history rows]
```

### 14.7 Common Response Convention

The V2 REST API uses `status_code: 0` for success and `status_code: 1` for failure in most complaint endpoints. This is the **reverse** of the typical REST convention noted in the API document. Always check the actual `status_code` value rather than treating it as boolean.

### 14.8 Error Handling Patterns

| Error Type | Android Behavior | Flutter Equivalent |
|-----------|-----------------|-------------------|
| No network | Toast then no API call | Show snackbar, disable submit buttons |
| `status_code == 1` | AlertDialog | Show error dialog or inline error message |
| `status_code >= 2` | AlertDialog (same as 1) | Show error dialog |
| null response | AlertDialog "Server connectivity error!" | Show error dialog with retry option |
| Volley/network error | Toast "Failed." | Show snackbar with retry |
