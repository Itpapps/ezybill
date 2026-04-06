# EzyBill Flutter App - Comprehensive Architectural Gap Analysis

> Generated: 2026-03-26
> Scope: Full audit of all existing code in lib/ against production-ready Clean Architecture standards.
> Purpose: Guide the entire Flutter rebuild strategy so the legacy Android mess is not repeated.

---

## 1. Current Architecture Assessment

### 1.1 Layers That Exist

| Layer | Status | Location |
|-------|--------|----------|
| Core (constants, network, theme) | Exists | `core/` |
| Remote Datasources | Exists (10 files) | `data/datasources/remote/` |
| Local Datasource | Exists (1 file: auth only) | `data/datasources/local/` |
| Data Models | **MISSING ENTIRELY** | `data/models/` does not exist |
| Repositories (concrete) | **MISSING ENTIRELY** | `data/repositories/` does not exist |
| Domain Entities | **MISSING ENTIRELY** | `domain/entities/` does not exist |
| Domain Repository Interfaces | **MISSING ENTIRELY** | `domain/repositories/` does not exist |
| Application Providers | Exists (11 files) | `application/providers/` |
| Application States | Inline in providers | No separate `states/` directory |
| Presentation (screens) | Exists (17+ screens) | `presentation/screens/` |
| Presentation (router) | Exists | `presentation/router/` |
| Presentation (shared widgets) | Minimal (1 file: AppShell) | `presentation/common/widgets/` |
| Core Utils | **MISSING ENTIRELY** | `core/utils/` does not exist |

### 1.2 Current Data Flow Pattern

```
Screen (ConsumerWidget)
  -> ref.watch(xxxProvider)          // Riverpod Notifier
    -> xxxRemoteDatasource           // Makes HTTP call via DioClient
      -> DioClient.post()            // Encrypts payload, sends request
        -> Server                    // Returns encrypted {payload, hash}
      <- _ResponseDecryptionInterceptor  // Decrypts to Map<String, dynamic>
    <- Returns raw Map<String, dynamic>
  -> Provider stores Map<String, dynamic> in state
Screen reads raw Map fields with string keys like data['customerName']
```

**Critical observation:** Data flows as untyped `Map<String, dynamic>` from API response all the way to the UI widget layer. There are ZERO Dart model classes anywhere in the codebase. The planned `data/models/` and `domain/entities/` directories from the FLUTTER_PROJECT_PLAN.md were never created.

### 1.3 How Data Is Passed Between Layers

- **Datasource -> Provider:** `Map<String, dynamic>` (raw JSON maps)
- **Provider state:** All state classes store `Map<String, dynamic>?` for data and `List<Map<String, dynamic>>` for lists
- **Provider -> Screen:** Screens access fields via string key lookup: `customer['customer_name']`, `customer['customerName']` (duplicated key handling)
- **Screen -> Datasource:** Some screens pass `Map<String, dynamic>` directly (e.g., `saveCustomer(customerData: Map)`)

### 1.4 Dependency Injection Pattern (Riverpod)

The DI graph is flat and correct in structure but bypasses clean architecture:

```
core_providers.dart:
  sharedPreferencesProvider  -> Provider<SharedPreferences> (overridden at startup)
  secureStorageProvider      -> Provider<FlutterSecureStorage>
  authLocalDatasourceProvider -> Provider<AuthLocalDatasource>
  dioClientProvider          -> Provider<DioClient>

Each feature provider file:
  xxxRemoteDatasourceProvider -> Provider<XxxRemoteDatasource>(dio: dioClient)
  xxxProvider -> NotifierProvider<XxxNotifier, XxxState>
```

**Problem:** Providers wire directly to datasources. There is no repository layer in between. The plan called for `domain/repositories/` (abstract interfaces) and `data/repositories/` (implementations), but neither exists.

---

## 2. Missing Architectural Layers -- What To Build

### 2.1 Data Models Layer (data/models/)

Every API response is currently consumed as raw `Map<String, dynamic>`. The following Freezed + json_serializable model classes must be created. Fields are derived from the existing datasource code, provider code, and screen_docs specifications.

#### auth/ (Authentication & Session)

**LoginResponse** (`data/models/auth/login_response.dart`)
```
Fields: statusCode (int), statusMsg (String), token (String),
  dealerId (int), employeeId (int), userType (String),
  firstName (String), lastName (String), email (String),
  phone (String), lcoCode (String), businessName (String),
  employeeParentType (String), employeeParentId (String),
  -- Config flags (44+ fields from login response) --
  USE_CUSTOMER_NUMBER (String), LCO_BILLTYPE (String),
  ALLOW_BILLPAY_AT_DEALERLEVEL (String), CURRENCY_CODE (String),
  USE_LCO_DEPOSITS (String), ENABLE_CASH_PAY (String),
  ENABLE_CHEQUE_PAY (String), ENABLE_CREDIT_PAY (String),
  ENABLE_VOUCHER_PAY (String), ENABLE_LCO_ONLINEPAY (String),
  ENABLE_CUSTOMER_ONLINEPAY (String), PAY_THROUGH_LCO_WALLETBALANCE (String),
  ENABLE_PAYMENT_RECEIPT (String), USE_RECEIPT_NUMBER_RANGE (String),
  USE_ALT_RECEIPT_NUMBER (String), APPEND_DESCRIPTION_SUFFIX (String),
  description_suffix_value (String), BLOCK_PREV_DATE_RECEIPT (String),
  RESTRICT_DUPLICATE_RECEIPT (String), ENABLE_AMOUNT_DUE_BILLPAY (String),
  ENABLE_BOXWISE_BILLPAY (String), SHOW_BILL_IN_PAYMENT (String),
  ENABLE_STB_REPLACEMENT (String), ENABLE_STB_ACTIVATION (String),
  ENABLE_STB_DEACTIVATION (String), ENABLE_TEMPORARY_ACTIVATION (String),
  ENABLE_CUSTOMER_GPS (String), ENABLE_EMPLOYEETRACKING_LCO (String),
  ENABLE_CUSTOMER_PRINT (String), ENABLE_RECEIPT_PRINT (String),
  ENABLE_INVOICE_PRINT (String), EMPLOYEE_WISE_COLLECTION (String),
  ENABLE_COMPLAINT_MODULE (String), ENABLE_SERVICE_DEACTIVATION (String),
  ENABLE_CUSTOMER_EDIT (String), ADD_CUSTOMER_ENABLE (String),
  ENABLE_PACKAGE_ACTIVATION (String), ENABLE_PACKAGE_EXTEND (String),
  ENABLE_BOX_DETAILS (String), ENABLE_CHANNEL_LIST (String),
  ENABLE_BILL_DETAILS (String), ENABLE_PAYMENT_HISTORY (String),
  ENABLE_INVOICE_HISTORY (String), ENABLE_PG_TRANSACTION_LOGS (String),
  ENABLE_RENEW_SERVICES (String)
```

**AccessControlResponse** (`data/models/auth/access_control_response.dart`)
```
Fields: statusCode (int),
  customerModule (bool), paymentModule (bool),
  complaintModule (bool), stbModule (bool),
  packageModule (bool), reportModule (bool),
  employeeModule (bool), settingsModule (bool)
```

