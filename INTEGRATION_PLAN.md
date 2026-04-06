# EzyBill Flutter Integration Plan

## Overview

Cross-reference analysis of the **Android production app**, **api_test.html**, **server code**, and **current Flutter app** to create a step-by-step migration plan with improvements.

---

## Architecture Comparison

| Aspect | Android (Legacy) | Flutter (Current) | Improvement |
|--------|-----------------|-------------------|-------------|
| API Protocol | SOAP (ksoap2) + REST (Volley/Retrofit) | REST only (Dio) | Cleaner — server already has REST endpoints |
| Auth | Static field `LoginActivity.authToken` passed inline everywhere | JWT Bearer header via Dio interceptor | Centralized, more secure |
| Config Storage | 39 static fields on `LoginActivity` (lost on process death) | SharedPreferences + SecureStorage | Persistent across restarts |
| Encryption | Triple hex encoding (same scheme) | Same scheme via `PayloadEncryption` | Matching ✓ |
| State Management | None (static fields + AsyncTask) | Riverpod 3.x Notifier pattern | Reactive, testable |
| Navigation | Fragment transactions | GoRouter with auth redirect | Deep linking support |

---

## Current State: What Works vs What's Missing

### ✅ Working in Flutter
- Login / Logout flow with JWT
- Payload encryption/decryption matching server scheme
- Bearer token injection via Dio interceptor
- 60 API endpoint constants defined (matching api_test.html)
- Basic CRUD screens for all modules (customers, payments, complaints, STB, packages, reports, employees)
- Persistent auth with SecureStorage
- GoRouter with auth redirect

### ❌ Missing / Broken
1. **Dashboard shows zeros** — `late final` bug (FIXED in this session)
2. **39 login config values not parsed** — Feature flags, billing config, validation rules all ignored
3. **No access control call** — `/getaccesscontrollRest` never called (Android has it too, but commented out — defaults to all-enabled)
4. **Wallet card shows `outStandingAmount`** — Android shows `deposit_amount` from login, then refreshes via `lco_deposit_amountRest`
5. **No expired services count** — Android has date-wise expiry dialog
6. **`CURRENCY_CODE` hardcoded as `₹`** — Should come from login response
7. **Customer filter list uses placeholder data** — Not connected to API
8. **No config-driven UI visibility** — Quick actions, menu items, form fields should show/hide based on config flags

---

## Integration Plan: Step-by-Step

### Phase 1: Fix Core Data Flow (Priority: CRITICAL)

#### Step 1.1: Parse & Store All Login Config Values
**Why:** Every subsequent feature depends on these config flags.

**What to do:**
- Add a `LoginConfig` model class with all 39 fields
- Parse from login response in `AuthNotifier.login()`
- Store in `AuthLocalDatasource` (individual prefs for frequently-accessed ones, JSON blob for the rest)
- Add getters to `AuthLocalDatasource`

**Config fields to add (grouped by usage):**

```
// Feature toggles
useCRF, useCAF, useLastName, useDiscount, useDataFromMasterTable,
useMandatoryForHotel, useAccountNumber

// Billing
lco_billtype, customer_billtype, useLcoDeposit, is_direct_lco

// STB/Service
stb_pairing, stb_unpairing, recurringServiceEdit, show_service_extension

// UI control
freezecustomerparamsinapp, blockpayment, show_serial_vc, appMenuFormat

// Payment config
AUTO_RECEIPT_NUMBER, allow_top_up, enable_box_wise_payment,
invoicepaymentsearchlimit

// Display
CURRENCY_CODE, show_mia_agreement_upload, accept_terms_condtions,
agreement_details_count, show_caf_mobile_validation, edit_quantity

// Defaults
defaultCountry, defaultState, defaultDistrict, defaultCity

// LCO info
deposit_amount, lcoLocation, lcoMobileNo

// Validation
config_values_array → min_mobile_length, max_mobile_length,
pincode_length, country_code
```

**Files to modify:**
- `lib/core/constants/app_constants.dart` — add pref keys
- `lib/data/datasources/local/auth_local_datasource.dart` — add save/get methods
- `lib/application/providers/auth_provider.dart` — extract fields in `login()`

#### Step 1.2: Fix Dashboard Data Loading
**Why:** Stats show zeros.

**What's already fixed:** `late final` → `late` in all 9 Notifier classes, error display added.

**Still needed:**
- Pass `use_lco_deposits` and `lco_billtype` from stored config to `getDashboardDetails()`
- Wallet card should show `deposit_amount` from login initially, then refresh via `lco_deposit_amountRest`
- Add pull-to-refresh on home screen

