# EzyBill Android → Flutter Migration: Gap Analysis & Coverage Review

> **Generated:** 2026-03-26
> **Method:** Systematic cross-check of all 75 source files against 9 generated documentation files.
> **Scope:** V2 REST API layer only. SOAP/ksoap2 items excluded unless they affect Flutter migration decisions.

---

## Summary

| Category | Total Items | Covered | Gaps Found |
|----------|------------|---------|------------|
| Activity/Fragment files | 75 | 74 | 1 (utility, not a screen) |
| REST API Endpoints | 70 | 66 | 4 |
| Complex Class models | 72 | 49 | 23 (see detail — most are SOAP-only or covered implicitly) |
| Adapter files | 21 | 14 | 7 (see detail — most are helper renderers, fully implicit) |
| Root utility files | 8 | 5 | 3 (utility classes, not screens) |

**Overall verdict:** All 75 screens/activities are covered. The 4 missing REST endpoints and 23 complex-class gaps are explained below — most are either SOAP-only, commented-out, or not yet called from any Android screen.

---

## 1. Activity / Fragment Coverage

### ✅ All 74 screens covered

The one file not mentioned by name in any doc:

| File | Status | Verdict |
|------|--------|---------|
| `SSLConection.java` | **Not a screen** — utility class that disables SSL certificate validation | Document as security note (see Section 7 below) |

---

## 2. REST API Endpoint Gaps (4 of 70 missing)

### 2.1 `getdashboardlist` — ⚠️ PARTIALLY DOCUMENTED

- **Where used:** `DashBoard_Active_Stb_Frag.java` line 92 via Retrofit: `api.getassignedtsb(authToken, dealerId, 4)`
- **Status:** The Retrofit client setup is **commented out** in the fragment. The endpoint is registered in `retrofit/Api.java` as `getassignedtsb()` with parameter `from_dashboard`. The call is live (un-commented) but Dagger injection is commented, so runtime behaviour depends on the `ApiComponent` being wired.
- **Documented in:** `05_stb_box_operations.md` covers the Retrofit `Api.java` interface, but the live Retrofit call in `DashBoard_Active_Stb_Frag` was not explicitly described.
- **Flutter action:** Call `POST /LcoRestServices/getdashboardlist` with `from_dashboard=4` (or 1–5 depending on STB type filter). Response field is `getDashboardDataList` (array of STB records).

**Add to `05_stb_box_operations.md` under `DashBoard_Active_Stb_Frag`:**
```
API: POST /LcoRestServices/getdashboardlist
Params: authtoken (String), dealer_id (int), from_dashboard (int: 1–5)
Response key: getDashboardDataList → List of STB records
```

---

### 2.2 `existingCustomerRest` — ℹ️ NOT CALLED FROM ANY ANDROID SCREEN

- **Where used:** Not found in any activity or fragment file.
- **API doc reference:** Section 3.3 — used for existing customer lookup by account/STB/CAF with `tempActivation` flag.
- **Likely intent:** Intended for the temporary activation flow to validate customer identity before activation. May have been replaced by `getCustomerDetailsRest` in the Android implementation.
- **Flutter action:** Implement as documented in `REST_API_V2_SERVICE_DOCUMENT.md` Section 3.3. Use when `tempActivation=true` is required (e.g., pre-activation check). Verify with backend team whether this replaces or supplements `getCustomerDetailsRest`.

---

### 2.3 `extendCustomerServices` — ℹ️ NOT CALLED FROM ANY ANDROID SCREEN

- **Where used:** Not found in any activity or fragment file.
- **API doc reference:** Section 7.5 — extends a customer's active service (adds validity days or quantity).
- **Status:** Backend endpoint exists. The `show_service_extension` config flag (from login response) is documented in `06_package_service_operations.md` and implies this feature is planned/gated.
- **Flutter action:** Implement this endpoint for the service extension feature. Show extension button only when `show_service_extension == 1` AND `edit_quantity == 1`. Use `POST /LcoRestServices/extendCustomerServices` with fields: `customer_id`, `product_id`, `stock_id`, `quantity`, `fromMobileApp=true`.

---

### 2.4 `customerAgingServices` — ℹ️ NOT CALLED FROM ANY ANDROID SCREEN

