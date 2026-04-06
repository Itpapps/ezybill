# 07 - Reports Module: Flutter Migration Gap Analysis

**Spec:** `screen_docs/07_reports.md`
**Date:** 2026-03-26
**Branch:** 16kbisssuefix

---

## Summary

The Flutter implementation currently has a single `ReportsScreen` with two tabs (Daily Report and Collections) that partially covers screens 07-B and 07-C from the spec. Three of the five spec screens have **no Flutter equivalent at all**, and the two that are partially present have significant structural and data-model deviations from the Android source.

---

## 1. API Endpoints

### 1.1 Endpoint Constants — Defined but Misused

| Endpoint | Constant Defined? | Datasource Method Exists? | Correctly Called? | Priority |
|---|---|---|---|---|
| `DailyreportRest` | YES (`ApiConstants.dailyReport`) | YES (`getDailyReport`) | PARTIAL — see 1.2 | HIGH |
| `empCollectionRest` | YES (`ApiConstants.empCollection`) | YES (`getEmpCollection`) | PARTIAL — see 1.3 | HIGH |
| `empCustomerCollectionDetailsRest` | YES (`ApiConstants.empCustomerCollection`) | YES (`getEmpCustomerCollection`) | NEVER CALLED from UI | HIGH |
| `empCollectionReportDownload` | NO | NO | NO | MEDIUM |
| `InvoiceServiceRest` | YES (`ApiConstants.invoiceHistory`) | YES (`getInvoiceHistory`) | Not relevant to reports hub | LOW |

### 1.2 `DailyreportRest` — Request Parameter Mismatch
**Priority: HIGH**

- **Spec says:** Request sends `date` and `dealer_id`.
- **Flutter sends:** `report_date` and `dealer_id`.
- **Gap:** Parameter key is `report_date` in Flutter but the spec (and Android SOAP mapping) uses `date`. Must be corrected to `date` or verified against V2 REST contract.

### 1.3 `empCollectionRest` — Request Parameter Mismatch
**Priority: HIGH**

- **Spec says:** Request sends `fromDate`, `toDate`, `imei`, `dealer_id`.
- **Flutter sends:** `from_date`, `to_date`, `dealer_id`.
- **Gaps:**
  - Parameter keys use snake_case (`from_date`, `to_date`) instead of camelCase (`fromDate`, `toDate`) as specified.
  - `imei` parameter is completely missing from the request.

### 1.4 `empCustomerCollectionDetailsRest` — Request Parameter Mismatch
**Priority: HIGH**

- **Spec says:** Request sends `authToken`, `fromDate`, `toDate`, `dealer_id`. Does NOT send `employee_id`.
- **Flutter datasource:** Method signature requires `employeeId` as a mandatory parameter and sends `employee_id` in the request payload.
- **Gaps:**
  - `employee_id` should NOT be sent per spec (the Android code captures it but never serialises it).
  - Parameter keys use snake_case (`from_date`, `to_date`, `employee_id`) instead of camelCase (`fromDate`, `toDate`).
  - This method is defined but never invoked from any UI screen.

### 1.5 `empCollectionReportDownload` — Not Implemented
**Priority: MEDIUM**

- Spec endpoint 8.5 (`empCollectionReportDownload`) for CSV/Excel binary download is neither defined in `ApiConstants` nor implemented anywhere in the datasource or UI.

---

## 2. Reports Hub (Screen 07-A)

**Priority: HIGH**

### Spec Requirement
A dedicated hub screen with two navigation buttons:
- "Collections" -> navigates to Employee Collection Date Filter (07-C)
- "Mini Collections" -> navigates to Mini Day Report (07-B)

### Flutter Implementation
No hub screen exists. Instead, `ReportsScreen` is a single monolithic screen with two tabs ("Daily Report" and "Collections"). There is no navigation to sub-screens.

### Gaps
| Gap | Description | Priority |
|---|---|---|
| No hub screen | Spec requires a simple navigation-only hub; Flutter merges everything into tabs | HIGH |
| No route `/reports` as entry point | The hub should be stateless with zero API calls | MEDIUM |
| Tab-based layout vs. button navigation | Deviates from the spec's explicit two-button design | MEDIUM |

---

## 3. Mini Day Report (Screen 07-B)

**Priority: HIGH**

### Spec Requirement
- Auto-fetches today's date (not user-selectable) via `DailyreportRest`.
- Displays a ListView with columns: `payment_mode`, `cust_count`, `total`.
- Footer shows grand total (sum of all `total` values, formatted to 2 decimal places with rupee sign).
- Print button triggers BLE thermal print flow.

### Flutter Implementation
The "Daily Report" tab in `ReportsScreen`:
- Has a date picker (user can select any date) — contradicts spec.
- Displays stat cards for `totalCollection`, `cashCollection`, `onlineCollection`, `totalReceipts`, `newActivations`, `deactivations`, `complaintsResolved`.
- Does NOT display a list of payment modes with `cust_count` and `total`.
- No print button.

