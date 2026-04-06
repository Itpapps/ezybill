# EzyBill Flutter App — Master Implementation Plan V2

> **Generated:** 2026-03-26
> **Source:** Gap analysis documents 01–10, REST API V2 Service Document, Flutter Project Plan, pubspec.yaml
> **Branch:** 16kbisssuefix
> **Total estimated effort:** ~320–400 hours across 10 phases

---

## How To Read This Plan

- **File paths** are relative to `lib/` unless otherwise noted.
- **Complexity:** S (<1h), M (1–4h), L (4–8h), XL (8+h).
- **Gap ref** cites the specific `_flutterchanges.md` document and section.
- **Deps** lists tasks that must complete first.
- Existing files that need modification use their current path. New files are marked **(NEW)**.

---

# PHASE 0: FOUNDATION

> Must complete before ANY feature work. This phase creates the missing architectural layers that every subsequent phase depends on.

---

## 0.1 Project Structure Setup

**Complexity: M** | **Gap ref:** Doc 10, Section 1.1 | **Deps:** None

Create all missing directories under `lib/`:

```
lib/
  core/
    config/                          # (NEW) AppSession, environment config
    constants/                       # EXISTS
    network/                         # EXISTS
    services/                        # (NEW) Bluetooth, receipt, connectivity
    theme/                           # EXISTS
    utils/                           # (NEW) Formatters, validators, parse utils
  data/
    datasources/
      local/                         # EXISTS (1 file)
      remote/                        # EXISTS (10 files)
    models/                          # (NEW — entire directory)
      auth/
      dashboard/
      customer/
      complaint/
      payment/
      stb/
      package/
      report/
      master_data/
      employee/
      lco/
    repositories/                    # (NEW — entire directory)
  domain/
    entities/                        # (NEW — entire directory)
    repositories/                    # (NEW — abstract interfaces)
  application/
    providers/                       # EXISTS (11 files)
    states/                          # (NEW — separate state files)
  presentation/
    common/widgets/                  # EXISTS (1 file: app_shell.dart)
    router/                          # EXISTS
    screens/                         # EXISTS (17+ screens)
```

**Build runner configuration:**

File: `build.yaml` **(NEW)** at project root:
```yaml
targets:
  $default:
    builders:
      freezed:
        generate_for:
          - lib/data/models/**
          - lib/core/config/**
      json_serializable:
        generate_for:
          - lib/data/models/**
          - lib/core/config/**
```

**Action items:**
1. Create all `(NEW)` directories listed above.
2. Create `build.yaml` with Freezed + json_serializable config.
3. Verify `dart run build_runner build --delete-conflicting-outputs` runs cleanly.

---

## 0.2 Core Models Layer

**Complexity: XL** | **Gap ref:** Doc 10, Section 2.1; Doc 09, Section 7.1 | **Deps:** 0.1

Every API response currently flows as untyped `Map<String, dynamic>` from datasource to UI. This task creates Freezed model classes for all domains.

### auth/ models

#### `data/models/auth/login_response.dart` **(NEW)**
- **Class:** `LoginResponse` (Freezed + json_serializable)
- **Fields:**
  - `int statusCode`
  - `String statusMsg`
  - `String token`
  - `int dealerId`
  - `int employeeId`
  - `String userType` — "RESELLER", "EMPLOYEE", "DEALER", "ADMIN", "SERVICE", "DISTRIBUTOR", "SUBDISTRIBUTOR", "TEAMLEAD"
  - `String firstName`, `String lastName`, `String email`, `String phone`
  - `String lcoCode`, `String businessName`
  - `String employeeParentType`, `String employeeParentId`
  - `String? username`, `String? logoImg`
  - Config flags (all `String` or `int` from server, parsed to appropriate types):
    - `int useCRF`, `String useCAF`, `int useLastName`, `int useDiscount`
    - `int useDataFromMasterTable`, `int useMandatoryForHotel`, `int useAccountNumber`
    - `int freezecustomerparamsinapp`, `int blockpayment`
    - `int lcoBilltype`, `int useLcoDeposit`, `int customerBilltype`
    - `int autoReceiptNumber`, `String currencyCode`
    - `int allowTopUp`, `int showCafMobileValidation`
    - `int stbPairing`, `int stbUnpairing`
    - `int showMiaAgreementUpload`, `int acceptTermsConditions`, `int agreementDetailsCount`
    - `int accessDistributorWise`, `int isDirectLco`, `int isUnpaidlco`
    - `String appMenuFormat`, `int invoicePaymentSearchLimit`
    - `int lcoMobileNo`, `String patchInformation`
    - `int recurringServiceEdit`, `int showLcoComplaint`
    - `double depositAmount`
    - `String? defaultCountry`, `int? defaultState`, `int? defaultDistrict`, `int? defaultCity`
    - `int showSerialVc`, `int showServiceExtension`, `int editQuantity`
    - `int enableBoxWisePayment`, `String? baidLabel`
    - `int? appTheme`, `int? appDashboard`, `int? enableAadhaar`
    - `int? lcoPayment`
- **Maps to:** `POST /LcoRestServices/validateLogin`
- **Codegen:** Freezed + json_serializable
- **Note:** `fromJson` must handle the snake_case/camelCase inconsistency from server. Use `@JsonKey(name: 'field_name')` annotations.

#### `data/models/auth/access_control_response.dart` **(NEW)**
- **Class:** `AccessControlResponse` (Freezed)
- **Fields:**
  - `int statusCode`
  - `int intBulkPayment` (default 1)
  - `int invoicePageAccess` (default 1)
  - `int paymentHistPageAccess` (default 1)
  - `int accessForComplaints` (default 1)
  - `int intStbActivation` (default 1)
  - `int intStbDeactivation` (default 1)
  - `int intStbReactivation` (default 1)
  - `int pgtransaction` (default 0)
- **Maps to:** `POST /LcoRestServices/getaccesscontrollRest`
- **Codegen:** Freezed + json_serializable
- **CRITICAL:** This endpoint uses inverted status codes: `status_code == 0` = success, `status_code == 1` = failure.

### dashboard/ models

#### `data/models/dashboard/dashboard_response.dart` **(NEW)**
- **Class:** `DashboardResponse` (Freezed)
- **Fields:**
  - `int totalStbs`, `int totalAssignedStbs`, `int totalUnAssignedStbs`
  - `int totalComplaints`
  - `int totalActiveCustomers`, `int totalDeactiveCustomers`
  - `double totalCurrentMonthBill`, `double totalDueAmount`, `double outStandingAmount`
  - `double msoShare`, `double totalCurrentMonthMsoShare`
  - `double currentMonthOutstanding`, `double currentMonthLCOBill`, `double lcuCurrentMonthDueAmount`
  - `int totalPaidCustomers`, `int totalUnPaidCustomers`
  - `int? lovEmpGrpCustomers`
- **Maps to:** `POST /LcoRestServices/dashBoardDetailsRest`
- **Codegen:** Freezed

#### `data/models/dashboard/wallet_response.dart` **(NEW)**
- **Class:** `WalletResponse` (Freezed)
- **Fields:** `int statusCode`, `double lcoDepositAmount`, `int? customerCount`
- **Maps to:** `POST /LcoRestServices/lco_deposit_amountRest`

#### `data/models/dashboard/expiry_services_response.dart` **(NEW)**
- **Class:** `ExpiryServicesResponse` (Freezed)
- **Fields:** `int statusCode`, `String statusMsg`, `List<ExpiryDateCount> expiryServicesList`
- **Nested class:** `ExpiryDateCount` — `String date`, `int stbCount`
- **Maps to:** `POST /LcoRestServices/getExpiryServicesDateWiseCount`

### customer/ models

#### `data/models/customer/customer_model.dart` **(NEW)**
- **Class:** `CustomerModel` (Freezed)
- **Fields:** `String customerId`, `String customerName`, `String? cafNumber`, `String? mobileNumber`, `String status`, `String? billingAddress`, `String? installationAddress`, `String? pinCode`, `String? crfNumber`, `double pendingAmount`, `int? onlineCustomer`, `int? checkaddserviceaccess`, `int? addonAfterBasepack`, `String? resellerId`, `String? billType`, `int? isDirectLco`, `String? accountNumber`, `double? latitude`, `double? longitude`, `String? serialNumber`, `String? vcNumber`, `int? stbCount`
- **Maps to:** `POST /LcoRestServices/getCustomerDetailsRest`
- **Note:** `fromJson` must handle both `customer_name` and `customerName` keys.

#### `data/models/customer/save_customer_request.dart` **(NEW)**
- **Class:** `SaveCustomerRequest` (Freezed)
- **Fields:** All 40+ fields from spec section 5.8 of doc 02: `firstName`, `lastName`, `mobileNumber`, `email`, `billingAddress1`, `billingAddress2`, `installationAddress1`, `installationAddress2`, `pinCode`, `gender`, `idType`, `idNumber`, `customerTypeId`, `customerTypeTypesId`, `groupId`, `cafNumber`, `lcoCustomerId`, `businessName`, `fatherName`, `accountNumber`, `billType`, `dob`, `doa`, `discount`, `remarks`, `countryCode`, `stateId`, `districtId`, `cityId`, `mandalId`, `latitude`, `longitude`, `stbSerialNumber`, `stbVcNumber`, `packageId`, `packageName`, `quantity`, `cycle`, `validityDays`, `pricingStructureType`, `idPhoto`, `customerPhoto`, `signatureImage`
- **Maps to:** `POST /LcoRestServices/saveCustomerRest`

#### `data/models/customer/edit_customer_request.dart` **(NEW)**
- **Class:** `EditCustomerRequest` (Freezed)
- **Fields:** `String customerId` + all editable SaveCustomerRequest fields + `bool changeAddress`, `bool changeInstallAddress`, `bool uploadDocs`
- **Maps to:** `POST /LcoRestServices/editCustomerRest`

#### `data/models/customer/form_validation.dart` **(NEW)**
- **Class:** `FormValidation` (Freezed)
- **Fields:** `String columnName`, `String isMandatory`
- **Maps to:** `POST /LcoRestServices/dynamicformvalidationsRest`

### complaint/ models

#### `data/models/complaint/complaint_model.dart` **(NEW)**
- **Class:** `ComplaintModel` (Freezed)
- **Fields:** `String complaintId`, `String ticketNumber`, `String customerId`, `String customerName`, `String category`, `String? categoryName`, `String? subCategory`, `String complaint`, `String status`, `String? assignedTo`, `String? assignedToName`, `String createdDate`, `String? closedDate`, `String? remarks`
- **Maps to:** `POST /LcoRestServices/getComplaintList`, `gettotalcomplaintslist`

#### `data/models/complaint/complaint_category.dart` **(NEW)**
- **Class:** `ComplaintCategory` (Freezed)
- **Fields:** `int categoryId`, `String categoryName`
- **Maps to:** `POST /LcoRestServices/complaintCategoriesRest`

#### `data/models/complaint/complaint_subcategory.dart` **(NEW)**
- **Class:** `ComplaintSubcategory` (Freezed)
- **Fields:** `int subCategoryId`, `String subCategoryName`, `int categoryId`
- **Maps to:** `POST /LcoRestServices/getComplaintsubCategory`

### payment/ models

#### `data/models/payment/payment_mode.dart` **(NEW)**
- **Class:** `PaymentMode` (Freezed)
- **Fields:** `String paymentModeId`, `String paymentModeName`
- **Maps to:** `POST /LcoRestServices/getPaymentModesRest`

#### `data/models/payment/pending_amount.dart` **(NEW)**
- **Class:** `PendingAmount` (Freezed)
- **Fields:** `int statusCode`, `double pendingAmount`, `String customerName`, `String mobileNumber`, `double msoShare`, `double lcoShare`, `String billingId`
- **Maps to:** `POST /LcoRestServices/getPendingAmountRest`

#### `data/models/payment/make_payment_request.dart` **(NEW)**
- **Class:** `MakePaymentRequest` (Freezed)
- **Fields:** `String altCustomerId`, `double amount`, `String modeType`, `String? receiptNumber`, `String? altReceiptNumber`, `String? remarks`, `String? billingId`, `String? chequeNo`, `String? bank`, `String? branch`, `String? chequeDate`, `String? rrnNo`, `String? cardholderName`, `String? voucherCode`, `String? imei`

#### `data/models/payment/payment_history.dart` **(NEW)**
- **Class:** `PaymentHistoryItem` (Freezed)
- **Fields:** `String paymentId`, `String paidOn`, `double paidAmount`, `String receiptNo`, `String paymentMode`, `String? remarks`, `String? employeeName`
- **Maps to:** `POST /LcoRestServices/PaymentServiceRest`

#### `data/models/payment/invoice_model.dart` **(NEW)**
- **Class:** `InvoiceItem` (Freezed)
- **Fields:** `String billingId`, `String billDate`, `String dueDate`, `double totalAmount`, `int quantity`, `double basePrice`, `String serialNumber`, `String macVcNumber`, `String pname`, `double setupPrice`, `double taxAmount`, `double pendingAmount`, `double discountAmount`, `int isAdhoc`
- **Maps to:** `POST /LcoRestServices/InvoiceServiceRest`

#### `data/models/payment/pg_transaction_model.dart` **(NEW)**
- **Class:** `PgTransaction` (Freezed)
- **Fields:** `String transactionId`, `String customerId`, `double amount`, `String status`, `String gateway`, `String orderId`, `String transactionDate`
- **Maps to:** `POST /LcoRestServices/pgTransactionLogs`

#### `data/models/payment/receipt_range.dart` **(NEW)**
- **Class:** `ReceiptRange` (Freezed)
- **Fields:** `String rangeId`, `String fromNumber`, `String toNumber`, `String currentNumber`
- **Maps to:** `POST /LcoRestServices/getReceiptRanges`

#### `data/models/payment/bill_detail.dart` **(NEW)**
- **Class:** `BillDetail` (Freezed)
- **Fields:** `double lcoShare`, `double msoShare`, `double totalAmount`, `String? ncfDisplayName`, `double ncfTotalAmount`, `String? encfDisplayName`, `double encfTotalAmount`, `int? enumAddOnAfterBase`, `int? enableProrataDiscount`
- **Maps to:** `POST /LcoRestServices/getbilldetailsRest`

### stb/ models