- **Where used:** Not found in any activity or fragment file.
- **API doc reference:** Section 7.10 — aging report for customer services with date range, serial number, VC number, BAID filters.
- **Status:** Backend endpoint exists. No Android screen was built for this — it is a future or web-only report.
- **Flutter action:** This can be a new screen in Flutter (aging/expiry report). Confirm with client whether this screen is in scope for Flutter.

---

## 3. Complex Class Gaps — Detailed Analysis

### 3.1 SOAP-Only Classes (Safe to Skip for V2 Flutter)

All of these implement `KvmSerializable` (ksoap2 interface) and have **no REST equivalent call** in the Android codebase:

| Class | Purpose | V2 Status |
|-------|---------|-----------|
| `CheckAadhaarList` | SOAP request: check Aadhaar number | **SOAP-only** — UI button commented out |
| `CreateAadhaarDetails` | SOAP request: submit Aadhaar data | **SOAP-only** — UI button commented out |
| `CreateAadharTransactionModel` | SOAP request: create Aadhaar transaction | **SOAP-only** |
| `UpdateAadhaarTransaction` | SOAP request: update Aadhaar transaction | **SOAP-only** |
| `CitiesByMandalInfo` | SOAP request wrapper for mandal→city lookup | **SOAP-only** (REST uses `getCitiesRest`) |
| `CitiesListbyMandal` | SOAP response wrapper | **SOAP-only** |

**Flutter action:** Skip all Aadhaar/eKYC SOAP classes. The `ENABLE_AADHAAR` flag (login response) is commented out in `CustomerOperations_Fragment`. If eKYC is required in Flutter, it should use a new REST endpoint to be defined. Flag to client.

---

### 3.2 Covered Implicitly (Referenced in Docs by Field Name, Not Class Name)

These classes were analyzed via their parent screen's code but their class names weren't explicitly cited in the doc:

| Class | Used In | Documented Via |
|-------|---------|----------------|
| `saveCustomerInfo` | `NewCustCreation_Fragment` | `02_customer_management.md` — 51 fields listed |
| `editCustomerInfo` | `Edit_Customer_Info` | `02_customer_management.md` — edit fields documented |
| `searchCustomerInfo` | `SearchCustomer_Fragment` | `02_customer_management.md` — search params documented |
| `ExistingCustomer_Model` | `existingCustomerRest` (not called) | `02_customer_management.md` — `existingCustomerRest` endpoint |
| `CustomerCreation_WithDevice_Model` | `NewCustomer_Confirm_Activity` | `02_customer_management.md` — confirmation screen |
| `CustomerPackageResult` | `NewCust_AddPackage_Activity` | `06_package_service_operations.md` — package selection |
| `CustomersResult` | `CustomerSearchList_Fragment` | `02_customer_management.md` — search result list |
| `getPendingAmountInfo` | `CustomerMgmtActivity_MakePayment_Fragment` | `03_payments_pg_integration.md` — payment pending amount |
| `modeCategories` | `CustomerMgmtActivity_MakePayment_Fragment` | `03_payments_pg_integration.md` — payment modes |
| `Basepackagemodel` | `FragActive_plan`, `Frag_deact_pack` | `06_package_service_operations.md` — package list |
| `PackageIdModel` | `NewCust_AddPackage_Activity` | `06_package_service_operations.md` |
| `stbInfo` | `Box_Operations_Fragment` | `05_stb_box_operations.md` — STB detail fields |
| `stbInfoList` | `Box_Operations_Fragment` | `05_stb_box_operations.md` |
| `updateCustomerPackage` | `Package_Operations_Fragment` | `06_package_service_operations.md` |
| `Minidaymodel` | `MiniDayReport_Fragment` | `07_reports.md` — miniday columns |

---

### 3.3 Voucher Payment Mode — ⚠️ GAP IN `03_payments_pg_integration.md`

`VoucherInfo` and `Voucher_Update_Status` are used in `CustomerMgmtActivity_MakePayment_Fragment`. The Voucher payment mode was **not fully documented** in the payment mode matrix.

