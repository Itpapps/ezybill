# 04 - Complaint Management: Flutter Changes Required

> **Generated:** 2026-03-26
> **Spec:** `screen_docs/04_complaint_management.md` (8 screens, 9 API endpoints)
> **Flutter files reviewed:**
> - `lib/data/datasources/remote/complaint_remote_datasource.dart`
> - `lib/application/providers/complaint_provider.dart`
> - `lib/presentation/screens/complaints/complaint_screen.dart`
> - `lib/core/constants/api_constants.dart`

---

## Summary

The Flutter implementation covers basic complaint listing and a simplified create flow, but is missing **5 of 8 screens** entirely, has significant gaps in the close/update complaint workflow, does not implement access control flags, lacks the description suffix convention, and is missing the status color mapping system. Of the 9 spec API endpoints, all 9 are defined in the datasource, but several are either unused or called with incomplete parameters.

---

## 1. API Endpoints

### 1.1 Endpoint Definition Status

| Endpoint | Constant Defined | Datasource Method | Actually Used in UI | Gap |
|----------|:---:|:---:|:---:|-----|
| `getComplaintList` | YES | YES | YES (loadComplaints) | -- |
| `gettotalcomplaintslist` | YES | YES | YES (loadComplaints) | -- |
| `getCustomerComplaintListRest` | YES | YES | NO | Not wired to any screen |
| `complaintCategoriesRest` | YES | YES | YES (loadCategories) | -- |
| `getComplaintsubCategory` | YES | YES | NO | Not wired to any screen |
| `createComplaintRest` | YES | YES | YES (createComplaint) | Missing params (see 1.2) |
| `complaintTypesRest` | YES | YES | NO | Not wired to any screen |
| `closeComplaintRest` | YES | YES | NO | Not wired to any screen (see 1.3) |
| `ComplaintHistoryRest` | YES | YES | NO | Not wired to any screen |

### 1.2 `createComplaintRest` -- Missing Request Parameters
**Priority: HIGH**

The spec requires these parameters; the Flutter datasource omits several:

| Parameter | Spec Required | Flutter Sends | Status |
|-----------|:---:|:---:|--------|
| `customerId` | Yes | Yes | OK |
| `complaint` | Yes | Yes | OK, but missing suffix (see Section 8) |
| `category` | Yes | Yes | OK |
| `error` | No | Optionally | OK |
| `assignedTo` | No | Optionally | OK in datasource, but provider NEVER passes it (see Section 5) |

The provider method `createComplaint()` does not accept or forward `assignedTo`. It must be added.

### 1.3 `closeComplaintRest` -- Incomplete Parameters
**Priority: HIGH**

The Flutter datasource sends only `complaintId` and optional `remarks`. The spec requires:

| Parameter | Spec Required | Flutter Sends | Gap |
|-----------|:---:|:---:|-----|
| `complaintId` | Yes | Yes | -- |
| `ticketNumber` | Yes | **NO** | MISSING |
| `comment` | Yes | Sent as `remarks` | Wrong key name; also missing suffix |
| `status` | Yes | **NO** | MISSING -- must send new status value |
| `assignedemp` | No | **NO** | MISSING -- needed for TEAMLEAD |
| `closer_ticket_type_id` | No | **NO** | V2 optional field, not in Android either |
| `closer_reason_id` | No | **NO** | V2 optional field, not in Android either |

The provider method `closeComplaint()` only accepts `complaintId` and `remarks`. It needs `ticketNumber`, `status`, `comment` (with suffix), and optionally `assignedemp`.

### 1.4 `getComplaintHistory` -- Incomplete Parameters
**Priority: MEDIUM**

The Flutter datasource sends only `complaintId`. The spec requires `dealer_id` and `customer_id` (not complaint ID). The parameter name and semantics are wrong.

### 1.5 `getCustomerComplaintListRest` -- Incomplete Parameters
**Priority: MEDIUM**

The Flutter datasource sends only `customerId`. The spec requires `altCustomerId`, `authToken`, and optionally `status` and `userType`. The parameter key may be mismatched (`customerId` vs `altCustomerId`).

---

## 2. Complaint Dashboard
**Priority: HIGH -- Partially implemented**

### What the spec requires (Screen 2):
- A dedicated dashboard view showing "Total Complaints - N" count label
- Paginated list (5 per page) with dynamic page-number buttons
- Uses `gettotalcomplaintslist` endpoint
- Uses `OpenComplaintsAdapter` row format (ticket no, customer name, status with color bar)

