# EzyBill Flutter Migration Gap Analysis: Auth, Dashboard & Navigation

> **Spec document:** `01_auth_dashboard_navigation.md`
> **Analysis date:** 2026-03-26
> **Comparing:** Flutter implementation vs Android migration spec

---

## Table of Contents

1. [API Endpoints](#1-api-endpoints)
2. [Models](#2-models)
3. [Config Flags (Login Response)](#3-config-flags-login-response)
4. [Access Control Flags](#4-access-control-flags)
5. [Login Screen UI](#5-login-screen-ui)
6. [Navigation Drawer](#6-navigation-drawer)
7. [Dashboard Screen](#7-dashboard-screen)
8. [Navigation & Routing](#8-navigation--routing)
9. [Session Management](#9-session-management)
10. [Status Code Handling](#10-status-code-handling)
11. [Base URL Configuration](#11-base-url-configuration)
12. [Missing Screens](#12-missing-screens)
13. [Theming System](#13-theming-system)
14. [Permissions](#14-permissions)
15. [Miscellaneous](#15-miscellaneous)

---

## 1. API Endpoints

### 1.1 validateLogin — `POST /LcoRestServices/validateLogin`

**Status:** IMPLEMENTED in `auth_remote_datasource.dart`

| Aspect | Spec Requirement | Flutter Implementation | Gap? |
|--------|-----------------|----------------------|------|
| Endpoint path | `/validateLogin` | `ApiConstants.validateLogin = '/validateLogin'` | OK |
| Base URL path | `/LcoRestServices/` | `restBase` = `baseUrl + '/LcoRestServices'` | OK |
| `UserName` param | Required | Sent | OK |
| `PassWord` param | Required | Sent | OK |
| `mobile_no` param | Optional | Sent conditionally | OK |
| `imei` param | Optional | Sent conditionally | OK |
| Comment in code | Says `/customerRestservices/validateLogin` | Should say `/LcoRestServices/validateLogin` | **LOW** — comment is wrong but code uses correct base via `restBase` |

### 1.2 getaccesscontrollRest — `POST /LcoRestServices/getaccesscontrollRest`

**Status:** IMPLEMENTED in `auth_remote_datasource.dart`

| Aspect | Spec Requirement | Flutter Implementation | Gap? |
|--------|-----------------|----------------------|------|
| Endpoint path | `/getaccesscontrollRest` | `ApiConstants.getAccessControl` | OK |
| `authtoken` param | Spec says `authtoken` (lowercase 't') | Code sends `authToken` (camelCase) | **HIGH** — parameter name mismatch may cause server rejection |
| `dealer_id` param | String | Sent as `int` | **MEDIUM** — server may expect String; should send `dealer_id.toString()` |
| `userstype` param | Required | Sent | OK |
| `employeeParentType` param | Required | Sent | OK |
| `employeeParentId` param | Required | Sent | OK |

**CRITICAL GAP:** The `getAccessControl()` method is defined but **NEVER CALLED** in the login flow. The `AuthNotifier.login()` method only calls `validateLogin` and then stores data. It never calls `getaccesscontrollRest`. The spec requires this call immediately after login success.

- **Priority:** **HIGH**
- **Action Required:** Add `getAccessControl()` call in `AuthNotifier.login()` after successful `validateLogin`, parse and store access control flags.

### 1.3 dashBoardDetailsRest — `POST /LcoRestServices/dashBoardDetailsRest`

**Status:** IMPLEMENTED in `dashboard_remote_datasource.dart`

| Aspect | Spec Requirement | Flutter Implementation | Gap? |
|--------|-----------------|----------------------|------|
| `use_lco_deposits` param | `LoginActivity.userLcoDeposit` (as String) | Passed optionally | **MEDIUM** — not being sent from `DashboardNotifier.loadDashboard()`, called with no args |
| `lco_billtype` param | `LoginActivity.lco_billtype` (as String) | Passed optionally | **MEDIUM** — not being sent from `DashboardNotifier.loadDashboard()` |

**Action Required:** `loadDashboard()` should read `useLcoDeposit` and `lco_billtype` from session state and pass them to `getDashboardDetails()`.

### 1.4 lco_deposit_amountRest — `POST /LcoRestServices/lco_deposit_amountRest`

**Status:** IMPLEMENTED in `dashboard_remote_datasource.dart`

| Aspect | Spec Requirement | Flutter Implementation | Gap? |
|--------|-----------------|----------------------|------|
| Trigger condition | Auto-load when `userType == "RESELLER" && is_direct_lco == 0` or `userType == "EMPLOYEE" && is_direct_lco == 0` | Not conditionally called from HomeScreen | **MEDIUM** |

**Action Required:** HomeScreen should conditionally call `getLcoDepositAmount()` based on `userType` and `is_direct_lco` flags.

### 1.5 getExpiryServicesDateWiseCount

**Status:** IMPLEMENTED (endpoint defined, datasource method exists)

| Aspect | Spec Requirement | Flutter Implementation | Gap? |
|--------|-----------------|----------------------|------|
| Trigger | `tv_expiredserviceslist` tap → popup dialog | No UI trigger exists on dashboard | **MEDIUM** |
| `authtoken` param | Required in POST body | Not sent — method only sends `dealer_id` | **HIGH** |

**Action Required:** Add `authtoken` to request params. Add "Expired Services" link to dashboard UI that triggers this call and shows a dialog.

### 1.6 Missing Endpoints

| Endpoint | Spec Section | Priority | Notes |
|----------|-------------|----------|-------|
| `POST /employeeRestServices/lcoPayment` | Section 7.4 — StatusActivity | **LOW** | LCO payment status screen — can be deferred |

---

## 2. Models

### 2.1 Model Classes — MISSING

**Status:** No model directory exists at `lib/data/models/auth/` or `lib/data/models/dashboard/`. No `lib/data/models/` directory at all.

The entire codebase uses raw `Map<String, dynamic>` instead of typed model classes.

| Missing Model | Fields Required (from spec) | Priority |
|---------------|---------------------------|----------|
| `LoginResponse` | All 38+ fields from spec section 3.6 | **HIGH** |
| `AccessControlResponse` | `int_bulk_payment`, `invoice_page_access`, `payment_hist_page_access`, `access_for_complaints`, `int_stb_activation`, `int_stb_deactivation`, `int_stb_reactivation`, `pgtransaction` | **HIGH** |
| `DashboardResponse` | `totalStbs`, `totalAssignedStbs`, `totalUnAssignedStbs`, `totalComplaints`, `totalActiveCustomers`, `totalDeactiveCustomers`, `totalCurrentMonthBill`, `totalPaidCustomers`, `totalUnPaidCustomers`, `totalDueAmount`, `outStandingAmount`, `msoShare`, `totalCurrentMonthMsoShare`, `currentMonthOutstanding`, `currentMonthLCOBill`, `lcocurrentmonthdueamount`, `lov_emp_grp_customers`, `gettotalPaidCustomers`, `gettotalUnPaidCustomers` | **MEDIUM** |
| `LcoWalletResponse` | `lco_deposit_amount`, `customerCount` | **LOW** |
| `ExpiryServicesResponse` | `status_code`, `status_msg`, `getExpiryServicesList` (array of `{date, stb_count}`) | **MEDIUM** |

**Action Required:** Create typed Dart model classes with `fromJson()` factories for all API responses. This improves type safety and makes missing field detection compile-time.

---

## 3. Config Flags (Login Response)

### 3.1 Fields Stored After Login

The spec documents **38+ fields** from the `validateLogin` response that must be stored as global session state. The Flutter app currently stores only **11 fields**.

#### Currently Stored (11 fields):

| Field | Storage Key | Status |
|-------|-------------|--------|
| `dealerId` | `dealer_id` | OK |
| `employeeId` | `employee_id` | OK |
| `userType` | `user_type` | OK |
| `first_name` | `first_name` | OK |
| `last_name` | `last_name` | OK |
| `email` | `email` | OK |
| `phone` | `phone` | OK |
| `lcoCode` | `lco_code` | OK |
| `business_name` | `business_name` | OK |
| `employeeParentType` | `employee_parent_type` | OK |
| `employeeParentId` | `employee_parent_id` | OK |

#### MISSING Fields (27+ fields) — **HIGH PRIORITY**:

| Spec Field | Static Variable Equivalent | Type | Purpose | Priority |
|------------|---------------------------|------|---------|----------|
| `useCRF` | CRF form toggle | int | Controls CRF/CAF form display | **MEDIUM** |
| `useCAF` | CAF usage flag | String | Controls CAF form display | **MEDIUM** |
| `deposit_amount` | LCO wallet initial balance | double | Dashboard wallet display | **MEDIUM** |
| `useLastName` | Show/hide last name field | int | Customer form UI | **HIGH** |
| `useDiscount` | Show/hide discount field | int | Payment UI | **MEDIUM** |
| `useDataFromMasterTable` | Data source toggle | int | Data fetching logic | **MEDIUM** |
| `useMandatoryForHotel` | Hotel mandatory fields | int | Customer form validation | **MEDIUM** |
| `useAccountNumber` | Show/hide account number | int | Customer form UI | **HIGH** |
| `lco_billtype` | LCO billing type | int | Dashboard API param | **HIGH** |
| `customer_billtype` | Customer billing type | int | Billing logic | **MEDIUM** |
| `lcoMobileNo` | LCO mobile contact | int | Display | **LOW** |
| `is_direct_lco` | Direct LCO flag | int | Controls wallet visibility, LCO top-up | **HIGH** |
| `AUTO_RECEIPT_NUMBER` | Auto-generate receipt | int | Payment flow | **MEDIUM** |
| `allow_top_up` | LCO top-up enabled | int | Toolbar menu visibility | **MEDIUM** |
| `show_caf_mobile_validation` | OTP validation on CAF | int | Customer creation flow | **MEDIUM** |
| `CURRENCY_CODE` | Currency symbol | String | All monetary displays (currently hardcoded as "₹") | **HIGH** |
| `patch_information` | Feature version string | String | Controls LCO wallet history visibility | **MEDIUM** |
| `stb_pairing` | STB pairing flag | int | Menu visibility | **MEDIUM** |
| `stb_unpairing` | STB unpairing flag | int | Menu visibility | **MEDIUM** |
| `recurringServiceEdit` | Recurring service edit | int | Service edit UI | **LOW** |
| `appMenuFormat` / `menuType` | Nav drawer variant | String | Controls drawer items array | **HIGH** |
| `useLcoDeposit` | LCO deposit flag | int | Dashboard API param | **HIGH** |
| `defaultCountry` | Default country | String | Customer form pre-fill | **MEDIUM** |
| `defaultState` | Default state | int | Customer form pre-fill | **MEDIUM** |
| `defaultDistrict` | Default district | int | Customer form pre-fill | **MEDIUM** |
| `defaultCity` | Default city | int | Customer form pre-fill | **MEDIUM** |
| `freezecustomerparamsinapp` | Lock customer edit fields | int | Customer form behavior | **HIGH** |
| `blockpayment` / `hidemakepayment` | Hide Make Payment | int | Quick action / menu visibility | **HIGH** |
| `show_mia_agreement_upload` | MIA upload feature | int | MIA feature gate | **LOW** |
| `accept_terms_condtions` | Terms accepted | int | Terms flow | **LOW** |
| `agreement_details_count` | MIA doc count | int | MIA feature | **LOW** |
| `access_distributor_wise` | Distributor access | int | Access control | **MEDIUM** |
| `username` / `login_username` | Display username | String | Nav drawer header | **MEDIUM** |
| `logo_img` | Logo URL | String | Toolbar/drawer logo | **LOW** |
| `APP_THEME` | Theme variant (1-5) | int | App theming | **LOW** |
| `APP_DASHBOARD` | Dashboard layout variant | int | Dashboard UI | **LOW** |
| `ENABLE_AADHAAR` | Aadhaar toggle | int | Feature gate | **LOW** |
| `LCO_PAYMENT` | LCO payment menu | int | Menu visibility | **MEDIUM** |

**Action Required:**
1. Expand `AuthLocalDatasource.saveUserData()` to persist all 38+ fields.
2. Add corresponding getter properties for each field.
3. Add corresponding `AppConstants.prefKey*` constants.
4. Parse all fields from login response in `AuthNotifier.login()`.

---

## 4. Access Control Flags

### 4.1 getaccesscontrollRest Response — NOT PROCESSED

**Status:** The endpoint method exists but is **never called** after login. None of the 8 access control flags are stored or used.

| Flag | Spec Default | Purpose | Currently Used? | Priority |
|------|-------------|---------|-----------------|----------|
| `int_bulk_payment` | 1 | Show Payments menu + Quick Pay button | **NO** | **HIGH** |
| `invoice_page_access` | 1 | Invoice page visibility | **NO** | **MEDIUM** |
| `payment_hist_page_access` | 1 | Payment history visibility | **NO** | **MEDIUM** |
| `access_for_complaints` | 1 | Show Complaints menu item | **NO** | **HIGH** |
| `int_stb_activation` | 1 | Box operations / activation | **NO** | **HIGH** |
| `int_stb_deactivation` | 1 | Box operations / deactivation | **NO** | **HIGH** |
| `int_stb_reactivation` | 1 | Box operations / reactivation | **NO** | **HIGH** |
| `int_payment_transaction_report_access` / `pgtransaction` | 0 | PG transaction report | **NO** | **LOW** |

**Action Required:**
1. Call `getAccessControl()` in `AuthNotifier.login()` after `validateLogin` succeeds.
2. Store all 8 flags in local session (SharedPreferences or Riverpod state).
3. Use flags to conditionally show/hide drawer items, quick actions, and route guards.

### 4.2 Inverted Status Code Handling

**Spec note (section 3.6):** The `getaccesscontrollRest` endpoint uses **inverted** status codes: `status_code == 0` means **success**, `status_code == 1` means **failure**. The current `getAccessControl()` method in `auth_remote_datasource.dart` returns raw `Map<String, dynamic>` with **no status code validation at all**.

- **Priority:** **HIGH**
- **Action Required:** Add status code parsing: treat `status_code == 0` (or missing status_code) as success, `status_code == 1` as error. The spec also notes: "on failure: startActivity(ApplicationIntroActivity) [still proceeds]" — so failure should be non-blocking but logged.

---

## 5. Login Screen UI

### 5.1 Implemented vs Required Elements

| Spec Element | Required | Flutter Implementation | Gap? |
|-------------|----------|----------------------|------|
| Logo image (from server URL) | `LOGIN_URL + APP_LOGO_PATH` with `ic_launcher` fallback | Hardcoded `LucideIcons.tv` icon placeholder | **MEDIUM** — No dynamic logo loading |
| "Login" label | TextView | "Welcome Back" text instead | **LOW** — cosmetic |
| Username field | Pre-fill from SharedPrefs if Remember Me | No pre-fill, no Remember Me | **MEDIUM** |
| Password field | Secure text entry | Implemented | OK |
| Remember Me checkbox | Saves username to SharedPrefs | **MISSING** | **MEDIUM** |
| Login button | "LOGIN" | "Sign In" | **LOW** — cosmetic |
| Copyright text | "itpworld.com, All Rights Reserved" | **MISSING** | **LOW** |
| Version display | Dynamic | Hardcoded `v1.0.0` | **LOW** |
| Empty fields validation | AlertDialog "Empty Fields!" | Form validator with inline error | OK (different UX, acceptable) |
| Network check | AlertDialog "No internet connection!" with Settings button | **MISSING** — no connectivity check | **HIGH** |
| Login failed error | AlertDialog | SnackBar | OK (different UX, acceptable) |
| Server error handling | AlertDialog "Server connectivity error!" | Generic error display | **MEDIUM** |

### 5.2 Missing Login Screen Features

| Feature | Spec Reference | Priority |
|---------|---------------|----------|
| Remember Me checkbox | Section 3.2 | **MEDIUM** |
| Network connectivity check before API call | Section 3.3 | **HIGH** |
| Dynamic logo from `APP_LOGO_PATH` | Section 3.8 | **MEDIUM** |
| IMEI/device ID sent with login | Section 3.4 — `imei` param | **MEDIUM** |
| Custom font (`gothic_0.TTF`) | Section 3.1 | **LOW** — using DM Sans instead |

---

## 6. Navigation Drawer

### 6.1 Drawer Header

| Spec Element | Required | Flutter Implementation | Gap? |
|-------------|----------|----------------------|------|
| Header image (dealer logo) | `LoginActivity.logo_img` | User initials avatar | **MEDIUM** |
| Username | `LoginActivity.login_username` | `authLocal.employeeName` | OK (different source field) |
| Email | `LoginActivity.login_email` (show "NA" if `"anyType{}"`) | **MISSING** — shows LCO code instead | **MEDIUM** |
| Email "anyType{}" handling | Display "NA" for `"anyType{}"` values | **MISSING** | **LOW** |

### 6.2 Drawer Menu Items — Static vs Dynamic

**CRITICAL GAP:** The Flutter drawer has a **hardcoded static menu** with no conditional visibility. The spec requires **dynamic menu construction** based on:
- `isDistributor` flag (userType/employeeParentType)
- `menuType` ("DEFAULT" vs other)
- Access control flags from `getaccesscontrollRest`

**Current Flutter drawer items (all always visible):**

| Item | Route | Spec Visibility Condition | Currently Conditional? |
|------|-------|--------------------------|----------------------|
| Dashboard | `/` | Always | OK |
| Customers | `/customers` | Always (Search Customer) | OK |
| Make Payment | `/make-payment` | `int_bulk_payment == 1` | **NO** — always shown |
| Complaints | `/complaints` | `access_for_complaints == 1` (non-distributor only) | **NO** — always shown |
| STB Operations | `/stb-operations` | `int_stb_activation==1 OR int_stb_deactivation==1 OR int_stb_reactivation==1` | **NO** — always shown |
| Package Operations | `/package-operations` | `int_stb_activation==1 OR int_stb_deactivation==1` | **NO** — always shown |
| Reports | `/reports` | Always (non-distributor only) | OK (but should be hidden for distributors) |
| Employees | `/employees` | **NOT IN SPEC** | Extra item |
| Settings | `/settings` | **NOT IN SPEC** as drawer item | Extra item |

**Missing drawer items from spec:**

| Spec Item | Condition | Priority |
|-----------|-----------|----------|
| New Customer | Always visible | **HIGH** |
| LCO Payment | `LCO_PAYMENT == 1` | **MEDIUM** |
| Pair/Unpair | `stb_pairing == 1 OR stb_unpairing == 1` (non-distributor) | **MEDIUM** |
| Privacy Policy | Overflow menu (not drawer) | **LOW** |
| About Us | Overflow menu (not drawer) | **LOW** |
| LCO Top-Up | Overflow menu, conditional on `userType == "RESELLER" && allow_top_up == 1 && is_direct_lco == 0` | **LOW** |
| LCO Payment History | Overflow menu, conditional on RESELLER + `patch_information` check | **LOW** |

### 6.3 Distributor vs Non-Distributor Menu

**MISSING:** No logic to detect distributor users and switch menu structure.

```
isDistributor = (userType in {DISTRIBUTOR, SUBDISTRIBUTOR})
             OR (employeeParentType in {DISTRIBUTOR, SUBDISTRIBUTOR})
```

- **Priority:** **HIGH**
- **Action Required:** Implement `isDistributor` flag check. Build separate menu arrays per spec sections 5.4.1 and 5.4.2.

---

## 7. Dashboard Screen

### 7.1 Stat Cards

| Spec Stat Card | API Field | Flutter Implementation | Gap? |
|----------------|-----------|----------------------|------|
| Total STBs | `totalStbs` | **MISSING** from stat pills | **HIGH** |
| Assigned STBs | `totalAssignedStbs` | **MISSING** from stat pills | **HIGH** |
| Unassigned STBs | `totalUnAssignedStbs` | **MISSING** from stat pills | **HIGH** |
| Total Complaints | `totalComplaints` | **MISSING** from stat pills | **MEDIUM** |
| Active Customers | `totalActiveCustomers` | Shown as "Active" pill | OK |
| Deactive Customers | `totalDeactiveCustomers` | Shown as "Inactive" pill | OK |
| Total (computed) | active + inactive | Shown as "Total" pill | OK |
| Unpaid Customers | `totalUnPaidCustomers` | Shown as "Unpaid" pill | OK (spec says UI was commented out in Android, but Flutter shows it) |

**The Flutter stat pills show 4 items (Total, Active, Inactive, Unpaid) but are MISSING the spec's primary stat cards: Total STBs, Assigned STBs, Unassigned STBs, and Total Complaints.**

- **Priority:** **HIGH**
- **Action Required:** Add stat cards for STB counts and complaints as documented in spec section 6.2 Section B.

### 7.2 LCO Wallet Section

| Spec Requirement | Flutter Implementation | Gap? |
|-----------------|----------------------|------|
| Visibility: Hidden for DEALER, ADMIN, SERVICE, DISTRIBUTOR, SUBDISTRIBUTOR | Always visible | **HIGH** |
| Visibility: Shown for RESELLER/EMPLOYEE when `is_direct_lco == 0` | No condition check | **HIGH** |
| Balance from `lco_deposit_amountRest` | Shows `outStandingAmount` from dashboard API | **MEDIUM** — wrong data source |
| Refresh button triggers `lco_deposit_amountRest` | Triggers `loadDashboard()` | **MEDIUM** |
| Open payment history link | Not implemented | **MEDIUM** |
| Conditional visibility of payment history based on `patch_information` | Not implemented | **MEDIUM** |

### 7.3 Quick Actions

| Spec Quick Action | Condition | Flutter Implementation | Gap? |
|-------------------|-----------|----------------------|------|
| Quick Pay | `int_bulk_payment == 1` | "Recharge" — always visible | **HIGH** — no conditional visibility |
| Search Customer | Always | Not in quick actions (in search bar instead) | **LOW** — different UX |
| New Customer | Always | **MISSING** from quick actions | **MEDIUM** |
| Package Operations | `int_stb_activation==1 OR int_stb_deactivation==1` | "Upgrade" + "Extend" — always visible | **MEDIUM** — no conditional visibility |
| Complaints | `access_for_complaints == 1` | **MISSING** from quick actions (has "Assign" linking to complaints route) | **MEDIUM** |
| STB Operations | `int_stb_activation==1 OR int_stb_deactivation==1 OR int_stb_reactivation==1` | "Deactivate" + "Pair STB" — always visible | **MEDIUM** — no conditional visibility |

**Extra Flutter quick actions not in spec:** "Deactivate", "Upgrade", "Extend", "Pair STB", "Assign" — these break down the spec's high-level actions into granular ones. Acceptable UX improvement but need conditional visibility.

### 7.4 Missing Dashboard Features

| Feature | Spec Reference | Priority |
|---------|---------------|----------|
| "All Complaints" text link | Section 6.2 Section D | **MEDIUM** |
| "Expired Services" text link (triggers popup dialog) | Section 6.2 Section D, Call 3 | **MEDIUM** |
| "Refresh" section label/button | Section 6.2 Section D | **LOW** |
| Back press → logout confirmation dialog | Section 6.4 | **MEDIUM** |
| Dashboard theme variant (`APP_DASHBOARD == 1` vs `!= 1`) | Section 6.1 | **LOW** |
| Error states: specific AlertDialogs per spec section 6.5 | Uses generic error display | **LOW** |

---

## 8. Navigation & Routing

### 8.1 Routes Defined vs Required

| Spec Screen | Required Route | Flutter Route | Status |
|-------------|---------------|---------------|--------|
| Login | `/login` | `/login` | OK |
| App Intro (first-run) | `/intro` | **MISSING** | **MEDIUM** |
| Dashboard (home) | `/` or position 0 | `/` | OK |
| Search Customer | Drawer item | `/customers` | OK |
| New Customer | Drawer item | `/customers/new` | OK (route exists but not in drawer) |
| Complaints | Conditional drawer item | `/complaints` | OK |
| Box/STB Operations | Conditional drawer item | `/stb-operations` | OK |
| Package Operations | Conditional drawer item | `/package-operations` | OK |
| Payments | Conditional drawer item | `/make-payment` | OK |
| Reports | Drawer item | `/reports` | OK |
| Pair/Unpair | Conditional drawer item | **MISSING** as separate route | **MEDIUM** |
| LCO Payment | Conditional drawer item | **MISSING** | **MEDIUM** |
| LCO Payment Status | `/lco-payment-status` | **MISSING** | **LOW** |
| About Us | Overflow menu | **MISSING** | **LOW** |
| Privacy Policy | Overflow menu | **MISSING** | **LOW** |
| LCO Top-Up | Overflow menu, conditional | **MISSING** | **LOW** |

### 8.2 App Intro / First-Run Screen

**MISSING:** No first-run intro screen. Spec requires checking `hasRunBefore_appIntro` SharedPreference.

- **Priority:** **MEDIUM**
- **Action Required:** Add intro screen with first-run detection, `hasRun_appIntro` flag persistence.

### 8.3 Bottom Navigation Bar

The Flutter app has a `BottomNavigationBar` with 4 tabs (Home, Customers, Reports, Settings) via `AppShell`. **This is NOT in the Android spec** — the Android app uses only a navigation drawer with no bottom nav. This is an acceptable Flutter UX improvement but should be noted.

---

## 9. Session Management

### 9.1 Token Storage

| Aspect | Spec Requirement | Flutter Implementation | Gap? |
|--------|-----------------|----------------------|------|
| JWT token storage | Used in all subsequent requests | `FlutterSecureStorage` | OK |
| Auth token (separate from JWT?) | Spec has `authToken` separate from `token` | Both set to same `data['token']` value | **MEDIUM** — may need distinct tokens |
| Token in request headers | `Authorization: Bearer {jwt}` | Implemented via `_AuthInterceptor` | OK |
| `authtoken` in POST body | Many endpoints require `authtoken` in form body | **NOT IMPLEMENTED** — only JWT header used | **HIGH** |

**CRITICAL:** The spec shows many endpoints (including `getaccesscontrollRest`, `dashBoardDetailsRest`, `getExpiryServicesDateWiseCount`) require `authtoken` as a POST body parameter. The Flutter `DioClient` only adds JWT to headers. Individual datasource methods for dashboard do NOT include `authtoken` in the POST body.

- **Priority:** **HIGH**
- **Action Required:** Either add `authtoken` to each POST body at the datasource level, or add it automatically via a Dio interceptor.

### 9.2 Static Field Equivalents

The Android app uses `LoginActivity` static fields for global state. Flutter uses `AuthLocalDatasource` (SharedPreferences) + `AuthState` (Riverpod).

**Gap:** Only 11 of 50+ static fields are persisted (see Section 3 above).

### 9.3 Remember Me

- **MISSING:** No Remember Me checkbox, no username persistence across sessions.
- **Priority:** **MEDIUM**

---

## 10. Status Code Handling

### 10.1 validateLogin

| Status Code | Spec Meaning | Flutter Handling | Gap? |
|-------------|-------------|-----------------|------|
| `status_code == 0` | Login failed / error | Not checked | **HIGH** |
| `status_code == 1` | Login success | `statusCode == 1 || data['token'] != null` | **CAUTION** — relying on `token` presence as fallback is fragile |

**Note:** The spec says the SOAP response used `statusCode == 0` for success. But the comment about REST says "Always verify the actual server response." The current Flutter code checks `statusCode == 1` which may be correct for the REST endpoint. Needs verification against live server.

### 10.2 getaccesscontrollRest — INVERTED STATUS CODES

**Spec (Section 3.6 note):** "The Android code for `getaccesscontrollRest` treats `statusCode == 0` as success and `statusCode == 1` as failure."

**Flutter:** `getAccessControl()` returns raw Map with **NO status code validation**. Since the method is never called, this is doubly broken.

- **Priority:** **HIGH**
- **Action Required:** Parse status_code from response. Treat `0` as success, `1` as failure. Extract access flags only on success.

### 10.3 Dashboard API

| Status Code | Spec Meaning | Flutter Handling | Gap? |
|-------------|-------------|-----------------|------|
| `statusCode == 1` | "Details not found!" | No status code check in `getDashboardDetails()` | **MEDIUM** |
| `statusCode >= 2` | "Details not found!" + message | No status code check | **MEDIUM** |
| Response null | "Server connectivity error!" | Handled by Dio exception | OK |

---

## 11. Base URL Configuration

### 11.1 REST Base URL

| Aspect | Spec Requirement | Flutter Implementation | Gap? |
|--------|-----------------|----------------------|------|
| Path prefix | `/LcoRestServices/` | `restBase = baseUrl + '/LcoRestServices'` | OK |
| Comments in datasource | Should reference `/LcoRestServices/` | Comments say `/customerRestservices/` | **LOW** — misleading but non-functional |

### 11.2 Dynamic Server URL

**Spec:** Server URL comes from cloud auth SOAP response and is stored in SharedPrefs `login_url`. The spec recommends seeding from build config or remote config.

**Flutter:** Hardcoded to `http://183.83.216.66:8882/v2_release/index.php`.

- **Priority:** **MEDIUM** for production (OK for development)
- **Action Required:** Make base URL configurable via environment/build config for production deployment.

---

## 12. Missing Screens

| Screen | Spec Section | Priority | Notes |
|--------|-------------|----------|-------|
| ApplicationIntroActivity (first-run) | Section 4 | **MEDIUM** | One-time intro slideshow |
| StatusActivity (LCO payment return) | Section 7 | **LOW** | Payment gateway return handler |
| About_Fragment | Section 8 | **LOW** | About Us page with marquee/WebView |
| PrivacyPolicy_Fragment | Section 9 | **LOW** | WebView loading privacy policy URL |
| LCO Top-Up screen | Section 5.2 | **LOW** | Overflow menu item |
| LCO Payment History | Section 5.2 | **LOW** | Overflow menu item |

---

## 13. Theming System

### 13.1 Multi-Theme Support

**Spec:** 5 color themes controlled by `APP_THEME` (1-5): Default, Red, Green, Blue, Purple.

**Flutter:** Single theme (`AppTheme.lightTheme`). No multi-theme support.

- **Priority:** **LOW** — cosmetic, can be added later
- **Action Required:** Create `ThemeProvider` with 5 theme variants. Persist selection in SharedPreferences. Apply via `MaterialApp.theme`.

### 13.2 Dashboard Layout Variant

**Spec:** `APP_DASHBOARD` controls default vs alternate layout.

**Flutter:** Single dashboard layout.

- **Priority:** **LOW**

---

## 14. Permissions

### 14.1 Runtime Permissions

**Spec:** 8 permissions requested at login time.

**Flutter:** No permission requests at all.

| Permission | Flutter Package | When Needed | Priority |
|-----------|----------------|-------------|----------|
| Location (fine + coarse) | `geolocator` / `permission_handler` | Customer location features | **MEDIUM** |
| Camera | `permission_handler` | QR/barcode scanning | **MEDIUM** |
| Phone State | Not applicable on Flutter | IMEI — use platform channel or skip | **LOW** |
| Contacts | `permission_handler` | Contact search | **LOW** |
| Bluetooth | `permission_handler` | Printer pairing | **LOW** |

**Spec recommendation:** "Request permissions before their respective features are used rather than all at login." — This is already the Flutter best practice.

- **Priority:** **MEDIUM** — Add as each feature is built

---

## 15. Miscellaneous

### 15.1 Toolbar Elements Missing

| Element | Spec Section | Priority |
|---------|-------------|----------|
| QR/Barcode scanner icon | Section 5.2 | **MEDIUM** |
| Bluetooth printer icon | Section 5.2 | **LOW** |
| Dealer logo in toolbar (tap → dashboard) | Section 5.2 | **LOW** |
| Overflow menu (Logout, Privacy Policy, About Us, LCO Top-Up, LCO Payment History) | Section 5.2 | **MEDIUM** |

### 15.2 Email "anyType{}" Handling

**Spec:** If email value is `"anyType{}"`, display `"NA"` instead.

**Flutter:** No such handling in `AuthLocalDatasource` or UI.

- **Priority:** **LOW**
- **Action Required:** Add sanitization in `saveUserData()` or getter.

### 15.3 Currency Code

**Spec:** `CURRENCY_CODE` from login response (default "₹"). Used throughout app.

**Flutter:** Hardcoded as `AppConstants.currencySymbol = '₹'`.

- **Priority:** **MEDIUM** — Breaks for non-INR deployments
- **Action Required:** Store `CURRENCY_CODE` from login response, use dynamically.

### 15.4 Root/Jailbreak Detection

**Spec:** RootBeer library checks for rooted devices.

**Flutter:** Not implemented.

- **Priority:** **LOW** — Security feature, add with `flutter_jailbreak_detection`

### 15.5 Network Connectivity Check

**Spec:** Multiple screens check connectivity before API calls, show "No internet connection!" dialog with Settings button.

**Flutter:** No explicit connectivity checks anywhere.

- **Priority:** **HIGH** — Add using `connectivity_plus` package

---

## Summary: Priority Counts

| Priority | Count | Key Items |
|----------|-------|-----------|
| **HIGH** | 15 | Access control never called, authtoken not in POST body, 27+ config flags missing, no conditional menu visibility, missing STB stat cards, wallet visibility not conditional, no network check |
| **MEDIUM** | 25 | Remember Me, dynamic logo, LCO wallet data source, dashboard API params, intro screen, missing quick actions, Expired Services dialog, many config flags |
| **LOW** | 15 | Cosmetic differences, About/Privacy screens, theming, root detection, copyright text |

### Top 5 Changes to Implement First

1. **Call `getaccesscontrollRest` after login** and store all 8 access flags — blocks conditional UI
2. **Add `authtoken` to POST body** for all authenticated endpoints — blocks API functionality
3. **Store all 38+ login config flags** — blocks feature gating across entire app
4. **Make drawer and quick actions conditional** based on access flags and user type — incorrect UI for restricted users
5. **Add network connectivity check** before API calls — poor UX without it

---

*Generated 2026-03-26 by comparing Flutter source against `01_auth_dashboard_navigation.md` spec*
