# Flutter Changes Required: LCO Payment, Access Control & Master Data

> **Comparison Date:** 2026-03-26
> **Spec Reference:** `09_lco_payment_access_control_master_data.md`
> **Status:** GAP ANALYSIS ONLY — no code changes made

---

## Section 1: LCO Payment Screen

### GAP 1.1 — LCO Payment Fragment (Entire Screen Missing)
**Priority: HIGH**

The spec defines `LCO_Payment_Fragment` with a two-phase search+pay workflow. **No Flutter equivalent exists.** There is no screen, datasource, provider, or model for LCO payment.

**What is needed:**
- New screen: `lco_payment_screen.dart` with two-phase UI (search panel -> payment entry panel)
- New datasource method (or new datasource file) for:
  - LCO advance/due search (`getlcoadvanceamountdue` — SOAP-origin, REST equivalent TBD)
  - LCO payment submit (`lcopaymentfunc` — SOAP-origin, REST equivalent TBD)
- New provider: `lco_payment_provider.dart`
- New models:
  - `LcoSearchRequest` (authToken, employee_id, lco_code)
  - `LcoSearchResponse` (statusCode, statusMessage, employee_id, dealer_id, billing_id, advance, due, bill_amount, tds_deduction)
  - `LcoPaymentRequest` (13 fields: authToken, lco_employee_id, lco_billing_id, receipt_number, amount, mode, adjust_flag, dabit_credit, accept, chequeddnumber, chequeDate, bank, branch, remarks)
- Validation rules: LCO code non-empty, amount non-empty/non-zero, remarks mandatory, BANK mode requires cheque number/bank/branch/cheque date, cheque date >= today
- BANK mode conditional UI: cheque fields visible only when BANK selected
- Adjustment checkbox: shows credit/debit spinner when checked

**Note on existing payment code:** `payment_remote_datasource.dart` handles *customer* payments (`makePaymentsRest`, `getPendingAmountRest`), NOT LCO-to-MSO payments. These are completely different flows.

### GAP 1.2 — LCO Payment REST Endpoints Not Defined
**Priority: HIGH**

`ApiConstants` has no entries for `getlcoadvanceamountdue` or `lcopaymentfunc`. The spec notes these are SOAP-origin endpoints with no confirmed REST equivalents. Two new constants are needed once the REST endpoints are confirmed by the server team:
- `ApiConstants.lcoAdvanceAmountDue`
- `ApiConstants.lcoPaymentFunc`

---

## Section 2: LCO Topup Screen

### GAP 2.1 — LCO Topup Screen Missing
**Priority: MEDIUM**

The spec defines `LcoTopupFragment` — a screen that captures an amount and launches a WebView payment gateway. **No Flutter equivalent exists.** The `wallet_card.dart` widget has an "Add Money" button with a `// TODO: Add money flow` comment, confirming this is unimplemented.

**What is needed:**
- New screen: `lco_topup_screen.dart`
  - Display LCO name (from session)
  - Display current wallet balance (from dashboard provider)
  - Amount input field with validation (> 0.0)
  - "Pay Now" button navigating to a WebView screen
- New screen: `payment_webview_screen.dart` using `webview_flutter` or `flutter_inappwebview`
- Visibility controlled by `allow_top_up` config flag (currently not stored — see GAP 4.1)

---

## Section 3: LCO Wallet History Screen

### GAP 3.1 — LCO Wallet History Display Screen Missing
**Priority: MEDIUM**

The spec defines `LcoWalletHistory` — a list display of wallet transactions using `Lcowalletmodel` with 14 fields. **No Flutter screen exists.** However, the REST endpoint `getlcowalletRest` IS implemented in `dashboard_remote_datasource.dart` (`getLcoWallet` method), which is good.

**What is needed:**
- New screen: `lco_wallet_history_screen.dart`
  - Date range picker (fromDate, toDate)
  - Total count header
  - ListView of wallet transactions
