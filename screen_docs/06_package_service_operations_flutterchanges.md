# 06 - Package & Service Operations: Flutter Changes Required

**Generated:** 2026-03-26
**Spec:** `06_package_service_operations.md`
**Compared against:**
- `lib/data/datasources/remote/package_remote_datasource.dart`
- `lib/application/providers/package_provider.dart`
- `lib/presentation/screens/packages/package_operations_screen.dart`
- `lib/core/constants/api_constants.dart`

---

## 1. API Endpoints

| # | Endpoint | Spec Requirement | Implemented? | Gap |
|---|----------|-----------------|--------------|-----|
| 1 | `getCustomerPackages_splitRest` | Load active packages (deactivation) | YES - constant defined, datasource method exists | None |
| 2 | `getUnassignedPackages_splitRest` | Load available packages (activation) | YES - constant defined, datasource method exists | None |
| 3 | `activateServiceRest` | Activate packages | PARTIAL - endpoint exists but request params incomplete | See 1.1 |
| 4 | `deactivateServiceRest` | Deactivate packages | PARTIAL - endpoint exists but request params incomplete | See 1.2 |
| 5 | `extendCustomerServices` | Extend service validity | YES - constant and datasource method exist | None |
| 6 | `getCasPackagesRest` | CAS packages for new customer flow | PARTIAL - endpoint exists but `boxNumber` param missing | See 1.3 |
| 7 | `channel_listRest` | View channels in a package | PARTIAL - endpoint exists but `dealer_id` param missing | See 1.4 |
| 8 | `renewServicesList` | Submit bulk renewal | PARTIAL - endpoint exists but params incomplete | See 1.5 |
| 9 | `getRenewServicesList` | Fetch renewable services list | PARTIAL - endpoint exists but params incomplete | See 1.6 |
| 10 | `getbilldetailsRest` | Bill calculation before activation | NOT IMPLEMENTED in datasource | See 1.7 |
| 11 | `getDeactiveReasonsRest` | Deactivation reason list | NOT IMPLEMENTED in datasource | See 1.8 |

### 1.1 `activateServiceRest` - Missing Request Parameters (HIGH)
**Current:** Sends only `customer_id`, `stb_no`, `package_id`.
**Required:** `authToken`, `customerId`, `productId` (comma-separated), `customerDeviceId`, `quantity` (hardcoded 1), `dateType`, `pricingStructureType`, `validityDays`, `stockId`, `fromMobileApp` (hardcoded 1), `dealer_id`, `reseller_id`, `login_employee_id`.

### 1.2 `deactivateServiceRest` - Missing Request Parameters (HIGH)
**Current:** Sends only `customer_id`, `stb_no`, `package_id`.
**Required:** `authToken`, `customerId`, `serviceId` (comma-separated service IDs, NOT package IDs), `reasonId`, `remarks` (with ".Deactivation From Flutter App" suffix appended), `stock_id`, `dealer_id`, `reseller_id`, `login_employee_id`, `fromMobileApp` (hardcoded 1).

### 1.3 `getCasPackagesRest` - Missing `boxNumber` Parameter (MEDIUM)
**Current:** No parameters sent at all.
**Required:** `authToken`, `boxNumber`.

### 1.4 `channel_listRest` - Missing `dealer_id` Parameter (MEDIUM)
**Current:** Sends only `package_id`.
**Required:** `authToken`, `product_id`, `dealer_id`.

### 1.5 `renewServicesList` - Missing Parameters (HIGH)
**Current:** Sends only `customer_id`, `stb_no`.
**Required:** `authtoken`, `dealer_id`, `customer_id`, `customer_service_id` (comma-separated), `product_ids` (comma-separated).

### 1.6 `getRenewServicesList` - Missing `dealer_id` Parameter (MEDIUM)
**Current:** Sends only `customer_id`, `stb_no`.
**Required:** `authtoken`, `dealer_id`, `customer_id`.

### 1.7 `getbilldetailsRest` - Not Implemented in Datasource (HIGH)
**Status:** The API constant `billDetails` exists in `api_constants.dart` (under Payments section), but there is NO method in `PackageRemoteDatasource` to call it for package activation.
**Required:** Add a `getBillDetails()` method sending: `authtoken`, `dealer_id`, `employee_id`, `customer_id`, `package_id` (comma-separated), `serial_number`.
**Response parsing needed:** `basePrice.lco_share`, `basePrice.mso_share`, `basePrice.total_amount`, `basePrice.ncf_display_name`, `basePrice.ncf_total_amount`, `basePrice.encf_display_name`, `basePrice.encf_total_amount`, plus `enum_add_on_after_base` and `ENABLE_PRORATA_DISCOUNT`.