**AppSession** (`data/models/auth/app_session.dart`)
```
Derived class that merges LoginResponse + AccessControlResponse into a
single typed config object. All config flag getters return bool.
```

#### customer/

**CustomerModel** (`data/models/customer/customer_model.dart`)
```
Fields: customerId (String), customerName (String),
  accountNumber (String), cafNo (String),
  mobileNo (String), email (String),
  billingAddress (String), status (String),
  isActive (bool, derived), stbCount (int),
  pendingAmount (double), billType (String),
  serialNumber (String), vcNumber (String),
  groupId (String), groupName (String),
  customerTypeId (String), customerTypeName (String),
  areaId (String), areaName (String),
  cityId (String), cityName (String),
  districtId (String), districtName (String),
  stateId (String), stateName (String),
  countryCode (String), pinCode (String),
  gender (String), idType (String), idNumber (String),
  latitude (double?), longitude (double?),
  createdDate (String), modifiedDate (String)
```

**CustomerSearchResponse** (`data/models/customer/customer_search_response.dart`)
```
Fields: statusCode (int), statusMessage (String),
  customerCount (int),
  customerDetailsList (List<CustomerModel>)
```

**SaveCustomerRequest** (`data/models/customer/save_customer_request.dart`)
```
Fields: firstName (String), lastName (String),
  mobileNumber (String), email (String?),
  billingAddress (String?), area (String?),
  cityId (String), districtId (String), stateId (String),
  countryCode (String), pinCode (String?),
  gender (String?), idType (String?), idNumber (String?),
  customerTypeId (String?), groupId (String?),
  latitude (double?), longitude (double?)
```

**EditCustomerRequest** (`data/models/customer/edit_customer_request.dart`)
```
Fields: customerId (String), + all SaveCustomerRequest fields
```

#### dashboard/

**DashboardResponse** (`data/models/dashboard/dashboard_response.dart`)
```
Fields: totalActiveCustomers (int), totalDeactiveCustomers (int),
  totalComplaints (int), totalClosedComplaints (int),
  totalStbs (int), totalAssignedStbs (int), totalUnAssignedStbs (int),
  totalDueAmount (double), totalCurrentMonthBill (double),
  outStandingAmount (double),
  totalPaidCustomers (int), totalUnPaidCustomers (int)
```

**WalletResponse** (`data/models/dashboard/wallet_response.dart`)
```
Fields: statusCode (int), walletBalance (double),
  walletEntries (List<LcoWalletEntry>)
```

**ExpiryServicesResponse** (`data/models/dashboard/expiry_services_response.dart`)
```
Fields: statusCode (int),
  expiryDateCounts (List<ExpiryDateCount>)
  -- ExpiryDateCount: date (String), count (int)
```

#### complaint/

**ComplaintModel** (`data/models/complaint/complaint_model.dart`)
```
Fields: complaintId (String), ticketNumber (String),
  customerId (String), customerName (String),
  category (String), categoryName (String),
  subCategory (String?), complaint (String),
  status (String), assignedTo (String?),
  assignedToName (String?), createdDate (String),
  closedDate (String?), remarks (String?),
  isOpen (bool, derived)
```

**ComplaintCategory** (`data/models/complaint/complaint_category.dart`)
```
Fields: categoryId (int), categoryName (String)
```

**ComplaintSubcategory** (`data/models/complaint/complaint_subcategory.dart`)
```
Fields: subCategoryId (int), subCategoryName (String), categoryId (int)
```

**CreateComplaintRequest** (`data/models/complaint/create_complaint_request.dart`)
```
Fields: customerId (String), complaint (String),
  category (int), error (String?), assignedTo (int?)
```

#### payment/

**PaymentMode** (`data/models/payment/payment_mode.dart`)
```
Fields: paymentModeId (String), paymentModeName (String)
```

**PendingAmount** (`data/models/payment/pending_amount.dart`)
```
Fields: statusCode (int), pendingAmount (double),
  customerName (String), mobileNumber (String),
  msoShare (double), lcoShare (double),
  billingId (String)
```

**MakePaymentRequest** (`data/models/payment/make_payment_request.dart`)
```
Fields: altCustomerId (String), amount (double),
  modeType (String), receiptNumber (String?),
  altReceiptNumber (String?), remarks (String?),
  billingId (String?), chequeNo (String?),
  bank (String?), branch (String?),
  chequeDate (String?), rrnNo (String?),
  cardholderName (String?), voucherCode (String?)
```

**PaymentHistory** (`data/models/payment/payment_history.dart`)
```
Fields: paymentId (String), customerId (String),
  amount (double), modeType (String), modeName (String),
  receiptNumber (String?), paymentDate (String),
  remarks (String?), employeeName (String?)
```

**InvoiceModel** (`data/models/payment/invoice_model.dart`)
```
Fields: invoiceId (String), customerId (String),
  invoiceDate (String), amount (double),
  dueDate (String), status (String),
  items (List<InvoiceItem>)
```

**PGTransactionModel** (`data/models/payment/pg_transaction_model.dart`)
```
Fields: transactionId (String), customerId (String),
  amount (double), status (String), gateway (String),
  orderId (String), transactionDate (String)
```

#### stb/

**StbModel** (`data/models/stb/stb_model.dart`)
```
Fields: stbNo (String), vcNo (String),
  customerId (String), status (String),
  isActive (bool, derived), casType (String),
  stockStatus (String), serialNumber (String),
  boxNumber (String)
```

**StbBoxDetail** (`data/models/stb/stb_box_detail.dart`)
```
Fields: stockId (String), serialNumber (String),
  vcNumber (String), status (String),
  casType (String), manufacturer (String),
  model (String), activationDate (String?),
  deactivationDate (String?)
```

**DeactivateBoxRequest** (`data/models/stb/deactivate_box_request.dart`)
```
Fields: customerId (String), stbNo (String),
  reasonId (String), remarks (String?)
```

**StbPairRequest** (`data/models/stb/stb_pair_request.dart`)
```
Fields: customerId (String), stbNo (String), vcNo (String)
```

**StbReplacementRequest** (`data/models/stb/stb_replacement_request.dart`)
```
Fields: customerId (String), oldStbNo (String),
  newStbNo (String), newVcNo (String)
```

**DeactivationReason** (`data/models/stb/deactivation_reason.dart`)
```
Fields: id (String), reason (String)
```

#### package/

**PackageModel** (`data/models/package/package_model.dart`)
```
Fields: packageId (String), packageName (String),
  price (double), packageType (String),
  expiryDate (String?), isAssigned (bool),
  productName (String?), serviceEndDate (String?),
  channels (int?)
```

**BillDetail** (`data/models/package/bill_detail.dart`)
```
Fields: serialNumber (String), packageId (String),
  customerId (String), billType (int?),
  amount (double), tax (double), total (double),
  billDate (String)
```

**ActivateServiceRequest** (`data/models/package/activate_service_request.dart`)
```
Fields: customerId (String), stbNo (String), packageId (String)
```

