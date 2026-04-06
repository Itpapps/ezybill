# 07 - Reports Module

**Module:** Reports
**Android Source:** `activities_fragments/Reports_frag.java` (hub), `MiniDayReport_Fragment.java`, `Report_EmpCollect_Fragment.java`, `Reports_Emp_Collection_List_Fragment.java`, `Employee_Collection_Details_Fragment.java`
**Flutter Route Group:** `/reports/*`
**Access Control:** `getaccesscontrollRest` response field `report` must be truthy; screen-level access is gated before navigation.

---

## Overview

The Reports module is a hub fragment (`Reports_frag`) containing navigation buttons to two sub-report flows:

| Button ID (Android) | Destination Fragment | Report Name |
|---|---|---|
| `reports_btn_collections` | `Report_EmpCollect_Fragment` | Employee Collection Report |
| `reports_btn_minicollections` | `MiniDayReport_Fragment` | Mini Day Report |

Both flows are purely read-only (no data creation). They support on-device printing via Bluetooth (generic devices) or an internal N910 thermal printer.

---

## Screen 07-A: Reports Hub

### Screen Identity

| Property | Value |
|---|---|
| Label / Title | Reports |
| Purpose | Navigation entry point to all report sub-screens |
| Android Fragment | `Reports_frag` |
| Layout | `fragment_reports_frag` |
| Flutter Widget | `StatelessWidget` / named route `/reports` |

### UI Elements

| Element | Type | Description |
|---|---|---|
| Collections button | `LinearLayout` (tappable) | Navigates to Employee Collection date-filter screen |
| Mini Collections button | `LinearLayout` (tappable) | Navigates directly to Mini Day Report (today auto-loaded) |

### Actions & Workflows

- Tapping **Collections** pushes `Report_EmpCollect_Fragment` with bundle arg `fromreport = 1`.
- Tapping **Mini Collections** pushes `MiniDayReport_Fragment` with no arguments; the fragment auto-fetches today's report on creation.

### API Calls

None. This screen is navigation-only.

---

## Screen 07-B: Mini Day Report

### Screen Identity

| Property | Value |
|---|---|
| Label / Title | Mini Day Report |
| Purpose | Displays today's collection totals grouped by payment mode, with printable receipt |
| Android Fragment | `MiniDayReport_Fragment` |
| Layout | `fragment_mini_day_report_` |
| Flutter Widget | `StatefulWidget` at `/reports/mini-day` |

### UI Elements

| Element ID | Type | Description |
|---|---|---|
| `lv_miniday` | `ListView` | Report rows — one row per payment mode |
| `tv_totalamount` | `TextView` | Grand total of all collections (formatted to 2 decimal places, prefixed with rupee sign) |
| `printreport_ll` | `LinearLayout` (tappable) | Triggers print flow |

#### Report List Columns (`lv_miniday` — row layout `row_miniday`)

| View ID | Adapter Field | API Response Field | Description |
|---|---|---|---|
| `tv_moderow` | `getPayment_mode()` | `payment_mode` | Payment mode label (e.g., CASH, BANK, UPI) |
| `countrow` | `getCust_count()` | `cust_count` | Number of customers who paid via this mode |
| `amountrow` | `getTotal()` | `total` | Total amount collected via this mode (₹) |

#### Footer Summary

| Element | Calculation | Display |
|---|---|---|
| `tv_totalamount` | Sum of all `Minidayresult.total` values | `₹ <grand_total formatted to 2dp>` |

### Actions & Workflows

1. **Auto-load on open:** On fragment creation, today's date is computed via `Calendar.getInstance()` and formatted as `yyyy-MM-dd`. `getminidayreport` AsyncTask fires immediately — no user input needed.
2. **Print:** Tap `printreport_ll`. If `status == 1` (report loaded successfully):
   - On N910 device: calls `payswiff_print()` — internal thermal printer.
   - On other devices: checks Bluetooth, opens `Bluetooth_Fragment` with bundle arg `offline_report = 3` and `minidayresultArrayList` parcelable.