### 1.8 `getDeactiveReasonsRest` - Not Implemented in Datasource (HIGH)
**Status:** The constant `deactivationReasons` exists in `api_constants.dart` (under STB/Box section), but there is NO method in `PackageRemoteDatasource` to call it for package deactivation reasons.
**Required:** Add a `getDeactivationReasons()` method sending: `authToken` (and optionally `showforlco`, `stockId`).
**Response:** `reasonList[]` array with `reasonId`, `reasonName`, `global_reason` per item.

---

## 2. Four-Tab Package Display (Base / Add-On / A-La-Carte / Broadcaster) (HIGH)

**Current:** The screen uses only 2 tabs: "Assigned" and "Available". Packages are displayed as a flat list without category segmentation.

**Required per spec:**
- Both the activation view and the deactivation view must have **4 category tabs**: Base, Add-On, A-La-Carte, Broadcaster.
- The API responses return `packageList_base`, `packageList_addon`, `packageList_ala`, `packageList_broadcaster` as separate arrays.
- The current code casts the entire response `data` as a single list, completely ignoring the 4-category split.
- Each tab should display its respective category list with search/filter capability.
- Selection state must persist across tab switches.

**Changes needed:**
- Replace the 2-tab `TabController` with a 4-tab controller for each context (activation/deactivation).
- Parse the 4 separate arrays from the API response instead of a single `data` array.
- Add a search bar that live-filters the active tab's list by package name.

---

## 3. Activation Flow - Two-Step Bill Preview (HIGH)

**Current:** Single-step: confirm dialog -> immediate `activateService` call. No bill preview step.

**Required per spec (mandatory two-step flow):**
1. User selects packages across all 4 tabs, taps "Save".
2. Summary dialog shows selected packages with names, computed start/end dates, prices, and total.
3. "Get Bill" button calls `getbilldetailsRest` with comma-separated package IDs.
4. On success: bill breakdown displayed (lco_share, mso_share, NCF, ENCF), "Get Bill" button hides, "Activate" button appears.
5. User taps "Activate" -> final "Are you sure?" confirmation -> `activateServiceRest` called.

**Changes needed:**
- Add `getBillDetails` method to datasource and provider.
- Build a multi-step confirmation dialog with bill breakdown UI.
- Show computed start/end dates per package in the summary.
- "Activate" button must be hidden until "Get Bill" succeeds.

---

## 4. Deactivation Flow - Reason Selection and Filtering (HIGH)

**Current:** Simple confirm dialog with no reason selection, no remarks, no reason filtering. Sends `package_id` instead of `serviceId`.

**Required per spec:**
- Load deactivation reasons from `getDeactiveReasonsRest`.
- Filter reasons: exclude items where `id == 21`, `id == 17`, or `global_reason == 1`.
- Display reason dropdown (spinner) and mandatory remarks text field.
- Append ".Deactivation From Flutter App" to user remarks before sending.
- Send `serviceId` (comma-separated customer service IDs), NOT `package_id`.
- Include `reasonId` and `remarks` in the API request.
- Show confirmation dialog with selected packages, names, and total price before final submit.
- Validation: remarks must not be empty.

**Changes needed:**
- Add `getDeactivationReasons()` to datasource.
- Add reason state, filtering logic, and remarks field to provider/UI.
- Fix the deactivation API call to send `serviceId` instead of `package_id`.
- Add remarks appending logic.

---

## 5. Renewal Flow - Bulk Renewal with Comma-Separated IDs (HIGH)

**Current:** No renewal UI exists in `PackageOperationsScreen`. The datasource has `renewServices()` and `getRenewServices()` methods but the screen does not use them. The provider (`PackageNotifier`) has no renewal methods.

**Required per spec:**
- Renew button visible only when `isexpired == 1` AND `patch_information` matches specific versions.
- Fetch renewable services via `getRenewServicesList` with `dealer_id`.
- Display list with checkboxes for multi-select.
- Collect `customer_service_id` values as comma-separated string and `product_id` values as comma-separated string.
- Summary dialog showing selected services and total price.
- Submit via `renewServicesList` with both comma-separated ID strings.

**Changes needed:**
- Add renewal state and methods to `PackageNotifier`.
- Build a RenewFragment-equivalent screen/tab.
- Implement multi-select with comma-separated ID aggregation.
- Add visibility gating based on `isexpired` and `patch_information`.

---

## 6. CAS Packages for New Customer Flow (MEDIUM)

**Current:** `getCasPackages()` in datasource sends no parameters at all.