**RenewalModel** (`data/models/package/renewal_model.dart`)
```
Fields: customerId (String), stbNo (String),
  packageId (String), months (int),
  amount (double)
```

#### report/

**MiniDayReportRow** (`data/models/report/mini_day_report_row.dart`)
```
Fields: totalCollection (double), cashCollection (double),
  onlineCollection (double), totalReceipts (int),
  newActivations (int), deactivations (int),
  complaintsResolved (int), reportDate (String)
```

**EmpCollectionSummary** (`data/models/report/emp_collection_summary.dart`)
```
Fields: employeeId (String), employeeName (String),
  totalCollection (double), cashCollection (double),
  onlineCollection (double), totalReceipts (int)
```

**EmpCollectionDetail** (`data/models/report/emp_collection_detail.dart`)
```
Fields: employeeId (String), customerId (String),
  customerName (String), amount (double),
  modeType (String), receiptNumber (String?),
  paymentDate (String)
```

#### master_data/

**Country** (`data/models/master_data/country.dart`)
```
Fields: countryCode (String), countryName (String)
```

**StateModel** (`data/models/master_data/state_model.dart`)
```
Fields: stateId (String), stateName (String), countryCode (String)
```

**District** (`data/models/master_data/district.dart`)
```
Fields: districtId (String), districtName (String), stateId (String)
```

**City** (`data/models/master_data/city.dart`)
```
Fields: cityId (String), cityName (String), districtId (String), stateId (String)
```

**Mandal** (`data/models/master_data/mandal.dart`)
```
Fields: mandalId (String), mandalName (String), districtId (String)
```

**Group** (`data/models/master_data/group.dart`)
```
Fields: groupId (String), groupName (String)
```

**CustomerType** (`data/models/master_data/customer_type.dart`)
```
Fields: customerTypeId (String), customerTypeName (String)
```

**IdType** (`data/models/master_data/id_type.dart`)
```
Fields: idTypeId (String), idTypeName (String)
```

**Gender** (enum, not a server model)
```
Values: male, female, other
```

#### employee/

**Employee** (`data/models/employee/employee.dart`)
```
Fields: employeeId (String), employeeName (String),
  phone (String), email (String), status (String),
  isActive (bool, derived)
```

**ServiceEmployee** (`data/models/employee/service_employee.dart`)
```
Fields: employeeId (String), employeeName (String),
  phone (String), email (String), status (String),
  serviceArea (String?)
```

#### lco/

**LcoPaymentModel** (`data/models/lco/lco_payment_model.dart`)
```
Fields: paymentId (String), amount (double),
  paymentDate (String), modeType (String),
  remarks (String?)
```

**LcoWalletEntry** (`data/models/lco/lco_wallet_entry.dart`)
```
Fields: entryId (String), amount (double),
  type (String), date (String),
  description (String), balance (double)
```

---

### 2.2 Repository Layer (data/repositories/)

Each repository wraps one or more datasources and provides:
- Type-safe return values (model classes, not Map)
- Centralized error mapping (ApiException -> domain failures)
- Caching strategy decisions
- Multiple datasource coordination (remote + local)

**Required repositories:**

| Repository | Datasources Used | Key Responsibilities |
|-----------|-----------------|---------------------|
| `AuthRepositoryImpl` | AuthRemoteDatasource, AuthLocalDatasource | Login, logout, session restore, token refresh |
| `DashboardRepositoryImpl` | DashboardRemoteDatasource | Dashboard stats, wallet, expiry counts |
| `CustomerRepositoryImpl` | CustomerRemoteDatasource | Search, CRUD, pagination, location update |
| `ComplaintRepositoryImpl` | ComplaintRemoteDatasource | CRUD complaints, categories, assignment |
| `PaymentRepositoryImpl` | PaymentRemoteDatasource | Pending amounts, make payment, modes, history |
| `StbRepositoryImpl` | StbRemoteDatasource | Box ops, pair/unpair, replacement, reasons |
| `PackageRepositoryImpl` | PackageRemoteDatasource | Assigned/available packages, activate/deactivate |
| `ReportRepositoryImpl` | ReportRemoteDatasource | Daily report, employee collections, invoices |
| `EmployeeRepositoryImpl` | EmployeeRemoteDatasource | Employee lists, service employees |
| `MasterDataRepositoryImpl` | MasterDataRemoteDatasource | Countries, states, districts, cities, mandals, groups, types |

**Offline caching strategy:**
- Master data (countries, states, districts, cities, groups, customer types, ID types): Cache in SharedPreferences/Hive with 24-hour TTL. These rarely change.
- Dashboard data: Cache last-fetched data to show stale-while-revalidate on app open.
- Customer search results: No cache (always live search).
- Payment modes, complaint categories, deactivation reasons: Cache with 1-hour TTL.

**Error handling at repository level:**
```dart
abstract class Result<T> {}
class Success<T> extends Result<T> { final T data; }
class Failure<T> extends Result<T> { final AppFailure failure; }

class AppFailure {
  final String message;
  final FailureType type; // network, server, auth, validation, unknown
}
```

Each repository method returns `Future<Result<T>>` instead of throwing exceptions. This eliminates the need for try/catch in every provider method.

---

### 2.3 Domain Entities (domain/entities/)

Domain entities are pure Dart classes with no framework dependencies. They contain business logic and validation.

| Entity | Maps To Model(s) | Business Logic |
|--------|------------------|---------------|
| `User` | LoginResponse, AppSession | `isAdmin`, `hasModule(String)`, `configFlag(String)` |
| `Customer` | CustomerModel | `displayName`, `isActive`, `hasPendingDue`, `formattedAddress` |
| `Complaint` | ComplaintModel | `isOpen`, `isClosed`, `daysOpen`, `canClose(userId)` |
| `Payment` | PaymentHistory, PendingAmount | `formattedAmount`, `isOverdue` |
| `StbBox` | StbModel, StbBoxDetail | `isPaired`, `isActive`, `canDeactivate`, `canReplace` |
| `TvPackage` | PackageModel | `isExpired`, `daysUntilExpiry`, `formattedPrice` |
| `EmployeeInfo` | Employee | `isActive`, `displayName` |
| `DailyReport` | MiniDayReportRow | `netCollection`, `collectionBreakdown` |

---

### 2.4 Domain Repositories (domain/repositories/)

Abstract interfaces that define the contract each repository must implement. The application layer (providers) depends ONLY on these interfaces, never on concrete implementations.

```dart
// Example: domain/repositories/customer_repository.dart
abstract class CustomerRepository {
  Future<Result<CustomerSearchResponse>> searchCustomers({
    String? name, String? mobile, String? boxNumber,
    String? customerId, String? vcNo,
    int startValue = 0, int endValue = 20,
  });
  Future<Result<int>> getCustomerCount({...});
  Future<Result<CustomerModel>> saveCustomer(SaveCustomerRequest request);
  Future<Result<CustomerModel>> editCustomer(EditCustomerRequest request);
  Future<Result<void>> updateLocation(String customerId, double lat, double lng);
}
```

Create one abstract interface per domain area (10 files matching the 10 repositories).

---