#### `data/models/stb/stb_model.dart` **(NEW)**
- **Class:** `StbModel` (Freezed)
- **Fields:** `String stbNo`, `String vcNo`, `String? customerId`, `String status`, `String casType`, `String? serialNumber`, `String? boxNumber`, `String? macAddress`, `String? stockId`, `String? deviceId`, `String? backendSetupId`, `String? stockStatus`, `String? activatedDate`, `String? assignedDate`, `int? isAssigned`, `String? installationAddress`, `int? isTempDeactivated`
- **Maps to:** `POST /LcoRestServices/getCustomerBoxDetailsRest`

#### `data/models/stb/deactivation_reason.dart` **(NEW)**
- **Class:** `DeactivationReason` (Freezed)
- **Fields:** `int reasonId`, `String reasonName`, `int? globalReason`, `int? disableForDpo`
- **Maps to:** `POST /LcoRestServices/getDeactiveReasonsRest`

#### `data/models/stb/stb_replacement_request.dart` **(NEW)**
- **Class:** `StbReplacementRequest` (Freezed)
- **Fields:** `String customerId`, `String serialNumber`, `String accountNumber`, `int replacementTypeId`, `double amount`, `String receiptNumber`, `String remarks`, `String replaceSerialNumber`, `String replaceVcNumber`, `int isPermanentSurrender`, `int pairCondition`

### package/ models

#### `data/models/package/package_model.dart` **(NEW)**
- **Class:** `PackageModel` (Freezed)
- **Fields:** `String packageId`, `String packageName`, `double price`, `String packageType`, `String? validity`, `int? channels`, `int? sdChannels`, `int? hdChannels`, `String? startDate`, `String? endDate`, `String? billingCycle`, `String? pricingStructureType`, `String? serviceId`, `String? customerServiceId`
- **Maps to:** `getCustomerPackages_splitRest`, `getUnassignedPackages_splitRest`
- **Note:** Both endpoints return 4 arrays: `packageList_base`, `packageList_addon`, `packageList_ala`, `packageList_broadcaster`

#### `data/models/package/cas_package.dart` **(NEW)**
- **Class:** `CasPackage` (Freezed)
- **Fields:** `String productId`, `String productName`, `String pricingStructureType`, `double? price`
- **Maps to:** `POST /LcoRestServices/getCasPackagesRest`

### report/ models

#### `data/models/report/mini_day_report_row.dart` **(NEW)**
- **Class:** `MiniDayReportRow` (Freezed)
- **Fields:** `String paymentMode`, `int custCount`, `double total`
- **Maps to:** `POST /LcoRestServices/DailyreportRest`
- **Note:** The current `ReportState` maps to wrong fields (totalCollection, cashCollection, etc.). This model must use the correct fields: `payment_mode`, `cust_count`, `total`.

#### `data/models/report/emp_collection_summary.dart` **(NEW)**
- **Class:** `EmpCollectionSummary` (Freezed)
- **Fields:** `String employeeId`, `String name`, `double amt`
- **Maps to:** `POST /LcoRestServices/empCollectionRest`

#### `data/models/report/emp_collection_detail.dart` **(NEW)**
- **Class:** `EmpCollectionDetail` (Freezed)
- **Fields:** `String customerId`, `String customerName`, `double paidAmount`, `String paidOn`, `String paymentMode`, `String paymentId`
- **Maps to:** `POST /LcoRestServices/empCustomerCollectionDetailsRest`

### master_data/ models

#### `data/models/master_data/country.dart` **(NEW)**
- **Class:** `Country` (Freezed)
- **Fields:** `String iso`, `String name`, `int? numcode`

#### `data/models/master_data/state_model.dart` **(NEW)**
- **Class:** `StateModel` (Freezed)
- **Fields:** `int id`, `String name`, `String countryCode`, `String? abbrev`

#### `data/models/master_data/district.dart` **(NEW)**
- **Class:** `District` (Freezed)
- **Fields:** `int id`, `String name`, `String? iso`, `int stateId`

#### `data/models/master_data/city.dart` **(NEW)**
- **Class:** `City` (Freezed)
- **Fields:** `int locationId`, `String locationName`, `int stateId`, `int? dealerId`, `String? locationCode`

#### `data/models/master_data/mandal.dart` **(NEW)**
- **Class:** `Mandal` (Freezed)
- **Fields:** `int districtId`, `int mandalId`, `String mandalName`

#### `data/models/master_data/group.dart` **(NEW)**
- **Class:** `GroupItem` (Freezed)
- **Fields:** `int groupId`, `String groupName`

#### `data/models/master_data/customer_type.dart` **(NEW)**
- **Class:** `CustomerType` (Freezed)
- **Fields:** `int customerTypeId`, `String customerType`, `int? isCommercialMultiBox`

#### `data/models/master_data/customer_type_type.dart` **(NEW)**
- **Class:** `CustomerTypeType` (Freezed)
- **Fields:** `int customerTypeTypesId`, `String name`

#### `data/models/master_data/id_type.dart` **(NEW)**
- **Class:** `IdType` (Freezed)
- **Fields:** `int id`, `String name`

#### `data/models/master_data/gender.dart` **(NEW)**
- **Class:** `Gender` (Freezed)
- **Fields:** `int id`, `String name`
- **Maps to:** `POST /LcoRestServices/getGendersRest` (endpoint currently missing from ApiConstants)

### employee/ models

#### `data/models/employee/employee.dart` **(NEW)**
- **Class:** `Employee` (Freezed)
- **Fields:** `String employeeId`, `String employeeName`, `String? phone`, `String? email`, `String? status`

#### `data/models/employee/service_employee.dart` **(NEW)**
- **Class:** `ServiceEmployee` (Freezed)
- **Fields:** `String employeeId`, `String employeeName`, `String? phone`, `String? serviceArea`

### lco/ models

#### `data/models/lco/lco_wallet_entry.dart` **(NEW)**
- **Class:** `LcoWalletEntry` (Freezed)
- **Fields:** `double? depositeAmount`, `String? depositDate`, `String? businessName`, `String? paymentMode`, `String? chequeDdnumber`, `String? bank`, `String? branch`, `String? instrumentDate`, `double? creditAmount`, `double? debitAmount`, `String? transactionNo`, `String? receiptNo`, `String? remarks`, `String? depositedBy`
- **Maps to:** `POST /LcoRestServices/getlcowalletRest`

#### `data/models/lco/lco_payment_request.dart` **(NEW)**
- **Class:** `LcoPaymentRequest` (Freezed)
- **Fields:** `String authToken`, `String lcoEmployeeId`, `String lcoBillingId`, `String receiptNumber`, `double amount`, `String mode`, `int adjustFlag`, `String dabitCredit`, `int accept`, `String? chequeDdnumber`, `String? chequeDate`, `String? bank`, `String? branch`, `String? remarks`
- **Maps to:** TBD — REST equivalent of `lcopaymentfunc` SOAP endpoint

**Total model files: ~35+ files**

**After creating all models, run:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 0.3 AppSession / Config State

**Complexity: L** | **Gap ref:** Doc 09, Section 6.1; Doc 01, Sections 3, 4 | **Deps:** 0.2

### File: `core/config/app_session.dart` **(NEW)**

```dart
@freezed
class AppSession with _$AppSession {
  const factory AppSession({
    // ── Identity (11 fields currently stored) ──
    required int dealerId,
    required int employeeId,
    required String userType,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String lcoCode,
    required String businessName,
    required String employeeParentType,
    required String employeeParentId,
    required String token,

    // ── 36 Config Flags from validateLogin ──
    @Default(0) int useCRF,
    @Default('MANUAL') String useCAF,
    @Default(1) int useLastName,
    @Default(0) int useDiscount,
    @Default(0) int useDataFromMasterTable,
    @Default(0) int useMandatoryForHotel,
    @Default(0) int useAccountNumber,
    @Default(0) int freezecustomerparamsinapp,
    @Default(0) int blockpayment,
    @Default(0) int lcoBilltype,
    @Default(0) int useLcoDeposit,
    @Default(0) int customerBilltype,
    @Default(1) int autoReceiptNumber,
    @Default('INR') String currencyCode,
    @Default(0) int allowTopUp,
    @Default(0) int showCafMobileValidation,
    @Default(0) int stbPairing,
    @Default(0) int stbUnpairing,
    @Default(0) int showMiaAgreementUpload,
    @Default(0) int acceptTermsConditions,
    @Default(0) int agreementDetailsCount,
    @Default(0) int accessDistributorWise,
    @Default(0) int isDirectLco,
    @Default(0) int isUnpaidlco,
    @Default('DEFAULT') String appMenuFormat,
    @Default(0) int invoicePaymentSearchLimit,
    @Default(0) int lcoMobileNo,
    @Default('') String patchInformation,
    @Default(0) int recurringServiceEdit,
    @Default(0) int showLcoComplaint,
    @Default(0.0) double depositAmount,
    String? defaultCountry,
    int? defaultState,
    int? defaultDistrict,
    int? defaultCity,
    @Default(1) int showSerialVc,
    @Default(0) int showServiceExtension,
    @Default(0) int editQuantity,
    @Default(0) int enableBoxWisePayment,
    String? baidLabel,
    @Default(1) int appTheme,
    @Default(1) int appDashboard,
    @Default(0) int enableAadhaar,
    @Default(0) int lcoPaymentFlag,

    // ── 8 Access Control Flags from getaccesscontrollRest ──
    @Default(1) int intBulkPayment,
    @Default(1) int invoicePageAccess,
    @Default(1) int paymentHistPageAccess,
    @Default(1) int accessForComplaints,
    @Default(1) int intStbActivation,
    @Default(1) int intStbDeactivation,
    @Default(1) int intStbReactivation,
    @Default(0) int pgtransaction,
  }) = _AppSession;

  const AppSession._();

  // ── Convenience getters ──
  String get displayName => '$firstName $lastName'.trim();
  String get currencySymbol => currencyCode == 'INR' ? '\u20B9' : currencyCode;

  bool get isDistributor =>
      userType == 'DISTRIBUTOR' ||
      userType == 'SUBDISTRIBUTOR' ||
      employeeParentType == 'DISTRIBUTOR' ||
      employeeParentType == 'SUBDISTRIBUTOR';

  bool get isReseller => userType == 'RESELLER';
  bool get isEmployee => userType == 'EMPLOYEE';
  bool get isTeamLead => userType == 'TEAMLEAD';

  bool get showWallet =>
      !isDistributor &&
      userType != 'DEALER' &&
      userType != 'ADMIN' &&
      userType != 'SERVICE' &&
      isDirectLco == 0;

  bool get showLcoTopUp =>
      isReseller && allowTopUp == 1 && isDirectLco == 0;

  factory AppSession.fromLoginAndAccessControl(
    Map<String, dynamic> loginData,
    Map<String, dynamic>? accessControlData,
  ) => /* parse all fields */;

  factory AppSession.fromJson(Map<String, dynamic> json) =>
      _$AppSessionFromJson(json);
}
```

### File: `application/providers/session_provider.dart` **(NEW)**

```dart
final appSessionProvider = StateNotifierProvider<SessionNotifier, AppSession?>(
  (ref) => SessionNotifier(ref.watch(authLocalDatasourceProvider)),
);

class SessionNotifier extends StateNotifier<AppSession?> {
  SessionNotifier(this._local) : super(null);
  final AuthLocalDatasource _local;

  void setSession(AppSession session) {
    state = session;
    _local.saveSessionJson(session.toJson()); // persist for restart
  }

  Future<void> restoreSession() async {
    final json = await _local.getSessionJson();
    if (json != null) state = AppSession.fromJson(json);
  }

  void clear() {
    state = null;
    _local.clearAll();
  }
}
```

### How login populates AppSession:

In `AuthNotifier.login()` (modify `application/providers/auth_provider.dart`):
1. Call `validateLogin` — get login response map.
2. Call `getaccesscontrollRest` — get access control map. Handle inverted status_code (0 = success).
3. Build `AppSession.fromLoginAndAccessControl(loginMap, accessControlMap)`.
4. Call `ref.read(appSessionProvider.notifier).setSession(session)`.

### How screens access config:

```dart
final session = ref.watch(appSessionProvider);
if (session?.accessForComplaints == 1) { /* show complaint menu */ }
Text(session?.currencySymbol ?? '₹');
```

---

## 0.4 Core Utils

**Complexity: M** | **Gap ref:** Doc 10, Sections 2.5, 3.9 | **Deps:** 0.1

### `core/utils/date_formatters.dart` **(NEW)**
- `toApiFormat(DateTime) -> String` (yyyy-MM-dd)
- `toDisplayDate(String) -> String` (dd MMM yyyy)
- `toDisplayDateTime(String) -> String` (dd MMM yyyy, hh:mm a)
- `parseApiDate(String?) -> DateTime?`
- `toReceiptDate(DateTime) -> String` (DDD MMM DD YYYY HH:MM:SS for thermal print)

### `core/utils/currency_formatter.dart` **(NEW)**
- `format(dynamic amount, {String? currencyCode})` — Indian notation: 1,23,456.00
- Reads `currencyCode` from AppSession, defaults to INR/₹
- Handles String, int, double inputs

### `core/utils/validators.dart` **(NEW)**
- `mobile(String?)` — 10-digit Indian mobile
- `email(String?)` — standard regex
- `pinCode(String?)` — 6-digit
- `required(String?, String fieldName)`
- `receiptNumber(String?)`
- `amount(String?)` — positive number
- `stbNumber(String?)`, `vcNumber(String?)`
- `minLength(String?, int min, String fieldName)`

### `core/utils/string_extensions.dart` **(NEW)**
- `appendSuffix(String)` — for `.Complaint Created from Flutter app` etc.
- `stripSuffix(String)` — remove suffix for display
- `capitalize()`, `initials()`, `isValidMobile`, `isValidEmail`

### `core/utils/parse_utils.dart` **(NEW)**
- `parseInt(dynamic, {int default})` — extracted from 5 duplicate copies
- `parseDouble(dynamic, {double default})`
- `parseBool(dynamic, {bool default})`
- `parseString(dynamic, {String default})`

### `core/utils/print_formatters.dart` **(NEW)** (stub for Phase 8)
- `receiptLayout(...)` — stub returning formatted string
- `invoiceLayout(...)` — stub
- `collectionReportLayout(...)` — stub

---

## 0.5 Repository Layer

**Complexity: XL** | **Gap ref:** Doc 10, Section 2.2 | **Deps:** 0.2, 0.4

### Error handling pattern