**Required per spec:**
- Send `authToken` and `boxNumber` to `getCasPackagesRest`.
- Display packages with pricing_structure_type awareness.
- Activation cycle spinner: Year/Month/Day for one-time (type 1), Year only for recurring (type 2).
- Quantity field (mandatory) and validity days field (visible only when "Day" cycle selected).
- Return selected values (productId, name, quantity, cycle, validityDays, pricingType) to caller.
- No screen or widget exists for this flow.

**Changes needed:**
- Fix `getCasPackages()` to accept and send `boxNumber`.
- Build `NewCust_AddPackage` screen with cycle spinner, quantity, and validity days fields.
- Implement validation rules per spec.

---

## 7. Channel List Viewing (MEDIUM)

**Current:** `getChannelList()` exists in datasource but sends only `package_id`. No UI exists anywhere to display channel lists.

**Required per spec:**
- Each package row should have a tappable channel count button.
- Tapping triggers `channel_listRest` with `product_id` and `dealer_id`.
- Display dialog with: package name + price as title, "Total Channels: N" header, list of channels showing name, language, logo, price.

**Changes needed:**
- Add `dealer_id` parameter to `getChannelList()`.
- Add channel count display to package card rows.
- Build channel list dialog UI.

---

## 8. Bill Calculation Display (lco_share, mso_share, NCF, ENCF) (HIGH)

**Current:** No bill calculation UI exists. No parsing of `basePrice` sub-object.

**Required per spec:**
- After "Get Bill" call succeeds, display:
  - `lco_share` (LCO operator share)
  - `mso_share` (MSO share)
  - `ncf_display_name` / `ncf_total_amount` (hidden if amount <= 0)
  - `encf_display_name` / `encf_total_amount` (hidden if amount <= 0)
  - `total_amount` (grand total)
- These are shown in a `ll_shares` container that becomes visible only after bill fetch.

**Changes needed:**
- Build bill breakdown UI section within the confirmation dialog.
- Parse nested `basePrice` JSON object from response.
- Conditionally show/hide NCF and ENCF rows based on amount > 0.

---

## 9. Config Flags Not Used (HIGH)

| Config Flag | Source | Current Status | Required Behavior |
|-------------|--------|---------------|-------------------|
| `recurringServiceEdit` | `validateLogin` | NOT USED | If 1, show full cycle spinner (Year/Month/Day); if 0, Year only regardless of pricing type |
| `show_service_extension` | `validateLogin` | NOT USED | Show/hide extend service option in package list |
| `enum_add_on_after_base` | `getbilldetailsRest` | NOT USED | Validate whether add-ons can be added without base package |
| `ENABLE_PRORATA_DISCOUNT` | `getbilldetailsRest` | NOT USED | Affects bill amount calculation/display in confirmation |
| `int_stb_activation` | `getaccesscontrollRest` | NOT USED | Show/hide Activate button on hub screen |
| `int_stb_deactivation` | `getaccesscontrollRest` | NOT USED | Show/hide Deactivate button on hub screen |
| `patch_information` | `validateLogin` | NOT USED | Gate Renew button visibility (must match "1.4.13.2", "1.4.13.3", or "1.4.13.4") |

**Changes needed:**
- Read and store these flags from login/access-control responses.
- Apply visibility and behavioral rules throughout the package operations screens.

---

## 10. Date Validity Logic (MEDIUM)

**Current:** No date computation exists in the Flutter code.

**Required per spec:** When a package is selected for activation, compute start and end dates locally for display in the confirmation dialog:

| Validity String Length | Calendar Operation |
|------------------------|-------------------|
| 7 characters (e.g. "1 Years") | Add `validity_days` YEARS to today |
| 8 characters (e.g. "1 Months") | Add `validity_days` MONTHS to today |
| Any other length | Add `validity_days` DAYS to today |

- Start date = today, formatted `dd-MM-yyyy`.
- End date = today + validity period - 1 day, formatted `dd-MM-yyyy`.
- These dates are display-only (not sent to activation API).

**Changes needed:**
- Add date computation utility based on validity string length.
- Display computed dates per selected package in the confirmation dialog.

---

## 11. Hub Screen / Navigation Architecture (MEDIUM)

**Current:** Single flat screen with 2 tabs (Assigned/Available). No hub navigation.

**Required per spec:**
- Hub screen with 3 operation buttons: Activate Package, Deactivate Package, Renew Services.
- Hub displays customer info: name (truncated at 18 chars), customer ID, box number, due amount with currency symbol.
- Each button navigates to a dedicated child screen/fragment.
- Button visibility controlled by access-control flags (`int_stb_activation`, `int_stb_deactivation`, `isexpired` + `patch_information`).