### What Flutter has:
- Tab-based view with Open / Closed / All tabs showing counts in the tab labels
- No explicit "Total Complaints - N" label outside tabs
- No pagination (full list rendered via `ListView.builder`)
- No page-number navigation buttons

### Gaps:
| Gap | Priority |
|-----|----------|
| No client-side pagination (5 per page with page buttons) | MEDIUM |
| Open/Closed/All tabs are a reasonable alternative to the Android dashboard; acceptable if intentional | LOW |

---

## 3. New Complaint Creation
**Priority: HIGH -- Major gaps**

### What the spec requires (Screen 5):
- Customer-linked flow: receives `custId`, `reseller_id`, `custName` from navigation
- Displays customer name and CRF/CAF as read-only fields
- Category dropdown -> triggers subcategory API call -> subcategory dropdown appears
- Employee assignment dropdown (loaded from `getLcoEmployeeList`)
- Description field auto-populated from selected category/subcategory name
- Appends `.Complaint Created from Android app` suffix before submission
- On success: shows AlertDialog with category, complaint text, and ticket number, then pops back

### What Flutter has:
- Manual `Customer ID` text input (not linked to customer navigation flow)
- Category dropdown (loads from API, with hardcoded fallback items)
- Description text field (not auto-populated)
- No subcategory dropdown
- No employee assignment dropdown
- No description suffix
- No ticket number shown on success

### Gaps:

| Gap | Description | Priority |
|-----|-------------|----------|
| No subcategory cascade | When a category is selected, `getComplaintsubCategory` should be called and a subcategory spinner shown. Subcategory ID should be sent as `category` if selected. | HIGH |
| No employee assignment | `getLcoEmployeeList` endpoint not called; no dropdown for assigning an employee. Provider does not pass `assignedTo`. | HIGH |
| Customer ID is manual text input | Should receive customer context from navigation (custId, custName) rather than requiring manual entry. | HIGH |
| No description auto-populate | Selecting a category/subcategory should auto-fill the description field with the category name. | MEDIUM |
| Hardcoded fallback categories | When API returns empty, 4 hardcoded categories are shown. Should show an error or retry instead. | MEDIUM |
| No success dialog with ticket number | Spec shows ticket number in success dialog; Flutter just shows a SnackBar. | MEDIUM |
| Missing `.Complaint Created from Android app` suffix | See Section 8. | HIGH |

---

## 4. Close / Update Complaint
**Priority: HIGH -- Not implemented**

### What the spec requires (Screen 7 - ComplaintHistory_Other):
- Shows complaint details: customer name, ticket number, complaint text (stripped of suffix), current status
- Status spinner loaded from `complaintTypesRest` (pre-selected to current status)
- Mandatory comment field
- Service employee spinner for TEAMLEAD users
- Appends `.Complaint Status Change From Android app` to comment before submission
- Sends: `complaintId`, `ticketNumber`, `comment`, `status`, `assignedemp`
- Validates: comment not empty, TEAMLEAD must select employee

### What Flutter has:
- Provider has a `closeComplaint(complaintId, {remarks})` method but it only sends `complaintId` and `remarks`
- No UI screen for updating/closing a complaint
- No complaint types/status spinner
- No comment field UI
- No service employee selector
- No comment suffix

### Gaps:

| Gap | Description | Priority |
|-----|-------------|----------|
| No Update Complaint screen | Entire screen missing. Must build UI with status spinner, comment field, employee selector. | HIGH |
| `closeComplaint` API call incomplete | Missing `ticketNumber`, `status`, `assignedemp` parameters. Key name `remarks` should be `comment`. | HIGH |
| No `complaintTypesRest` integration | Datasource method exists but is never called from provider or UI. | HIGH |
| No comment suffix `.Complaint Status Change From Android app` | See Section 8. | HIGH |
| No TEAMLEAD employee validation | See Section 9. | HIGH |

---

## 5. Complaint History (Customer-Linked)
**Priority: HIGH -- Not implemented**

### What the spec requires (Screen 9 - ComapliantHistory):
- Receives `custId` from navigation
- Calls `ComplaintHistoryRest` with `dealer_id` and `customer_id`
- Shows "Total Complaints - N" label
- List with columns: ticket number, date, category, description, status

### What Flutter has:
- Datasource method `getComplaintHistory(complaintId)` exists but sends wrong parameter (`complaintId` instead of `customer_id` + `dealer_id`)
- No UI screen
- Not called from provider

### Gaps:

| Gap | Description | Priority |
|-----|-------------|----------|
| No Complaint History screen | Entire screen missing. | HIGH |
| Wrong API parameters | Must send `dealer_id` and `customer_id`, not `complaintId`. | HIGH |
| Provider has no method for complaint history | Must add `loadComplaintHistory()` to `ComplaintNotifier`. | HIGH |