File: `core/network/result.dart` **(NEW)**
```dart
sealed class Result<T> {
  const Result();
}
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}
class Failure<T> extends Result<T> {
  final AppFailure failure;
  const Failure(this.failure);
}

class AppFailure {
  final String message;
  final FailureType type;
  const AppFailure(this.message, this.type);
}

enum FailureType { network, server, auth, validation, unknown }
```

### Domain repository interfaces (abstract)

All in `domain/repositories/`:

| File **(NEW)** | Methods |
|---|---|
| `auth_repository.dart` | `login(username, password, {mobile, imei})`, `getAccessControl(...)`, `logout()`, `restoreSession()` |
| `dashboard_repository.dart` | `getDashboardDetails(dealerId, {useLcoDeposit, lcoBilltype})`, `getLcoDepositAmount(dealerId)`, `getExpiryServicesDateWiseCount(dealerId)` |
| `customer_repository.dart` | `searchCustomers(...)`, `getCustomerCount(...)`, `saveCustomer(SaveCustomerRequest)`, `editCustomer(EditCustomerRequest)`, `updateLocation(customerId, lat, lng)`, `getExistingCustomer(...)` |
| `complaint_repository.dart` | `getComplaints(dealerId, {status, page})`, `getCustomerComplaints(customerId)`, `getCategories()`, `getSubCategories(categoryId)`, `getComplaintTypes()`, `createComplaint(CreateComplaintRequest)`, `closeComplaint(...)`, `getComplaintHistory(dealerId, customerId)` |
| `payment_repository.dart` | `getPendingAmount(customerId)`, `makePayment(MakePaymentRequest)`, `getPaymentModes()`, `getReceiptRanges(dealerId)`, `getPaymentHistory(customerId, {fromDate, toDate})`, `getInvoiceHistory(customerId)`, `getBillDetails(...)`, `getPgTransactions(dealerId, {status})` |
| `stb_repository.dart` | `getCustomerBoxDetails(customerId)`, `getParticularBoxDetails(customerId, stockId)`, `deactivateBox(...)`, `reactivateBox(...)`, `getDeactivationReasons({showforlco, stockId})`, `temporaryActivation(customerId, stockId)`, `validateBoxInfo(serialNumber)`, `stbPair(serialNumber, vcNumber)`, `stbUnpair(serialNumber)`, `stbReplacement(StbReplacementRequest)` |
| `package_repository.dart` | `getAssignedPackages(customerId, stbNo)`, `getAvailablePackages(customerId, stbNo)`, `activateService(...)`, `deactivateService(...)`, `extendService(...)`, `getCasPackages(boxNumber)`, `getChannelList(productId, dealerId)`, `getRenewServicesList(dealerId, customerId)`, `renewServices(...)`, `getBillDetails(...)` |
| `report_repository.dart` | `getDailyReport(dealerId)`, `getEmpCollection(dealerId, fromDate, toDate, {imei})`, `getEmpCustomerCollectionDetails(dealerId, fromDate, toDate)`, `downloadReport(...)` |
| `employee_repository.dart` | `getEmployeeList(dealerId)`, `getServiceEmployeeList(dealerId)` |
| `master_data_repository.dart` | `getCountries()`, `getStates(countryCode)`, `getDistricts(stateId)`, `getCities(stateId, districtId)`, `getMandals(districtId)`, `getLocationsOfDistrict(districtId)`, `getGroups()`, `getCustomerTypes()`, `getCustomerTypeTypes(customerTypeId)`, `getIdTypes()`, `getGenders()`, `getDynamicFormValidations(tableName, dealerId)` |

### Concrete implementations

All in `data/repositories/`:

Each `XxxRepositoryImpl` implements the corresponding domain interface, depends on the remote datasource (and optionally local datasource for caching). Every method:
1. Calls the datasource.
2. Parses the response into a typed model via `fromJson`.
3. Returns `Result<T>` — never throws.
4. Checks `status_code` per the API convention (1 = success, except `getaccesscontrollRest` where 0 = success).

### Caching strategy

| Data | Cache Location | TTL |
|---|---|---|
| Master data (countries, states, districts, cities, groups, types, IDs) | SharedPreferences | 24 hours |
| Dashboard stats | In-memory + stale-while-revalidate | 5 minutes |
| Payment modes, complaint categories, deactivation reasons | In-memory | 1 hour |
| Customer search results | No cache | Always live |
| Session/config flags | SharedPreferences | Until logout |

---

## 0.6 Fix Existing Datasources

**Complexity: L** | **Gap ref:** Doc 01, Section 9.1; Doc 10, Sections 3.1, 3.2, 3.9 | **Deps:** 0.3

### 0.6.1 Add `authtoken` to POST body pattern
**File:** All 10 files in `data/datasources/remote/`

The spec requires `authtoken` (lowercase 't') in the POST body of most authenticated endpoints. Currently only the JWT header is sent.

**Option A (recommended):** Add a Dio interceptor in `core/network/dio_client.dart` that auto-appends `authtoken` to every POST body (reading from the stored auth token).

**Option B:** Add `authtoken` param to each datasource method call.

### 0.6.2 Fix parameter name casing
**File:** `data/datasources/remote/auth_remote_datasource.dart`
- Change `authToken` to `authtoken` in `getAccessControl()` request body.
- Change `dealer_id` to send as String: `dealer_id.toString()`.

### 0.6.3 Add status_code response checking
**Files:** All remote datasources.
- After each API call, check `response['status_code']`.
- Standard: `status_code == 1` = success, `0` = error, `>= 2` = "Contact support".
- Exception: `getaccesscontrollRest` uses inverted codes (0 = success).
- Return typed error in `Result.Failure` instead of throwing generic exceptions.

### 0.6.4 Remove duplicate helper methods
**Files:** `auth_provider.dart`, `dashboard_provider.dart`, `dashboard_customer_list_provider.dart`, `customer_provider.dart`, `report_provider.dart`
- Delete all local `_parseInt`, `_parseDouble` copies.
- Import from `core/utils/parse_utils.dart`.
- Delete duplicated `_extractCustomerList` / `_extractComplaintList`.
- Move response normalization logic to model `fromJson` factories.

---

## 0.7 Reusable Widget Library

**Complexity: L** | **Gap ref:** Doc 10, Section 4.1 | **Deps:** 0.1

All files go in `presentation/common/widgets/`:

| Widget File **(NEW)** | Props | Used By |
|---|---|---|
| `search_bar_with_debounce.dart` | `onChanged`, `hintText`, `debounceMs` | Home, Customer Search, Employee List, Filter List |
| `paginated_list_view.dart` | `itemCount`, `pageSize`, `onPageChange`, `itemBuilder`, `currentPage` | Customer Search, Complaints, STB Dashboard, Reports |
| `status_badge.dart` | `status: String`, `statusColorMap: Map<String, Color>` | Customer, Complaint, STB, Package screens |
| `loading_state.dart` | `message: String?` | All screens |
| `error_state.dart` | `message: String`, `onRetry: VoidCallback?` | All screens |
| `empty_state.dart` | `icon`, `title`, `subtitle` | All screens |
| `confirmation_dialog.dart` | `title`, `message`, `confirmLabel`, `cancelLabel`, `onConfirm` | STB, Package, Payment, Logout |
| `section_header.dart` | `title`, `trailing` | Reports, Settings, Dashboard |
| `stat_card.dart` | `label`, `value`, `icon`, `color` | Dashboard, Reports |
| `customer_info_card.dart` | `CustomerModel customer`, `onTap`, `compact: bool` | Customer Search, Filter List, Profile |
| `stb_detail_card.dart` | `StbModel stb`, `actions: List<Widget>` | STB Operations, Customer Search |
| `action_chip_button.dart` | `label`, `icon`, `onTap`, `color` | Quick Actions, Customer Operations |
| `cascading_dropdown.dart` | `label`, `items`, `selectedValue`, `onChanged`, `isLoading` | New Customer, Edit Customer |
| `date_range_selector.dart` | `fromDate`, `toDate`, `onFromChanged`, `onToChanged` | Reports, Wallet History |
| `receipt_preview_card.dart` | `receiptData: Map<String, String>` | Payment Receipt, Invoice display |
| `form_field_wrapper.dart` | `label`, `child`, `isRequired`, `errorText` | All forms |

---

## 0.8 UI Design System (from POC)

**Complexity: L** | **Gap ref:** `screen_docs/11_ui_design_spec.md` | **Deps:** 0.1

The Flutter app must achieve a 100% visual match with the UI POC at `screen_docs/ezyquick-lco-v2.html`. This overrides the old Android app UI entirely.

### 0.8.1 Theme Overhaul

**File:** `core/theme/app_colors.dart` — **REWRITE**

Replace current blue-based palette (`#4361ee`) with POC red-based palette:
- Primary: `#e53935` (red), gradient to `#c62828` (red-dark)
- Full light + dark token sets (see `11_ui_design_spec.md` Section 1.2)
- Avatar color palette (6 hashed colors)
- Status dot colors: active `#00c853`, deactivated `#ff1744`, suspended `#f5a623`, fresh `#4a90d9`

**File:** `core/theme/app_theme.dart` — **REWRITE**

- Font: `Plus Jakarta Sans` (body) + `JetBrains Mono` (numbers/money)
- Border radii: 14px (cards), 10px (small), 100px (pills)
- Shadow hierarchy: sm → card → lg
- Full dark theme with all dark token values
- Theme extensions for custom color tokens

### 0.8.2 Reusable UI Components from POC

These widgets implement the POC design and are used across all phases:

| Widget | File **(NEW)** | Props |
|--------|------|-------|
| `AppHeader` | `presentation/common/widgets/app_header.dart` | LCO name, code, location, wallet balance, notifications |
| `WalletBar` | `presentation/common/widgets/wallet_bar.dart` | balance, lastRecharge, onTopUp |
| `OverviewDonut` | `presentation/screens/home/widgets/overview_donut.dart` | active, inactive, fresh counts (fl_chart or CustomPainter) |
| `OverviewLegend` | `presentation/screens/home/widgets/overview_legend.dart` | 2x2 clickable stat cards |
| `AlertChipsRow` | `presentation/screens/home/widgets/alert_chips.dart` | horizontal scroll chips with icon+count+label |
| `WalletHistoryPanel` | `presentation/screens/home/widgets/wallet_history_panel.dart` | animated toggle panel |
| `AppSearchBar` | `presentation/common/widgets/app_search_bar.dart` | red-focus border, go button, pill shape |
| `PillTabBar` | `presentation/common/widgets/pill_tab_bar.dart` | per-tab colors (green/red/green/amber), badge counts |
| `SubscriberCard` | `presentation/common/widgets/subscriber_card.dart` | avatar, info, status dot, due text, context-aware action row |
| `AlphabetSidebar` | `presentation/common/widgets/alphabet_sidebar.dart` | A-Z vertical bar, active letter highlight |
| `SubscriberDetailSheet` | `presentation/screens/customers/widgets/subscriber_detail_sheet.dart` | bottom sheet with profile, detail grid, packages, circle actions |
| `CircleActionBar` | `presentation/common/widgets/circle_action_bar.dart` | 52px circle buttons with colored icons + labels |
| `WalletTopUpSheet` | `presentation/screens/home/widgets/wallet_topup_sheet.dart` | preset grid + custom amount + confirm |
| `RechargeSheet` | `presentation/screens/payments/widgets/recharge_sheet.dart` | plan toggle, summary, pay from wallet |
| `AppToast` | `presentation/common/widgets/app_toast.dart` | success (green) / info (blue) overlay toast |
| `StatusDot` | `presentation/common/widgets/status_dot.dart` | 9px colored circle per status |
| `UserAvatar` | `presentation/common/widgets/user_avatar.dart` | initials + hash-based color from 6-color palette |
| `MonoText` | Extension on Text | JetBrains Mono styling for numbers/money/codes |

### 0.8.3 Bottom Navigation Overhaul

**File:** `presentation/common/widgets/app_shell.dart` — **REWRITE**

Replace current drawer navigation with 5-tab bottom nav:
| Tab | Icon | Route |
|-----|------|-------|
| Home | `LucideIcons.home` | `/` |
| Subscribers | `LucideIcons.users` | `/subscribers` |
| Reports | `LucideIcons.barChart3` | `/reports` |
| Transactions | `LucideIcons.dollarSign` | `/transactions` |
| Settings | `LucideIcons.settings` | `/settings` |

Active state: red-soft bg, red icon + label. Include AI FAB (floating action button) with BETA badge.

### 0.8.4 Context-Aware Action Matrix

Every subscriber card and detail sheet must show different actions based on status:
- **Active:** Recharge (red), Refresh (blue), Upgrade (purple), Deactivate (red-dot)
- **Deactivated:** Recharge (red), Activate (green), Refresh (blue), Upgrade (purple)
- **Fresh:** Activate (green), Add Pkg (amber), Refresh (blue), Pairing (ink-40)

### 0.8.5 Dark Theme Support

- All widgets must use theme tokens, never hardcoded colors
- Theme toggle stored in SharedPreferences key `ezyquick-theme`
- Animated theme transition
- Test every screen in both light and dark modes

---

# PHASE 1: AUTH + NAVIGATION

> Login must work correctly first — it populates the session that everything else depends on.

---

## 1.1 Login Screen Fixes

**Complexity: L** | **Gap ref:** Doc 01, Sections 1.2, 3, 4, 5, 10 | **Deps:** Phase 0

### 1.1.1 Parse all login response fields
**File:** `application/providers/auth_provider.dart` (MODIFY)
- Parse all 38+ fields from validateLogin response into `LoginResponse` model.
- Build `AppSession` from parsed data.
- **Complexity: M**

### 1.1.2 Call getaccesscontrollRest after login
**File:** `application/providers/auth_provider.dart` (MODIFY)
- After `validateLogin` succeeds, call `getAccessControl()`.
- Use inverted status_code handling: `status_code == 0` = success.
- On failure: non-blocking — log error, proceed with default access flags (all 1).
- Parse 8 access control flags, merge into `AppSession`.
- Store full session via `appSessionProvider`.
- **Complexity: M**

### 1.1.3 Fix authtoken parameter casing
**File:** `data/datasources/remote/auth_remote_datasource.dart` (MODIFY)
- Change `authToken` to `authtoken` in `getAccessControl()` body.
- **Complexity: S**

### 1.1.4 Add Remember Me checkbox
**File:** `presentation/screens/auth/login_screen.dart` (MODIFY)
- Add `Checkbox` + "Remember Me" label.
- On login success, if checked, save username to SharedPreferences.
- On screen load, pre-fill username from SharedPreferences.
- **Complexity: S**