- New model: `LcoWalletTransaction` with 14 fields:
  - `deposite_amount`, `Deposit_Date`, `business_name`, `payment_mode`, `cheque_ddnumber`, `bank`, `branch`, `instrument_date`, `credit_amount`, `debit_amount`, `transaction_no`, `receipt_no`, `Remarks`, `Deposited_By`
- Currently the `getLcoWallet` response is returned as raw `Map<String, dynamic>` — needs structured model parsing

---

## Section 4: Access Control Flags

### GAP 4.1 — Access Control Response Not Parsed or Stored
**Priority: HIGH**

The `getaccesscontrollRest` endpoint IS called in `auth_remote_datasource.dart` (`getAccessControl` method), but **the response is never consumed**. There is no code in `auth_provider.dart` or anywhere else that:
1. Calls `getAccessControl` after login
2. Parses the 8 access control flags from the response
3. Stores them in any state/provider

**The 8 missing access control flags:**

| Flag | Default | Status |
|------|---------|--------|
| `report` | — | NOT STORED |
| `int_bulk_payment` | 1 | NOT STORED |
| `invoice_page_access` | 1 | NOT STORED |
| `payment_hist_page_access` | 1 | NOT STORED |
| `access_for_complaints` | 1 | NOT STORED |
| `int_stb_activation` | 1 | NOT STORED |
| `int_stb_deactivation` | 1 | NOT STORED |
| `int_stb_reactivation` | 1 | NOT STORED |

**What is needed:**
- Call `getAccessControl` in the login flow (in `AuthNotifier.login()`) after successful validateLogin
- Parse all 8 flags
- Store in session state (see GAP 6.1) with defaults of 1 (deny-by-exception model)
- Use these flags to conditionally show/hide menu items and screens throughout the app

---

## Section 5: Login Response Fields

### GAP 5.1 — Only 11 of 38+ Login Response Fields Explicitly Saved
**Priority: HIGH**

`AuthLocalDatasource.saveUserData()` explicitly saves only 11 fields:
- `dealerId`, `employeeId`, `userType`, `firstName`, `lastName`, `email`, `phone`, `lcoCode`, `businessName`, `parentType`, `parentId`

The full login response IS saved as a JSON blob (`prefKeyLoginResponse`), but **no code extracts or uses** any of the remaining 27+ fields from it. The following critical fields from the spec are never parsed:

**Missing identity/location fields:**
- `deposit_amount` (double)
- `defaultCountry`, `defaultState`, `defaultDistrict`, `defaultCity` (location defaults for forms)

**Missing feature flags (all 30+ from validateLogin):**
- `useCRF`, `useCAF`, `useLastName`, `useDiscount`, `useDataFromMasterTable`, `useMandatoryForHotel`, `useAccountNumber`, `freezecustomerparamsinapp`, `blockpayment`, `lco_billtype`, `use_lco_deposits`/`useLcoDeposit`, `customer_billtype`, `AUTO_RECEIPT_NUMBER`, `CURRENCY_CODE`, `allow_top_up`, `show_caf_mobile_validation`, `stb_pairing`, `stb_unpairing`, `show_mia_agreement_upload`, `show_serial_vc`, `show_service_extension`, `edit_quantity`, `enable_box_wise_payment`, `baid_label`, `is_direct_lco`, `access_distributor_wise`, `is_unpaidlco`, `appMenuFormat`, `invoicepaymentsearchlimit`, `lcoMobileNo`, `patch_information`, `recurringServiceEdit`, `showLcoComplaint`, `accept_terms_condtions`, `agreement_details_count`, `user_image`, `config_values_array`

**Note:** `AppConstants.currencySymbol` is hardcoded to `'₹'` instead of being read from the login response `CURRENCY_CODE` field. This will break for non-INR operators.

---

## Section 6: Global Config Flags (44 Total)

### GAP 6.1 — No Session/Config State Object Exists
**Priority: HIGH**

The spec defines 44 config flags (36 from `validateLogin` + 8 from `getaccesscontrollRest`) that should be stored in a session model. **Flutter has no `AppSession` or `SessionNotifier` equivalent.** The `AuthState` class only holds `status`, `errorMessage`, and raw `loginData` map.