---

## 6. Open Complaints List -- Column and Detail Dialog Gaps
**Priority: MEDIUM**

### What the spec requires (Screen 3):
Each row shows:
- Ticket number (`tkt_number`)
- Customer name (`customer_name`)
- Status with color-coded bar (`igv_bgclr`)
- "Update" button to navigate to `ComplaintHistory_Other_Fragment`
- Tap opens detail dialog showing: ticket number, description (stripped of suffix), customer account ID, CAF

### What Flutter has:
- `_ComplaintCard` shows: complaint ID, customer name, category, status badge, date
- Binary color: warning (open) or success (closed) -- no 5-color status mapping
- No "Update" button on rows
- No detail dialog on tap
- No ticket number display (uses `complaint_id` / `complaintId` instead)

### Gaps:

| Gap | Description | Priority |
|-----|-------------|----------|
| Missing ticket number display | Card shows `complaint_id` but not `tkt_number`. Spec uses ticket number as primary identifier. | HIGH |
| No detail dialog on tap | Spec shows a popup with ticket no, description, customer account ID, CAF. | MEDIUM |
| No "Update" button per row | Cannot navigate to update complaint screen. | HIGH |
| Missing 5-color status mapping | See Section 13. | MEDIUM |
| No TEAMLEAD service employee filter spinner | Open complaints should show a service employee filter when userType is TEAMLEAD. | MEDIUM |
| Missing columns: `customer_account_id`, `CAF`, `assigned_name` | Spec shows these fields in detail dialog. | LOW |

---

## 7. Config Flags
**Priority: HIGH**

### 7.1 `showLcoComplaint`
- **Spec:** Controls visibility of complaint menu items. When `"0"`, hide all complaint screens from navigation.
- **Flutter:** Not referenced anywhere. No conditional rendering of complaint menu.
- **Action:** Read `showLcoComplaint` from login response; conditionally show/hide complaint navigation items.

### 7.2 `access_for_complaints`
- **Spec:** From `getaccesscontrollRest` response. Controls whether complaint create/update actions are enabled.
- **Flutter:** Not referenced anywhere. No permission checks before complaint operations.
- **Action:** Read `access_for_complaints` from access control response; disable create/update buttons when not permitted.

### 7.3 `patch_information`
- **Spec:** Version gating for subcategory cascade, employee assignment, and ticket number in success dialog.
- **Flutter:** Per spec Section 14.4, these should be standard features in Flutter (no version gating needed). However, the features themselves (subcategory, employee assignment, ticket number) are still missing.

---

## 8. Description Suffixes
**Priority: HIGH**

### 8.1 Create Complaint Suffix
- **Spec:** Append `.Complaint Created from Android app` to complaint description before submission.
- **Flutter:** Not implemented. The description is sent as-is.
- **Action:** Append the suffix in the `createComplaint` provider method before calling the datasource.

### 8.2 Update Complaint Comment Suffix
- **Spec:** Append `.Complaint Status Change From Android app` to comments on status update.
- **Flutter:** Not implemented (update screen does not exist).
- **Action:** Implement when building the Update Complaint screen.

### 8.3 Display Stripping
- **Spec:** Strip `.Complaint Created from Android app` from all displayed complaint descriptions.
- **Flutter:** Not implemented. Descriptions are displayed raw.
- **Action:** Add `.replaceAll('.Complaint Created from Android app', '')` to all complaint description display widgets in `_ComplaintCard` and any future detail/history screens.

---

## 9. TEAMLEAD Restriction
**Priority: HIGH**

### What the spec requires:
- On the Update Complaint screen: if `userType == "TEAMLEAD"`, a service employee spinner must be shown. The user MUST select a service employee before submitting. If not selected, show alert: "Please select a Service Employee".
- On the Open Complaints list: TEAMLEAD users see a service employee filter spinner to filter complaints by assigned employee.
- Service employee list loaded from `getServiceEmployeeList` endpoint.

### What Flutter has:
- No `userType` checks anywhere in complaint code.
- No service employee spinner on any screen.
- `getComplaintList` datasource method accepts `serviceEmployeeId` parameter but always defaults to `0` (the provider calls `loadComplaints()` with defaults).

### Gaps:

| Gap | Description | Priority |
|-----|-------------|----------|
| No TEAMLEAD detection | Must read `userType` from login state. | HIGH |
| No service employee filter on open complaints | Must load employee list and show filter spinner for TEAMLEAD. | HIGH |
| No mandatory employee selection on update | Must enforce employee selection validation for TEAMLEAD before closing/updating. | HIGH |
| `getServiceEmployeeList` endpoint not defined in ApiConstants | The `serviceEmployeeList` constant exists but is not used in complaint context. | MEDIUM |