### Gaps
| Gap | Description | Priority |
|---|---|---|
| Date should NOT be user-selectable | Spec says "always today, not user-selectable"; Flutter has a date picker | HIGH |
| Wrong data model | `ReportState` maps to completely different fields (`totalCollection`, `cashCollection`, `newActivations`, etc.) that do not exist in the spec's `Dailyreport_details` response | HIGH |
| Missing ListView of payment modes | Spec requires rows of `payment_mode / cust_count / total`; Flutter shows summary stat cards instead | HIGH |
| Missing grand total footer | Sum of all `total` values with rupee sign and 2dp formatting | HIGH |
| Missing print button | No print/export trigger exists | HIGH |
| Missing status code handling | Spec defines codes 0, 1, >=2, null with specific AlertDialog messages; Flutter only has generic error display | MEDIUM |

---

## 4. Employee Collection Date Filter (Screen 07-C)

**Priority: HIGH**

### Spec Requirement
- Separate screen with two individual date pickers (start date, end date).
- Both default to today.
- Validation: no future dates, end >= start, with Toast messages and reset on violation.
- Search button triggers `empCollectionRest` and navigates to Employee Collection Summary List (07-D).

### Flutter Implementation
The "Collections" tab uses a `showDateRangePicker` (combined range picker) inside the same screen. Default start date is 30 days ago (not today). Results are rendered inline as cards — no navigation to a separate summary list screen.

### Gaps
| Gap | Description | Priority |
|---|---|---|
| Not a separate screen | Should be its own StatefulWidget at `/reports/emp-collection/filter` | HIGH |
| Wrong default start date | Spec says both dates default to today; Flutter defaults `_fromDate` to 30 days ago | HIGH |
| Combined range picker vs. two individual pickers | Spec requires two separate date picker buttons with independent validation | MEDIUM |
| Missing validation messages | Spec requires specific Toast messages for future dates and end < start | MEDIUM |
| No navigation to summary list | After search, should navigate to 07-D; Flutter renders inline | HIGH |
| Missing `imei` in API request | `empCollectionRest` call omits `imei` parameter | HIGH |

---

## 5. Employee Collection Summary List (Screen 07-D)

**Priority: HIGH — SCREEN DOES NOT EXIST**

### Spec Requirement
- Dedicated screen at `/reports/emp-collection/list`.
- Receives `collResultList`, `fromDate`, `toDate` via route arguments.
- ListView rows: employee `name` and `Amt` (total amount collected).
- Footer: grand total (sum of all `Amt`).
- Row tap triggers `empCustomerCollectionDetailsRest` and navigates to Employee Collection Details (07-E).
- Print button with receipt layout: `NAME` (17 chars) / `AMOUNT` (10 chars) + `TOTAL AMOUNT` footer.

### Flutter Implementation
**No equivalent screen exists.** The Collections tab in `ReportsScreen` renders `_CollectionCard` widgets inline with different field names (`employee_name`, `total_collection`, `cash_collection`, `online_collection`, `total_receipts`) that do not match the spec's response model (`employee_id`, `name`, `Amt`).

### Gaps
| Gap | Description | Priority |
|---|---|---|
| Screen missing entirely | Must create `/reports/emp-collection/list` StatefulWidget | HIGH |
| Wrong response field mapping | Flutter reads `employee_name`, `total_collection`, etc.; spec says `name`, `Amt`, `employee_id` | HIGH |
| No drill-down on row tap | Tapping a row should call `empCustomerCollectionDetailsRest` then navigate to 07-E | HIGH |
| No grand total footer | Sum of all `Amt` values with rupee prefix | HIGH |
| No print button | Receipt layout with NAME/AMOUNT columns missing | HIGH |
| `employee_id` not captured | Needed for drill-down UX (display) even though not sent in API request | MEDIUM |

---

## 6. Employee Collection Details — Customer-Level (Screen 07-E)

**Priority: HIGH — SCREEN DOES NOT EXIST**

### Spec Requirement
- Dedicated screen at `/reports/emp-collection/details`.
- Receives `empCollection_responseArrayList` via route arguments (no API call in this screen).
- RecyclerView columns: `customer_id`, `customer_name`, `paid_amount`, `paid_on`, `payment_mode`, `payment_id`.
- Print button with receipt layout: `Name` (12 chars) / `Amount` (8 chars) / `Paidon` (10 chars, truncated).
- "View Maps" button to open map with geo-data.

### Flutter Implementation
**No equivalent screen exists.** No model, no provider state, and no UI for customer-level collection details.

### Gaps
| Gap | Description | Priority |
|---|---|---|
| Screen missing entirely | Must create `/reports/emp-collection/details` StatefulWidget | HIGH |
| No data model for `Empcustomercollection` | Need model with fields: `customer_id`, `customer_name`, `paid_amount`, `paid_on`, `payment_mode`, `payment_id` | HIGH |
| No print button | Receipt layout with Name/Amount/Paidon columns missing | HIGH |
| No map view integration | "View Maps" button for geo-plotting payment locations | LOW |
| `paid_on` truncation logic | Print should use `substring(0, 10)`; list should show full datetime | MEDIUM |