**What is needed:**
- Create `AppSession` model class (as specified in spec Section 4.2) with all 44+ typed fields
- Create `SessionNotifier` (Riverpod notifier) that:
  - Is populated after login + access control calls
  - Exposes typed getters for every flag
  - Persists critical fields to SharedPreferences for app restart survival
- Replace scattered `Map<String, dynamic>` usage with typed session access

### GAP 6.2 — Config Flags Coverage Audit

**From validateLogin (36 flags) — NONE are individually stored or typed:**

| Flag | Stored? | Used? |
|------|---------|-------|
| `useCRF` | NO | NO |
| `useCAF` | NO | NO |
| `useLastName` | NO | NO |
| `useDiscount` | NO | NO |
| `useDataFromMasterTable` | NO | NO |
| `useMandatoryForHotel` | NO | NO |
| `useAccountNumber` | NO | NO |
| `freezecustomerparamsinapp` | NO | NO |
| `blockpayment` | NO | NO |
| `appMenuFormat` | NO | NO |
| `invoicepaymentsearchlimit` | NO | NO |
| `lco_billtype` | NO | Passed ad-hoc to dashboard datasource |
| `use_lco_deposits` | NO | Passed ad-hoc to dashboard datasource |
| `customer_billtype` | NO | NO |
| `AUTO_RECEIPT_NUMBER` | NO | NO |
| `CURRENCY_CODE` | NO | Hardcoded as `'₹'` in `AppConstants` |
| `allow_top_up` | NO | NO |
| `show_caf_mobile_validation` | NO | NO |
| `stb_pairing` | NO | NO |
| `stb_unpairing` | NO | NO |
| `show_mia_agreement_upload` | NO | NO |
| `show_serial_vc` | NO | NO |
| `show_service_extension` | NO | NO |
| `edit_quantity` | NO | NO |
| `enable_box_wise_payment` | NO | NO |
| `baid_label` | NO | NO |
| `is_direct_lco` | NO | NO |
| `access_distributor_wise` | NO | NO |
| `is_unpaidlco` | NO | NO |
| `patch_information` | NO | NO |
| `recurringServiceEdit` | NO | NO |
| `showLcoComplaint` | NO | NO |
| `accept_terms_condtions` | NO | NO |
| `agreement_details_count` | NO | NO |
| `config_values_array` | NO | NO |
| `lcoMobileNo` | NO | NO |

**From getaccesscontrollRest (8 flags) — NONE stored:**

| Flag | Stored? | Used? |
|------|---------|-------|
| `report` | NO | NO |
| `int_bulk_payment` | NO | NO |
| `invoice_page_access` | NO | NO |
| `payment_hist_page_access` | NO | NO |
| `access_for_complaints` | NO | NO |
| `int_stb_activation` | NO | NO |
| `int_stb_deactivation` | NO | NO |
| `int_stb_reactivation` | NO | NO |

**TOTAL: 0 of 44 config flags are individually stored or typed. All 44 are missing.**

The raw JSON blob is saved, but nothing reads individual flags from it.

---

## Section 7: Master Data Models

### GAP 7.1 — No Dart Model Classes for Any Master Data Entity
**Priority: HIGH**

The `lib/data/models/` directory is empty — no model files exist. The spec defines typed models for 9+ master data entities. All master data is currently handled as raw `Map<String, dynamic>` / `List<Map<String, dynamic>>`.

**Required Dart model classes:**