3. **Print layout (receipt):**
   - Header: `MINIDAY REPORT` + current datetime
   - Columns: `MODE`, `COUNT`, `AMOUNT`
   - One line per payment mode row
   - Footer: `TOTAL AMOUNT <grand_total>`

### API Call: DailyreportRest

| Property | Value |
|---|---|
| Endpoint | `POST /LcoRestServices/DailyreportRest` |
| Android SOAP key | `dreport` (property file key, maps to `dailyreport` SOAP method) |
| V2 REST Equivalent | `POST /LcoRestServices/DailyreportRest` |
| Protocol (Android) | SOAP via `ksoap2`; V2 must use REST JSON |
| Trigger | Automatic on screen open |

#### Request Parameters

| Parameter | Type | Source | Description |
|---|---|---|---|
| `authToken` | String | `LoginActivity.authToken` | Session auth token |
| `dealer_id` | int | `LoginActivity.dealerId` | Authenticated dealer ID |
| `date` | String | `Calendar.getInstance()` formatted `yyyy-MM-dd` | Report date (always today, not user-selectable) |

**Note:** In the V2 REST call, `authToken` is sent via JWT header; `dealer_id` is extracted server-side from the token. The explicit payload only needs `date` and optionally `dealer_id` for override.

#### Response Structure

```json
{
  "status_code": 0,
  "status_msg": "Success",
  "Dailyreport_details": [
    {
      "cust_count": 12,
      "total": 3500.00,
      "payment_mode": "CASH"
    },
    {
      "cust_count": 3,
      "total": 900.00,
      "payment_mode": "UPI"
    }
  ]
}
```

#### Response Field Mapping (Minidayresult model)

| Response Field | Java Field | Type | Displayed In |
|---|---|---|---|
| `cust_count` | `Minidayresult.cust_count` | int | `countrow` TextView |
| `total` | `Minidayresult.total` | double | `amountrow` TextView |
| `payment_mode` | `Minidayresult.payment_mode` | String | `tv_moderow` TextView |

#### Status Code Handling

| `statusCode` | Meaning | UI Action |
|---|---|---|
| `0` | Success — data loaded | Populate ListView, show total, enable print (`status = 1`) |
| `1` | No collections found | AlertDialog: "No collections! — Report appears when collections are done" |
| `>= 2` | Server error | AlertDialog: "Deactivation Failed!" (legacy error message) |
| `null` response | Network/server unreachable | AlertDialog: "Server connectivity error!" |

### Validation Rules

- **Date:** Always today. Not user-selectable. Date format: `yyyy-MM-dd`.
- **Print guard:** Print button only triggers print flow when `status == 1`; otherwise shows Toast "Cannot print, report not generated properly."

---

## Screen 07-C: Employee Collection Date Filter

### Screen Identity

| Property | Value |
|---|---|
| Label / Title | Collection Report — Date Filter |
| Purpose | Date range picker screen before fetching employee collection summary |
| Android Fragment | `Report_EmpCollect_Fragment` |
| Layout | `activity_report_dailycoll` |
| Flutter Widget | `StatefulWidget` at `/reports/emp-collection/filter` |

### UI Elements

| Element ID | Type | Description |
|---|---|---|
| `dailycoll_btn_stdate` | `LinearLayout` (tappable) | Opens start date `DatePickerDialog` |
| `dailycoll_btn_enddate` | `LinearLayout` (tappable) | Opens end date `DatePickerDialog` |
| `strtdatetv` | `TextView` | Displays selected start date in `d-M-yyyy` format |
| `enddatetv` | `TextView` | Displays selected end date in `d-M-yyyy` format |
| `dailycoll_btn_search` | `Button` | Triggers collection fetch |

### Actions & Workflows