### 2.5 Core Utils (core/utils/)

These utility classes are referenced across multiple screens but do not exist yet.

**date_formatters.dart**
```dart
class DateFormatters {
  static String toApiFormat(DateTime date);          // -> 'yyyy-MM-dd'
  static String toDisplayDate(String apiDate);       // -> 'dd MMM yyyy'
  static String toDisplayDateTime(String apiDate);   // -> 'dd MMM yyyy, hh:mm a'
  static DateTime? parseApiDate(String? dateStr);
  static String relativeTime(String apiDate);        // -> '2 hours ago'
}
```

**currency_formatter.dart**
```dart
class CurrencyFormatter {
  static String format(dynamic amount, {String? currencyCode});
  // Uses CURRENCY_CODE from login config, defaults to INR/rupee symbol
  // Handles String, int, double inputs
  // Formats with commas: 1,23,456.00 (Indian notation)
}
```

**validators.dart**
```dart
class Validators {
  static String? mobile(String? value);        // 10-digit Indian mobile
  static String? email(String? value);         // Standard email regex
  static String? pinCode(String? value);       // 6-digit Indian pin
  static String? required(String? value, String fieldName);
  static String? receiptNumber(String? value); // Alphanumeric, min length
  static String? amount(String? value);        // Positive number
  static String? stbNumber(String? value);     // Alphanumeric, expected length
  static String? vcNumber(String? value);
}
```

**string_extensions.dart**
```dart
extension StringX on String {
  String appendSuffix(String suffix);       // For APPEND_DESCRIPTION_SUFFIX config
  String stripSuffix(String suffix);
  String capitalize();
  String initials();                        // 'John Doe' -> 'JD'
  bool get isValidMobile;
  bool get isValidEmail;
}
```

**print_formatters.dart**
```dart
class PrintFormatters {
  static String receiptLayout({
    required String businessName,
    required String customerName,
    required String amount,
    required String receiptNumber,
    required String date,
    required String paymentMode,
    String? remarks,
  });
  static String invoiceLayout({...});
  static String customerDetailLayout({...});
}
```

**parse_utils.dart**
```dart
class ParseUtils {
  static int parseInt(dynamic value, {int defaultValue = 0});
  static double parseDouble(dynamic value, {double defaultValue = 0.0});
  static bool parseBool(dynamic value, {bool defaultValue = false});
  static String parseString(dynamic value, {String defaultValue = ''});
}
```
> Note: `_parseInt` is currently duplicated in 5+ files (DashboardState, DashboardCustomerListNotifier, CustomerSearchNotifier, AuthNotifier, ReportState). This must be extracted.

---

## 3. Anti-Patterns Found -- What To Fix

### 3.1 Raw Map<String, dynamic> Everywhere (CRITICAL)

**Where:** Every datasource returns `Map<String, dynamic>`. Every state class stores `Map<String, dynamic>`. Every screen reads fields via string keys.

**Examples found:**
- `dashboard_provider.dart` line 17: `final Map<String, dynamic>? dashboardData;`
- `complaint_provider.dart` line 14: `final List<Map<String, dynamic>> openComplaints;`
- `customer_filter_list.dart` line 48: `customer['customer_name'] ?? customer['customerName']`
- `customer_search_screen.dart` line 343: `customer['customer_id'] ?? customer['customerId']`

**Impact:** No compile-time safety. Field name typos cause silent null values. Duplicate key handling (snake_case vs camelCase) is scattered across 15+ files. Refactoring is dangerous because nothing will break at compile time.

**Fix:** Create Freezed model classes (Section 2.1). Update datasources to return typed models. Update providers to store typed models in state.

### 3.2 Inconsistent API Response Key Names

The server returns different key names for the same data depending on the endpoint:
- Customer name: `customer_name` vs `customerName`
- Customer ID: `customer_id` vs `customerId`
- Mobile: `mobile_no` vs `mobileNumber`
- Account: `account_number` vs `caf_no`
- Status code: `status_code` vs `statusCode`

**Where found:** `customer_filter_list.dart` lines 48-66, `customer_search_screen.dart` lines 343-346, 450-457, `customer_profile_screen.dart` lines 97-99, `customer_remote_datasource.dart` line 60.

**Fix:** Handle normalization ONCE in the model's `fromJson` factory, not in every screen widget. Example:
```dart
factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
  customerId: json['customer_id']?.toString() ?? json['customerId']?.toString() ?? '',
  customerName: json['customer_name']?.toString() ?? json['customerName']?.toString() ?? '',
  // ... normalize once here
);
```

### 3.3 Business Logic in UI Screens

**customer_search_screen.dart** (lines 57-123): `_loadBoxDetails()` directly calls `stbRemoteDatasourceProvider` and `packageRemoteDatasourceProvider` from the screen, manages its own `_BoxData` cache in local state. This should be a provider method.

**customer_filter_list.dart** (lines 42-76): Local filtering logic with field name normalization duplicated. This should be a utility or provider method.

**customer_profile_screen.dart** (lines 37-89): `_loadCustomer()` directly calls `customerRemoteDatasourceProvider` and manually extracts customer from response list. This is repository-level logic in the UI.

**home_screen.dart** (lines 235-347): Entire drawer is built inline with 12 hardcoded menu items. Should be data-driven from access control config.

**reports_screen.dart** (lines 38-49): Date formatting and dealer ID retrieval mixed into UI callbacks.

### 3.4 Hardcoded Strings That Should Be Config-Driven

| Hardcoded Value | Location | Should Be |
|----------------|----------|-----------|
| `'Cash', 'Online', 'Cheque', 'UPI'` | make_payment_screen.dart line 502 | Fetched from API (paymentModes) |
| `'Signal Issue', 'Billing Issue', etc.` | complaint_screen.dart lines 124-141 | Fetched from API (complaintCategories) |
| Currency symbol `'₹'` | app_constants.dart line 25 | From login config `CURRENCY_CODE` |
| `'v1.0.0'` | login_screen.dart line 257 | From `AppConstants.appVersion` |
| `'RESELLER'` | complaint_provider.dart line 65 | From login session `userType` |
| Dashboard type values `1,2,3,4,5` | dashboard_remote_datasource.dart line 59 | Named constants/enum |
| `fontFamily: 'DM Sans'` | 100+ occurrences | Already in theme but bypassed inline |

### 3.5 Missing Error Handling

**dashboard_provider.dart** line 111: `loadWallet` swallows ALL errors silently:
```dart
Future<void> loadWallet(int dealerId) async {
  try { ... } catch (_) {}  // Silent failure
}
```

**complaint_provider.dart** line 100: `loadCategories` silently swallows:
```dart
Future<void> loadCategories() async {
  try { ... } catch (_) {}
}
```

**stb_provider.dart** line 82: `loadDeactivationReasons` silently swallows:
```dart
Future<void> loadDeactivationReasons() async {
  try { ... } catch (_) {}
}
```

**payment_provider.dart** line 98: `loadPaymentModes` silently swallows.

**Pattern:** Auxiliary data loaders (modes, categories, reasons) all silently fail. The user sees empty dropdowns with no explanation.