---

## 7. Report Export / Download

**Priority: MEDIUM**

| Gap | Description | Priority |
|---|---|---|
| `empCollectionReportDownload` not defined | Spec endpoint 8.5 requires binary CSV/Excel download via `dio` with `ResponseType.bytes` | MEDIUM |
| No download trigger in UI | No download/export button exists anywhere in the reports module | MEDIUM |
| `pgTransactionReportDownload` not defined | Spec endpoint 8.6 (GET) for PG transaction download | LOW |

---

## 8. Date Format Enforcement

**Priority: MEDIUM**

| Area | Spec Requirement | Flutter Status | Gap |
|---|---|---|---|
| Daily Report API call | `yyyy-MM-dd` | Uses `DateFormat('yyyy-MM-dd')` — CORRECT | None |
| Collection filter API call | `yyyy-MM-dd` | Uses `DateFormat('yyyy-MM-dd')` — CORRECT | None |
| Display date (Daily Report) | Not user-facing (always today) | Shows `dd MMM yyyy` — acceptable for display but date should not be selectable | See Section 3 |
| Display dates (Collection filter) | `d-M-yyyy` for display per spec | Shows `dd MMM` / `dd MMM yyyy` | MINOR — display format differs from spec |

---

## 9. Print / BLE Thermal Print Layouts

**Priority: HIGH**

No print functionality is implemented anywhere in the Flutter reports module. The spec requires three distinct print receipt layouts:

| Report | Print Layout | Status |
|---|---|---|
| Mini Day Report (07-B) | Header: `MINIDAY REPORT` + datetime; Columns: `MODE / COUNT / AMOUNT`; Footer: `TOTAL AMOUNT` | NOT IMPLEMENTED |
| Emp Collection Summary (07-D) | Header: `COLLECTION REPORT` + datetime; Columns: `NAME (17ch) / AMOUNT (10ch)`; Footer: `TOTAL AMOUNT` | NOT IMPLEMENTED |
| Emp Collection Details (07-E) | Header: `COLLECTION REPORT` + datetime; Columns: `Name (12ch) / Amount (8ch) / Paidon (10ch)` | NOT IMPLEMENTED |

### Recommended Approach (from spec)
Use the `pdf` package for PDF generation and `printing` package for share/print. Receipt format should match the column widths and alignment specified above.

---

## 10. Missing Screens Summary

| Spec Screen | Route | Flutter File Exists? | Status |
|---|---|---|---|
| 07-A: Reports Hub | `/reports` | NO (merged into tabs) | REDESIGN NEEDED |
| 07-B: Mini Day Report | `/reports/mini-day` | PARTIAL (wrong data model, wrong UX) | MAJOR REWORK |
| 07-C: Emp Collection Date Filter | `/reports/emp-collection/filter` | PARTIAL (inline tab, wrong defaults) | MAJOR REWORK |
| 07-D: Emp Collection Summary List | `/reports/emp-collection/list` | NO | NEW SCREEN NEEDED |
| 07-E: Emp Collection Details | `/reports/emp-collection/details` | NO | NEW SCREEN NEEDED |

---

## 11. Provider / State Management Gaps

| Gap | Description | Priority |
|---|---|---|
| `ReportState` has wrong fields | `dailyReport` convenience getters (`totalCollection`, `cashCollection`, `onlineCollection`, `totalReceipts`, `newActivations`, `deactivations`, `complaintsResolved`) do not match spec's `Dailyreport_details` array of `{payment_mode, cust_count, total}` | HIGH |
| No state for `Dailyreport_details` list | Need `List<MinidayResult>` with fields `payment_mode`, `cust_count`, `total` and computed `grandTotal` | HIGH |
| No state for employee collection details | Need `List<Empcustomercollection>` state for screen 07-E | HIGH |
| `empCollections` response parsing | Provider reads `data['data']`; spec says response key is `collectionList` | HIGH |
| No `loadEmpCustomerCollectionDetails` method | Provider has no method to call `empCustomerCollectionDetailsRest` | HIGH |
| No status code handling | Spec defines per-endpoint status codes (0=success, 1=no data, 2=error, 3/null=network) with specific dialog/toast messages; provider only has generic error string | MEDIUM |

---

## 12. Access Control

| Gap | Description | Priority |
|---|---|---|
| No access control gate | Spec requires `getaccesscontrollRest` response field `report` to be truthy before allowing navigation to Reports | MEDIUM |

---

## Priority Summary

| Priority | Count | Key Items |
|---|---|---|
| **HIGH** | 25+ | Missing screens (07-D, 07-E), wrong data models, missing API parameters, no print, no drill-down navigation |
| **MEDIUM** | 8 | Missing download endpoints, no access control gate, missing validation messages, status code handling |
| **LOW** | 3 | Map view integration, display date format, PG transaction download |