**Android behavior reference:**
- Dashboard stats are loaded when user clicks refresh button (NOT auto-loaded)
- LCO deposit auto-loads on dashboard open for RESELLER/EMPLOYEE where `is_direct_lco == 0`
- Wallet visibility depends on `userType` and `is_direct_lco`

**Flutter improvement:** Auto-load dashboard on home screen (better UX than requiring manual refresh).

#### Step 1.3: Connect Customer Filter List to Real API
**Why:** Currently shows hardcoded placeholder data.

**API calls needed:**
- `/getCustomerDetailsCountRest` — get counts per filter
- `/getCustomerDetailsRest` — get paginated customer list

**What the Android does:**
- Dashboard shows total/active/inactive counts from `dashBoardDetailsRest`
- Customer search is a separate screen, not on dashboard
- No customer list on dashboard itself

**Flutter improvement:** Keep the filter list on dashboard (better UX), but connect to real API with pagination.

---

### Phase 2: Config-Driven UI (Priority: HIGH)

#### Step 2.1: Quick Actions Visibility
Based on login config flags, show/hide quick actions:

| Action | Show when |
|--------|----------|
| Recharge | `blockpayment == 0` |
| Deactivate | `stb_pairing == 1` OR `stb_unpairing == 1` |
| Upgrade | `show_service_extension == "1"` |
| Extend | `show_service_extension == "1"` |
| Pair STB | `stb_pairing == 1` |
| Assign | Always (complaint operations) |

#### Step 2.2: Drawer Menu Visibility
Same config-driven approach:

| Menu Item | Show when |
|-----------|----------|
| Make Payment | `blockpayment == 0` |
| STB Operations | `stb_pairing == 1` OR `stb_unpairing == 1` |
| Package Operations | Always |
| Complaints | Always (Android's `access_for_complaints` defaults to 1) |
| Employees | `userType == "RESELLER"` or admin types |

#### Step 2.3: Currency Code from Server
Replace hardcoded `₹` with server-provided `CURRENCY_CODE`.

---

### Phase 3: Complete API Integration (Priority: MEDIUM)

#### Step 3.1: Fix Known API Issues (from API_SUMMARY.md)
These response key mismatches need fixing in remote datasources:

| Issue | Current (Wrong) | Correct | File |
|-------|-----------------|---------|------|
| Complaint categories | `complaintCategoryList` | `complaintCategories` | complaint_remote_datasource.dart |
| Complaint statuses | `complaintTypesList` | `complaintStatuses` | complaint_remote_datasource.dart |
| Districts key | `districtsList` | `districtList` | customer form code |
| Customer types | `customerTypesList` | `customerTypeList` | customer form code |
| States param | `countryId` | `countryCode` | master data calls |
| Cities param | needs `stateId` + `districtId` | only sends `districtId` | master data calls |

#### Step 3.2: Implement Missing API Calls

| Endpoint | Status | Notes |
|----------|--------|-------|
| `/validateLogin` | ✅ Working | |
| `/getaccesscontrollRest` | ❌ Not called | Call after login, store flags |
| `/dashBoardDetailsRest` | ✅ Working (after fix) | Pass config params |
| `/lco_deposit_amountRest` | ⚠️ Defined but not used on dashboard | Connect to wallet card |
| `/getlcowalletRest` | ⚠️ Defined, used in provider but not called from UI | |
| `/getdashboardlist` | ❌ Not used | STB assignment list |
| `/getExpiryServicesDateWiseCount` | ❌ Not used | Add expired services dialog |
| `/getCustomerDetailsCountRest` | ✅ Used in customer search | |
| `/getCustomerDetailsRest` | ✅ Used in customer search | |
| `/existingCustomerRest` | ✅ Defined | Check before new customer |
| `/saveCustomerRest` | ✅ Defined | |
| `/editCustomerRest` | ✅ Defined | |
| `/updateCustomerLocation` | ❌ Not used | Add GPS tracking |
| `/getPendingAmountRest` | ✅ Used | |
| `/makePaymentsRest` | ✅ Used | |
| `/getPaymentModesRest` | ✅ Used | |
| `/getReceiptRanges` | ⚠️ Defined but check usage | Auto receipt number |
| `/getbilldetailsRest` | ⚠️ Defined | |
| `/PaymentServiceRest` | ✅ Payment history | |
| `/getComplaintList` | ✅ Used | |
| `/complaintCategoriesRest` | ✅ Used (fix key) | |
| `/getComplaintsubCategory` | ✅ Defined | |
| `/complaintTypesRest` | ✅ Used (fix key) | |
| `/createComplaintRest` | ✅ Used | |
| `/closeComplaintRest` | ✅ Defined | |
| `/getCustomerBoxDetailsRest` | ✅ Used | |
| `/deactivateBoxRest` | ✅ Used | |
| `/reactivateBoxRest` | ✅ Used | |
| `/getDeactiveReasonsRest` | ✅ Used | |
| `/temporaryActivationRest` | ✅ Defined | |
| `/stbPairRest` | ✅ Defined | |
| `/stbUnpairRest` | ✅ Defined | |
| `/stb_replacement` | ⚠️ Defined | |
| `/getCustomerPackages_splitRest` | ✅ Used | |
| `/getUnassignedPackages_splitRest` | ✅ Used | |
| `/activateServiceRest` | ✅ Used | |
| `/deactivateServiceRest` | ✅ Used | |
| `/extendCustomerServices` | ✅ Defined | |
| `/DailyreportRest` | ✅ Used | |
| `/empCollectionRest` | ✅ Used | |
| `/empCustomerCollectionDetailsRest` | ✅ Defined | |
| `/InvoiceServiceRest` | ✅ Defined | |
| `/getLcoEmployeeList` | ✅ Used | |
| `/getServiceEmployeeList` | ✅ Defined | |
| Master data (countries/states/districts/cities/mandals/groups/types) | ✅ All defined | Fix param names |

---

### Phase 4: UX Improvements Over Android (Priority: MEDIUM)

#### 4.1: Dashboard Auto-Load
**Android:** User must click refresh to load stats.
**Flutter:** Auto-load on home screen with pull-to-refresh. ✅ Already doing this.

#### 4.2: Customer Cards on Dashboard
**Android:** No customer preview on dashboard — requires navigating to search.
**Flutter:** Keep the customer filter list on dashboard for quick access. Just connect to real API.

#### 4.3: Better Error Handling
**Android:** `Toast.makeText()` for errors, often swallowed.
**Flutter:** Show SnackBars with retry actions, error states in widgets with retry buttons.

#### 4.4: Offline Resilience
**Android:** No offline support, crashes on network failure.
**Flutter:** Add connection state awareness, cache last dashboard data, show stale-while-revalidate.

#### 4.5: Form Validation Using Server Config
**Android:** Uses `config_values_array` for mobile length, pincode length.
**Flutter:** Use same config for form validators:
- Mobile: `min_mobile_length` to `max_mobile_length` digits
- Pincode: exactly `pincode_length` digits
- Country code prefix: `country_code`

#### 4.6: Receipt Number Handling
**Android:** `AUTO_RECEIPT_NUMBER == 1` means auto-generate, else show receipt input field.
**Flutter:** Same logic in payment form.

---

### Phase 5: Security & Robustness (Priority: LOW but important)

#### 5.1: Remove Debug Prints Before Production
All `debugPrint` statements in interceptors and providers are guarded by `kDebugMode` or will be stripped in release. Verify this.

#### 5.2: Token Refresh / Expiry Handling
**Current:** JWT has `exp` claim (set to ~90 days from login response). No refresh mechanism.
**Improvement:** Check JWT expiry before API calls, force re-login if expired.

#### 5.3: Certificate Pinning
**Current:** Neither Android nor Flutter implements cert pinning.
**Improvement:** Add for production (low priority since server uses HTTP not HTTPS currently).

#### 5.4: Sensitive Data in SharedPreferences
**Current:** User profile data (name, email, phone) in unencrypted SharedPreferences. Tokens in SecureStorage.
**Assessment:** Acceptable — same pattern as Android. Profile data is not highly sensitive.

---

## Phase 5.5: Dashboard Customer List (IMPLEMENTED)

### What Was Built
The customer filter tabs on the home screen now connect to real API data:

**API Used:** `/getdashboardlist` with `from_dashboard` parameter
- `from_dashboard=4` → Active customers/STBs
- `from_dashboard=5` → Inactive (deactivated) customers/STBs
- No list endpoint exists for Unpaid/Fresh (count only from dashboard)

**Server Response Fields Per Customer:**
`serial_number`, `vc_number`, `customer_name`, `account_number`, `mobile_no`, `customer_id`, `is_active`, `service_enddate`, `installation_address`, `cas`, `mac_address`, `box_number`

**Architecture:**
- `DashboardCustomerListProvider` (`dashboard_customer_list_provider.dart`) — manages tab selection, API calls, client-side pagination
- Server returns ALL customers for a tab at once (no server-side pagination)
- Client-side lazy loading: shows 20 at a time with "Load More" button (handles 1K-5K customers efficiently)
- Tab counts come from `dashboardProvider` (dashBoardDetailsRest response)

**Customer Card Shows:**
- Customer name + Active/Inactive badge
- STB number + VC number
- Account number (if available)
- Service end date
- Action buttons: Recharge, Deactivate/Reactivate (context-aware), Call (if mobile available)
- Tap card → navigates to customer profile

**Tab Behavior:**
| Tab | Data Source | Behavior |
|-----|-----------|----------|
| Active | `/getdashboardlist?from_dashboard=4` | Full customer list with cards |
| Inactive | `/getdashboardlist?from_dashboard=5` | Full customer list with cards |
| Unpaid | Count from dashboard only | Shows count + "Search to find them" link |
| Fresh | Count from dashboard only | Shows count + "Search to find them" link |

**Pagination Strategy (Android vs Flutter):**
| Aspect | Android | Flutter |
|--------|---------|---------|
| Page size | 100 (server-side) | 20 (client-side lazy load) |
| Mechanism | Numbered page buttons + server calls per page | "Load More" button, all data loaded once |
| UX | Click page 1, 2, 3... | Smooth scroll + load more |
| Performance | Multiple API calls | Single API call, client slicing |

**Note:** For LCOs with 5K+ active customers, the single API call approach may be slow. Consider adding server-side pagination to `/getdashboardlist` in the future (add `startValue`/`endValue` support).

---

## Implementation Order (Recommended)

| Order | Task | Effort | Impact |
|-------|------|--------|--------|
| 1 | ~~Fix `late final` in all Notifiers~~ | ✅ DONE | Dashboard loads |
| 2 | ~~Add error display to dashboard stats~~ | ✅ DONE | Visible failures |
| 3 | Parse & store login config values | Medium | Unblocks all config-driven features |
| 4 | Pass config to dashboard API call | Small | Correct dashboard data |
| 5 | Fix wallet card (use deposit_amount + lco_deposit API) | Small | Correct wallet display |
| 6 | Fix API response key mismatches (6 issues) | Small | Fix complaints, customer forms |
| 7 | Connect customer filter list to real API | Medium | Real data on dashboard |
| 8 | Config-driven quick actions visibility | Small | Correct feature access |
| 9 | Config-driven drawer menu visibility | Small | Correct navigation |
| 10 | Add expired services count dialog | Medium | Feature parity |
| 11 | Form validation from config_values_array | Small | Correct validation |
| 12 | Server-driven CURRENCY_CODE | Trivial | Correct currency display |
| 13 | Pull-to-refresh on dashboard | Small | Better UX |
| 14 | Offline awareness / stale cache | Medium | Robustness |

---

## Android Code Reference Map

For each Flutter module, the corresponding Android source files:

| Flutter Module | Android Files |
|---------------|---------------|
| Login | `LoginActivity.java`, `ValidateLoginInfo.java`, `LoginResponse.java` |
| Dashboard | `Dashboard_Fragment.java`, `dashBoard.java`, `Getlcodeposit.java` |
| Customer Search | `SearchCustomer_Fragment.java` |
| Customer Profile | `CustomerSummary_Fragment.java` |
| New Customer | `STB_Check_Fragment_Old.java`, `CustomerInformation_Fragment.java` |
| Payments | `MakePayments_Fragment.java`, `BulkPayments_Fragment.java` |
| Complaints | `ComplaintManagement_Fragment.java`, `OpenComplaints_frag.java` |
| STB Operations | `BoxMgmt_Fragment.java` |
| Package Operations | `PackageMgmt_Fragment.java` |
| Reports | `DailyReportFragment.java`, `CollectionReportFragment.java` |
| Employees | `EmployeeList_Fragment.java` |

All Android files are in: `D:\ITP2026\android\ezybill\app\src\main\java\com\itp\ezybill\androidapp\activities_fragments\`

---

## Key Differences: Android SOAP vs Flutter REST

The Flutter app uses the **REST versions** of all endpoints (suffix `Rest` or no suffix for newer endpoints). This is correct — the server provides both SOAP and REST interfaces. The REST endpoints:
- Accept `application/x-www-form-urlencoded` POST
- Use `Authorization: Bearer <JWT>` instead of inline `authToken` param
- Return JSON (encrypted with single-hex `hash` field)
- Extract `dealer_id` and `employee_id` from JWT claims server-side

This means the Flutter app does NOT need to send `dealer_id` or `employee_id` as explicit params for most endpoints (unlike the Android SOAP calls which required them). The server's REST controller does:
```php
$this->dealerId = $this->jwt_helper->getDealerIdFromJwt($authtoken);
```

**Exception:** Some REST endpoints still require explicit `dealer_id`:
- `/getlcowalletRest` — needs `dealer_id`
- `/getExpiryServicesDateWiseCount` — needs `dealer_id`
- `/getdashboardlist` — needs `dealer_id` and `from_dashboard`
- `/getComplaintList` — needs params per api_test.html