**Fix:** At minimum, set an error state or log the failure. Better: use a Result type so the UI can show "Failed to load payment modes - tap to retry."

### 3.6 Missing Loading States

**customer_profile_screen.dart**: Uses local `_isLoading` state variable instead of the provider's state. This means the loading state is not reactive and cannot be observed by other widgets.

**customer_search_screen.dart**: Uses local `_BoxData` class with its own loading state per customer, not integrated into any provider.

**new_customer_screen.dart** line 36: Uses local `_isLoading` and a fake `Future.delayed(2 seconds)` instead of calling any API:
```dart
// TODO: Call customer provider to save
await Future.delayed(const Duration(seconds: 2));
```
The save customer feature is NOT IMPLEMENTED. The screen shows a fake success dialog.

### 3.7 Screens Directly Calling Datasources

**customer_search_screen.dart** line 65-66:
```dart
final stbDs = ref.read(stbRemoteDatasourceProvider);
final pkgDs = ref.read(packageRemoteDatasourceProvider);
```
The screen directly invokes datasource methods bypassing any provider/repository layer.

**customer_profile_screen.dart** line 44:
```dart
final ds = ref.read(customerRemoteDatasourceProvider);
```
Same issue -- screen directly calls datasource.

**reports_screen.dart** line 40:
```dart
final dealerId = ref.read(authLocalDatasourceProvider).dealerId;
```
Screen directly accesses local datasource for session data.

### 3.8 God Providers / Missing Separation

**dashboard_customer_list_provider.dart** (284 lines): This single provider handles tab selection, active customer pagination, inactive customer loading, fallback logic, client-side filtering by activity status, and customer list extraction from multiple response formats. It should be split into:
- A repository that handles the data fetching and normalization
- A simpler notifier that manages UI state (selected tab, pagination)

### 3.9 Duplicated `_parseInt` Helper

The following files each contain their own copy of `_parseInt`:
1. `auth_provider.dart` (line 123)
2. `dashboard_provider.dart` (line 64 in DashboardState)
3. `dashboard_customer_list_provider.dart` (line 274)
4. `customer_provider.dart` (line 151)
5. `report_provider.dart` (line 52 in ReportState)

**Fix:** Extract to `core/utils/parse_utils.dart`.

### 3.10 Duplicated `_extractCustomerList` Helper

Found in:
1. `customer_provider.dart` (line 131)
2. `dashboard_customer_list_provider.dart` (line 259)

Both try multiple keys: `customerDetailsList`, `existCustomerDetails`, `customerDetails`, `data`.

**Fix:** This is response normalization that belongs in the model's `fromJson` or in the repository.

### 3.11 Duplicated `_extractComplaintList` Helper

Found in `complaint_provider.dart` (line 155): tries `lcoComplaintlist`, `complaintList`, `data`.

Same pattern. Belongs in model layer.

### 3.12 Missing Null Safety Patterns

**customer_filter_list.dart** line 48:
```dart
final name = (c['customer_name'] ?? c['customerName'] ?? '').toString().trim().toUpperCase();
```
Triple-null-coalesce chains are error-prone and unreadable. With typed models, this becomes `c.customerName.toUpperCase()`.

### 3.13 Missing Dispose / Cleanup

- `DioClient.onAuthFailure` callback is set but never cleared on logout
- Dashboard data persists in provider state after logout (no invalidation)
- `TextEditingController` instances are properly disposed in most screens (good)

### 3.14 Font Family Specified Inline Instead of Using Theme

Over 100 occurrences of `fontFamily: 'DM Sans'` scattered across all screen files, despite `AppTheme` already configuring `GoogleFonts.dmSansTextTheme()`. Widgets create their own `TextStyle` instead of using `Theme.of(context).textTheme.bodyMedium`.

### 3.15 Excessive Debug Print Statements

**dashboard_provider.dart** lines 87-96: 6 `debugPrint` statements for a single API call. These should be removed or gated behind a logging framework.

**dio_client.dart** lines 121-155: `_ResponseDecryptionInterceptor` prints response data including decrypted content. This is a security risk in production.

### 3.16 Drawer Menu Not Access-Control-Driven

**home_screen.dart** lines 287-327: All 10 drawer menu items are hardcoded. The `getAccessControl` API is called in `auth_remote_datasource.dart` but its response is NEVER used. Menu visibility should be driven by access control flags.

---

## 4. Reusable Widgets Needed

### 4.1 Widgets That Should Be Extracted

| Widget | Current Duplication | Where Used |
|--------|-------------------|------------|
| **SearchBarWithDebounce** | 4 different search bars built inline | home_screen, customer_search_screen, customer_filter_list, employee_list_screen |
| **PaginatedListView** | Manual "Load More" button + isLoadingMore logic | customer_filter_list (lines 296-332) |
| **DateRangePicker** | Built inline in reports_screen | reports_screen (lines 51-78) |
| **CascadingDropdown** | Not built yet, needed for New Customer form | Country->State->District->City->Mandal chain |
| **StatusBadge** | 8+ inline implementations with isActive/isOpen logic | customer_filter_list, customer_search_screen, complaint_screen, stb_operations_screen, employee_list_screen, package_operations_screen |
| **LoadingState** | Inline `CircularProgressIndicator` in 10+ places | Every screen |
| **ErrorState** | Inline error containers in 5+ places | customer_filter_list, reports_screen, customer_search_screen |
| **EmptyState** | 7 different "No X found" implementations | customer_filter_list, customer_search_screen, complaint_screen, stb_operations_screen, package_operations_screen, reports_screen, employee_list_screen |
| **ConfirmationDialog** | 5 different `showDialog` implementations | stb_operations_screen, package_operations_screen, make_payment_screen, settings_screen, home_screen |
| **CustomerInfoCard** | 3 different customer row/card implementations | customer_filter_list (_CompactCustomerCard), customer_search_screen (_CustomerResultCard), customer_profile_screen |
| **StbDetailCard** | 2 implementations | customer_search_screen (_BoxCard), stb_operations_screen (_StbCard) |
| **StatCard** | 2 implementations | reports_screen (_StatCard), dashboard_stats_row (_MiniPill) |
| **ActionButton** | 5+ implementations | customer_search_screen (_ActionBtn), stb_operations_screen (_ActionButton), quick_actions (_ActionChip), customer_filter_list (_MiniAction) |
| **SectionHeader** | Inline in 3+ screens | reports_screen, settings_screen, new_customer_screen |
| **ReceiptPreviewCard** | Not built yet, needed for payment confirmation | make_payment_screen (planned) |

### 4.2 Recommended Widget Library Structure

```
presentation/common/widgets/
  search_bar_with_debounce.dart
  paginated_list_view.dart
  status_badge.dart
  loading_state.dart
  error_state.dart
  empty_state.dart
  confirmation_dialog.dart
  section_header.dart
  stat_card.dart
  customer_info_card.dart
  stb_detail_card.dart
  action_chip_button.dart
  cascading_dropdown.dart
  date_range_selector.dart
  receipt_preview_card.dart
  form_field_wrapper.dart         # Standardized form field with label, validation
  app_shell.dart                  # Already exists
```