### 1.1.5 Add network connectivity check
**File:** `presentation/screens/auth/login_screen.dart` (MODIFY)
- Before API call, check connectivity via `connectivity_plus`.
- If offline, show dialog: "No internet connection!" with Settings button.
- **Complexity: S**

### 1.1.6 Dynamic logo loading
**File:** `presentation/screens/auth/login_screen.dart` (MODIFY)
- Replace `LucideIcons.tv` with `CachedNetworkImage` loading from `APP_LOGO_PATH`.
- Fallback to app icon on error.
- **Complexity: S**

### 1.1.7 Version display from package_info
- Add `package_info_plus` to pubspec.yaml.
- Show dynamic version string instead of hardcoded `v1.0.0`.
- **Complexity: S**

---

## 1.2 Navigation Drawer

**Complexity: L** | **Gap ref:** Doc 01, Section 6 | **Deps:** 1.1

### 1.2.1 Make drawer menu dynamic
**File:** `presentation/screens/home/home_screen.dart` (MODIFY)
- Read `AppSession` from provider.
- Build menu items conditionally based on:
  - `isDistributor` flag — use distributor menu array.
  - `appMenuFormat` — "DEFAULT" vs other.
  - Access control flags:
    - `intBulkPayment == 1` → show "Make Payment"
    - `accessForComplaints == 1` → show "Complaints" (non-distributor only)
    - `intStbActivation == 1 || intStbDeactivation == 1 || intStbReactivation == 1` → show "STB Operations"
    - `intStbActivation == 1 || intStbDeactivation == 1` → show "Package Operations"
    - `stbPairing == 1 || stbUnpairing == 1` → show "Pair/Unpair" (non-distributor)
    - `lcoPaymentFlag == 1` → show "LCO Payment"
    - Non-distributor only: show "Reports"
- Add "New Customer" as always-visible item.
- **Complexity: L**

### 1.2.2 Fix drawer header
**File:** `presentation/screens/home/home_screen.dart` (MODIFY)
- Show dealer logo from `logoImg` (use `CachedNetworkImage`, fallback to initials avatar).
- Show username from session.
- Show email — if value is `"anyType{}"`, display "NA" instead.
- **Complexity: S**

### 1.2.3 Add overflow menu items
**File:** `presentation/screens/home/home_screen.dart` (MODIFY)
- AppBar overflow menu: Logout, Privacy Policy, About Us.
- Conditional: LCO Top-Up (when `showLcoTopUp` is true), LCO Payment History.
- QR/Barcode scanner icon in AppBar.
- **Complexity: M**

---

## 1.3 Dashboard Fixes

**Complexity: L** | **Gap ref:** Doc 01, Section 7 | **Deps:** 1.1

### 1.3.1 Add missing stat cards
**File:** `presentation/screens/home/widgets/dashboard_stats_row.dart` (MODIFY)
- Add cards for: Total STBs, Assigned STBs, Unassigned STBs, Total Complaints.
- Read from `DashboardResponse` typed model.
- **Complexity: M**

### 1.3.2 Fix LCO wallet visibility
**File:** `presentation/screens/home/widgets/wallet_card.dart` (MODIFY)
- Show only when `session.showWallet == true`.
- Fetch balance from `lco_deposit_amountRest` (not `outStandingAmount`).
- Add refresh button triggering `getLcoDepositAmount`.
- **Complexity: M**

### 1.3.3 Make dashboard API calls pass config params
**File:** `application/providers/dashboard_provider.dart` (MODIFY)
- Pass `useLcoDeposit` and `lcoBilltype` from session to `getDashboardDetails`.
- Conditionally call `getLcoDepositAmount` when `session.showWallet`.
- **Complexity: S**

### 1.3.4 Add expired services popup
**File:** `presentation/screens/home/home_screen.dart` (MODIFY)
- Add "Expired Services" link to dashboard.
- On tap: call `getExpiryServicesDateWiseCount`, show dialog with date/count list.
- Fix: add `authtoken` to the API request.
- **Complexity: M**

### 1.3.5 Conditional quick action visibility
**File:** `presentation/screens/home/widgets/quick_actions.dart` (MODIFY)
- Gate "Recharge" on `intBulkPayment == 1`.
- Gate STB actions on activation/deactivation/reactivation flags.
- Gate "Complaints" on `accessForComplaints == 1`.
- Add "New Customer" quick action.
- **Complexity: M**

### 1.3.6 Back press logout confirmation
**File:** `presentation/screens/home/home_screen.dart` (MODIFY)
- On back press from dashboard, show confirmation dialog: "Do you want to logout?"
- **Complexity: S**

---

# PHASE 2: CUSTOMER MANAGEMENT

> Core business flow — search, create, edit customers.

---

## 2.1 Customer Search

**Complexity: L** | **Gap ref:** Doc 02, Section 3 | **Deps:** Phase 0, Phase 1

### 2.1.1 Add all 6 search fields
**File:** `presentation/screens/customers/customer_search_screen.dart` (MODIFY)
- Add CAF/CRF number search chip and LCO Customer ID chip (total 6 chips).
- **Complexity: S**

### 2.1.2 Implement pagination with controls
**File:** `presentation/screens/customers/customer_search_screen.dart` (MODIFY)
**File:** `application/providers/customer_provider.dart` (MODIFY)
- Change `endValue` from 50 to 100 (`NUM_ITEMS_PAGE = 100`).
- Add First/Prev/Next/Last page navigation buttons.
- Calculate `pageCount = ceil(customerCount / 100)`.
- Add 10,000 count limit check — show "Large Count" dialog.
- **Complexity: M**

### 2.1.3 Result routing based on origin
**File:** `presentation/screens/customers/customer_search_screen.dart` (MODIFY)
- Accept `origin` parameter: `customerMgmt`, `payments`, `complaintMgmt`, `packageMgmt`, `stb_Map_custID`.
- On row tap, navigate to different screens based on origin:
  - `customerMgmt` → Customer Profile
  - `payments` → Make Payment (with customer context)
  - `complaintMgmt` → Complaint Operations (with customer context)
  - `packageMgmt` → Package Operations (with customer context)
  - `stb_Map_custID` → STB Operations (with customer context)
- Add `onlineCustomer + checkaddserviceaccess` guard for packageMgmt origin.
- **Complexity: L**

---

## 2.2 Customer Profile / Operations

**Complexity: L** | **Gap ref:** Doc 02, Sections 5, 9 | **Deps:** 2.1

### 2.2.1 Full profile display
**File:** `presentation/screens/customers/customer_profile_screen.dart` (MODIFY)
- Show all fields: Name, A/C, CAF/CRF (label based on `useCRF` flag), Mobile, Address, STB Count, Status, Bill Type, Pending Amount.
- **Complexity: M**

### 2.2.2 Add operation buttons with access control
**File:** `presentation/screens/customers/customer_profile_screen.dart` (MODIFY)
- Add buttons: Edit Customer, Invoice History, Payment History, Complaint History, View on Map, Update Location.
- Gate each button on access control flags.
- Pass full customer context (custId, custName, pending_amount, resellerId, billType) to all navigation targets.
- **Complexity: M**

### 2.2.3 Edit Customer screen
**File:** `presentation/screens/customers/edit_customer_screen.dart` **(NEW)**
- Full form with 20+ fields, 11 spinners, 3 checkboxes (change address, change install address, upload docs).
- Pre-populate from existing customer data.
- Account number lock when `useAccountNumber > 0`.
- Address editability toggles.
- 7 validation rules from spec.
- Call `editCustomerRest` on Update.
- **Complexity: XL**

### 2.2.4 Customer location update
**File:** `presentation/screens/customers/customer_profile_screen.dart` (MODIFY)
- Add "Update Location" button.
- Use `geolocator` to get current GPS position.
- Call `updateCustomerLocation` API.
- **Complexity: M**

---

## 2.3 New Customer Wizard

**Complexity: XL** | **Gap ref:** Doc 02, Section 4 | **Deps:** 2.1, Phase 0

### 2.3.1 Step 1: STB Scan
**File:** `presentation/screens/customers/new_customer_screen.dart` (REWRITE)
- Integrate barcode scanner (`mobile_scanner`) for STB serial number.
- Pre-fill and lock STB serial field from scanned value.
- Call `validateBoxInfoRest` to verify STB is valid and unassigned.
- **Complexity: L**

### 2.3.2 Step 2: Customer Form
**File:** `presentation/screens/customers/new_customer_screen.dart` (REWRITE)
- Implement all ~30 form fields from spec.
- Cascading address dropdowns: Country → State → District → City + Mandal.
- Use `MasterDataProvider` (new) to load/cache dropdown data.
- Dynamic form validations: call `dynamicformvalidationsRest` with `table_name: "customer_details"` and `dealerId`.
- Apply config flags: `useLastName`, `useCRF/useCAF`, `useAccountNumber`, `useMandatoryForHotel`.
- Default values from session: `defaultCountry`, `defaultState`, `defaultDistrict`, `defaultCity`.
- GPS auto-fill for latitude/longitude.
- Image capture: ID photo, customer photo, signature.
- "Same as Billing Address" checkbox.
- **Complexity: XL**

### 2.3.3 Step 3: Package Selection
**File:** `presentation/screens/customers/new_customer_package_screen.dart` **(NEW)**
- Call `getCasPackagesRest` with `boxNumber`.
- Display searchable package list.
- Activation cycle spinner: Year/Month/Day for one-time (type 1), Year only for recurring (type 2).
- Quantity field, validity days field (visible for Day cycle).
- Return selected package data to wizard.
- **Complexity: L**

### 2.3.4 Step 4: Confirmation & Save
**File:** `presentation/screens/customers/new_customer_confirm_screen.dart` **(NEW)**
- Read-only review of all fields.
- Confirm button calls `saveCustomerRest` with all 40+ fields.
- On success: show dialog with customer ID, navigate back.
- **Complexity: L**

### 2.3.5 Master Data Provider
**File:** `application/providers/master_data_provider.dart` **(NEW)**
- Manages cascading dropdown state.
- Loads and caches countries, states, districts, cities, mandals, groups, customer types, ID types, genders.
- Pre-selects default values from session.
- **Complexity: L**

---

# PHASE 3: PAYMENTS

> Revenue-critical — handles money movement.

---

## 3.1 Make Payment Screen Fixes

**Complexity: XL** | **Gap ref:** Doc 03, Sections 2.1–2.9 | **Deps:** Phase 0, Phase 1

### 3.1.1 Payment mode field visibility matrix
**File:** `presentation/screens/payments/make_payment_screen.dart` (MODIFY)
- **Cash:** Amount, Receipt Number, Remarks.
- **Bank/Cheque:** Amount, Receipt Number, Cheque No, Bank Name, Branch, Cheque Date, Remarks.
- **Card:** Amount, Receipt Number, Card Type (debit/credit), Cardholder Name, RRN No, Remarks.
- **Voucher:** Voucher Code (amount set to 0), Remarks.
- **UPI Payment:** Amount, Remarks, QR Code image display.
- Show/hide fields dynamically based on `_selectedPaymentMode`.
- **Complexity: L**

### 3.1.2 Forward mode-specific fields through provider
**File:** `application/providers/payment_provider.dart` (MODIFY)
- Add params: `chequeNo`, `bank`, `branch`, `chequeDate`, `voucherCode`, `rrnNo`, `cardholderName`, `altReceiptNumber`, `imei`.
- Forward to datasource.
- **Complexity: M**

### 3.1.3 AUTO_RECEIPT_NUMBER logic
**File:** `presentation/screens/payments/make_payment_screen.dart` (MODIFY)
- Read `autoReceiptNumber` from session.
- When `== 0`: hide manual receipt field, call `getReceiptRanges`, show searchable grid picker.
- When `== 1`: show manual receipt entry for Cash/UPI modes only.
- **Complexity: M**

### 3.1.4 Amount vs pending validation
**File:** `presentation/screens/payments/make_payment_screen.dart` (MODIFY)
- Amount < pending: block with "Invalid Amount" alert (when `useLcoDeposit == 0`).
- Amount > pending: show "Excess amount" confirmation dialog.
- Amount == pending: proceed.
- When `useLcoDeposit == 1`: amount field disabled, locked to pending amount.
- **Complexity: M**

### 3.1.5 Block payment check
**File:** `presentation/screens/payments/make_payment_screen.dart` (MODIFY)
- Check `session.blockpayment` before allowing entry to screen.
- **Complexity: S**

### 3.1.6 Post-payment receipt navigation
**File:** `presentation/screens/payments/make_payment_screen.dart` (MODIFY)
- On success, navigate to Display Payment Details (3.2) instead of just showing a SnackBar.
- **Complexity: S**

---

## 3.2 Payment Receipt Screen (Display Payment Details)

**Complexity: M** | **Gap ref:** Doc 03, Section 3.11 | **Deps:** 3.1

**File:** `presentation/screens/payments/payment_receipt_screen.dart` **(NEW)**
- Shows: Customer Name, ID, Mobile, Address, Receipt No, Due Amount, Paid Amount, Payment Mode, Date.
- Print button (BLE thermal — stub until Phase 8).
- Share button (PDF via `printing` package).
- **Complexity: M**

---

## 3.3 Payment History Screen

**Complexity: L** | **Gap ref:** Doc 03, Section 3.1 | **Deps:** Phase 0

**File:** `presentation/screens/payments/payment_history_screen.dart` **(NEW)**
- Receives `customerId` via route.
- Calls `PaymentServiceRest`.
- ListView: `paid_on`, `paid_amount`, `receipt_no`, `payment_mode`, `payment_id`, `remarks`.
- Total count label.
- Print and Share per row.
- **Complexity: L**

---

## 3.4 Invoice History Screen

**Complexity: L** | **Gap ref:** Doc 03, Section 3.2 | **Deps:** Phase 0

**File:** `presentation/screens/payments/invoice_history_screen.dart` **(NEW)**
- New datasource method for `InvoiceServiceRest`.
- ListView: `billing_id`, `bill_date`, `due_date`, `total_amount`, `quantity`, `base_price`, `serial_number`, `mac_vc_number`, `pname`, `setup_price`, `tax_amount`, `pending_amount`, `discount_amount`.
- Print per row.
- **Complexity: L**

**File:** `data/datasources/remote/payment_remote_datasource.dart` (MODIFY)
- Add `getInvoiceHistory(customerId)` method.
- **Complexity: S**

---

## 3.5 Payment WebView / PG Integration