| Model | Fields | Status |
|-------|--------|--------|
| `Country` | iso, name, numcode | NOT CREATED |
| `StateModel` | id, name, countryCode, abbrev | NOT CREATED |
| `District` | id, name, iso, stateId | NOT CREATED |
| `City` | locationId, locationName, stateId, dealerId, locationCode | NOT CREATED |
| `Mandal` | districtId, mandalId, mandalName | NOT CREATED |
| `Gender` | id, name | NOT CREATED |
| `CustomerType` | customerTypeId, customerType, isCommercialMultiBox | NOT CREATED |
| `CustomerTypeType` | customerTypeTypesId, name | NOT CREATED |
| `IdItem` | id, name | NOT CREATED |
| `GroupItem` | groupId, groupName | NOT CREATED |
| `LcoLocation` | locationId, locationName, lcoCode | NOT CREATED |
| `LcoWalletTransaction` | 14 fields (see GAP 3.1) | NOT CREATED |
| `AssignedStbModel` | 9 fields | NOT CREATED |
| `ExpiredCountModel` | service_end_date, stb_count | NOT CREATED |

Each model should include `fromJson` factory constructor and `toJson` method.

---

## Section 8: Master Data Endpoints

### GAP 8.1 — Endpoints Defined but Missing Genders
**Priority: MEDIUM**

**Endpoint implementation status in `MasterDataRemoteDatasource`:**

| Spec Endpoint | ApiConstants Entry | Datasource Method | Status |
|--------------|-------------------|-------------------|--------|
| `getCountriesRest` | `countries` | `getCountries()` | IMPLEMENTED |
| `getStatesRest` | `states` | `getStates()` | IMPLEMENTED |
| `getdistrictsRest` | `districts` | `getDistricts()` | IMPLEMENTED |
| `getCitiesRest` | `cities` | `getCities()` | IMPLEMENTED |
| `getmandalsRest` | `mandals` | `getMandals()` | IMPLEMENTED |
| `getGroupsRest` | `groups` | `getGroups()` | IMPLEMENTED |
| `getCustomerTypesRest` | `customerTypes` | `getCustomerTypes()` | IMPLEMENTED |
| `getcustomerTypeTypesRest` | `customerTypeTypes` | `getCustomerTypeTypes()` | IMPLEMENTED |
| `getIdsRest` | `idTypes` | `getIdTypes()` | IMPLEMENTED |
| `getLocationsOfDistrictRest` | `locationsOfDistrict` | `getLocationsOfDistrict()` | IMPLEMENTED |
| `getGendersRest` | — | — | **MISSING** |

**What is needed:**
- Add `getGendersRest` endpoint constant to `ApiConstants`
- Add `getGenders()` method to `MasterDataRemoteDatasource`

### GAP 8.2 — No Master Data Provider/State Management
**Priority: MEDIUM**

There is no `master_data_provider.dart` to manage cached master data state. The datasource methods exist but nothing coordinates loading/caching the dropdown data for forms.

**What is needed:**
- `MasterDataProvider`/`MasterDataNotifier` that:
  - Loads and caches countries, states, districts, cities, mandals, groups, customer types, IDs, genders
  - Supports cascading loads (country -> states -> districts -> cities/mandals)
  - Caches results to avoid redundant API calls

---

## Section 9: Session Storage

### GAP 9.1 — SharedPreferences Keys Cover Only 13 of 40+ Required Fields
**Priority: HIGH**

`AppConstants` defines only 16 preference keys (13 data fields + token + jwt + isLoggedIn). The spec's `LoginActivity` has 40+ static fields that serve as the session store.

**Currently stored (13 fields):**
dealerId, employeeId, userType, firstName, lastName, email, phone, lcoCode, businessName, parentType, parentId, employeeName, loginResponseJson

**Not stored individually (27+ fields):**
deposit_amount, defaultCountry, defaultState, defaultDistrict, defaultCity, useCRF, useCAF, useLastName, useDiscount, useDataFromMasterTable, useMandatoryForHotel, useAccountNumber, freezecustomerparamsinapp, blockpayment, lco_billtype, useLcoDeposit, customer_billtype, AUTO_RECEIPT_NUMBER, CURRENCY_CODE, allow_top_up, show_caf_mobile_validation, stb_pairing, stb_unpairing, show_mia_agreement_upload, is_direct_lco, access_distributor_wise, appMenuFormat, patch_information, recurringServiceEdit, showLcoComplaint, accept_terms_condtions, agreement_details_count, lcoMobileNo, all 8 access control flags

