# Customer Management — Flutter Changes Required

> **Generated:** 2026-03-26
> **Compared:** Flutter implementation vs `02_customer_management.md` spec
> **Branch:** 16kbisssuefix

---

## Table of Contents

1. [API Endpoints](#1-api-endpoints)
2. [Models](#2-models)
3. [Search Flow (SC-01, SC-02)](#3-search-flow)
4. [New Customer Wizard (SC-04, SC-05, SC-06)](#4-new-customer-wizard)
5. [Edit Customer (SC-07)](#5-edit-customer)
6. [Master Data Cascading Dropdowns](#6-master-data-cascading-dropdowns)
7. [Dynamic Form Validations](#7-dynamic-form-validations)
8. [Config Flags](#8-config-flags)
9. [Customer Operations Routing (SC-03)](#9-customer-operations-routing)
10. [STB Dashboard Fragments (SC-11)](#10-stb-dashboard-fragments)
11. [Additional Missing Screens](#11-additional-missing-screens)

---

## 1. API Endpoints

### Implemented

| Endpoint | Status | File |
|---|---|---|
| `getCustomerDetailsCountRest` | Implemented | `customer_remote_datasource.dart` |
| `getCustomerDetailsRest` | Implemented (pagination present) | `customer_remote_datasource.dart` |
| `existingCustomerRest` | Implemented | `customer_remote_datasource.dart` |
| `saveCustomerRest` | Implemented (accepts generic Map) | `customer_remote_datasource.dart` |
| `editCustomerRest` | Implemented (accepts generic Map) | `customer_remote_datasource.dart` |
| `updateCustomerLocation` | Implemented | `customer_remote_datasource.dart` |
| `getCountriesRest` | Implemented | `master_data_remote_datasource.dart` |
| `getStatesRest` | Implemented | `master_data_remote_datasource.dart` |
| `getdistrictsRest` | Implemented | `master_data_remote_datasource.dart` |
| `getCitiesRest` | Implemented | `master_data_remote_datasource.dart` |
| `getmandalsRest` | Implemented | `master_data_remote_datasource.dart` |
| `getLocationsOfDistrictRest` | Implemented | `master_data_remote_datasource.dart` |
| `getGroupsRest` | Implemented | `master_data_remote_datasource.dart` |
| `getCustomerTypesRest` | Implemented | `master_data_remote_datasource.dart` |
| `getcustomerTypeTypesRest` | Implemented | `master_data_remote_datasource.dart` |
| `getIdsRest` | Implemented | `master_data_remote_datasource.dart` |
| `dynamicformvalidationsRest` | Implemented (datasource only) | `master_data_remote_datasource.dart` |
| `getCasPackagesRest` | Defined in `api_constants.dart` | Constant exists but no screen uses it |

### Missing / Gaps

| Gap | Spec Requirement | Priority |
|---|---|---|
| `getCustomerDetailsCountRest` missing `cafNumber` param | Spec SC-01 shows 6 search fields; the count endpoint only accepts 5 (no `cafNumber`). The details endpoint has it, but count does not. | **MEDIUM** |
| `dynamicformvalidationsRest` missing request params | Spec requires `table_name` and `dealerId` in the request. Current implementation sends empty body `{}`. | **HIGH** |
| `getCitiesRest` missing `boxNumber` param | Spec section 15.2 shows `getCitiesRest` needs `stateId` + `boxNumber`. Current implementation sends `stateId` + `districtId` instead. Verify server expectation. | **MEDIUM** |
| `getassignedtsb` endpoint not defined | Spec SC-11 requires a `getassignedtsb` API (or equivalent REST) for dashboard STB count fragments. No constant or datasource method exists. | **HIGH** |
| `getCasPackagesRest` not wired to any datasource method | Constant defined in `api_constants.dart` but no method in any datasource calls it. Needed for SC-05 (package selection). | **HIGH** |
| `getCustomerParticularBoxDetailsRest` not called from profile | Spec SC-08 requires fetching particular box details with `stockId` and `userType`. No Flutter code calls this for the STB select flow. | **MEDIUM** |

---

## 2. Models

### Current State

**No Dart model files exist.** The `lib/data/models/` directory is empty (or does not exist). All data is passed as raw `Map<String, dynamic>` throughout the codebase:
- `CustomerSearchState.customers` is `List<Map<String, dynamic>>`
- `CustomerProfileScreen._customer` is `Map<String, dynamic>`
- `saveCustomer` and `editCustomer` accept `Map<String, dynamic>`

### Required Models

| Model | Spec Reference | Priority |
|---|---|---|
| `CustomerSearchResult` — typed model with `customerId`, `customerName`, `cafNumber`, `mobileNumber`, `status`, `billingAddress`, `installationAddress`, `pinCode`, `crfNumber`, `pending_amount`, `online_customer`, `checkaddserviceaccess`, `ADDON_AFTER_BASEPACK`, `reseller_id`, `bill_type`, `is_direct_lco`, `accountnumber`, `latitude`, `longitude` | SC-02 section 3.2 | **HIGH** |
| `SaveCustomerRequest` — typed model covering all 40+ fields from spec section 5.8 | SC-04 section 5.8 | **HIGH** |
| `EditCustomerRequest` — typed model covering all fields from spec section 8.6 | SC-07 section 8.6 | **HIGH** |
| `FormValidation` — model with `column_name` (String) and `is_mandatory` (String) | Section 14.1 | **HIGH** |
| `CasPackage` — model with `productId`, `productName`, `pricingStructureType` | SC-05 section 6.4 | **HIGH** |
| `EditCustomerResponse` — model for pre-populating edit form (section 8.2 lists all mapped fields) | SC-07 section 8.2 | **MEDIUM** |
| `AssignedStbModel` — model for dashboard STB list items | SC-11 section 12.4 | **MEDIUM** |
| `CustomerBoxDetail` — model with `serialNumber`, `vcNumber`, `boxNumber`, `macAddress`, `stockId`, `deviceId`, `backendSetupId`, `stockStatus` | SC-08 section 9.3 | **MEDIUM** |

---

## 3. Search Flow (SC-01, SC-02)

### What EXISTS

- `CustomerSearchScreen` has 4 search type chips: `Name`, `Serial / VC`, `Mobile`, `Customer ID`.
- `CustomerSearchNotifier.search()` calls count first, then details.
- Pagination params passed as `startValue: 0, endValue: 50`.
- Results displayed in an expandable card list with inline box/package details.

### Gaps

| Gap | Spec Requirement | Current State | Priority |
|---|---|---|---|
| Missing `cafNumber` search field | Spec SC-01 has 5 distinct input fields (custId, name, mobile, boxNo, lcoCustomerId). The 6th field `cafNumber` is used in the details call but not exposed as a UI search option. | No CAF/CRF search chip. `_searchTypes` only has 4 entries. | **MEDIUM** |
| Missing `lcoCustomerId` as separate search option | Spec has `lcoCustomerId` as a distinct field. Flutter maps "Customer ID" to `lcoCustomerId`. The spec also has a separate `customerNumber` (VC No). | "Customer ID" maps to `lcoCustomerId`, and "VC No" maps to `customerNumber` in provider. This is correct but should be verified the labels match business intent. | **LOW** |
| Pagination is hardcoded to 50, not 100 | Spec SC-02 says `NUM_ITEMS_PAGE = 100` with page navigation buttons (First/Prev/Next/Last). | Flutter fetches first 50 results only. No pagination UI or "load more" exists. | **HIGH** |
| No pagination controls | Spec has First/Prev/Next/Last page buttons with calculated `pageCount`. | No pagination buttons in Flutter UI. Only first page shown. | **HIGH** |
| Missing 10,000 count limit check | Spec: if `customerCount >= 10000`, show "Large Count" dialog and block navigation. | No count limit check in `CustomerSearchNotifier.search()`. | **MEDIUM** |
| Missing `origin` / `request_origin` routing | Spec SC-02 section 3.5: row-tap destination depends on `request_origin` (customerMgmt, payments, complaintMgmt, packageMgmt, stb_Map_custID). | Flutter has no origin parameter. Search screen always behaves the same way regardless of where it was launched from. Customer card expands inline instead of navigating. | **HIGH** |
| Missing "at least one field" validation | Spec: "Please enter data in atleast one field." when all empty. | Provider returns early if `query.trim().isEmpty` but no dialog/snackbar shown to user. | **LOW** |
| Missing name minimum 3-char validation | Spec: "Please enter 3 letters to search with name." | No min-length check for name search. | **LOW** |
| No `online_customer` + `checkaddserviceaccess` guard | Spec: for `packageMgmt` origin, if `online_customer == 1 AND checkaddserviceaccess != 1`, block navigation with dialog. | Not implemented. | **MEDIUM** |

---

## 4. New Customer Wizard (SC-04, SC-05, SC-06)

### What EXISTS

`NewCustomerScreen` is a basic single-page form with 6 fields:
- First Name, Last Name, Mobile Number, Email, Address, Area/Locality
- `_submit()` has a `TODO: Call customer provider to save` and uses `Future.delayed` as a stub.
- No connection to `saveCustomerRest`.

### Gaps

| Gap | Spec Requirement | Current State | Priority |
|---|---|---|---|
| **No multi-step wizard** | Spec requires: STB scan -> Form -> Package selection -> Confirm -> Save. 4 distinct screens (SC-04, SC-05, SC-06). | Single flat form with no steps. No stepper, no wizard flow. | **HIGH** |
| **No STB scan integration** | Spec: STB serial pre-filled from barcode scan and locked (`newcust_boxno` not editable). | No STB field at all. No camera/barcode scanner integration. | **HIGH** |
| **Missing ~25 form fields** | Spec SC-04 section 5.1 lists: Customer Type spinner, Customer Sub-type spinner, Group spinner, CAF Number, LCO Customer ID, Business Name, Father's Name, ID Type spinner, ID Number, Account Number, Address Line 1+2, Installation Address 1+2, Pincode, Phone, Gender spinner, Bill Type spinner, DOB picker, DOA picker, Discount, Remarks, Latitude, Longitude. | Only 6 fields present: First Name, Last Name, Mobile, Email, Address, Area. | **HIGH** |
| **No cascading address dropdowns** | Spec: Country -> State -> District -> City + Mandal (5 spinners). | No dropdown selectors at all. Just a plain text "Address" field. | **HIGH** |
| **No package selection screen (SC-05)** | Spec: `NewCust_AddPackage_Activity` calls `getCasPackagesRest`, shows searchable list, user picks package + quantity + cycle. | No package selection screen exists. No route defined. | **HIGH** |
| **No confirmation screen (SC-06)** | Spec: Read-only review of all fields before save. Confirm button triggers save API. | No confirmation step. Stub `_submit()` shows fake success dialog. | **HIGH** |
| **Save API not connected** | Spec: `saveCustomerRest` with 40+ fields including images, GPS, package info. | `_submit()` does `Future.delayed(2s)` and shows hardcoded success. Datasource method exists but is never called from UI. | **HIGH** |
| **No image capture** | Spec: ID Photo, Customer Photo, Signature capture via camera. | No image fields or camera integration. | **MEDIUM** |
| **No "Same as Billing Address" checkbox** | Spec: checkbox auto-fills installation address from billing address. | No such control. | **MEDIUM** |
| **No existing customer check** | Spec flow implies `existingCustomerRest` should be called (datasource method exists). | Never invoked from any UI screen. | **MEDIUM** |
| **No GPS auto-fill** | Spec: Latitude/Longitude auto-filled from device GPS. | No location service integration. | **MEDIUM** |
| **No Clear button** | Spec: "Clear" button resets all fields. | Not present. | **LOW** |

---

## 5. Edit Customer (SC-07)

### What EXISTS

**No Edit Customer screen exists.** There is no `edit_customer_screen.dart` or equivalent. The `editCustomer` method exists in `customer_remote_datasource.dart` and `ApiConstants.editCustomer` is defined, but no UI calls them.

### Gaps

| Gap | Spec Requirement | Priority |
|---|---|---|
| **Entire screen missing** | Spec SC-07: Full edit form with 20+ EditText fields, 11 spinners, 3 checkboxes (change address, change install address, upload docs), image capture, and `editCustomerRest` API call on Update. | **HIGH** |
| No pre-population from existing customer data | Spec section 8.2: All fields pre-populated from `EditCustomer_ResponseModel`. | **HIGH** |
| No address editability toggles | Spec: Billing and Installation address editable only when respective checkbox is checked. | **HIGH** |
| No account number lock logic | Spec section 8.3: `useAccountNumber == 0` -> editable; `> 0` -> locked. | **HIGH** |
| No validation rules | Spec section 8.4: 7 validation rules on Update tap. | **HIGH** |
| No route to Edit from Customer Profile | `CustomerProfileScreen` has no "Edit" button. Spec SC-03 has Edit Customer as an operation button. | **HIGH** |

---

## 6. Master Data Cascading Dropdowns

### What EXISTS

`MasterDataRemoteDatasource` has all 5 cascade methods implemented:
- `getCountries()`, `getStates(countryCode)`, `getDistricts(stateId)`, `getCities(stateId, districtId)`, `getMandals(districtId)`, `getLocationsOfDistrict(districtId)`
- Also: `getGroups()`, `getCustomerTypes()`, `getCustomerTypeTypes(customerTypeId)`, `getIdTypes()`

### Gaps

| Gap | Spec Requirement | Current State | Priority |
|---|---|---|---|
| **Datasource exists but no UI uses it** | Spec: Both New Customer and Edit Customer forms implement 5-level cascading. | `MasterDataRemoteDatasource` is defined but never imported or called from any screen widget. No provider wraps it. | **HIGH** |
| No `MasterDataProvider` / Notifier | Spec: On selection cascade (Country -> State -> District -> City+Mandal). | No provider exists to manage cascade state. | **HIGH** |
| No default value pre-selection | Spec section 15.3: `defaultcountry`, `defaultstate`, `defaultdistrict`, `defaultcity` from login response should pre-select dropdowns. | Not implemented. | **MEDIUM** |
| `getCitiesRest` param mismatch | Spec says request needs `stateId` + `boxNumber`. Current implementation sends `stateId` + `districtId`. | **MEDIUM** |

---

## 7. Dynamic Form Validations

### What EXISTS

- `MasterDataRemoteDatasource.getDynamicFormValidations()` method exists.
- `ApiConstants.dynamicFormValidations` constant defined.

### Gaps

| Gap | Spec Requirement | Current State | Priority |
|---|---|---|---|
| **Never called from any screen** | Spec: Call on entry to both New Customer and Edit Customer screens. | Method exists in datasource but no screen invokes it. | **HIGH** |
| **Missing request parameters** | Spec section 14: requires `table_name: "customer_details"` and `dealerId` in request body. | `getDynamicFormValidations()` sends empty body (no parameters). | **HIGH** |
| **No FormValidation model** | Spec section 14.1: response is array of `{column_name, is_mandatory}`. Need typed model. | Returns raw `Map<String, dynamic>`. | **MEDIUM** |
| **No mandatory field indicator in UI** | Spec: Red `*` asterisk appended to label when `is_mandatory == "1"`. | No dynamic mandatory indicators on any form. | **HIGH** |
| **No mapping of 8 known column names** | Spec section 14.2: `last_name`, `email`, `id_type`, `id_number`, `gender`, `mobile_no`, `baid`, `mandal_id` each map to specific validation behavior. | No mapping logic exists. | **HIGH** |

---

## 8. Config Flags

### What EXISTS

**None of the config flags are implemented.** No references to any of the following flags exist anywhere in the Flutter codebase:

### Gaps

| Flag | Spec Effect | Priority |
|---|---|---|
| `useCRF` (int) | Controls "CRF No" vs "CAF No" label; controls CAF field visibility in new customer form. | **HIGH** |
| `useCAF` (String) | "AUTO" = hide CAF input; "MANUAL" = show and require CAF input. | **HIGH** |
| `useLastName` (int) | 1 = show Last Name field; 0 = hide, use single "Customer Name" field. | **HIGH** |
| `useDiscount` (int) | 0=hide; 1=show for DEALER/ADMIN/EMPLOYEE; 2=always show. | **MEDIUM** |
| `useAccountNumber` (int) | 0=user enters; >0=auto-generated/locked. | **HIGH** |
| `useMandatoryForHotel` (int) | 1=show customer sub-type spinner. | **MEDIUM** |
| `freezecustomerparamsinapp` (int) | Lock customer fields in app. | **LOW** |
| `hidemakepayment` (int) | 0=show payment button; 1=hide. | **MEDIUM** |
| `int_bulk_payment` (int) | 1=show payment button (from access control). | **MEDIUM** |
| `int_stb_activation/deactivation/reactivation` | Control Box Operations button visibility. | **MEDIUM** |
| `invoice_page_access` | 1=Invoice History button visible. | **MEDIUM** |
| `payment_hist_page_access` | 1=Payment History button visible. | **MEDIUM** |
| `access_for_complaints` | 1=Complaint buttons visible. | **MEDIUM** |
| `defaultcountry/state/district/city` | Pre-select address dropdowns. | **MEDIUM** |

**Action required:** Store all config flags from login response (likely in `AuthState` or a dedicated `ConfigProvider`), and read them in New Customer, Edit Customer, and Customer Operations screens to control field visibility, labels, and validation behavior.

---

## 9. Customer Operations Routing (SC-03)

### What EXISTS

`CustomerProfileScreen` has 4 quick action buttons:
- **Pay** -> routes to `RouteNames.makePayment` (with customerId, customerName)
- **Complaint** -> routes to `RouteNames.complaints` (no customerId passed)
- **STBs** -> routes to `RouteNames.stbOperations` (with customerId, customerName)
- **Packages** -> routes to `RouteNames.packageOperations` (no customerId passed)

Also shows personal details (Name, ID, A/C, Mobile, Address) and subscription info (Status, STB Count, Bill Type, Pending Amount).

### Gaps

| Gap | Spec Requirement | Current State | Priority |
|---|---|---|---|
| **Missing Edit Customer button** | Spec SC-03 section 4.3: Edit Customer is a primary operation. | No Edit button on profile screen. No edit screen exists. | **HIGH** |
| **Missing Invoice History button** | Spec: visible when `invoice_page_access == 1`. | Not present. | **MEDIUM** |
| **Missing Payment History button** | Spec: visible when `payment_hist_page_access == 1`. | Not present. | **MEDIUM** |
| **Missing Complaint History button** | Spec: visible when `access_for_complaints == 1`. | Not present. | **MEDIUM** |
| **Missing View on Map / Update Location** | Spec section 4.6: `tv_locate` and `custoper_update` for GPS location features. | Not present (though `updateCustomerLocation` API exists in datasource). | **LOW** |
| **Complaint route missing customerId** | Spec: Complaint operations need `custId` and `custName`. | `context.push(RouteNames.complaints)` sends no customer data. | **MEDIUM** |
| **Package route missing customerId** | Spec: Package operations need `custId`, `custName`, `pending_amount`, `resellerid`, `bill_type`. | `context.push(RouteNames.packageOperations)` sends no extra data. | **MEDIUM** |
| **No CAF/CRF display** | Spec section 4.1: shows `cafNo` with label from `useCRF` flag. | Profile screen does not show CAF/CRF number. | **MEDIUM** |
| **No due amount button** | Spec: `custoper_tv_dueamtbtn` visible when `pending_amount > 0`, navigates to payment. | Due amount is displayed as text but not clickable to navigate to payment. | **LOW** |
| **No access-control-based button visibility** | Spec section 4.3: Each button visibility depends on access control flags (`int_bulk_payment`, `int_stb_activation`, etc.). | All 4 quick action buttons always visible. | **MEDIUM** |

---

## 10. STB Dashboard Fragments (SC-11)

### What EXISTS

- `dashboard_remote_datasource.dart` and `dashboard_provider.dart` reference `stbType` or `assignedtsb` patterns (confirmed by grep).
- No dedicated STB list screens for the 5 dashboard tiles.

### Gaps

| Gap | Spec Requirement | Current State | Priority |
|---|---|---|---|
| **No STB count list screens** | Spec SC-11: 5 fragments (Assigned stbType=1, Unassigned=2, Total=3, Active=4, Deactive=5) each showing a paginated list of STBs (15 per page). | No dedicated screens exist. Dashboard may show count tiles but tapping them has nowhere to navigate. | **HIGH** |
| **No `getassignedtsb` API endpoint** | Spec: `GET /api/getassignedtsb` with `dealerId` + `stbType`. | Not defined in `ApiConstants`. No datasource method. | **HIGH** |
| **No `AssignedStbModel`** | Spec: response contains `getOpenComplaintsModels` list of `AssignedStbModel`. | No model exists. | **MEDIUM** |
| **No pagination (15 per page)** | Spec: `rowSize = 15`, dynamically generated page buttons. | No implementation. | **MEDIUM** |
| **No route defined** | No route in `app_router.dart` for any STB dashboard list screen. | **HIGH** |

---

## 11. Additional Missing Screens

| Screen | Spec Reference | Status | Priority |
|---|---|---|---|
| **SC-08 — Customer STB/Box Selection** | Section 9: Spinner to select from multiple STBs, calls `getCustomerBoxDetailsRest` then `getCustomerParticularBoxDetailsRest`. Auto-proceeds if only 1 box. | Not implemented as a standalone screen. Box data is fetched inline in search results, but no selection-and-proceed flow exists. | **HIGH** |
| **SC-09 — Payment Receipt Display** | Section 10: Post-payment receipt with print/share. | No receipt display screen found in customer management flow. | **MEDIUM** |
| **SC-10 — Account Activation (POS)** | Section 11: POS hardware-specific. | Not needed per spec note ("can be omitted for mobile"). | **N/A** |

---

## Summary by Priority

### HIGH Priority (17 items — blocks core functionality)

1. No typed Dart models for any customer data structures
2. New Customer form is a stub — missing ~25 fields, no API connection
3. No multi-step wizard (STB scan -> form -> package -> confirm)
4. No package selection screen (SC-05)
5. No confirmation screen (SC-06)
6. Entire Edit Customer screen (SC-07) is missing
7. No cascading address dropdown UI (datasource exists but unused)
8. Dynamic form validations never called, missing request params
9. No config flags stored or used anywhere (`useCRF`, `useCAF`, `useLastName`, `useAccountNumber`)
10. Pagination hardcoded to 50, no page navigation controls (spec: 100 per page with First/Prev/Next/Last)
11. No `origin`/`request_origin` routing in search flow
12. Missing Edit Customer button on profile screen
13. STB Dashboard list screens not implemented (5 fragments)
14. No `getassignedtsb` API endpoint defined
15. No STB Dashboard routes
16. `getCasPackagesRest` not wired to any datasource method
17. No Customer STB/Box Selection standalone screen (SC-08)

### MEDIUM Priority (15 items — important for feature completeness)

1. `cafNumber` missing from count API call
2. `getCitiesRest` parameter mismatch (`districtId` vs `boxNumber`)
3. No 10,000 count limit check on search
4. Missing `online_customer` + `checkaddserviceaccess` guard for package operations
5. No image capture (ID photo, customer photo, signature)
6. No default value pre-selection for address dropdowns
7. Missing Invoice History, Payment History, Complaint History buttons on profile
8. Complaint and Package routes missing customerId
9. No CAF/CRF display on profile screen
10. No access-control-based button visibility on profile
11. No `EditCustomerResponse` model for pre-populating edit form
12. No `AssignedStbModel` for dashboard STB lists
13. No pagination for STB dashboard lists
14. Payment receipt display screen missing
15. No existing customer check (`existingCustomerRest` never called from UI)

### LOW Priority (5 items — polish and edge cases)

1. No "at least one field" validation message on empty search
2. No minimum 3-char name validation
3. `freezecustomerparamsinapp` flag not used
4. No View on Map / Update Location buttons on profile
5. No due amount click-to-pay on profile

---

*End of changes-required document*