**Complexity: L** | **Gap ref:** Doc 03, Sections 3.8, 3.9 | **Deps:** Phase 0

**File:** `presentation/screens/payments/payment_webview_screen.dart` **(NEW)**
- WebView loading server-hosted PG page.
- POST params: `auth_key`, `employee_id`, `dealer_id`, `customer_id`, `amount`, `from_mobile_app`.
- URL interception for UPI intents and redirect detection.
- Back button blocked during transaction.
- **Complexity: L**

**File:** `presentation/screens/payments/payment_response_screen.dart` **(NEW)**
- New datasource method for `customer_transaction_reponseRest`.
- Shows success/fail icon, transaction ID, amount, customer name.
- **Complexity: M**

---

## 3.6 PG Transaction Report

**Complexity: M** | **Gap ref:** Doc 03, Section 3.6 | **Deps:** Phase 0

**File:** `presentation/screens/payments/pg_transaction_report_screen.dart` **(NEW)**
- New datasource method for `pgTransactionLogs`.
- Status filter spinner (All/Success/Fail).
- ListView with `PgTransaction` model fields.
- **Complexity: M**

---

# PHASE 4: STB + PACKAGE OPERATIONS

---

## 4.1 STB Operations Fixes

**Complexity: L** | **Gap ref:** Doc 05, Sections 3, 4, 8, 9 | **Deps:** Phase 0, Phase 1

### 4.1.1 Fix deactivation API call
**File:** `data/datasources/remote/stb_remote_datasource.dart` (MODIFY)
- Add missing params: `from_mobileapp: 1`, `serialNumber`, `vcNumber`, `boxNumber`, `macAddress`, `stockId`, `deviceId`, `backEndSetupId`, `dealer_id`, `reseller_id`.
- Append remarks suffix: `". Box Deactivation from Flutter app"`.
- Add `showforlco` and `stockId` to `getDeactivationReasons` call.
- **Complexity: M**

### 4.1.2 Filter reason ID 17
**File:** `presentation/screens/stb/stb_operations_screen.dart` (MODIFY)
- Filter out `reasonId == 17` from deactivation reasons dropdown.
- Apply `global_reason` / `disable_for_dpo` filtering based on user type.
- **Complexity: S**

### 4.1.3 Fix reactivation API call
**File:** `data/datasources/remote/stb_remote_datasource.dart` (MODIFY)
- Add `reinitialize: 1` plus all missing params: `serialNumber`, `boxNumber`, `macAddress`, `stockId`, `deviceId`, `backEndSetupId`.
- **Complexity: S**

### 4.1.4 Implement status_code checking
**File:** `application/providers/stb_provider.dart` (MODIFY)
- Check `status_code` in all responses. `status_code == 1` = success for REST API.
- Show server's `status_msg` instead of hardcoded success messages.
- Handle `status_code >= 2` as "Contact Support".
- **Complexity: M**

### 4.1.5 Config flag-driven button visibility
**File:** `presentation/screens/stb/stb_operations_screen.dart` (MODIFY)
- Gate Activate on `intStbActivation == 1`.
- Gate Deactivate on `intStbDeactivation == 1`.
- Gate Reactivate on `intStbReactivation == 1`.
- **Complexity: S**

### 4.1.6 Track is_temp_deactivated state
**File:** `application/providers/stb_provider.dart` (MODIFY)
- Parse `is_temp_deactivated` from deactivation response.
- Store in `StbState`.
- Show "Temporary Activate STB" button when `is_temp_deactivated == 1`.
- **Complexity: M**

---

## 4.2 STB Pair/Unpair Screen

**Complexity: L** | **Gap ref:** Doc 05, Section 6 | **Deps:** Phase 0

**File:** `presentation/screens/stb/stb_pair_unpair_screen.dart` **(NEW)**
- Two tabs: Pair, Unpair. Tab visibility from `stbPairing` and `stbUnpairing` flags.
- Pair tab: Serial Number + VC Number input fields, barcode scanner integration, Pair button.
- Unpair tab: Serial Number input, barcode scanner, Unpair button.
- Fix field names: Pair sends `serialNumber`, `vcNumber` (not `stb_no`, `vc_no`, `customer_id`).
- Unpair sends only `serialNumber` (not `customer_id`, `stb_no`).
- Navigate to home on success.
- **Complexity: L**

---

## 4.3 STB Replacement Screen

**Complexity: L** | **Gap ref:** Doc 05, Section 7 | **Deps:** Phase 0

**File:** `presentation/screens/stb/stb_replacement_screen.dart` **(NEW)**
- Form: Old STB details (read-only from `getCustomerParticularBoxDetailsRest`), New STB serial/VC input, Replacement Type spinner, Amount, Receipt Number, Remarks, Pair Condition checkbox.
- Fix datasource to send all required params.
- Add provider method for replacement.
- **Complexity: L**

---

## 4.4 Temporary Activation

**Complexity: M** | **Gap ref:** Doc 05, Section 5 | **Deps:** 4.1

**File:** `presentation/screens/stb/stb_operations_screen.dart` (MODIFY)
- Add "Temporary Activate" button when `is_temp_deactivated == 1`.
- Fires immediately on tap — NO confirmation dialog.
- Fix datasource: use `customerId` and `stockId` (not `customer_id`, `stb_no`, `days`).
- Add provider method calling `temporaryActivation`.
- **Complexity: M**

---

## 4.5 Package Operations Fixes

**Complexity: XL** | **Gap ref:** Doc 06, Sections 2–5, 9 | **Deps:** Phase 0

### 4.5.1 4-tab category display
**File:** `presentation/screens/packages/package_operations_screen.dart` (MODIFY)
- Replace 2-tab (Assigned/Available) with proper display:
  - Activation view: 4 tabs — Base, Add-On, A-La-Carte, Broadcaster (from `packageList_base`, `packageList_addon`, `packageList_ala`, `packageList_broadcaster`).
  - Deactivation view: Same 4 tabs.
- Multi-select checkboxes per package.
- Search bar filtering active tab's list.
- **Complexity: L**

### 4.5.2 Two-step activation flow
**File:** `presentation/screens/packages/package_operations_screen.dart` (MODIFY)
- Step 1: Select packages across tabs, tap "Save".
- Step 2: Summary dialog with names, computed start/end dates, prices, total.
- "Get Bill" button calls `getbilldetailsRest`.
- Bill breakdown: lco_share, mso_share, NCF, ENCF, total.
- "Activate" button appears after bill fetch succeeds.
- Final confirmation dialog before `activateServiceRest`.
- Fix activation API: send all required params (authToken, customerId, productId comma-separated, customerDeviceId, quantity=1, dateType, pricingStructureType, validityDays, stockId, fromMobileApp=1, dealer_id, reseller_id, login_employee_id).
- **Complexity: XL**

### 4.5.3 Deactivation with reason selection
**File:** `presentation/screens/packages/package_operations_screen.dart` (MODIFY)
- Load deactivation reasons, filter out ID 21, 17, and `global_reason == 1`.
- Reason dropdown + mandatory remarks field.
- Append `.Deactivation From Flutter App` to remarks.
- Send `serviceId` (comma-separated customer service IDs), NOT `package_id`.
- Fix all missing params in `deactivateServiceRest`.
- **Complexity: L**

### 4.5.4 Renewal flow
**File:** `presentation/screens/packages/package_renewal_screen.dart` **(NEW)**
- Visible when `isexpired == 1` AND `patchInformation` matches version gate.
- Fetch `getRenewServicesList` with `dealer_id`.
- Multi-select checkboxes.
- Collect `customer_service_id` and `product_id` as comma-separated strings.
- Summary dialog, submit via `renewServicesList`.
- **Complexity: L**

### 4.5.5 Package provider expansion
**File:** `application/providers/package_provider.dart` (MODIFY)
- Add state fields: 4 category lists for assigned, 4 for available, deactivationReasons, selectedPackageIds, billDetails, renewableServices, channelList.
- Add methods: `loadBillDetails()`, `loadDeactivationReasons()`, `loadRenewableServices()`, `submitRenewal()`, `loadChannelList()`.
- **Complexity: L**

---

# PHASE 5: COMPLAINTS

---

## 5.1 Complaint Screen Fixes

**Complexity: L** | **Gap ref:** Doc 04, Sections 3, 6, 7, 8, 9, 11 | **Deps:** Phase 0, Phase 1

### 5.1.1 Subcategory cascade
**File:** `presentation/screens/complaints/complaint_screen.dart` (MODIFY)
- On category selection, call `getComplaintsubCategory` API.
- Show subcategory dropdown. If subcategory selected, send its ID as `category`.
- **Complexity: M**

### 5.1.2 Employee assignment dropdown
**File:** `presentation/screens/complaints/complaint_screen.dart` (MODIFY)
- Load employee list from `getLcoEmployeeList`.
- Show employee dropdown on create complaint form.
- Pass `assignedTo` to provider.
- **Complexity: M**

### 5.1.3 Description suffixes
- On create: append `.Complaint Created from Flutter app` to complaint text.
- On update: append `.Complaint Status Change From Flutter app` to comment.
- On display: strip `.Complaint Created from Android app` and `.Complaint Created from Flutter app` from all displayed descriptions.
- **Complexity: S**

### 5.1.4 Status 5-color mapping
**File:** `presentation/screens/complaints/complaint_screen.dart` (MODIFY)
- Create `getStatusColor(String status)`:
  - `Assigned` → `#08C889` (green)
  - `resolved` → `#08C889` (green)
  - `inprocess` → `#00BEB7` (teal)
  - `onhold` → `#E67E22` (orange)
  - `closed` → `#E74C3C` (red)
  - default → `#0875C8` (blue)
- Case-insensitive matching. Replace current binary color logic.
- **Complexity: S**

### 5.1.5 TEAMLEAD restriction
**File:** `presentation/screens/complaints/complaint_screen.dart` (MODIFY)
- When `userType == "TEAMLEAD"`:
  - Open complaints list: show service employee filter spinner.
  - Update complaint: mandatory service employee selection.
- Load service employee list from API.
- **Complexity: M**

### 5.1.6 Receive customer context from navigation
**File:** `presentation/screens/complaints/complaint_screen.dart` (MODIFY)
- Accept `custId`, `custName`, `resellerId` from route params.
- Pre-fill customer ID (read-only) instead of manual text input.
- Display customer name and CAF as read-only.
- **Complexity: M**

### 5.1.7 Fix close complaint API
**File:** `data/datasources/remote/complaint_remote_datasource.dart` (MODIFY)
**File:** `application/providers/complaint_provider.dart` (MODIFY)
- Add missing params: `ticketNumber`, `status`, `assignedemp`.
- Change key `remarks` to `comment`.
- Add comment suffix.
- **Complexity: M**

### 5.1.8 Show ticket number and detail dialog
**File:** `presentation/screens/complaints/complaint_screen.dart` (MODIFY)
- Display `tkt_number` (not `complaint_id`) as primary identifier.
- Add "Update" button per row navigating to update screen.
- Add detail dialog on tap: ticket number, description (stripped), customer account ID, CAF.
- **Complexity: M**

---

## 5.2 Complaint History Screen

**Complexity: M** | **Gap ref:** Doc 04, Section 5 | **Deps:** Phase 0

**File:** `presentation/screens/complaints/complaint_history_screen.dart` **(NEW)**
- Receives `customerId` via route.
- Calls `ComplaintHistoryRest` with `dealer_id` and `customer_id` (NOT `complaintId` — fix existing datasource params).
- Shows "Total Complaints - N" label.
- List: ticket number, date, category, description, status.
- **Complexity: M**

---

## 5.3 Close/Update Complaint Screen

**Complexity: L** | **Gap ref:** Doc 04, Section 4 | **Deps:** 5.1

**File:** `presentation/screens/complaints/update_complaint_screen.dart` **(NEW)**
- Displays: customer name, ticket number, complaint text (stripped), current status.
- Status spinner loaded from `complaintTypesRest`.
- Mandatory comment field.
- Service employee spinner (mandatory for TEAMLEAD).
- Sends: `complaintId`, `ticketNumber`, `comment` (with suffix), `status`, `assignedemp`.
- **Complexity: L**

---

# PHASE 6: REPORTS

---

## 6.1 Mini Day Report Fix

**Complexity: L** | **Gap ref:** Doc 07, Section 3 | **Deps:** Phase 0

**File:** `presentation/screens/reports/reports_screen.dart` (REWRITE as hub)
**File:** `presentation/screens/reports/mini_day_report_screen.dart` **(NEW)**
- Auto-fetches today's date (NOT user-selectable).
- Fix API param: change `report_date` to `date`.
- Use correct data model: `List<MiniDayReportRow>` with `payment_mode`, `cust_count`, `total`.
- ListView with columns.
- Footer: grand total (sum of all `total`), formatted `₹ X,XX,XXX.00`.
- Print button (stub for Phase 8).
- **Complexity: L**

---

## 6.2 Employee Collection Summary

**Complexity: L** | **Gap ref:** Doc 07, Sections 4, 5 | **Deps:** Phase 0

**File:** `presentation/screens/reports/emp_collection_filter_screen.dart` **(NEW)**
- Two individual date pickers (start, end), both default to today.
- Validation: no future dates, end >= start.
- Fix API params: `fromDate`/`toDate` (camelCase), add `imei`.
- Search navigates to summary list screen.
- **Complexity: M**

**File:** `presentation/screens/reports/emp_collection_list_screen.dart` **(NEW)**
- Receives `collResultList`, `fromDate`, `toDate`.
- ListView: employee `name`, `Amt`.
- Footer: grand total.
- Row tap calls `empCustomerCollectionDetailsRest`, navigates to detail screen.
- Print button with receipt layout.
- Fix API: fix param keys to camelCase; do NOT send `employee_id`.
- **Complexity: L**

---

## 6.3 Employee Collection Details

**Complexity: M** | **Gap ref:** Doc 07, Section 6 | **Deps:** 6.2

**File:** `presentation/screens/reports/emp_collection_detail_screen.dart` **(NEW)**
- Receives collection details via route args (no API call).
- ListView: `customer_id`, `customer_name`, `paid_amount`, `paid_on`, `payment_mode`, `payment_id`.
- Print button.
- "View Maps" button (stub until Phase 8).
- **Complexity: M**

---

## 6.4 Report Export/Download

**Complexity: M** | **Gap ref:** Doc 07, Section 7 | **Deps:** 6.2