**What is needed:**
- Expand `AppConstants` with preference keys for all session fields
- Expand `AuthLocalDatasource.saveUserData()` to persist all config flags
- Add getters for each persisted field
- Or alternatively, create a dedicated `SessionLocalDatasource` that serializes/deserializes the full `AppSession` model

### GAP 9.2 — CloudAuth Fields Not Handled
**Priority: LOW**

The spec defines `CloudAuthResponse` with fields: `ipAddress`, `appThemeColor`, `appDashboard`, `appLogoPath`, `enableAadhar`. The Flutter app appears to have a hardcoded base URL in `ApiConstants`. If cloud auth is needed for dynamic server URL resolution, this entire flow is missing. If the server URL is fixed for all operators, this may be acceptable.

---

## Section 10: SOAP-to-REST Mapping

### GAP 10.1 — Two Unconfirmed REST Endpoints Not Handled
**Priority: HIGH**

The spec identifies two SOAP-only endpoints with no confirmed REST equivalents:

| SOAP Method | Purpose | REST Status |
|------------|---------|-------------|
| `getlcoadvanceamountdue` | Fetch LCO advance balance and due amount | **No REST endpoint confirmed** |
| `lcopaymentfunc` | Submit LCO payment record | **No REST endpoint confirmed** |

**What is needed:**
1. Confirm with server team whether REST equivalents exist (check for `/lcoAdvanceAmountDueRest` or similar)
2. If REST endpoints exist: add to `ApiConstants` and implement in a new `LcoPaymentRemoteDatasource`
3. If no REST endpoints exist: either implement SOAP-over-HTTP XML calls in Flutter, or request the server team to create REST endpoints
4. This blocks the entire LCO Payment screen (GAP 1.1)

---

## Priority Summary

### HIGH Priority (Blocks core functionality)
| Gap | Description |
|-----|-------------|
| 6.1 | No AppSession/SessionNotifier — 0 of 44 config flags stored/typed |
| 6.2 | All 44 config flags missing from typed state |
| 5.1 | Only 11 of 38+ login response fields explicitly saved |
| 4.1 | Access control response never consumed after login |
| 7.1 | No Dart model classes for any master data entity |
| 9.1 | SharedPreferences covers only 13 of 40+ session fields |
| 1.1 | LCO Payment screen entirely missing |
| 1.2 | LCO Payment REST endpoints not defined |
| 10.1 | Two SOAP endpoints have no confirmed REST equivalents |

### MEDIUM Priority (Feature gaps)
| Gap | Description |
|-----|-------------|
| 2.1 | LCO Topup screen missing (wallet_card has TODO) |
| 3.1 | LCO Wallet History display screen missing (REST endpoint exists) |
| 8.1 | Genders endpoint/method missing from master data |
| 8.2 | No master data provider for caching/state management |

### LOW Priority (Edge cases / deferred)
| Gap | Description |
|-----|-------------|
| 9.2 | CloudAuth dynamic server URL flow not implemented |

---

## Recommended Implementation Order

1. **Create `AppSession` model + `SessionNotifier`** (GAP 6.1) — This is the foundation; every other screen depends on config flags.
2. **Parse all validateLogin response fields into AppSession** (GAP 5.1) — Populate the session on login.
3. **Call getAccessControl after login and store flags** (GAP 4.1) — Complete the session state.
4. **Expand SharedPreferences storage** (GAP 9.1) — Persist session across restarts.
5. **Create all master data Dart models** (GAP 7.1) — Type safety for dropdowns.
6. **Add Genders endpoint** (GAP 8.1) and **master data provider** (GAP 8.2).
7. **Confirm LCO payment REST endpoints with server team** (GAP 10.1) — Unblocks screen work.
8. **Build LCO Payment screen** (GAP 1.1, 1.2).
9. **Build LCO Topup screen** (GAP 2.1).
10. **Build LCO Wallet History screen** (GAP 3.1).