**What was found in source:**
- Payment mode `"Voucher"` shows a dedicated `voucher_et` EditText (View ID: `makepayact_et_vouchercode`)
- Button label changes to `"Pay by Voucher"` when Voucher mode selected
- `paymentInfo.voucherCode` is populated from `voucher_et` input
- `paymentInfo.modeType` is set to `"voucher"`
- `tablerowVoucher` LinearLayout shown/hidden based on mode selection
- Voucher code is passed in `makePaymentsRest` as field `voucherCode`

**Flutter action:** Add Voucher as a 4th payment mode option (alongside Cash, Cheque, Online). Show `voucherCode` text field only when Voucher mode is selected. Send `modeType="voucher"` and `voucherCode` in `makePaymentsRest` payload.

---

## 4. Adapter Gaps — Analysis

### 4.1 Implicitly Covered

| Adapter | Used In | Status |
|---------|---------|--------|
| `NavDrawerListAdapter` | `MainActivity` | Covered in `01_auth_dashboard_navigation.md` — nav drawer structure documented. Adapter is a standard BaseAdapter; Flutter uses `ListView`/`Column` directly. |
| `MinidayAdpter` | `MiniDayReport_Fragment` | Covered in `07_reports.md` — all columns documented. |
| `Employee_Collection_List_Adapter` | `Reports_Emp_Collection_List_Fragment` AND `LcoWalletHistory` | Covered in `07_reports.md`. Note: same adapter is reused for LCO Wallet History list — same column structure applies. |
| `ExpiredAdapter` | `Dashboard_Fragment` | Used for the `getExpiryServicesDateWiseCount` popup dialog on dashboard. Covered in `01_auth_dashboard_navigation.md`. |
| `Profile_Services_Adapter` | `FragActive_plan` | Used to display the deactivated package list during the bill preview step before activation. Should be added to `06_package_service_operations.md`. |

### 4.2 Unused / Not in Active Code Path

| Adapter | Status |
|---------|--------|
| `DashBoardRecyclerAdapter` | Both usages are **commented out** in `Dashboard_Fragment.java` (lines 613 and 624). Not in active code path. Can be ignored for Flutter. |
| `ImageAdapter` | No active usage found in any screen. Appears to be unused legacy code. |

---

## 5. Root Utility Files Not in Docs

| File | Status | Flutter Action |
|------|--------|----------------|
| `DecimalDigitsInputFilter.java` | Input filter that restricts decimal places on EditText | Flutter equivalent: `FilteringTextInputFormatter` — no doc needed |
| `FontChange.java` | Changes app-wide font (likely Typeface utility) | Flutter uses `ThemeData` / `GoogleFonts` — no doc needed |
| `TransparentProgressDialog.java` | Custom progress dialog with transparent background | Flutter equivalent: `CircularProgressIndicator` in a `Stack` with overlay — no doc needed |

---

## 6. Aadhaar / eKYC Module — Full Status

The eKYC module exists in the codebase but is **entirely inactive**:

- `CustomerOperations_Fragment.java` lines 729–750: The `btn_edit_linkaadhar` button and `ENABLE_AADHAAR` visibility check are fully **commented out**
- All eKYC model classes (`CheckAadhaarList`, `CreateAadhaarDetails`, etc.) use **ksoap2 SOAP serialization** — no REST equivalents exist in `REST_API_V2_SERVICE_DOCUMENT.md`
- `api/CreateAadharTransaction_Response.java` is a SOAP response model

**Flutter action:** Do NOT implement Aadhaar/eKYC in the initial Flutter migration. Add a placeholder button (hidden by default) that can be activated by `ENABLE_AADHAAR` config flag if the backend team adds a V2 REST endpoint in future. Flag this to the client.

---

## 7. SSLConection — Critical Security Warning

`SSLConection.java` is called in `LoginActivity.java` line 920: `SSLConection.allowAllSSL()`.

**What it does:** Installs a trust-all `X509TrustManager` that accepts any SSL certificate (including self-signed and expired certs) and sets a `HostnameVerifier` that returns `true` for all hostnames. This completely bypasses TLS certificate validation for all `HttpsURLConnection` requests.

**Why it's there:** The EzyBill server uses HTTP (not HTTPS) for the REST API (`http://itpworld.linkpc.net:81/...`). The `allowAllSSL()` is called defensively for the BMS SOAP endpoint which may use self-signed HTTPS.