- Add `empCollectionReportDownload` to `ApiConstants`.
- New datasource method with `ResponseType.bytes` for CSV/Excel download.
- Download trigger button in collection summary screen.
- Save to device downloads folder.
- **Complexity: M**

---

# PHASE 7: LCO OPERATIONS

---

## 7.1 LCO Payment Screen

**Complexity: L** | **Gap ref:** Doc 09, Section 1 | **Deps:** Phase 0, Phase 1

**File:** `presentation/screens/lco/lco_payment_screen.dart` **(NEW)**
**File:** `data/datasources/remote/lco_remote_datasource.dart` **(NEW)**
**File:** `application/providers/lco_payment_provider.dart` **(NEW)**

- Two-phase UI: LCO code search panel → payment entry panel.
- Confirm REST equivalents of `getlcoadvanceamountdue` and `lcopaymentfunc` with server team.
- LCO search: send `authToken`, `employee_id`, `lco_code`.
- Payment form: amount, mode (Cash/Bank), adjustment checkbox with credit/debit, bank fields (conditional on Bank mode), remarks.
- Validation: LCO code non-empty, amount non-zero, remarks mandatory, bank fields required when Bank mode.
- **Complexity: L**

**BLOCKER:** REST endpoints not yet confirmed — coordinate with server team.

---

## 7.2 LCO Wallet Top-up

**Complexity: M** | **Gap ref:** Doc 09, Section 2 | **Deps:** Phase 0

**File:** `presentation/screens/lco/lco_topup_screen.dart` **(NEW)**
- Display LCO name from session, current wallet balance from dashboard provider.
- Amount input with validation (> 0).
- "Pay Now" navigates to Payment WebView (from Phase 3.5).
- Visibility: `session.showLcoTopUp` must be true.
- **Complexity: M**

---

## 7.3 LCO Wallet History

**Complexity: M** | **Gap ref:** Doc 09, Section 3 | **Deps:** Phase 0

**File:** `presentation/screens/lco/lco_wallet_history_screen.dart` **(NEW)**
- Date range picker.
- Calls existing `getLcoWallet` in dashboard datasource.
- ListView with `LcoWalletEntry` model fields (14 fields).
- Total count header.
- **Complexity: M**

---

# PHASE 8: HARDWARE INTEGRATION

---

## 8.1 BLE Printer

**Complexity: XL** | **Gap ref:** Doc 08, Sections 1–3 | **Deps:** Phase 0

### 8.1.1 Add Bluetooth package
- Add `flutter_blue_plus` (or `flutter_bluetooth_serial`) to `pubspec.yaml`.
- **Complexity: S**

### 8.1.2 Bluetooth service
**File:** `core/services/bluetooth_print_service.dart` **(NEW)**
- Connection states: NONE, LISTENING, CONNECTING, CONNECTED.
- Device discovery, pairing.
- RFCOMM socket connection.
- Write bytes to printer.
- Store selected printer MAC in SharedPreferences key `bluetoothmac`.
- **Complexity: XL**

### 8.1.3 Device discovery & paired device screens
**File:** `presentation/screens/bluetooth/device_discovery_screen.dart` **(NEW)**
**File:** `presentation/screens/bluetooth/paired_device_list_screen.dart` **(NEW)**
- Scan for nearby Bluetooth devices.
- Show paired devices list.
- Select and connect to a printer.
- **Complexity: L**

### 8.1.4 ESC/POS commands
**File:** `core/services/esc_pos_commands.dart` **(NEW)**
- Font command byte arrays (`bufLinear` indices 1–16).
- Line separator widths: 32 dots for 58mm, 40 dashes for 80mm.
- **Complexity: M**

### 8.1.5 Receipt formatter — all 9 formats
**File:** `core/services/receipt_formatter.dart` **(NEW)**
- DEFAULT payment receipt (58mm/80mm)
- FORMAT1 payment receipt (cheque)
- Legacy payment receipt (ESC/POS)
- Payment history receipt
- Invoice history receipt
- Employee collection report
- Collection report
- Miniday report
- Services/packages report
- Printer model detection: `ANTHERMAL` prefix → 58mm, `97BT-` prefix → 80mm.
- Pagination for batch reports: flush every 15 rows with 3-second delay.
- String formatting: `fixedLengthString`, left-align, right-align.
- **Complexity: XL**

---

## 8.2 Barcode Scanner

**Complexity: M** | **Gap ref:** Doc 08, Section 4 | **Deps:** Phase 0

**File:** `presentation/screens/scanner/barcode_scanner_screen.dart` **(NEW)**
- Uses `MobileScanner` widget (already in pubspec: `mobile_scanner: ^7.2.0`).
- On scan: call `getCustomerDetailsCountRest` with `boxNumber = scannedValue`.
- Navigate to customer search results.
- Pass `origin` parameter for routing.
- Handle camera permission via `permission_handler`.
- **Complexity: M**

---

## 8.3 GPS / Maps

**Complexity: L** | **Gap ref:** Doc 08, Section 6 | **Deps:** Phase 0

### 8.3.1 Configure Google Maps API key
- `android/app/src/main/AndroidManifest.xml` — add API key.
- `ios/Runner/AppDelegate.swift` — add API key.
- **Complexity: S**

### 8.3.2 Employee tracking map
**File:** `presentation/screens/employees/employee_tracking_screen.dart` (REWRITE)
- Replace placeholder with actual `GoogleMap` widget.
- Implement `getEmployeeTrackInfo` REST API call.
- Display markers (green first, azure subsequent) with polylines.
- **Complexity: L**

### 8.3.3 Customer location capture
**File:** `presentation/screens/customers/customer_profile_screen.dart` (MODIFY — already in 2.2.4)
- Use `geolocator` for current position.
- Call `updateCustomerLocation` REST endpoint.
- **Complexity: M**

---

## 8.4 Signature Capture

**Complexity: M** | **Gap ref:** Doc 08, Section 5 | **Deps:** Phase 0

**File:** `presentation/widgets/signature_pad.dart` **(NEW)**
- `CustomPainter` + `GestureDetector`.
- Touch: ACTION_DOWN → moveTo, ACTION_MOVE → lineTo.
- Canvas: 600x320, stroke width 5.0, black, round joins.
- Actions: Clear, Save (as PNG bytes), Cancel.
- Integration: New Customer screen and payment transaction flow.
- **Complexity: M**

---

# PHASE 9: SETTINGS + POLISH

---

## 9.1 Settings Screen

**Complexity: L** | **Gap ref:** Doc 08, Sections 12, 7 | **Deps:** Phase 0

**File:** `presentation/screens/settings/settings_screen.dart` (MODIFY)

### 9.1.1 Password change
**File:** `presentation/screens/settings/change_password_screen.dart` **(NEW)**
- Old password + new password fields.
- Add password change REST endpoint to `ApiConstants`.
- **Complexity: M**

### 9.1.2 Bluetooth printer management
- Link to paired device list screen (from Phase 8).
- Show currently connected printer name/MAC.
- **Complexity: S**

### 9.1.3 Theme selection
- 5 themes from `APP_THEME` (1–5): Default, Red, Green, Blue, Purple.
- Persist in SharedPreferences.
- Create `ThemeProvider`.
- **Complexity: M**

### 9.1.4 Server URL configuration
- Make base URL configurable (for multi-tenant support).
- Store in SharedPreferences under `login_url`.
- **Complexity: S**

### 9.1.5 About/Privacy screens
**File:** `presentation/screens/settings/about_screen.dart` **(NEW)**
**File:** `presentation/screens/settings/privacy_policy_screen.dart` **(NEW)**
- WebView loading privacy policy URL.
- About page with app info.
- **Complexity: S**

---

## 9.2 App Version Check

**Complexity: M** | **Gap ref:** Doc 08, Section 11 | **Deps:** Phase 0

- Add `package_info_plus` to pubspec.yaml.
- Create version check service calling server endpoint before login.
- `statusCode == 0`: proceed.
- `statusCode == 1`: non-dismissible update dialog with Play Store link.
- `statusCode == 3`: "Server is busy" — close app.
- **Complexity: M**

---

## 9.3 Network Connectivity Handling

**Complexity: M** | **Gap ref:** Doc 01, Section 5.2 (login); Doc 10, Section 5.1 | **Deps:** Phase 0

**File:** `core/network/network_info.dart` **(NEW)**
- Wraps `connectivity_plus`.
- `isConnected` getter.
- Stream listener for connectivity changes.

**File:** `presentation/common/widgets/offline_banner.dart` **(NEW)**
- Persistent banner shown when offline.

- Add connectivity check before every critical API call.
- Show "No internet connection!" dialog with Settings button.
- **Complexity: M**

---

## 9.4 Session Timeout

**Complexity: M** | **Gap ref:** Doc 10, Section 5.2 | **Deps:** Phase 0

**File:** `core/network/dio_client.dart` (MODIFY)
- Connect `onAuthFailure` callback to `ref.read(authProvider.notifier).logout()`.
- On 401 response: show "Session expired" snackbar, navigate to login.
- **Complexity: M**

---

# APPENDIX A: Complete File Manifest

Every file that should exist in `lib/` when all phases are complete.