**Changes needed:**
- Restructure as hub + 3 child screens, OR add proper navigation/routing within the current screen.
- Add customer context display (name, ID, box, due amount).
- Implement visibility rules for each operation button.

---

## 12. Package Card Row Fields Incomplete (MEDIUM)

**Current:** Each package card shows: name, price, type badge, expiry date (assigned only).

**Required per spec - Activation row fields:**
- Package name
- Validity (e.g. "1 Monthly", "1 Yearly")
- Base price
- Channel count (SD + HD combined)
- Multi-select checkbox
- Channel list button (tappable)

**Required per spec - Deactivation row fields:**
- Product name
- Start date, end date
- Base price
- SD/HD channel counts
- Billing cycle (monthly_or_yearly)
- Multi-select checkbox

**Changes needed:**
- Add validity display, channel count, and checkbox multi-select to package cards.
- Add channel list button to each row.
- Show start/end dates on assigned (deactivation) package cards.

---

## 13. Provider State Incomplete (MEDIUM)

**Current `PackageState`:** Only holds `isLoading`, `errorMessage`, `successMessage`, `assignedPackages` (flat list), `availablePackages` (flat list).

**Required additional state:**
- 4 category lists for assigned: `basePackages`, `addonPackages`, `alacartePackages`, `broadcasterPackages`
- 4 category lists for available (same split)
- `deactivateCustomerServices` list (currently active services shown as reference during activation)
- `deactivationReasons` list (filtered)
- `selectedPackageIds` set (multi-select tracking)
- `billDetails` (lco_share, mso_share, ncf, encf, total)
- `renewableServices` list
- `channelList` per package (for dialog display)
- `selectedReason` and `remarks` for deactivation

**Changes needed:**
- Expand `PackageState` with all required fields.
- Add provider methods: `loadBillDetails()`, `loadDeactivationReasons()`, `loadRenewableServices()`, `submitRenewal()`, `loadChannelList()`.

---

## 14. Missing `fromMobileApp` Flag (LOW)

**Current:** Neither `activateService` nor `deactivateService` sends `fromMobileApp = 1`.

**Required:** Both activation and deactivation API calls must include `fromMobileApp: 1` (integer).

---

## 15. Missing Incoming Navigation Context (LOW)

**Current:** Screen accepts `customerId`, `stbNo`, `customerName` only.

**Required per spec:** `custId`, `boxNo`, `custDevId` (device ID), `custStockId` (stock ID), `resellerid`, `isexpired`, `reqOrigin`, `pending_amount`.

**Changes needed:**
- Add `deviceId`, `stockId`, `resellerId`, `isExpired`, `pendingAmount` parameters.
- These are needed for API calls (`stockId` in activation/deactivation, `resellerId` as `reseller_id`, `isExpired` for renewal button visibility).

---

## Priority Summary

### HIGH Priority (Functional blockers - core operations broken or missing)
1. **Section 2** - 4-tab package display (Base/Add-On/A-La-Carte/Broadcaster) not implemented
2. **Section 3** - Two-step activation flow (Get Bill -> Activate) missing entirely
3. **Section 4** - Deactivation reason selection, filtering (exclude IDs 21/17/global_reason==1), and remarks missing
4. **Section 5** - Renewal flow has no UI, no provider methods
5. **Section 8** - Bill calculation display (lco_share, mso_share, NCF, ENCF) not implemented
6. **Section 9** - Config flags not used (access control, recurring edit, prorata discount)
7. **Section 1.1** - activateServiceRest missing most required parameters
8. **Section 1.2** - deactivateServiceRest sends wrong ID type and missing most parameters
9. **Section 1.7** - getbilldetailsRest not implemented in datasource
10. **Section 1.8** - getDeactiveReasonsRest not implemented in datasource

### MEDIUM Priority (Feature gaps - secondary flows or display issues)
1. **Section 6** - CAS packages screen for new customer flow missing
2. **Section 7** - Channel list viewing dialog missing
3. **Section 10** - Date validity computation missing
4. **Section 11** - Hub screen navigation architecture differs from spec
5. **Section 12** - Package card row fields incomplete
6. **Section 13** - Provider state needs significant expansion
7. **Section 15** - Missing navigation context parameters
8. **Section 1.3** - getCasPackagesRest missing boxNumber parameter
9. **Section 1.4** - channel_listRest missing dealer_id parameter
10. **Section 1.5** - renewServicesList missing required parameters
11. **Section 1.6** - getRenewServicesList missing dealer_id parameter

### LOW Priority (Minor gaps)
1. **Section 14** - Missing `fromMobileApp` flag in API calls