1. **Default dates:** Both start and end date default to today's date on fragment creation via `setCurrentDateOnView()`.
2. **Date picker (start):** Native `DatePickerDialog` pre-populated with current `styear/stmonth/stday`. On selection, updates `act_startDate` in `yyyy-M-d` format.
3. **Date picker (end):** Native `DatePickerDialog` pre-populated with current `endyear/endmonth/endday`. On selection, updates `act_endDate`.
4. **Search:** Tapping `dailycoll_btn_search` with `fromreport == 1` fires `Collections` AsyncTask (empCollectionRest SOAP call). On success, navigates to `Reports_Emp_Collection_List_Fragment` passing the result list plus date strings.

**Note:** `fromreport == 2` path calls `getlcowallet()` (REST call to `getlcowalletRest`) and navigates to `LcoWalletHistory`. This is a different report flow (LCO Wallet History) reusing the same date-filter screen. This document covers `fromreport == 1` only.

### Validation Rules

| Rule | Enforcement | Message |
|---|---|---|
| Start date must not be in the future | Checked against today in `startdatePickerListener` | "Start date must not be greater than current date" (Toast) — resets to today |
| End date must not be before start date | Checked in `enddatePickerListener` | "End date must not be greater than start date" (Toast) — resets to today |
| End date must not be in the future | Checked in `enddatePickerListener` | "End date must not be greater than current date" (Toast) — resets to today |

Both validations call `setCurrentDateOnView()` to reset the picker displays on violation.

**Internal date format stored in `act_startDate` / `act_endDate`:** `yyyy-M-d ` (note trailing space — passed directly to the API after `dateFormat.format()` re-parse, which normalizes to `yyyy-MM-dd`).

### API Call: empCollectionRest

| Property | Value |
|---|---|
| Endpoint | `POST /LcoRestServices/empCollectionRest` |
| Android SOAP key | `empColl` (property file key) |
| V2 REST Equivalent | `POST /LcoRestServices/empCollectionRest` |
| Protocol (Android) | SOAP via `ksoap2`; V2 must use REST JSON |
| Trigger | Tap Search button |

#### Request Parameters (checkCollectionInfo model)

| Parameter | Type | Source | SOAP Property Name | Description |
|---|---|---|---|---|
| `authToken` | String | `LoginActivity.authToken` | `authToken` | Session auth token |
| `fromDate` | String | `act_startDate` (re-parsed via `yyyy-MM-dd`) | `fromDate` | Report start date |
| `toDate` | String | `act_endDate` (re-parsed via `yyyy-MM-dd`) | `toDate` | Report end date |
| `imei` | String | `LoginActivity.imeiNo` | `imei` | Device IMEI |
| `dealer_id` | int | `LoginActivity.dealerId` | `dealer_id` | Dealer ID |

#### Response Structure

```json
{
  "status_code": 0,
  "status_msg": "Success",
  "collectionList": [
    {
      "employee_id": 5,
      "name": "John Doe",
      "Amt": 12500.00
    }
  ]
}
```

#### Response Field Mapping (collectionResult model)

| Response Field | Java Field | Type | Description |
|---|---|---|---|
| `employee_id` | `collectionResult.employee_id` | int | Internal employee ID (used as key for drill-down) |
| `name` | `collectionResult.name` | String | Employee name |
| `Amt` | `collectionResult.Amt` | double | Total amount collected by this employee |

#### Status Code Handling

| `statusCode` | Meaning | UI Action |
|---|---|---|
| `0` | Success | Navigate to `Reports_Emp_Collection_List_Fragment` with `collResultList`, `fromDate`, `toDate` |
| `1` | No data | AlertDialog: "Collection not Found in between these dates." |
| `2` | Error | Toast: `statusMessage + ": Contact Support"` |
| `3` / null | Network error | AlertDialog: "Server is busy or Un reachable!" |

---

## Screen 07-D: Employee Collection Summary List

### Screen Identity

| Property | Value |
|---|---|
| Label / Title | Collection Report — Employee Summary |
| Purpose | Shows per-employee collection totals; tap to drill into customer-level detail |
| Android Fragment | `Reports_Emp_Collection_List_Fragment` |
| Layout | `collection_result_list` |
| Flutter Widget | `StatefulWidget` at `/reports/emp-collection/list` |