---

## 5. Cross-Cutting Concerns

### 5.1 Network Connectivity Check

**Status:** `connectivity_plus` is in pubspec.yaml but NEVER imported or used anywhere.

**Need:**
- `NetworkInfo` class wrapping `connectivity_plus` to check before API calls
- Offline banner widget shown when connectivity is lost
- Auto-retry on reconnection for failed requests

### 5.2 Session Timeout Handling

**Status:** `DioClient.onAuthFailure` callback exists and is invoked on 401 responses, but it is NEVER connected to the auth provider. The `_AuthInterceptor.onError` calls `_client.onAuthFailure?.call()` but nothing sets `onAuthFailure`.

**Need:**
- In `core_providers.dart`, after creating `DioClient`, set `onAuthFailure` to trigger `ref.read(authProvider.notifier).logout()`
- Show a "Session expired" dialog/snackbar before redirecting to login
- Auto-navigate to login on 401

### 5.3 Global Error Handling

**Status:** No global error handler. Each provider has its own try/catch with `e.toString().replaceAll('ApiException: ', '')` (found in 6+ files).

**Need:**
- A `ProviderObserver` that logs all provider state changes and errors
- A central `ErrorHandler` class that maps `ApiException` subtypes to user-facing messages
- Flutter's `FlutterError.onError` and `PlatformDispatcher.instance.onError` for uncaught errors

### 5.4 Logging / Analytics

**Status:** Only `debugPrint` statements. No structured logging. No analytics.

**Need:**
- Replace `debugPrint` with a `Logger` class that respects build mode
- Strip all sensitive data (decrypted payloads, tokens) from logs
- Prepare hooks for Firebase Analytics / Crashlytics integration

### 5.5 Offline Mode Strategy

**Status:** No offline support. App is completely online-dependent.

**Recommended strategy:**
- **Phase 1:** Show cached dashboard data on startup, then refresh
- **Phase 2:** Cache master data (countries, states, etc.) with TTL
- **Phase 3:** Queue payments/complaints for sync when online

### 5.6 Theme Consistency

**Status:** `AppTheme` and `AppColors` exist and are well-structured, but screens bypass the theme with inline `TextStyle(fontFamily: 'DM Sans', ...)` in 100+ locations.

**Fix:** Use `Theme.of(context).textTheme.xxx` everywhere. Add extension methods:
```dart
extension ContextTheme on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
```

### 5.7 Localization Readiness

**Status:** Zero localization support. All strings are hardcoded in English.

**Need:**
- Add `flutter_localizations` to pubspec
- Create `l10n/` directory with ARB files
- Replace hardcoded strings with `AppLocalizations.of(context).xxx`
- At minimum, extract all user-facing strings to a constants file

### 5.8 Deep Linking Support

**Status:** GoRouter is configured but all routes pass data via `extra` (in-memory maps), which does not survive deep links or app restarts.

**Fix:** Use path/query parameters for essential navigation data:
```
/customers/profile/:customerId    (instead of extra: {'customerId': '...'})
/make-payment/:customerId         (instead of extra: {'customerId': '...'})
/stb-operations/:customerId
```

---

## 6. Config-Driven Architecture

### 6.1 The AppSession / ConfigService Class

The login response contains 44+ configuration flags that control feature visibility, payment modes, UI behavior, and module access. Currently, the full login response is stored as a raw JSON string in SharedPreferences and is NEVER parsed for config flags.

```dart
// core/config/app_session.dart
class AppSession {
  // ---- Identity ----
  final int dealerId;
  final int employeeId;
  final String userType;
  final String firstName;
  final String lastName;
  final String lcoCode;
  final String businessName;
  final String employeeParentType;
  final String employeeParentId;
  final String token;

  // ---- Feature Flags (44+) ----
  final bool useCustomerNumber;
  final String lcoBillType;
  final bool allowBillPayAtDealerLevel;
  final String currencyCode;
  final bool useLcoDeposits;
  final bool enableCashPay;
  final bool enableChequePay;
  final bool enableCreditPay;
  final bool enableVoucherPay;
  final bool enableLcoOnlinePay;
  final bool enableCustomerOnlinePay;
  final bool payThroughLcoWalletBalance;
  final bool enablePaymentReceipt;
  final bool useReceiptNumberRange;
  final bool useAltReceiptNumber;
  final bool appendDescriptionSuffix;
  final String descriptionSuffixValue;
  final bool blockPrevDateReceipt;
  final bool restrictDuplicateReceipt;
  final bool enableAmountDueBillPay;
  final bool enableBoxWiseBillPay;
  final bool showBillInPayment;
  final bool enableStbReplacement;
  final bool enableStbActivation;
  final bool enableStbDeactivation;
  final bool enableTemporaryActivation;
  final bool enableCustomerGps;
  final bool enableEmployeeTrackingLco;
  final bool enableCustomerPrint;
  final bool enableReceiptPrint;
  final bool enableInvoicePrint;
  final bool employeeWiseCollection;
  final bool enableComplaintModule;
  final bool enableServiceDeactivation;
  final bool enableCustomerEdit;
  final bool addCustomerEnable;
  final bool enablePackageActivation;
  final bool enablePackageExtend;
  final bool enableBoxDetails;
  final bool enableChannelList;
  final bool enableBillDetails;
  final bool enablePaymentHistory;
  final bool enableInvoiceHistory;
  final bool enablePgTransactionLogs;
  final bool enableRenewServices;

  // ---- Access Control (from getaccesscontrollRest) ----
  final bool canAccessCustomers;
  final bool canAccessPayments;
  final bool canAccessComplaints;
  final bool canAccessStb;
  final bool canAccessPackages;
  final bool canAccessReports;
  final bool canAccessEmployees;
  final bool canAccessSettings;

  // ---- Convenience Methods ----
  String get displayName => '$firstName $lastName'.trim();
  String get currencySymbol => currencyCode == 'INR' ? '\u20B9' : currencyCode;
  bool get isAdmin => userType == 'RESELLER';
  bool get isEmployee => userType == 'EMPLOYEE';

  factory AppSession.fromLoginResponse(
    Map<String, dynamic> loginData,
    Map<String, dynamic>? accessControlData,
  );

  Map<String, dynamic> toJson();
  factory AppSession.fromJson(Map<String, dynamic> json);
}
```

### 6.2 How Screens Should Access Config Values

```dart
// Provider
final appSessionProvider = StateProvider<AppSession?>((ref) => null);

// In any screen:
final session = ref.watch(appSessionProvider);
if (session?.enableComplaintModule == true) { ... }
if (session?.enableStbReplacement == true) { showReplacementButton(); }

// For currency:
Text('${session?.currencySymbol}${amount}')
```

### 6.3 How Menu Visibility Should Be Driven