**Flutter action:**
```dart
// In Dio configuration (dio_client.dart):
(dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true; // ⚠️ Only for dev/self-signed certs
  return client;
};
```
**Security recommendation:** Do NOT use trust-all in production Flutter. Instead, pin the server's certificate or switch the server to a valid CA-signed certificate. If the server is HTTP-only, no SSL config is needed.

---

## 8. `Profile_Services_Adapter` — Missing from Package Docs

**Used in:** `FragActive_plan.java` line 1677 — displays the list of **selected packages awaiting activation** in a bottom sheet or dialog before the user confirms.

**Fields displayed:**
- Package name (`getServicename()` from `Deactpacklist` model)
- Package type/category
- Pricing

**Flutter action:** Add to `06_package_service_operations.md` under FragActive_plan: after `getbilldetailsRest` response, show a confirmation list of selected packages using `Profile_Services_Adapter`-equivalent widget before calling `activateServiceRest`.

---

## 9. `Employee_Collection_List_Adapter` Dual Usage

This adapter is used in **two different screens** with the same data structure:

1. `Reports_Emp_Collection_List_Fragment` — Employee collection summary (documented in `07_reports.md`)
2. `LcoWalletHistory` — LCO wallet transaction list (documented in `09_lco_payment_access_control_master_data.md`)

**Flutter action:** Create a single reusable `CollectionListTile` widget that both screens can use.

---

## 10. Actions Required — Priority List

### 🔴 High Priority (affects Flutter functionality)

| # | Action | Target Doc |
|---|--------|-----------|
| 1 | Add **Voucher payment mode** to payment mode matrix — 4th mode with `voucherCode` field | `03_payments_pg_integration.md` |
| 2 | Document **`extendCustomerServices`** endpoint in Package Operations with `show_service_extension` flag gating | `06_package_service_operations.md` |
| 3 | Add `getdashboardlist` Retrofit call detail to `DashBoard_Active_Stb_Frag` section | `05_stb_box_operations.md` |
| 4 | Add `Profile_Services_Adapter` confirmation step to FragActive_plan activation flow | `06_package_service_operations.md` |

### 🟡 Medium Priority (flutter implementation notes)

| # | Action | Target Doc |
|---|--------|-----------|
| 5 | Document `SSLConection.allowAllSSL()` call and Flutter equivalent in Login section | `01_auth_dashboard_navigation.md` |
| 6 | Flag `existingCustomerRest` as backend-only or verify with backend team | `02_customer_management.md` |
| 7 | Note `Employee_Collection_List_Adapter` dual usage (reports + LCO wallet) for widget reuse | `07_reports.md` |

### 🟢 Low Priority (informational)

| # | Action | Target Doc |
|---|--------|-----------|
| 8 | Note `customerAgingServices` as future screen opportunity | `06_package_service_operations.md` |
| 9 | Note Aadhaar/eKYC as commented-out SOAP module, not in scope | `02_customer_management.md` |
| 10 | Note `DashBoardRecyclerAdapter` is commented out (not in active code) | `01_auth_dashboard_navigation.md` |
| 11 | Note `DecimalDigitsInputFilter`, `FontChange`, `TransparentProgressDialog` Flutter equivalents | General Flutter setup |

---

## 11. Complete Screen Coverage Matrix

All 74 active source files mapped to documentation:

| Source File | Documented In |
|-------------|--------------|
| `ACT_LoginActivity.java` | `01` — SOAP-only, skip |
| `About_Fragment.java` | `01` |
| `AccountActivation.java` | `02` — POS hardware, skip |
| `AccountActivation_fgrag_payswiff.java` | `03` — Payswiff POS |
| `ActivityDevice.java` | `08` — BLE printer |
| `ApplicationIntroActivity.java` | `01` — App intro/splash |
| `AssignedSTB_CountsFrag.java` | `02` — STB dashboard fragments |
| `BilldeskPaymentActivity.java` | `03` — PG integration |
| `Bluetooth_Fragment.java` | `08` — BLE printer |
| `Box_Operations_Fragment.java` | `05` — STB box ops |
| `CaptureSignature.java` | `08` — Signature |
| `CloudAuthentication.java` | `01` — SOAP-only, skip |
| `ComapliantHistory.java` | `04` — Complaint history |
| `ComplaintDashboard.java` | `04` |
| `ComplaintHistory_Close_Fragment.java` | `04` |
| `ComplaintHistory_Other_Fragment.java` | `04` |
| `ComplaintSearchResultList_Fragment.java` | `04` |
| `Complaint_NewComplint_Fragment.java` | `04` |
| `Complaint_Operations_Fragment.java` | `04` |
| `ConnectionDevice.java` | `08` — BLE printer |
| `CustomerMgmtActivity_MakePayment_Fragment.java` | `03` |
| `CustomerOperations_Fragment.java` | `02` + `05` |
| `CustomerSearchList_Fragment.java` | `02` |
| `Customer_STB_Select_Fragment.java` | `02` |
| `DashBoard_Active_Stb_Frag.java` | `02` + `05` (gap: getdashboardlist) |
| `Dashboard_Fragment.java` | `01` |
| `DeactiveStb_Frag.java` | `02` |
| `DeviceListActivity.java` | `08` — BLE printer |
| `DisplayPaymentDetails_Fragment2.java` | `03` |
| `Displayfrag.java` | `02` |
| `Edit_Customer_Info.java` | `02` |
| `Employee_Collection_Details_Fragment.java` | `07` + `09` |
| `FragActive_plan.java` | `06` (gap: Profile_Services_Adapter step) |
| `Frag_deact_pack.java` | `06` |
| `InvoiceHistory.java` | `03` |
| `LCO_Payment_Fragment.java` | `09` |
| `LcoTopupFragment.java` | `03` + `09` |
| `LcoWalletHistory.java` | `03` + `09` |
| `LoginActivity.java` | `01` (gap: SSLConection call) |
| `MainActivity.java` | `01` |
| `MapActivity_Fragment.java` | `08` — GPS/Maps |
| `MapsActivity.java` | `08` |
| `MapsFragmentlocupdate.java` | `08` |
| `MiniDayReport_Fragment.java` | `07` |
| `NewCustCreation_Fragment.java` | `02` |
| `NewCust_AddPackage_Activity.java` | `06` |
| `NewCustomer_Confirm_Activity.java` | `02` |
| `OpenComplaints_frag.java` | `04` |
| `PG_Transaction_Frag.java` | `03` |
| `Package_Operations_Fragment.java` | `06` |
| `PairedDeviceList.java` | `08` — BLE printer |
| `PaymentHistory.java` | `03` |
| `PaymentResponseActivity.java` | `03` |
| `PaymentTransactionActivity.java` | `03` |
| `PaymentTransaction_frag_payswiff.java` | `03` — Payswiff POS |
| `Payment_Webview_Frag.java` | `03` |
| `PaymenttransacFragment.java` | `03` |
| `PrivacyPolicy_Fragment.java` | `01` |
| `RenewFragment.java` | `06` |
| `Report_EmpCollect_Fragment.java` | `07` |
| `Reports_Emp_Collection_List_Fragment.java` | `07` |
| `Reports_frag.java` | `07` |
| `Route.java` | `08` — GPS directions |
| `SSLConection.java` | ⚠️ **Not documented** — utility, see Section 7 above |
| `STB_Check_Fragment_Old.java` | `05` |
| `SampleCallBack.java` | `03` — Billdesk callback |
| `ScannerFrag.java` | `08` — Barcode scanner |
| `SearchCustomer_Fragment.java` | `02` |
| `SignatureCapture_Fragment.java` | `08` |
| `SignaturecaptureFrag.java` | `08` |
| `StatusActivity.java` | `01` — PG return handler |
| `StbPairUnpair.java` | `05` |
| `TotalStbs_Frag.java` | `02` |
| `Transacdetailfrag.java` | `03` |
| `TransactionDetails.java` | `03` |
| `TransactionDetailsDeclined.java` | `03` |
| `TransactionDetails_Frag_payswiff.java` | `03` — Payswiff POS |
| `UnAssignedStb_Frag.java` | `02` |

---

*This gap analysis document should be read alongside the 9 category docs. The 4 high-priority actions above should be patched into the respective documents before handing off to the Flutter development team.*