### UI Elements

| Element ID | Type | Description |
|---|---|---|
| `android_list` | `ListView` | One row per employee showing name and collected amount |
| `tv_totalamountcollectionreport` | `TextView` | Grand total of all employee amounts (updated live in `grandTotal()`) |
| `report_print_btn_result` | `TextView` (tappable) | Triggers print flow |
| `printreport_ll` | `ImageView` (tappable) | Alternative print trigger |

#### Report List Columns (`android_list` — row layout `custsearchlist_items_new`)

| View ID | Adapter Field | Model Field | Description |
|---|---|---|---|
| `searchcustlist_custname` | `getName()` | `collectionResult.name` | Employee name |
| `searchcustlist_custdueamount` | `getAmt()` | `collectionResult.Amt` | Total amount collected by the employee |

**Note:** Serial number (`searchcustlist_sno`) view ID exists in the ViewHolder definition but its `setText` call is commented out — not displayed.

#### Footer

| Element | Calculation | Display |
|---|---|---|
| `tv_totalamountcollectionreport` | Sum of `collectionResult.Amt` for all rows | `₹ <grand_total>` (updated row by row in loop) |

### Actions & Workflows

1. **Data received:** `collResultList` (ArrayList\<collectionResult\>), `fromDate`, `toDate` are passed via Bundle from `Report_EmpCollect_Fragment`.
2. **Drill-down:** Tapping a list row captures `selectedempId = collResultList.get(i).getEmployee_id()` and fires `EmpCustomerCollectionDetails` AsyncTask (empCustColl SOAP call). On success, navigates to `Employee_Collection_Details_Fragment` passing `empCollection_responseArrayList`.
3. **Print:** Tap `printreport_ll`.
   - N910: calls `payswiff_print()`.
   - Other: Bluetooth flow with `offline_report = 5`, passes `collResultList` and `totalamt` string.
4. **Print layout:**
   - Header: `COLLECTION REPORT` + current datetime
   - Columns: `NAME` (17 chars left-aligned), `AMOUNT` (10 chars right-aligned)
   - Footer: `TOTAL AMOUNT <totalPrice>`

### API Call: empCustomerCollectionDetailsRest (drill-down trigger)

This call is made from `Reports_Emp_Collection_List_Fragment` when a row is tapped, not from `Employee_Collection_Details_Fragment` itself. The detail fragment only renders.

| Property | Value |
|---|---|
| Endpoint | `POST /LcoRestServices/empCustomerCollectionDetailsRest` |
| Android SOAP key | `empCustColl` (property file key) |
| V2 REST Equivalent | `POST /LcoRestServices/empCustomerCollectionDetailsRest` |
| Protocol (Android) | SOAP via `ksoap2`; V2 must use REST JSON |
| Trigger | Tap on employee row in summary list |

#### Request Parameters (empCustomerCollectionDetails model)

| Parameter | Type | Source | SOAP Property Name | Description |
|---|---|---|---|---|
| `authToken` | String | `LoginActivity.authToken` | `authToken` | Session auth token |
| `fromDate` | String | Bundle `fromDate` | `fromDate` | Same start date passed from filter screen |
| `toDate` | String | Bundle `toDate` | `toDate` | Same end date passed from filter screen |
| `dealer_id` | int | `LoginActivity.dealerId` | `dealer_id` | Dealer ID |