```
lib/
├── main.dart                                                 # EXISTS — add version check, session restore
│
├── core/
│   ├── config/
│   │   └── app_session.dart                                  # NEW (Phase 0.3)
│   │   └── app_session.freezed.dart                          # GENERATED
│   │   └── app_session.g.dart                                # GENERATED
│   ├── constants/
│   │   ├── api_constants.dart                                # EXISTS — add missing endpoints
│   │   ├── app_constants.dart                                # EXISTS — expand SharedPrefs keys
│   │   └── ui_constants.dart                                 # NEW (Phase 0.1)
│   ├── network/
│   │   ├── api_exception.dart                                # EXISTS
│   │   ├── dio_client.dart                                   # EXISTS — add authtoken interceptor, session timeout
│   │   ├── network_info.dart                                 # NEW (Phase 9.3)
│   │   ├── payload_encryption.dart                           # EXISTS
│   │   └── result.dart                                       # NEW (Phase 0.5)
│   ├── services/
│   │   ├── bluetooth_print_service.dart                      # NEW (Phase 8.1)
│   │   ├── esc_pos_commands.dart                             # NEW (Phase 8.1)
│   │   └── receipt_formatter.dart                            # NEW (Phase 8.1)
│   ├── theme/
│   │   ├── app_colors.dart                                   # EXISTS
│   │   └── app_theme.dart                                    # EXISTS — add 5 theme variants
│   └── utils/
│       ├── currency_formatter.dart                           # NEW (Phase 0.4)
│       ├── date_formatters.dart                              # NEW (Phase 0.4)
│       ├── parse_utils.dart                                  # NEW (Phase 0.4)
│       ├── print_formatters.dart                             # NEW (Phase 0.4)
│       ├── string_extensions.dart                            # NEW (Phase 0.4)
│       └── validators.dart                                   # NEW (Phase 0.4)
│
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── auth_local_datasource.dart                    # EXISTS — expand to persist all session fields
│   │   │   └── cache_local_datasource.dart                   # NEW (Phase 0.5)
│   │   └── remote/
│   │       ├── auth_remote_datasource.dart                   # EXISTS — fix param casing
│   │       ├── complaint_remote_datasource.dart              # EXISTS — fix params
│   │       ├── customer_remote_datasource.dart               # EXISTS — fix params
│   │       ├── dashboard_remote_datasource.dart              # EXISTS
│   │       ├── employee_remote_datasource.dart               # EXISTS
│   │       ├── lco_remote_datasource.dart                    # NEW (Phase 7.1)
│   │       ├── master_data_remote_datasource.dart            # EXISTS — add getGenders, fix params
│   │       ├── package_remote_datasource.dart                # EXISTS — fix params, add getBillDetails
│   │       ├── payment_remote_datasource.dart                # EXISTS — add invoice, PG methods
│   │       ├── report_remote_datasource.dart                 # EXISTS — fix param keys
│   │       └── stb_remote_datasource.dart                    # EXISTS — fix params
│   ├── models/
│   │   ├── auth/
│   │   │   ├── login_response.dart                           # NEW (Phase 0.2)
│   │   │   └── access_control_response.dart                  # NEW (Phase 0.2)
│   │   ├── dashboard/
│   │   │   ├── dashboard_response.dart                       # NEW (Phase 0.2)
│   │   │   ├── wallet_response.dart                          # NEW (Phase 0.2)
│   │   │   └── expiry_services_response.dart                 # NEW (Phase 0.2)
│   │   ├── customer/
│   │   │   ├── customer_model.dart                           # NEW (Phase 0.2)
│   │   │   ├── save_customer_request.dart                    # NEW (Phase 0.2)
│   │   │   ├── edit_customer_request.dart                    # NEW (Phase 0.2)
│   │   │   └── form_validation.dart                          # NEW (Phase 0.2)
│   │   ├── complaint/
│   │   │   ├── complaint_model.dart                          # NEW (Phase 0.2)
│   │   │   ├── complaint_category.dart                       # NEW (Phase 0.2)
│   │   │   └── complaint_subcategory.dart                    # NEW (Phase 0.2)
│   │   ├── payment/
│   │   │   ├── payment_mode.dart                             # NEW (Phase 0.2)
│   │   │   ├── pending_amount.dart                           # NEW (Phase 0.2)
│   │   │   ├── make_payment_request.dart                     # NEW (Phase 0.2)
│   │   │   ├── payment_history.dart                          # NEW (Phase 0.2)
│   │   │   ├── invoice_model.dart                            # NEW (Phase 0.2)
│   │   │   ├── pg_transaction_model.dart                     # NEW (Phase 0.2)
│   │   │   ├── receipt_range.dart                            # NEW (Phase 0.2)
│   │   │   └── bill_detail.dart                              # NEW (Phase 0.2)
│   │   ├── stb/
│   │   │   ├── stb_model.dart                                # NEW (Phase 0.2)
│   │   │   ├── deactivation_reason.dart                      # NEW (Phase 0.2)
│   │   │   └── stb_replacement_request.dart                  # NEW (Phase 0.2)
│   │   ├── package/
│   │   │   ├── package_model.dart                            # NEW (Phase 0.2)
│   │   │   └── cas_package.dart                              # NEW (Phase 0.2)
│   │   ├── report/
│   │   │   ├── mini_day_report_row.dart                      # NEW (Phase 0.2)
│   │   │   ├── emp_collection_summary.dart                   # NEW (Phase 0.2)
│   │   │   └── emp_collection_detail.dart                    # NEW (Phase 0.2)
│   │   ├── master_data/
│   │   │   ├── country.dart                                  # NEW (Phase 0.2)
│   │   │   ├── state_model.dart                              # NEW (Phase 0.2)
│   │   │   ├── district.dart                                 # NEW (Phase 0.2)
│   │   │   ├── city.dart                                     # NEW (Phase 0.2)
│   │   │   ├── mandal.dart                                   # NEW (Phase 0.2)
│   │   │   ├── group.dart                                    # NEW (Phase 0.2)
│   │   │   ├── customer_type.dart                            # NEW (Phase 0.2)
│   │   │   ├── customer_type_type.dart                       # NEW (Phase 0.2)
│   │   │   ├── id_type.dart                                  # NEW (Phase 0.2)
│   │   │   └── gender.dart                                   # NEW (Phase 0.2)
│   │   ├── employee/
│   │   │   ├── employee.dart                                 # NEW (Phase 0.2)
│   │   │   └── service_employee.dart                         # NEW (Phase 0.2)
│   │   └── lco/
│   │       ├── lco_wallet_entry.dart                         # NEW (Phase 0.2)
│   │       └── lco_payment_request.dart                      # NEW (Phase 0.2)
│   └── repositories/
│       ├── auth_repository_impl.dart                         # NEW (Phase 0.5)
│       ├── dashboard_repository_impl.dart                    # NEW (Phase 0.5)
│       ├── customer_repository_impl.dart                     # NEW (Phase 0.5)
│       ├── complaint_repository_impl.dart                    # NEW (Phase 0.5)
│       ├── payment_repository_impl.dart                      # NEW (Phase 0.5)
│       ├── stb_repository_impl.dart                          # NEW (Phase 0.5)
│       ├── package_repository_impl.dart                      # NEW (Phase 0.5)
│       ├── report_repository_impl.dart                       # NEW (Phase 0.5)
│       ├── employee_repository_impl.dart                     # NEW (Phase 0.5)
│       └── master_data_repository_impl.dart                  # NEW (Phase 0.5)
│
├── domain/
│   ├── entities/
│   │   ├── user.dart                                         # NEW (Phase 0.5)
│   │   ├── customer.dart                                     # NEW (Phase 0.5)
│   │   ├── complaint.dart                                    # NEW (Phase 0.5)
│   │   ├── payment.dart                                      # NEW (Phase 0.5)
│   │   ├── stb_box.dart                                      # NEW (Phase 0.5)
│   │   ├── tv_package.dart                                   # NEW (Phase 0.5)
│   │   ├── employee_info.dart                                # NEW (Phase 0.5)
│   │   └── daily_report.dart                                 # NEW (Phase 0.5)
│   └── repositories/
│       ├── auth_repository.dart                              # NEW (Phase 0.5)
│       ├── dashboard_repository.dart                         # NEW (Phase 0.5)
│       ├── customer_repository.dart                          # NEW (Phase 0.5)
│       ├── complaint_repository.dart                         # NEW (Phase 0.5)
│       ├── payment_repository.dart                           # NEW (Phase 0.5)
│       ├── stb_repository.dart                               # NEW (Phase 0.5)
│       ├── package_repository.dart                           # NEW (Phase 0.5)
│       ├── report_repository.dart                            # NEW (Phase 0.5)
│       ├── employee_repository.dart                          # NEW (Phase 0.5)
│       └── master_data_repository.dart                       # NEW (Phase 0.5)
│
├── application/
│   ├── providers/
│   │   ├── auth_provider.dart                                # EXISTS — modify for session
│   │   ├── complaint_provider.dart                           # EXISTS — expand methods
│   │   ├── core_providers.dart                               # EXISTS — add session provider
│   │   ├── customer_provider.dart                            # EXISTS — add pagination
│   │   ├── dashboard_customer_list_provider.dart             # EXISTS
│   │   ├── dashboard_provider.dart                           # EXISTS — pass config params
│   │   ├── employee_provider.dart                            # EXISTS
│   │   ├── lco_payment_provider.dart                         # NEW (Phase 7.1)
│   │   ├── master_data_provider.dart                         # NEW (Phase 2.3)
│   │   ├── package_provider.dart                             # EXISTS — expand state
│   │   ├── payment_provider.dart                             # EXISTS — forward all params
│   │   ├── report_provider.dart                              # EXISTS — fix models
│   │   ├── session_provider.dart                             # NEW (Phase 0.3)
│   │   └── stb_provider.dart                                 # EXISTS — add temp activation
│   └── states/                                               # NEW directory
│       └── (states extracted from providers as needed)
│
└── presentation/
    ├── common/widgets/
    │   ├── app_shell.dart                                    # EXISTS
    │   ├── action_chip_button.dart                           # NEW (Phase 0.7)
    │   ├── cascading_dropdown.dart                           # NEW (Phase 0.7)
    │   ├── confirmation_dialog.dart                          # NEW (Phase 0.7)
    │   ├── customer_info_card.dart                           # NEW (Phase 0.7)
    │   ├── date_range_selector.dart                          # NEW (Phase 0.7)
    │   ├── empty_state.dart                                  # NEW (Phase 0.7)
    │   ├── error_state.dart                                  # NEW (Phase 0.7)
    │   ├── form_field_wrapper.dart                           # NEW (Phase 0.7)
    │   ├── loading_state.dart                                # NEW (Phase 0.7)
    │   ├── offline_banner.dart                               # NEW (Phase 9.3)
    │   ├── paginated_list_view.dart                          # NEW (Phase 0.7)
    │   ├── receipt_preview_card.dart                         # NEW (Phase 0.7)
    │   ├── search_bar_with_debounce.dart                     # NEW (Phase 0.7)
    │   ├── section_header.dart                               # NEW (Phase 0.7)
    │   ├── stat_card.dart                                    # NEW (Phase 0.7)
    │   ├── status_badge.dart                                 # NEW (Phase 0.7)
    │   └── stb_detail_card.dart                              # NEW (Phase 0.7)
    ├── router/
    │   ├── app_router.dart                                   # EXISTS — add all new routes
    │   └── route_names.dart                                  # EXISTS — add all new route names
    ├── screens/
    │   ├── auth/
    │   │   └── login_screen.dart                             # EXISTS — modify
    │   ├── bluetooth/
    │   │   ├── device_discovery_screen.dart                  # NEW (Phase 8.1)
    │   │   └── paired_device_list_screen.dart                # NEW (Phase 8.1)
    │   ├── complaints/
    │   │   ├── complaint_screen.dart                         # EXISTS — modify
    │   │   ├── complaint_history_screen.dart                 # NEW (Phase 5.2)
    │   │   └── update_complaint_screen.dart                  # NEW (Phase 5.3)
    │   ├── customers/
    │   │   ├── customer_profile_screen.dart                  # EXISTS — modify
    │   │   ├── customer_search_screen.dart                   # EXISTS — modify
    │   │   ├── edit_customer_screen.dart                     # NEW (Phase 2.2)
    │   │   ├── new_customer_screen.dart                      # EXISTS — rewrite
    │   │   ├── new_customer_package_screen.dart              # NEW (Phase 2.3)
    │   │   └── new_customer_confirm_screen.dart              # NEW (Phase 2.3)
    │   ├── employees/
    │   │   ├── employee_list_screen.dart                     # EXISTS
    │   │   └── employee_tracking_screen.dart                 # EXISTS — rewrite
    │   ├── home/
    │   │   ├── home_screen.dart                              # EXISTS — modify drawer
    │   │   └── widgets/
    │   │       ├── customer_filter_list.dart                 # EXISTS
    │   │       ├── dashboard_stats_row.dart                  # EXISTS — add STB/complaint cards
    │   │       ├── quick_actions.dart                        # EXISTS — add conditional visibility
    │   │       └── wallet_card.dart                          # EXISTS — fix visibility/data
    │   ├── lco/
    │   │   ├── lco_payment_screen.dart                       # NEW (Phase 7.1)
    │   │   ├── lco_topup_screen.dart                         # NEW (Phase 7.2)
    │   │   └── lco_wallet_history_screen.dart                # NEW (Phase 7.3)
    │   ├── packages/
    │   │   ├── package_operations_screen.dart                # EXISTS — major rework
    │   │   └── package_renewal_screen.dart                   # NEW (Phase 4.5)
    │   ├── payments/
    │   │   ├── invoice_history_screen.dart                   # NEW (Phase 3.4)
    │   │   ├── make_payment_screen.dart                      # EXISTS — modify
    │   │   ├── payment_history_screen.dart                   # NEW (Phase 3.3)
    │   │   ├── payment_receipt_screen.dart                   # NEW (Phase 3.2)
    │   │   ├── payment_response_screen.dart                  # NEW (Phase 3.5)
    │   │   ├── payment_webview_screen.dart                   # NEW (Phase 3.5)
    │   │   └── pg_transaction_report_screen.dart             # NEW (Phase 3.6)
    │   ├── reports/
    │   │   ├── emp_collection_detail_screen.dart             # NEW (Phase 6.3)
    │   │   ├── emp_collection_filter_screen.dart             # NEW (Phase 6.2)
    │   │   ├── emp_collection_list_screen.dart               # NEW (Phase 6.2)
    │   │   ├── mini_day_report_screen.dart                   # NEW (Phase 6.1)
    │   │   └── reports_screen.dart                           # EXISTS — rewrite as hub
    │   ├── scanner/
    │   │   └── barcode_scanner_screen.dart                   # NEW (Phase 8.2)
    │   ├── settings/
    │   │   ├── about_screen.dart                             # NEW (Phase 9.1)
    │   │   ├── change_password_screen.dart                   # NEW (Phase 9.1)
    │   │   ├── privacy_policy_screen.dart                    # NEW (Phase 9.1)
    │   │   └── settings_screen.dart                          # EXISTS — modify
    │   └── stb/
    │       ├── stb_operations_screen.dart                    # EXISTS — modify
    │       ├── stb_pair_unpair_screen.dart                   # NEW (Phase 4.2)
    │       └── stb_replacement_screen.dart                   # NEW (Phase 4.3)
    └── widgets/
        └── signature_pad.dart                                # NEW (Phase 8.4)
```

**Approximate file count:**
- Existing files to modify: ~30
- New files to create: ~95 (including generated .freezed.dart and .g.dart)
- Total lib/ files at completion: ~125 source files + ~35 generated files

---

# APPENDIX B: API Endpoint Checklist

All 70 REST endpoints mapped to implementation phases.