```dart
// In drawer builder:
final session = ref.watch(appSessionProvider);
final menuItems = [
  DrawerItem(icon: Icons.home, label: 'Dashboard', route: '/', visible: true),
  DrawerItem(icon: Icons.people, label: 'Customers', route: '/customers',
    visible: session?.canAccessCustomers ?? false),
  DrawerItem(icon: Icons.payment, label: 'Make Payment', route: '/make-payment',
    visible: session?.canAccessPayments ?? false),
  DrawerItem(icon: Icons.warning, label: 'Complaints', route: '/complaints',
    visible: session?.enableComplaintModule == true && session?.canAccessComplaints == true),
  // ...
].where((item) => item.visible).toList();
```

### 6.4 Feature Flag Pattern

```dart
// core/config/feature_flags.dart
class FeatureFlags {
  final AppSession _session;
  FeatureFlags(this._session);

  bool get showPaymentReceipt => _session.enablePaymentReceipt;
  bool get showReceiptRange => _session.useReceiptNumberRange;
  bool get allowBoxWisePayment => _session.enableBoxWiseBillPay;
  bool get showBillInPayment => _session.showBillInPayment;
  bool get canAddCustomer => _session.addCustomerEnable;
  bool get canEditCustomer => _session.enableCustomerEdit;
  bool get showGpsButton => _session.enableCustomerGps;
  bool get showEmployeeTracking => _session.enableEmployeeTrackingLco;
  bool get canPrintReceipt => _session.enableReceiptPrint;
  bool get canPrintInvoice => _session.enableInvoicePrint;
  bool get canPrintCustomer => _session.enableCustomerPrint;
  // ... group related flags into meaningful capabilities
}

final featureFlagsProvider = Provider<FeatureFlags>((ref) {
  final session = ref.watch(appSessionProvider);
  return FeatureFlags(session ?? AppSession.empty());
});
```

---

## 7. Production Readiness Checklist

### 7.1 Error Boundaries

- [ ] Wrap app in `ErrorBoundary` widget (or custom equivalent)
- [ ] Implement `FlutterError.onError` handler in `main.dart`
- [ ] Implement `PlatformDispatcher.instance.onError` for async errors
- [ ] Each screen should have error fallback UI (not just white screen)

### 7.2 Crash Reporting

- [ ] Integrate Firebase Crashlytics (or Sentry)
- [ ] Log non-fatal errors (API failures, parse errors)
- [ ] Include user context (dealerId, userType) in crash reports
- [ ] Strip sensitive data (tokens, passwords) from crash logs

### 7.3 Performance Monitoring

- [ ] Firebase Performance Monitoring for API call timings
- [ ] Monitor widget rebuild counts in debug builds
- [ ] Profile the customer_filter_list.dart -- it rebuilds the entire customer list on every keystroke (no debounce, no `const` optimization)
- [ ] Large list optimization: customer_filter_list renders ALL customers in a Column with `.map()` instead of using `ListView.builder` for virtualization

### 7.4 Secure Storage for Tokens

- [x] JWT and auth tokens stored in `flutter_secure_storage` (already implemented)
- [ ] Ensure tokens are cleared on logout (already done in `clearAll()`)
- [ ] Add token expiry checking (not implemented -- tokens never expire client-side)
- [ ] Never log tokens (currently printed by `_LoggingInterceptor`)

### 7.5 ProGuard / Obfuscation

- [ ] Enable Flutter obfuscation: `flutter build apk --obfuscate --split-debug-info=build/debug-info`
- [ ] Obfuscate the encryption keys in `payload_encryption.dart`
- [ ] Add ProGuard rules for Dio, Google Maps, and other native plugins

### 7.6 App Signing

- [ ] Generate release keystore
- [ ] Configure `android/app/build.gradle` signing config
- [ ] Store keystore securely (not in git)
- [ ] iOS provisioning profile and distribution certificate

### 7.7 CI/CD Readiness

- [ ] GitHub Actions or Codemagic pipeline
- [ ] Lint check: `flutter analyze`
- [ ] Test step: `flutter test`
- [ ] Build step: `flutter build apk --release`
- [ ] Artifact upload
- [ ] Version bumping strategy (pubspec.yaml version + build number)

### 7.8 Additional Production Items

- [ ] Remove ALL `debugPrint` statements from production code (or gate behind `kDebugMode`)
- [ ] Remove the CORS proxy configuration (only needed for web debug)
- [ ] Change API base URL to production server (currently hardcoded to dev IP `183.83.216.66:8882`)
- [ ] Environment-specific config (dev/staging/prod base URLs)
- [ ] App icon and splash screen
- [ ] Privacy policy URL
- [ ] Terms of service URL

---

## 8. Recommended File Structure

Below is the complete target `lib/` structure. Files marked with `[EXISTS]` are already in the codebase. All others need to be created.