**Note:** `imei` field exists in the model class but is commented out of the property serialization (property count = 4, not 5). It is NOT sent in the request.
**Note:** `employee_id` (the tapped row's `selectedempId`) is captured client-side but is NOT currently sent in the request payload — the server returns all customer collections for the dealer/date range rather than filtering by employee. This is an important behavioral note for Flutter migration.

#### Response Structure

```json
{
  "status_code": 0,
  "status_msg": "Success",
  "collectionList": [
    {
      "customer_id": 1042,
      "customer_name": "Ramesh Kumar",
      "paid_amount": 350.00,
      "paid_on": "2024-01-15 14:30:00",
      "payment_mode": "CASH",
      "payment_id": 9901
    }
  ]
}
```

#### Response Field Mapping (Empcustomercollection model)

| Response Field | Java Field | Type | Description |
|---|---|---|---|
| `customer_id` | `Empcustomercollection.customer_id` | int | Internal customer ID |
| `customer_name` | `Empcustomercollection.customer_name` | String | Customer full name |
| `paid_amount` | `Empcustomercollection.paid_amount` | double | Amount paid by customer |
| `paid_on` | `Empcustomercollection.paid_on` | String | Payment timestamp (full datetime string) |
| `payment_mode` | `Empcustomercollection.payment_mode` | String | Payment mode (CASH / BANK / UPI etc.) |
| `payment_id` | `Empcustomercollection.payment_id` | int | Payment record ID |

#### Status Code Handling

| `statusCode` | Meaning | UI Action |
|---|---|---|
| `0` | Success | Toast "Loaded successfully", navigate to `Employee_Collection_Details_Fragment` |
| `1` | No details | AlertDialog: "No details Found." |
| `2` | Error | Toast: `statusMessage + ": Contact Support"` |
| `3` / null | Network error | AlertDialog: "Server is busy or Un reachable!" — redirects to `LoginActivity` |

---

## Screen 07-E: Employee Collection Details (Customer-Level)

### Screen Identity

| Property | Value |
|---|---|
| Label / Title | Collection Report — Customer Details |
| Purpose | Customer-level payment breakdown for all employees in the selected date range |
| Android Fragment | `Employee_Collection_Details_Fragment` |
| Layout | `employee_collection_report` |
| Flutter Widget | `StatefulWidget` at `/reports/emp-collection/details` |

### UI Elements

| Element ID | Type | Description |
|---|---|---|
| `employee_collection_recyclerView` | `RecyclerView` | Customer-level collection rows |
| `printreport_ll` | `LinearLayout` | Container print button area |
| `report_print_btn` | `LinearLayout` (tappable) | Triggers print flow |
| `report_viewmaps` | `ImageView` (tappable) | Opens `MapsActivity` with collection geo-data (hidden on N910) |

#### Report List Columns (`employee_collection_recyclerView` — row layout `employee_collection_report_items`)

| View ID | Adapter Getter | Model Field | API Response Field | Description |
|---|---|---|---|---|
| `employee_coll_cust_id` | `getCustomer_id()` | `Empcustomercollection.customer_id` | `customer_id` | Internal customer ID |
| `customername` | `getCustomer_name()` | `Empcustomercollection.customer_name` | `customer_name` | Customer full name |
| `employee_paidamt` | `getPaid_amount()` | `Empcustomercollection.paid_amount` | `paid_amount` | Amount paid (₹ prefix added by adapter) |
| `employee_paidon` | `getPaid_on()` | `Empcustomercollection.paid_on` | `paid_on` | Payment date/time (full datetime from server) |
| `employee_paymentmode` | `getPayment_mode()` | `Empcustomercollection.payment_mode` | `payment_mode` | Payment mode string |
| `employee_paymentid` | `getPayment_id()` | `Empcustomercollection.payment_id` | `payment_id` | Payment record ID |

### Actions & Workflows

1. **Data received:** `empCollection_responseArrayList` (ArrayList\<Empcustomercollection\>) via Bundle from `Reports_Emp_Collection_List_Fragment` — no API call made in this fragment.
2. **Print:** Tap `report_print_btn`.
   - N910: calls `payswiff_print()`.
   - Other: Bluetooth flow with `offline_report = 2`, passes `empcollection_reports` parcelable list.
3. **View Maps:** Tap `report_viewmaps` launches `MapsActivity` via explicit Intent, passing `empcollection_reports` parcelable list for geo-plotting customer payment locations.
4. **Print layout:**
   - Header: `COLLECTION REPORT` + current datetime
   - Columns: `Name` (12 chars left-aligned), `Amount` (8 chars left-aligned), `Paidon` (10 chars right-aligned, truncated to first 10 chars of `paid_on`)
   - One line per customer row

### No API Call

This fragment is purely a renderer. All data is received from the parent list fragment via `getArguments().getParcelableArrayList("EmpcollResultList")`.

---

## Additional Model: EmpCollection_ResponseModel

This model class (`EmpCollection_ResponseModel.java`) is defined but its usage is commented out in `Reports_Emp_Collection_List_Fragment` (the JSON parsing block in `onPostExecute` is fully commented). The active code uses `Empcustomercollection` instead. The model is retained for reference as a richer data structure that may be reactivated.

| Field | Type | Description |
|---|---|---|
| `customer_id` | String | Internal customer ID |
| `alt_cust_id` | String | Alternate customer ID |
| `customnumber` | String | Customer connection number |
| `alt_custom_number` | String | Alternate connection number |
| `crfno` | String | CRF number |
| `employee_id` | String | Employee who collected |
| `paid_amount` | String | Amount paid |
| `paid_on` | String | Payment timestamp |
| `hht_paid` | String | HHT payment flag |
| `payment_mode` | String | Payment mode |
| `address` | String | Customer address |
| `customer_name` | String | Customer name |
| `name` | String | Employee name |
| `ukey` | String | Unique key |
| `latitude` | String | GPS latitude (for maps) |
| `longitude` | String | GPS longitude (for maps) |

---

## Additional Models: Unpaid Customer Classes

These models exist in the codebase but are not used by the five report fragments analyzed here. They belong to a separate unpaid-customers reporting flow (not yet surfaced in the Reports hub screen).

### unpaidCustomersCountInfo — Request Model

| Field | Type | SOAP Property | Description |
|---|---|---|---|
| `authToken` | String | `authToken` | Auth token |
| `startDate` | String | `startDate` | Report start date |
| `endDate` | String | `endDate` | Report end date |
| `employeeId` | int | `employeeId` | Filter by employee |
| `dealerId` | int | `dealerId` | Dealer ID |
| `groupId` | int | `groupId` | Filter by group |

### unpaidCustomersInfo — Request Model (paginated)

Extends `unpaidCustomersCountInfo` with pagination fields:

| Field | Type | SOAP Property | Description |
|---|---|---|---|
| `startValue` | int | `startValue` | Pagination start index |
| `endValue` | int | `endValue` | Pagination end index |

### unpaidCustomersList — Response Model

| Field | Type | Description |
|---|---|---|
| `customerId` | String | Customer ID |
| `customerName` | String | Customer name |
| `dueAmount` | double | Outstanding due amount |

---

## Complete API Reference for Reports Module

| # | Endpoint | Method | Key Request Fields | Key Response Fields | Flutter Screen |
|---|---|---|---|---|---|
| 8.1 | `DailyreportRest` | POST | `dealer_id`, `date` | `Dailyreport_details[]` → `payment_mode`, `cust_count`, `total` | Mini Day Report |
| 8.2 | `empCollectionRest` | POST | `dealer_id`, `fromDate`, `toDate`, `imei` | `collectionList[]` → `employee_id`, `name`, `Amt` | Emp Collection Summary |
| 8.3 | `empCustomerCollectionDetailsRest` | POST | `dealer_id`, `fromDate`, `toDate` | `collectionList[]` → `customer_id`, `customer_name`, `paid_amount`, `paid_on`, `payment_mode`, `payment_id` | Emp Collection Details |
| 8.4 | `InvoiceServiceRest` | POST | `dealer_id`, `customer_id` | `invoice_details` | (Invoice History — separate screen) |
| 8.5 | `empCollectionReportDownload` | POST | `fromDate`, `toDate` | Binary CSV/Excel download | Download button in collection screen |
| 8.6 | `pgTransactionReportDownload` | GET | none | Binary file | PG Transaction download |
| 8.7 | `customer_deduction_logs` | POST | `dateRange`, `customerId` | `deduction_logs` | (Customer deduction — separate screen) |

---

## Navigation Flow Diagram

```
Reports Hub (07-A)
├── [Mini Collections] ──────────────────────────────────► Mini Day Report (07-B)
│                                                            Auto-fetches today via DailyreportRest
│                                                            ListView: payment_mode | cust_count | total
│                                                            Footer: Grand Total
│                                                            [Print] ──► Bluetooth_Fragment / N910 printer
│
└── [Collections] ────────────────────────────────────────► Date Filter (07-C)
                                                              DatePicker: From Date, To Date
                                                              Defaults: today → today
                                                              Validation: no future dates, end >= start
                                                              [Search] ──► empCollectionRest
                                                                            │
                                                                            ▼
                                                                    Emp Summary List (07-D)
                                                                    ListView: employee name | Amt
                                                                    Footer: Grand Total
                                                                    [Print] ──► Bluetooth_Fragment / N910
                                                                    [Row tap] ──► empCustomerCollectionDetailsRest
                                                                                    │
                                                                                    ▼
                                                                            Details (07-E)
                                                                            RecyclerView:
                                                                              customer_id | customer_name
                                                                              paid_amount | paid_on
                                                                              payment_mode | payment_id
                                                                            [Print] ──► Bluetooth / N910
                                                                            [Map] ──► MapsActivity
```

---

## Flutter Migration Notes

### State Management
- **Mini Day Report:** Single stateful widget; fetch on `initState`; hold `List<MinidayResult>` and `double totalAmount` in state.
- **Emp Collection Filter:** Hold `DateTime startDate`, `DateTime endDate` in state; default to `DateTime.now()`.
- **Emp Summary List:** Receives data via route arguments; compute grand total in `initState`.
- **Emp Details:** Receives data via route arguments; purely display, no async work.

### Date Format Convention
All API calls send dates as `yyyy-MM-dd` (ISO date, no time component). Android code parses the user-selected date through `SimpleDateFormat("yyyy-MM-dd")` before sending. Flutter should use `DateFormat('yyyy-MM-dd').format(selectedDate)` from the `intl` package.

### Print Replacement
The Android print flow (Bluetooth + N910) has no direct Flutter equivalent for mobile printing. In Flutter, implement PDF generation using the `pdf` package and share via `printing` package. The receipt format should match:
- Mini Day Report receipt: MODE / COUNT / AMOUNT columns + TOTAL AMOUNT footer.
- Collection Details receipt: Name / Amount / Paidon columns.

### `employee_id` Not Sent in Details Call
The Android code captures `selectedempId` when a row is tapped but never includes it in the `empCustomerCollectionDetailsRest` request. The server returns all customer-level collections for the dealer over the date range. Flutter should replicate this behavior exactly — do not add `employee_id` to the request unless the API contract changes.

### `paid_on` Display Truncation
In the print receipt for Employee Collection Details, `paid_on` is truncated to 10 characters (`paidon.substring(0, 10)`) to extract just the date portion. In the RecyclerView, the full datetime string is shown. Flutter should follow the same convention: display full string in the list, show only `paid_on.substring(0, 10)` in print/export previews.

### Download Endpoint
`empCollectionReportDownload` (8.5) accepts `fromDate` and `toDate` and returns a binary CSV/Excel file. Flutter should implement this using `dio` with `ResponseType.bytes` and save/share via `path_provider` + `share_plus`. This download button is not currently visible in the five fragments analyzed but is listed in the access control endpoint summary.

### LCO Wallet Report (fromreport == 2)
`Report_EmpCollect_Fragment` is dual-purpose: when `fromreport == 2`, it calls `getlcowalletRest` and navigates to `LcoWalletHistory`. Flutter should use a separate route (`/reports/lco-wallet/filter`) with the same date-picker UI but different submit action, to avoid logic branching inside the filter screen.