| # | Endpoint | Phase | Datasource File | Repository | Screen(s) |
|---|----------|-------|----------------|------------|-----------|
| 1 | `validateLogin` | 1.1 | auth_remote_ds | AuthRepo | login_screen |
| 2 | `getaccesscontrollRest` | 1.1 | auth_remote_ds | AuthRepo | login (post-auth) |
| 3 | `dashBoardDetailsRest` | 1.3 | dashboard_remote_ds | DashboardRepo | home_screen |
| 4 | `lco_deposit_amountRest` | 1.3 | dashboard_remote_ds | DashboardRepo | wallet_card |
| 5 | `getExpiryServicesDateWiseCount` | 1.3 | dashboard_remote_ds | DashboardRepo | home_screen (dialog) |
| 6 | `getCustomerDetailsCountRest` | 2.1 | customer_remote_ds | CustomerRepo | customer_search_screen |
| 7 | `getCustomerDetailsRest` | 2.1 | customer_remote_ds | CustomerRepo | customer_search_screen |
| 8 | `saveCustomerRest` | 2.3 | customer_remote_ds | CustomerRepo | new_customer_confirm_screen |
| 9 | `editCustomerRest` | 2.2 | customer_remote_ds | CustomerRepo | edit_customer_screen |
| 10 | `existingCustomerRest` | 2.3 | customer_remote_ds | CustomerRepo | new_customer_screen |
| 11 | `updateCustomerLocation` | 2.2 | customer_remote_ds | CustomerRepo | customer_profile_screen |
| 12 | `dynamicformvalidationsRest` | 2.3 | master_data_remote_ds | MasterDataRepo | new/edit customer |
| 13 | `getCountriesRest` | 2.3 | master_data_remote_ds | MasterDataRepo | new/edit customer |
| 14 | `getStatesRest` | 2.3 | master_data_remote_ds | MasterDataRepo | new/edit customer |
| 15 | `getdistrictsRest` | 2.3 | master_data_remote_ds | MasterDataRepo | new/edit customer |
| 16 | `getCitiesRest` | 2.3 | master_data_remote_ds | MasterDataRepo | new/edit customer |
| 17 | `getmandalsRest` | 2.3 | master_data_remote_ds | MasterDataRepo | new/edit customer |
| 18 | `getLocationsOfDistrictRest` | 2.3 | master_data_remote_ds | MasterDataRepo | new/edit customer |
| 19 | `getGroupsRest` | 2.3 | master_data_remote_ds | MasterDataRepo | new/edit customer |
| 20 | `getCustomerTypesRest` | 2.3 | master_data_remote_ds | MasterDataRepo | new/edit customer |
| 21 | `getcustomerTypeTypesRest` | 2.3 | master_data_remote_ds | MasterDataRepo | new/edit customer |
| 22 | `getIdsRest` | 2.3 | master_data_remote_ds | MasterDataRepo | new/edit customer |
| 23 | `getGendersRest` | 2.3 | master_data_remote_ds | MasterDataRepo | new/edit customer |
| 24 | `getPendingAmountRest` | 3.1 | payment_remote_ds | PaymentRepo | make_payment_screen |
| 25 | `makePaymentsRest` | 3.1 | payment_remote_ds | PaymentRepo | make_payment_screen |
| 26 | `getPaymentModesRest` | 3.1 | payment_remote_ds | PaymentRepo | make_payment_screen |
| 27 | `getReceiptRanges` | 3.1 | payment_remote_ds | PaymentRepo | make_payment_screen |
| 28 | `getbilldetailsRest` | 3.1/4.5 | payment_remote_ds | PaymentRepo | make_payment, package_ops |
| 29 | `PaymentServiceRest` | 3.3 | payment_remote_ds | PaymentRepo | payment_history_screen |
| 30 | `InvoiceServiceRest` | 3.4 | payment_remote_ds | PaymentRepo | invoice_history_screen |
| 31 | `pgTransactionLogs` | 3.6 | payment_remote_ds | PaymentRepo | pg_transaction_report |
| 32 | `customer_transaction_reponseRest` | 3.5 | payment_remote_ds | PaymentRepo | payment_response_screen |
| 33 | `getCustomerBoxDetailsRest` | 4.1 | stb_remote_ds | StbRepo | stb_operations_screen |
| 34 | `getCustomerParticularBoxDetailsRest` | 4.1/4.3 | stb_remote_ds | StbRepo | stb_ops, replacement |
| 35 | `deactivateBoxRest` | 4.1 | stb_remote_ds | StbRepo | stb_operations_screen |
| 36 | `reactivateBoxRest` | 4.1 | stb_remote_ds | StbRepo | stb_operations_screen |
| 37 | `getDeactiveReasonsRest` | 4.1/4.5 | stb_remote_ds | StbRepo | stb_ops, package_ops |
| 38 | `temporaryActivationRest` | 4.4 | stb_remote_ds | StbRepo | stb_operations_screen |
| 39 | `validateBoxInfoRest` | 2.3/4.2 | stb_remote_ds | StbRepo | new_customer, pair_unpair |
| 40 | `stbPairRest` | 4.2 | stb_remote_ds | StbRepo | stb_pair_unpair_screen |
| 41 | `stbUnpairRest` | 4.2 | stb_remote_ds | StbRepo | stb_pair_unpair_screen |
| 42 | `stb_replacement` | 4.3 | stb_remote_ds | StbRepo | stb_replacement_screen |
| 43 | `getCustomerPackages_splitRest` | 4.5 | package_remote_ds | PackageRepo | package_operations |
| 44 | `getUnassignedPackages_splitRest` | 4.5 | package_remote_ds | PackageRepo | package_operations |
| 45 | `activateServiceRest` | 4.5 | package_remote_ds | PackageRepo | package_operations |
| 46 | `deactivateServiceRest` | 4.5 | package_remote_ds | PackageRepo | package_operations |
| 47 | `extendCustomerServices` | 4.5 | package_remote_ds | PackageRepo | package_operations |
| 48 | `getCasPackagesRest` | 2.3 | package_remote_ds | PackageRepo | new_customer_package |
| 49 | `channel_listRest` | 4.5 | package_remote_ds | PackageRepo | package_operations |
| 50 | `renewServicesList` | 4.5 | package_remote_ds | PackageRepo | package_renewal |
| 51 | `getRenewServicesList` | 4.5 | package_remote_ds | PackageRepo | package_renewal |
| 52 | `getComplaintList` | 5.1 | complaint_remote_ds | ComplaintRepo | complaint_screen |
| 53 | `gettotalcomplaintslist` | 5.1 | complaint_remote_ds | ComplaintRepo | complaint_screen |
| 54 | `getCustomerComplaintListRest` | 5.1 | complaint_remote_ds | ComplaintRepo | complaint_screen |
| 55 | `complaintCategoriesRest` | 5.1 | complaint_remote_ds | ComplaintRepo | complaint_screen |
| 56 | `getComplaintsubCategory` | 5.1 | complaint_remote_ds | ComplaintRepo | complaint_screen |
| 57 | `createComplaintRest` | 5.1 | complaint_remote_ds | ComplaintRepo | complaint_screen |
| 58 | `complaintTypesRest` | 5.3 | complaint_remote_ds | ComplaintRepo | update_complaint |
| 59 | `closeComplaintRest` | 5.3 | complaint_remote_ds | ComplaintRepo | update_complaint |
| 60 | `ComplaintHistoryRest` | 5.2 | complaint_remote_ds | ComplaintRepo | complaint_history |
| 61 | `DailyreportRest` | 6.1 | report_remote_ds | ReportRepo | mini_day_report |
| 62 | `empCollectionRest` | 6.2 | report_remote_ds | ReportRepo | emp_collection_filter |
| 63 | `empCustomerCollectionDetailsRest` | 6.2 | report_remote_ds | ReportRepo | emp_collection_list |
| 64 | `empCollectionReportDownload` | 6.4 | report_remote_ds | ReportRepo | emp_collection_list |
| 65 | `getlcowalletRest` | 7.3 | dashboard_remote_ds | DashboardRepo | lco_wallet_history |
| 66 | `getdashboardlist` | 1.3 | dashboard_remote_ds | DashboardRepo | STB dashboard tiles |
| 67 | `getLcoEmployeeList` | 5.1 | employee_remote_ds | EmployeeRepo | complaint_screen |
| 68 | `getServiceEmployeeList` | 5.1 | employee_remote_ds | EmployeeRepo | complaint_screen |
| 69 | `lcoAdvanceAmountDue` (TBD) | 7.1 | lco_remote_ds | LcoRepo | lco_payment_screen |
| 70 | `lcoPaymentFunc` (TBD) | 7.1 | lco_remote_ds | LcoRepo | lco_payment_screen |

---

# APPENDIX C: Config Flag Checklist

All 44 config flags + 8 access control flags.

## Config Flags from validateLogin (36 flags)

| # | Flag | Type | Default | First Used In Phase | Screens That Depend On It |
|---|------|------|---------|-------|---------------------------|
| 1 | `useCRF` | int | 0 | 2.2 | Customer Profile (CAF/CRF label), New Customer, Edit Customer |
| 2 | `useCAF` | String | "MANUAL" | 2.3 | New Customer (AUTO hides CAF input, MANUAL shows it) |
| 3 | `useLastName` | int | 1 | 2.3 | New Customer, Edit Customer (1=show Last Name, 0=single Name field) |
| 4 | `useDiscount` | int | 0 | 3.1 | Make Payment (0=hide, 1=show for DEALER/ADMIN/EMPLOYEE, 2=always) |
| 5 | `useDataFromMasterTable` | int | 0 | 2.3 | New Customer (data source toggle) |
| 6 | `useMandatoryForHotel` | int | 0 | 2.3 | New Customer (1=show customer sub-type spinner) |
| 7 | `useAccountNumber` | int | 0 | 2.2/2.3 | New/Edit Customer (0=user enters, >0=auto/locked) |
| 8 | `freezecustomerparamsinapp` | int | 0 | 2.2 | Edit Customer (lock fields) |
| 9 | `blockpayment` | int | 0 | 3.1 | Make Payment (0=allow, 1=block entry), Quick Actions, Drawer |
| 10 | `lcoBilltype` | int | 0 | 1.3 | Dashboard API param |
| 11 | `useLcoDeposit` | int | 0 | 1.3 | Dashboard API param, Make Payment (lock amount) |
| 12 | `customerBilltype` | int | 0 | 3.1 | Billing logic |
| 13 | `autoReceiptNumber` | int | 1 | 3.1 | Make Payment (0=receipt range picker, 1=manual entry) |
| 14 | `currencyCode` | String | "INR" | 0.4 | All monetary displays — replaces hardcoded "₹" |
| 15 | `allowTopUp` | int | 0 | 1.2 | Drawer/overflow menu (LCO Top-Up visibility) |
| 16 | `showCafMobileValidation` | int | 0 | 2.3 | New Customer (OTP validation on CAF) |
| 17 | `stbPairing` | int | 0 | 1.2/4.2 | Drawer (Pair/Unpair menu), STB Pair tab |
| 18 | `stbUnpairing` | int | 0 | 1.2/4.2 | Drawer (Pair/Unpair menu), STB Unpair tab |
| 19 | `showMiaAgreementUpload` | int | 0 | 2.3 | MIA upload feature gate |
| 20 | `acceptTermsConditions` | int | 0 | 1.1 | Terms flow |
| 21 | `agreementDetailsCount` | int | 0 | 2.3 | MIA document count |
| 22 | `accessDistributorWise` | int | 0 | 1.2 | Access control |
| 23 | `isDirectLco` | int | 0 | 1.3 | Wallet visibility, LCO top-up, dashboard API |
| 24 | `isUnpaidlco` | int | 0 | 3.1 | Payment restrictions |
| 25 | `appMenuFormat` | String | "DEFAULT" | 1.2 | Drawer variant (DEFAULT vs other) |
| 26 | `invoicePaymentSearchLimit` | int | 0 | 3.4 | Invoice history search limit |
| 27 | `lcoMobileNo` | int | 0 | 1.2 | Display |
| 28 | `patchInformation` | String | "" | 4.5/7.3 | LCO wallet history visibility, renew button gate |
| 29 | `recurringServiceEdit` | int | 0 | 4.5 | Package activation cycle spinner behavior |
| 30 | `showLcoComplaint` | int | 0 | 5.1 | Complaint menu visibility |
| 31 | `depositAmount` | double | 0.0 | 1.3 | Dashboard wallet initial |
| 32 | `showSerialVc` | int | 1 | 4.1 | STB list serial/VC column visibility |
| 33 | `showServiceExtension` | int | 0 | 4.5 | Package extend button visibility |
| 34 | `editQuantity` | int | 0 | 4.5 | Package quantity editable |
| 35 | `enableBoxWisePayment` | int | 0 | 3.1 | Box-wise payment flow |
| 36 | `baidLabel` | String? | null | 2.3 | Custom label for BAID field |

## Default Location Flags (4 flags)

| # | Flag | Type | First Used | Screen |
|---|------|------|------------|--------|
| 37 | `defaultCountry` | String? | 2.3 | New/Edit Customer (pre-select country) |
| 38 | `defaultState` | int? | 2.3 | New/Edit Customer (pre-select state) |
| 39 | `defaultDistrict` | int? | 2.3 | New/Edit Customer (pre-select district) |
| 40 | `defaultCity` | int? | 2.3 | New/Edit Customer (pre-select city) |

## Display/Theme Flags (4 flags)

| # | Flag | Type | First Used | Screen |
|---|------|------|------------|--------|
| 41 | `appTheme` | int | 9.1 | App-wide theme variant (1–5) |
| 42 | `appDashboard` | int | 1.3 | Dashboard layout variant |
| 43 | `enableAadhaar` | int | N/A | Deferred — feature commented out in Android |
| 44 | `lcoPaymentFlag` | int | 1.2 | LCO Payment drawer item visibility |

## Access Control Flags from getaccesscontrollRest (8 flags)

| # | Flag | Type | Default | First Used | Screens |
|---|------|------|---------|------------|---------|
| 45 | `intBulkPayment` | int | 1 | 1.2 | Drawer (Make Payment), Quick Actions (Quick Pay) |
| 46 | `invoicePageAccess` | int | 1 | 2.2 | Customer Profile (Invoice History button) |
| 47 | `paymentHistPageAccess` | int | 1 | 2.2 | Customer Profile (Payment History button) |
| 48 | `accessForComplaints` | int | 1 | 1.2 | Drawer (Complaints), Quick Actions, Customer Profile |
| 49 | `intStbActivation` | int | 1 | 1.2/4.1/4.5 | Drawer (STB Ops, Package Ops), STB activate button, Package activate |
| 50 | `intStbDeactivation` | int | 1 | 1.2/4.1/4.5 | Drawer (STB Ops, Package Ops), STB deactivate button, Package deactivate |
| 51 | `intStbReactivation` | int | 1 | 1.2/4.1 | Drawer (STB Ops), STB reactivate button |
| 52 | `pgtransaction` | int | 0 | 3.6 | PG Transaction Report visibility |

---

# APPENDIX D: Effort Summary by Phase

| Phase | Description | Estimated Hours | New Files | Modified Files |
|-------|-------------|----------------|-----------|----------------|
| 0 | Foundation (models, repos, utils, widgets) | 60–80h | ~70 | ~15 |
| 1 | Auth + Navigation | 20–30h | 2 | 8 |
| 2 | Customer Management | 40–50h | 5 | 5 |
| 3 | Payments | 30–40h | 7 | 3 |
| 4 | STB + Package Operations | 40–50h | 4 | 5 |
| 5 | Complaints | 20–25h | 3 | 3 |
| 6 | Reports | 20–25h | 5 | 1 |
| 7 | LCO Operations | 15–20h | 4 | 0 |
| 8 | Hardware Integration | 40–50h | 8 | 2 |
| 9 | Settings + Polish | 15–20h | 5 | 3 |
| **Total** | | **300–390h** | **~113** | **~45** |

---

# APPENDIX E: Critical Path & Dependency Graph

```
Phase 0 (Foundation) ─────────────────────────┐
  ├── 0.1 Project Structure                    │
  ├── 0.2 Core Models ← 0.1                   │
  ├── 0.3 AppSession ← 0.2                    │
  ├── 0.4 Core Utils ← 0.1                    │
  ├── 0.5 Repository Layer ← 0.2, 0.4         │
  ├── 0.6 Fix Datasources ← 0.3               │
  └── 0.7 Widget Library ← 0.1                │
                                               │
Phase 1 (Auth + Nav) ← Phase 0 ───────────────┤
  ├── 1.1 Login Fixes ← 0.3, 0.6              │
  ├── 1.2 Navigation Drawer ← 1.1             │
  └── 1.3 Dashboard Fixes ← 1.1               │
                                               │
Phase 2 (Customers) ← Phase 0, 1 ─────────────┤
  ├── 2.1 Customer Search ← 0.5               │
  ├── 2.2 Customer Profile ← 2.1              │
  └── 2.3 New Customer Wizard ← 2.1, 0.7      │
                                               │
Phase 3 (Payments) ← Phase 0, 1 ──────────────┤
  ├── 3.1 Make Payment Fixes ← 0.3, 0.5       │
  ├── 3.2 Receipt Screen ← 3.1                │
  ├── 3.3 Payment History ← 0.5               │
  ├── 3.4 Invoice History ← 0.5               │
  ├── 3.5 PG Integration ← 0.5                │
  └── 3.6 PG Report ← 0.5                     │
                                               │
Phase 4 (STB + Packages) ← Phase 0, 1 ────────┤
  ├── 4.1 STB Fixes ← 0.3, 0.6               │
  ├── 4.2 STB Pair/Unpair ← 0.5               │
  ├── 4.3 STB Replacement ← 0.5               │
  ├── 4.4 Temp Activation ← 4.1               │
  └── 4.5 Package Fixes ← 0.3, 0.5            │
                                               │
Phase 5 (Complaints) ← Phase 0, 1 ────────────┤
Phase 6 (Reports) ← Phase 0, 1 ───────────────┤
Phase 7 (LCO) ← Phase 0, 1, 3.5 ─────────────┤
Phase 8 (Hardware) ← Phase 0 ─────────────────┤
Phase 9 (Settings) ← Phase 0, 1 ──────────────┘
```

**Parallelizable after Phase 0 + 1:** Phases 2, 3, 4, 5, 6 can proceed in parallel with independent developers. Phase 7 depends on 3.5 (WebView). Phase 8 is independent of all feature phases.

---

*End of Implementation Plan V2*