---

## 10. Missing Screens

| # | Spec Screen | Android Class | Flutter Equivalent | Status |
|---|------------|--------------|-------------------|--------|
| 2 | Complaint Dashboard | `ComplaintDashboard` | `ComplaintScreen` (partial -- tabs instead of dashboard) | PARTIAL |
| 3 | Open Complaints List | `OpenComplaints_frag` | `ComplaintScreen` Open tab (partial) | PARTIAL |
| 4 | Complaint Operations (Customer-Linked) | `Complaint_Operations_Fragment` | **NONE** | MISSING |
| 5 | New Complaint Creation | `Complaint_NewComplint_Fragment` | `_showCreateComplaintSheet` (partial -- bottom sheet) | PARTIAL |
| 6 | Complaint Search Result List | `ComplaintSearchResultList_Fragment` | **NONE** | MISSING |
| 7 | Update Complaint | `ComplaintHistory_Other_Fragment` | **NONE** | MISSING |
| 8 | Closed Complaint Detail | `ComplaintHistory_Close_Fragment` | **NONE** | MISSING |
| 9 | Complaint History (Customer-Linked) | `ComapliantHistory` | **NONE** | MISSING |

### Summary: 5 screens completely missing, 3 partially implemented.

### Required new screens:

1. **Complaint Operations (Customer-Linked)** -- Entry point from customer record with "New Complaint" and "Update Complaint" buttons. Priority: HIGH.
2. **Complaint Search Result List** -- Shows customer-specific complaint list with routing to update or closed detail based on status. Priority: HIGH.
3. **Update Complaint** -- Status change spinner, comment field, employee assignment. Priority: HIGH.
4. **Closed Complaint Detail** -- Read-only view of closed complaint (customer name, ticket number, complaint text, status, back button). Priority: MEDIUM.
5. **Complaint History (Customer-Linked)** -- Per-customer history list with ticket, date, category, description, status columns. Priority: HIGH.

---

## 11. Status Color Mapping
**Priority: MEDIUM**

### What the spec requires (Section 13):

| Status | Color | Hex |
|--------|-------|-----|
| `Assigned` | Green | `#08C889` |
| `resolved` | Green | `#08C889` |
| `inprocess` | Teal | `#00BEB7` |
| `onhold` | Orange | `#E67E22` |
| `closed` | Red | `#E74C3C` |
| (default) | Blue | `#0875C8` |

Case-insensitive matching.

### What Flutter has:
- Binary color: `isOpen` (not closed) = warning orange/yellow, closed = success green.
- Only 2 colors instead of 5+default.

### Action:
Implement a `getStatusColor(String status)` utility function with the 5 status-specific colors plus a blue default. Apply to all complaint card status badges and any future list rows.

---

## 12. Provider State Gaps
**Priority: MEDIUM**

### Missing state fields in `ComplaintState`:
- `subCategories` -- list of subcategories for selected category
- `complaintTypes` -- list of status types for update spinner
- `employeeList` -- list of LCO employees for assignment
- `serviceEmployeeList` -- list of service employees for TEAMLEAD filter
- `complaintHistory` -- per-customer complaint history
- `customerComplaints` -- complaints for a specific customer (from `getCustomerComplaintListRest`)
- `selectedCategoryId` -- for triggering subcategory load

### Missing provider methods in `ComplaintNotifier`:
- `loadSubCategories(String categoryId)` -- calls `getComplaintSubCategories`
- `loadComplaintTypes()` -- calls `getComplaintTypes`
- `loadEmployeeList()` -- calls LCO employee list
- `loadServiceEmployeeList()` -- calls service employee list
- `loadCustomerComplaints(String customerId)` -- calls `getCustomerComplaintList`
- `loadComplaintHistory(String customerId)` -- calls `getComplaintHistory` with correct params
- `updateComplaint(...)` -- full close/update with all required parameters

---

## Priority Summary

| Priority | Count | Key Items |
|----------|-------|-----------|
| **HIGH** | 18 | 5 missing screens, incomplete close/update API, no subcategory cascade, no employee assignment, no description suffixes, no access control flags, no TEAMLEAD restrictions |
| **MEDIUM** | 8 | No pagination, no detail dialog, no status color mapping, missing provider state, hardcoded fallback categories, wrong ComplaintHistory API params |
| **LOW** | 3 | Missing detail columns (CAF, account ID), tab-vs-dashboard layout choice, description auto-populate |