```
lib/
  main.dart                                          [EXISTS]

  core/
    config/
      app_session.dart                               # Typed session from login
      feature_flags.dart                             # Feature flag convenience class
      environment.dart                               # Dev/staging/prod config

    constants/
      api_constants.dart                             [EXISTS]
      app_constants.dart                             [EXISTS]

    network/
      dio_client.dart                                [EXISTS]
      payload_encryption.dart                        [EXISTS]
      api_exception.dart                             [EXISTS]
      network_info.dart                              # Connectivity checker

    theme/
      app_colors.dart                                [EXISTS]
      app_theme.dart                                 [EXISTS]
      app_text_styles.dart                           # Named text styles (optional)

    utils/
      date_formatters.dart                           # Date formatting helpers
      currency_formatter.dart                        # Currency display
      validators.dart                                # Form validation
      string_extensions.dart                         # String utilities
      parse_utils.dart                               # parseInt/parseDouble/parseBool
      print_formatters.dart                          # Receipt/invoice layouts
      logger.dart                                    # Structured logging wrapper

  data/
    datasources/
      remote/
        auth_remote_datasource.dart                  [EXISTS]
        dashboard_remote_datasource.dart             [EXISTS]
        customer_remote_datasource.dart              [EXISTS]
        complaint_remote_datasource.dart             [EXISTS]
        payment_remote_datasource.dart               [EXISTS]
        stb_remote_datasource.dart                   [EXISTS]
        package_remote_datasource.dart               [EXISTS]
        report_remote_datasource.dart                [EXISTS]
        employee_remote_datasource.dart              [EXISTS]
        master_data_remote_datasource.dart           [EXISTS]
      local/
        auth_local_datasource.dart                   [EXISTS]
        cache_local_datasource.dart                  # Offline data cache (master data, etc.)

    models/
      auth/
        login_response.dart
        login_response.freezed.dart                  # Generated
        login_response.g.dart                        # Generated
        access_control_response.dart
      customer/
        customer_model.dart
        customer_search_response.dart
        save_customer_request.dart
        edit_customer_request.dart
      dashboard/
        dashboard_response.dart
        wallet_response.dart
        expiry_services_response.dart
      complaint/
        complaint_model.dart
        complaint_category.dart
        complaint_subcategory.dart
        create_complaint_request.dart
      payment/
        payment_mode.dart
        pending_amount.dart
        make_payment_request.dart
        payment_history.dart
        invoice_model.dart
        pg_transaction_model.dart
      stb/
        stb_model.dart
        stb_box_detail.dart
        deactivate_box_request.dart
        stb_pair_request.dart
        stb_replacement_request.dart
        deactivation_reason.dart
      package/
        package_model.dart
        bill_detail.dart
        activate_service_request.dart
        renewal_model.dart
      report/
        mini_day_report_row.dart
        emp_collection_summary.dart
        emp_collection_detail.dart
      employee/
        employee.dart
        service_employee.dart
      master_data/
        country.dart
        state_model.dart
        district.dart
        city.dart
        mandal.dart
        group.dart
        customer_type.dart
        id_type.dart
      lco/
        lco_payment_model.dart
        lco_wallet_entry.dart

    repositories/
      auth_repository_impl.dart
      dashboard_repository_impl.dart
      customer_repository_impl.dart
      complaint_repository_impl.dart
      payment_repository_impl.dart
      stb_repository_impl.dart
      package_repository_impl.dart
      report_repository_impl.dart
      employee_repository_impl.dart
      master_data_repository_impl.dart

  domain/
    entities/
      user.dart
      customer.dart
      complaint.dart
      payment.dart
      stb_box.dart
      tv_package.dart
      employee_info.dart
      daily_report.dart

    repositories/
      auth_repository.dart
      dashboard_repository.dart
      customer_repository.dart
      complaint_repository.dart
      payment_repository.dart
      stb_repository.dart
      package_repository.dart
      report_repository.dart
      employee_repository.dart
      master_data_repository.dart

    failures/
      app_failure.dart                               # Base failure class
      result.dart                                    # Result<T> = Success | Failure

  application/
    providers/
      core_providers.dart                            [EXISTS - needs update]
      auth_provider.dart                             [EXISTS - needs refactor]
      dashboard_provider.dart                        [EXISTS - needs refactor]
      dashboard_customer_list_provider.dart           [EXISTS - needs refactor]
      customer_provider.dart                         [EXISTS - needs refactor]
      complaint_provider.dart                        [EXISTS - needs refactor]
      payment_provider.dart                          [EXISTS - needs refactor]
      stb_provider.dart                              [EXISTS - needs refactor]
      package_provider.dart                          [EXISTS - needs refactor]
      report_provider.dart                           [EXISTS - needs refactor]
      employee_provider.dart                         [EXISTS - needs refactor]
      master_data_provider.dart                      # Not yet created
      app_session_provider.dart                      # AppSession state
      feature_flag_provider.dart                     # FeatureFlags provider

  presentation/
    router/
      app_router.dart                                [EXISTS - needs deep link params]
      route_names.dart                               [EXISTS]

    common/
      widgets/
        app_shell.dart                               [EXISTS]
        search_bar_with_debounce.dart
        paginated_list_view.dart
        status_badge.dart
        loading_state.dart
        error_state.dart
        empty_state.dart
        confirmation_dialog.dart
        section_header.dart
        stat_card.dart
        customer_info_card.dart
        stb_detail_card.dart
        action_chip_button.dart
        cascading_dropdown.dart
        date_range_selector.dart
        receipt_preview_card.dart
        form_field_wrapper.dart
        offline_banner.dart

    screens/
      auth/
        login_screen.dart                            [EXISTS]
        widgets/
          login_form.dart                            # Extract form from login_screen
      home/
        home_screen.dart                             [EXISTS - needs refactor]
        widgets/
          dashboard_stats_row.dart                   [EXISTS]
          quick_actions.dart                         [EXISTS]
          wallet_card.dart                           [EXISTS]
          customer_filter_list.dart                  [EXISTS - needs refactor]
      customers/
        customer_search_screen.dart                  [EXISTS - needs refactor]
        customer_profile_screen.dart                 [EXISTS - needs refactor]
        new_customer_screen.dart                     [EXISTS - NOT FUNCTIONAL, needs full impl]
        edit_customer_screen.dart                    # Not yet created
        widgets/
          customer_result_card.dart                  # Extract from customer_search_screen
          customer_box_section.dart                  # Extract expanded section
      complaints/
        complaint_screen.dart                        [EXISTS]
        create_complaint_screen.dart                 # Extract bottom sheet to full screen
        complaint_detail_screen.dart                 # Not yet created (view history, close)
        widgets/
          complaint_card.dart                        # Extract from complaint_screen
      payments/
        make_payment_screen.dart                     [EXISTS]
        payment_history_screen.dart                  # Not yet created
        invoice_history_screen.dart                  # Not yet created
        widgets/
          payment_mode_selector.dart                 # Extract from make_payment_screen
          pending_amount_card.dart                   # Extract from make_payment_screen
      stb/
        stb_operations_screen.dart                   [EXISTS]
        stb_pair_screen.dart                         # Not yet created
        stb_replacement_screen.dart                  # Not yet created
        widgets/
          stb_card.dart                              # Extract from stb_operations_screen
      packages/
        package_operations_screen.dart               [EXISTS]
        widgets/
          package_card.dart                          # Extract from package_operations_screen
      reports/
        reports_screen.dart                          [EXISTS]
        widgets/
          stat_card.dart                             # Extract from reports_screen
          collection_card.dart                       # Extract from reports_screen
      settings/
        settings_screen.dart                         [EXISTS]
      employees/
        employee_list_screen.dart                    [EXISTS]
        employee_tracking_screen.dart                [EXISTS - placeholder, needs map impl]
        widgets/
          employee_card.dart                         # Extract from employee_list_screen
      drawer/
        app_drawer.dart                              # Extract from home_screen, make config-driven
        drawer_item.dart
```

---

## Summary of Priority Actions

### P0 -- Blocking Issues (Fix Before Any New Feature)
1. **Create data models layer** -- Eliminate all `Map<String, dynamic>` usage with Freezed classes
2. **Create repository layer** -- Decouple providers from datasources
3. **Implement AppSession** -- Parse and store the 44+ config flags from login
4. **Connect `onAuthFailure`** -- 401 responses currently do nothing
5. **Implement `new_customer_screen.dart`** -- It is completely fake (shows success without calling API)

### P1 -- Architectural Debt (Fix During Sprint)
6. **Extract duplicated helpers** -- `_parseInt`, `_extractCustomerList`, key normalization
7. **Create reusable widgets** -- StatusBadge, EmptyState, LoadingState, ConfirmationDialog, SearchBarWithDebounce
8. **Fix silent error swallowing** -- 4+ providers catch and discard errors
9. **Make drawer access-control-driven** -- Use `getaccesscontrollRest` response
10. **Replace inline font declarations** -- Use `Theme.of(context).textTheme`

### P2 -- Production Readiness (Fix Before Release)
11. **Remove debug prints** -- Especially the ones that log decrypted API responses
12. **Add environment config** -- Dev/staging/prod base URLs
13. **Implement deep link parameters** -- Replace `extra` map passing with URL params
14. **Add crash reporting** -- Firebase Crashlytics or Sentry
15. **Enable obfuscation** -- Protect encryption logic
16. **Fix `customer_filter_list` performance** -- Renders all items via Column.map() instead of ListView.builder

### P3 -- Nice to Have (Future Sprints)
17. Network connectivity monitoring with offline banner
18. Offline caching for master data
19. Localization / i18n support
20. CI/CD pipeline
21. Unit and widget tests
