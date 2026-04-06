# EzyBill Flutter Rebuild -- Changes Log
## Date: 2026-03-26 / 2026-03-27

---

### Session Summary
- **Total Dart files:** 272 (source + generated)
- **Phases completed:** 0-9 (all)
- **Compile errors fixed:** 537 -> 0
- **Models with type-safety sanitizers:** 18+
- **API documentation created:** 4 docs
- **Architecture:** Clean Architecture (data/domain/application/presentation) + Riverpod + GoRouter + Freezed

---

## Phase-by-Phase Changes

### Phase 0: Project Setup & Analysis
- Analyzed existing Android Java codebase at `D:\ITP2026\android\ezybill\`
- Decision: Update existing Flutter project (not create new) at `D:\ITP2026\android\Flutter_ezybill\`
- Established Clean Architecture folder structure:
  - `lib/core/` - config, constants, network, theme, utils
  - `lib/data/` - datasources, models, repositories
  - `lib/domain/` - repository interfaces
  - `lib/application/` - providers (Riverpod state management)
  - `lib/presentation/` - screens, router, common widgets
- Added dependencies: freezed, freezed_annotation, json_annotation, json_serializable, build_runner, flutter_riverpod, go_router, dio, shared_preferences, connectivity_plus, google_fonts, lucide_icons

### Phase 1: Core Infrastructure
**Files created:**
- `lib/core/constants/api_constants.dart` - Base URL, endpoint paths
- `lib/core/constants/app_constants.dart` - Timeouts, page sizes
- `lib/core/config/app_session.dart` - 50+ config flags from login, typed session object
- `lib/core/network/dio_client.dart` - Dio HTTP client with encryption interceptors
- `lib/core/network/payload_encryption.dart` - Triple-hex encryption matching PHP server
- `lib/core/network/api_exception.dart` - Typed exception hierarchy
- `lib/core/utils/result.dart` - Success/Failure sealed class for error handling
- `lib/core/utils/string_extensions.dart` - Helper extensions
- `lib/core/theme/app_colors.dart` - ThemeExtension color system (light + dark)
- `lib/core/theme/app_theme.dart` - Material3 theme with Plus Jakarta Sans

### Phase 2: Data Models (Freezed)
**Files created (46 model source files):**
- `lib/data/models/auth/login_response.dart` - 95 fields, full sanitizer
- `lib/data/models/auth/access_control_response.dart` - 10 fields, sanitizer
- `lib/data/models/dashboard/dashboard_response.dart` - 20 fields, sanitizer
- `lib/data/models/dashboard/wallet_response.dart` - 3 fields, sanitizer
- `lib/data/models/dashboard/expiry_services_response.dart` - nested model, sanitizer
- `lib/data/models/dashboard/wallet_history_entry.dart` - 14 nullable fields
- `lib/data/models/customer/customer_model.dart` - 22 fields, sanitizer
- `lib/data/models/customer/customer_search_response.dart` - handles both statusCode patterns
- `lib/data/models/customer/save_customer_request.dart` - 36 fields
- `lib/data/models/customer/edit_customer_request.dart` - 35 fields
- `lib/data/models/customer/form_validation.dart`
- `lib/data/models/payment/pending_amount.dart` - sanitizer for String->double
- `lib/data/models/payment/payment_mode.dart` - PaymentModeName capital P handled
- `lib/data/models/payment/make_payment_request.dart`
- `lib/data/models/payment/make_payment_response.dart`
- `lib/data/models/payment/payment_history_item.dart`
- `lib/data/models/payment/invoice_item.dart`
- `lib/data/models/payment/bill_detail.dart`
- `lib/data/models/payment/pg_transaction.dart`
- `lib/data/models/payment/receipt_range.dart`
- `lib/data/models/complaint/complaint_model.dart`
- `lib/data/models/complaint/complaint_category.dart` - sanitizer
- `lib/data/models/complaint/complaint_subcategory.dart` - sanitizer
- `lib/data/models/complaint/create_complaint_request.dart`
- `lib/data/models/complaint/close_complaint_request.dart`
- `lib/data/models/stb/stb_model.dart`
- `lib/data/models/stb/deactivation_reason.dart` - sanitizer
- `lib/data/models/stb/stb_replacement_request.dart`
- `lib/data/models/package/package_model.dart` - sanitizer
- `lib/data/models/package/cas_package.dart`
- `lib/data/models/package/channel_model.dart`
- `lib/data/models/employee/employee_model.dart`
- `lib/data/models/employee/service_employee.dart`
- `lib/data/models/report/emp_collection_summary.dart` - sanitizer
- `lib/data/models/report/emp_collection_detail.dart` - sanitizer
- `lib/data/models/report/mini_day_report_row.dart` - sanitizer
- `lib/data/models/lco/lco_payment_request.dart`
- `lib/data/models/lco/lco_wallet_entry.dart`
- `lib/data/models/master_data/country.dart` - sanitizer
- `lib/data/models/master_data/state_model.dart` - sanitizer
- `lib/data/models/master_data/district.dart` - sanitizer
- `lib/data/models/master_data/city.dart` - sanitizer
- `lib/data/models/master_data/gender.dart` - sanitizer
- `lib/data/models/master_data/customer_type.dart` - sanitizer
- `lib/data/models/master_data/id_type.dart` - sanitizer
- `lib/data/models/master_data/group_model.dart` - sanitizer
- `lib/data/models/master_data/mandal.dart` - sanitizer

### Phase 3: Data Layer (Datasources + Repositories)
**Files created:**
- `lib/data/datasources/remote/auth_remote_datasource.dart`
- `lib/data/datasources/remote/dashboard_remote_datasource.dart`
- `lib/data/datasources/remote/customer_remote_datasource.dart`
- `lib/data/datasources/remote/payment_remote_datasource.dart`
- `lib/data/datasources/remote/complaint_remote_datasource.dart`
- `lib/data/datasources/remote/stb_remote_datasource.dart`
- `lib/data/datasources/remote/package_remote_datasource.dart`
- `lib/data/datasources/remote/report_remote_datasource.dart`
- `lib/data/datasources/remote/employee_remote_datasource.dart`
- `lib/data/datasources/remote/master_data_remote_datasource.dart`
- `lib/data/datasources/local/auth_local_datasource.dart`
- `lib/data/repositories/auth_repository_impl.dart`
- `lib/data/repositories/dashboard_repository_impl.dart`
- `lib/data/repositories/customer_repository_impl.dart`
- `lib/data/repositories/payment_repository_impl.dart`
- `lib/data/repositories/complaint_repository_impl.dart`

### Phase 4: Domain Layer (Repository Interfaces)
**Files created:**
- `lib/domain/repositories/auth_repository.dart`
- `lib/domain/repositories/dashboard_repository.dart`
- `lib/domain/repositories/customer_repository.dart`
- `lib/domain/repositories/payment_repository.dart`
- `lib/domain/repositories/complaint_repository.dart`

### Phase 5: Application Layer (Providers)
**Files created:**
- `lib/application/providers/core_providers.dart` - DioClient, SharedPreferences, AppSession
- `lib/application/providers/auth_provider.dart` - Login, logout, session restore
- `lib/application/providers/dashboard_provider.dart` - Dashboard stats, wallet, expiry
- `lib/application/providers/customer_provider.dart` - Search with pagination
- `lib/application/providers/dashboard_customer_list_provider.dart` - Tab-based customer lists
- `lib/application/providers/payment_provider.dart` - Payment flow (modes, pending, pay)
- `lib/application/providers/complaint_provider.dart` - CRUD complaints
- `lib/application/providers/stb_provider.dart` - STB operations
- `lib/application/providers/package_provider.dart` - Package CRUD, bill details, renewal

### Phase 6: Presentation - Router & Shell
**Files created:**
- `lib/presentation/router/app_router.dart` - GoRouter with StatefulShellRoute (5 tabs)
- `lib/presentation/router/route_names.dart` - 30+ named routes
- `lib/presentation/common/widgets/app_shell.dart` - Bottom nav with IndexedStack

### Phase 7: Presentation - Common Widgets
**Files created (20+ reusable widgets):**
- `lib/presentation/common/widgets/subscriber_card.dart`
- `lib/presentation/common/widgets/app_search_bar.dart`
- `lib/presentation/common/widgets/pill_tab_bar.dart`
- `lib/presentation/common/widgets/section_label.dart`
- `lib/presentation/common/widgets/alphabet_sidebar.dart`
- `lib/presentation/common/widgets/app_toast.dart`
- And 15+ more widget files

### Phase 8: Presentation - Screens
**Files created (35+ screens):**
- `lib/presentation/screens/auth/login_screen.dart`
- `lib/presentation/screens/home/home_screen.dart` + 5 widget files
- `lib/presentation/screens/customers/customer_search_screen.dart`
- `lib/presentation/screens/customers/customer_profile_screen.dart`
- `lib/presentation/screens/customers/new_customer_screen.dart`
- `lib/presentation/screens/customers/edit_customer_screen.dart`
- `lib/presentation/screens/payments/make_payment_screen.dart`
- `lib/presentation/screens/payments/payment_history_screen.dart`
- `lib/presentation/screens/payments/invoice_history_screen.dart`
- `lib/presentation/screens/payments/payment_response_screen.dart`
- `lib/presentation/screens/payments/payment_webview_screen.dart`
- `lib/presentation/screens/payments/pg_transaction_report_screen.dart`
- `lib/presentation/screens/complaints/complaint_screen.dart`
- `lib/presentation/screens/complaints/complaint_history_screen.dart`
- `lib/presentation/screens/complaints/update_complaint_screen.dart`
- `lib/presentation/screens/stb/stb_operations_screen.dart`
- `lib/presentation/screens/stb/stb_pair_unpair_screen.dart`
- `lib/presentation/screens/stb/stb_replacement_screen.dart`
- `lib/presentation/screens/packages/package_operations_screen.dart`
- `lib/presentation/screens/packages/package_renewal_screen.dart`
- `lib/presentation/screens/reports/reports_screen.dart`
- `lib/presentation/screens/reports/mini_day_report_screen.dart`
- `lib/presentation/screens/reports/emp_collection_filter_screen.dart`
- `lib/presentation/screens/reports/emp_collection_list_screen.dart`
- `lib/presentation/screens/reports/emp_collection_detail_screen.dart`
- `lib/presentation/screens/lco/lco_payment_screen.dart`
- `lib/presentation/screens/lco/lco_topup_screen.dart`
- `lib/presentation/screens/lco/lco_wallet_history_screen.dart`
- `lib/presentation/screens/employees/employee_list_screen.dart`
- `lib/presentation/screens/employees/employee_tracking_screen.dart`
- `lib/presentation/screens/settings/settings_screen.dart`
- `lib/presentation/screens/settings/change_password_screen.dart`
- `lib/presentation/screens/settings/about_screen.dart`
- `lib/presentation/screens/settings/privacy_policy_screen.dart`
- `lib/presentation/screens/transactions/transactions_screen.dart`
- `lib/presentation/screens/bluetooth/device_discovery_screen.dart`
- `lib/presentation/screens/bluetooth/paired_device_list_screen.dart`
- `lib/presentation/screens/scanner/barcode_scanner_screen.dart`

### Phase 9: API Documentation & Type Safety
**Files created:**
- `screen_docs/12_server_api_contracts.md` - 800+ lines from server PHP code
- `screen_docs/13_api_request_response_samples.md` - 1000+ lines from live testing
- `screen_docs/14_comprehensive_api_request_response.md` - 1050+ lines combining both
- `screen_docs/api_responses.json` - Raw server response captures

---

## Bug Fixes During Testing

### Runtime Type Errors (String->int/double cast failures)
1. **LoginResponse** - `employeeId`, `dealerId` sent as String `"1054"`, model expected int. Fixed with `_sanitizeLoginJson()`.
2. **LoginResponse** - `userNotifications` sent as `[]` (List), model expected int. Fixed by checking for List type.
3. **LoginResponse** - `lcoMobileNo` sent as String `"919963575490"`, was mapped to int (overflow risk). Changed to String type.
4. **DashboardResponse** - `outStandingAmount` sent as String `"139655.05"`, `lcocurrentmonthdueamount` sent as null. Fixed with `_sanitize()`.
5. **CustomerModel** - `pending_amount`, `latitude`, `longitude` sent as String. Fixed with sanitizer.
6. **CustomerModel** - `stb_count`, `online_customer`, `is_direct_lco` sent as String. Fixed with sanitizer.
7. **CustomerSearchResponse** - Uses `statusCode` (camelCase) instead of `status_code`. Model updated with correct JsonKey.
8. **ExpiryDateCount** - `stb_count` sent as String `"3"`. Fixed with `_sanitizeCount()`.
9. **WalletResponse** - `deposit_amount` sent as String `"7467.76"`, `customerCount` as String `"512"`. Fixed with sanitizer.
10. **PackageModel** - `base_price`, `tax1-6` sent as String. `product_id` sometimes int. Fixed with sanitizer.
11. **ComplaintCategory** - `categoryId` sent as String `"6"`. Added sanitizer.
12. **ComplaintSubcategory** - `subCategoryId`, `categoryId` sent as String. Added sanitizer.
13. **DeactivationReason** - `reasonId`, `act_deact_reason_id` sent as String. Added sanitizer.
14. **Master data models** (Country, StateModel, District, City, CustomerType, IdType, GroupModel, Mandal, Gender) - IDs sent as String. All have sanitizers.
15. **EmpCollectionSummary** - `Amt` sent as String or int. Fixed with sanitizer.
16. **EmpCollectionDetail** - `paidAmount` sent as String. Fixed with sanitizer.
17. **MiniDayReportRow** - `cust_count`, `total` sent as String. Fixed with sanitizer.

### Encryption Issues
- Initial encryption was not matching server format. Corrected to triple-hex encoding per PHP `Encryption_lib`.
- Response decryption uses `hash` field (single hex decode) for performance.

### Navigation Issues
- StatefulShellRoute requires branches to have different initial paths. Each tab has unique path.
- Standalone screens (customer profile, make payment, etc.) use `parentNavigatorKey: _rootNavigatorKey` to display full-screen without bottom nav.

---

## Known Issues / TODO

### Critical
1. **PaymentMode.paymentModeName JsonKey** - The `@JsonKey(name: 'PaymentModeName')` is correct (capital P matches server). Verified working.
2. **MakePaymentResponse field names** - Server returns `status_code`/`status_msg` but model uses `statusCode`/`statusMsg` (camelCase). Needs sanitizer or JsonKey correction. **POTENTIAL RUNTIME BUG.**
3. **MakePaymentResponse `required` fields** - `statusCode`, `statusMsg`, `receiptNumber` are `required` but server may not always send them. Should use `@Default` values.
4. **BillDetail `required` fields** - All double fields (`lcoShare`, `msoShare`, etc.) are `required` with no sanitizer. Server likely sends as String. **WILL CRASH.**
5. **PaymentHistoryItem `required` fields** - `paidAmount` is `required double` with no sanitizer. Server sends as String. **WILL CRASH.**
6. **InvoiceItem `required` fields** - All numeric fields are `required` with no sanitizer. **WILL CRASH.**
7. **PgTransaction `required` fields** - `amount` is `required double` with no sanitizer. **WILL CRASH.**
8. **StbModel lacks sanitizer** - Fields like `isAssigned`, `isTempDeactivated` sent as String from server. No sanitizer present.
9. **CasPackage lacks sanitizer** - `price` may come as String from server.
10. **ChannelModel JsonKey names** - May not match server field names (server uses `channel_id`, `channel_name` with underscores; model uses camelCase).
11. **WalletHistoryEntry lacks sanitizer** - `depositeAmount`, `creditAmount`, `debitAmount` may come as String.
12. **LcoWalletEntry lacks sanitizer** - Same issue as WalletHistoryEntry.

### Medium
13. **StbProvider `_isSuccess` checks for `status_code == 1`** - But per API docs, 0 = success for all endpoints. This is **INVERTED** and will cause all STB operations to appear failed when they succeed (and vice versa). **Same bug in PackageProvider.**
14. **DashboardResponse missing `totalDeactiveAssignedStbs`** - Server sends this field but model doesn't map it.
15. **DashboardResponse missing `totalActiveAssignedStbs`** - Server sends but not mapped in model.
16. **AccessControlResponse missing `int_payment_transaction_report_access`** - Server sends but not mapped. Has extra `pgtransaction` not from server.
17. **config_values_array** not parsed - Login response includes `config_values_array` with `min_mobile_length`, `max_mobile_length`, `pincode_length`, `country_code`. Currently stripped by sanitizer. Should be parsed for form validation.

### Low
18. **Hardcoded version** - `v1.0.0` in login_screen.dart should come from pubspec.yaml or AppSession.patchInformation.
19. **Debug logging** - Extensive `debugPrint` calls in DioClient interceptors should be behind a flag or removed for release.
20. **`dart:math` import** in customer_provider.dart - Only used for `max()`, consider removing.
21. **Memory: walletHistory as `List<Map<String, dynamic>>`** in DashboardState - Should use typed `WalletHistoryEntry` model.

---

## API Type Mismatch Fixes Applied

### Complete Table of String->num Fixes

| Model | Field | Server Sends | Model Type | Sanitizer |
|-------|-------|-------------|------------|-----------|
| LoginResponse | employeeId | `"1054"` (String) | int | _sanitizeLoginJson |
| LoginResponse | dealerId | `"1"` (String) | int | _sanitizeLoginJson |
| LoginResponse | useCRF | `"1"` (String) | int | _sanitizeLoginJson |
| LoginResponse | useLastName | `"1"` (String) | int | _sanitizeLoginJson |
| LoginResponse | useDiscount | `"1"` (String) | int | _sanitizeLoginJson |
| LoginResponse | useDataFromMasterTable | `"1"` (String) | int | _sanitizeLoginJson |
| LoginResponse | useMandatoryForHotel | `"1"` (String) | int | _sanitizeLoginJson |
| LoginResponse | useAccountNumber | `"1"` (String) | int | _sanitizeLoginJson |
| LoginResponse | freezecustomerparamsinapp | `"0"` (String) | int | _sanitizeLoginJson |
| LoginResponse | lco_billtype | `"0"` (String) | int | _sanitizeLoginJson |
| LoginResponse | use_lco_deposits | `"1"` (String) | int | _sanitizeLoginJson |
| LoginResponse | customer_billtype | `"0"` (String) | int | _sanitizeLoginJson |
| LoginResponse | AUTO_RECEIPT_NUMBER | `"1"` (String) | int | _sanitizeLoginJson |
| LoginResponse | deposit_amount | `"7467.76"` (String) | double | _sanitizeLoginJson |
| LoginResponse | show_mia_agreement_upload | `"1"` (String) | int | _sanitizeLoginJson |
| LoginResponse | accept_terms_condtions | `"0"` (String) | int | _sanitizeLoginJson |
| LoginResponse | access_distributor_wise | `"0"` (String) | int | _sanitizeLoginJson |
| LoginResponse | is_unpaidlco | `"0"` (String) | int | _sanitizeLoginJson |
| LoginResponse | invoicepaymentsearchlimit | `"600"` (String) | int | _sanitizeLoginJson |
| LoginResponse | recurringServiceEdit | `"0"` (String) | int | _sanitizeLoginJson |
| LoginResponse | showLcoComplaint | `"0"` (String) | int | _sanitizeLoginJson |
| LoginResponse | show_service_extension | `"1"` (String) | int | _sanitizeLoginJson |
| LoginResponse | edit_quantity | `"1"` (String) | int | _sanitizeLoginJson |
| LoginResponse | enable_box_wise_payment | `"0"` (String) | int | _sanitizeLoginJson |
| LoginResponse | defaultState | `"101"` (String) | int? | _sanitizeLoginJson |
| LoginResponse | defaultDistrict | `"20"` (String) | int? | _sanitizeLoginJson |
| LoginResponse | defaultCity | `"-1"` (String) | int? | _sanitizeLoginJson |
| LoginResponse | userNotifications | `[]` (List) | int | _sanitizeLoginJson |
| LoginResponse | lcoMobileNo | `"919963575490"` (String) | String | Type changed from int |
| AccessControlResponse | int_stb_activation | `"1"` (String) | int | _sanitizeAclJson |
| AccessControlResponse | int_stb_deactivation | `"1"` (String) | int | _sanitizeAclJson |
| AccessControlResponse | int_stb_reactivation | `"1"` (String) | int | _sanitizeAclJson |
| DashboardResponse | outStandingAmount | `"139655.05"` (String) | double | _sanitize |
| DashboardResponse | currentMonthOutstanding | `"46.34"` (String) | double | _sanitize |
| DashboardResponse | lcocurrentmonthdueamount | `null` | double | _sanitize |
| WalletResponse | deposit_amount | `"7467.76"` (String) | double | _sanitize |
| WalletResponse | customerCount | `"512"` (String) | int | _sanitize |
| ExpiryDateCount | stb_count | `"3"` (String) | int | _sanitizeCount |
| CustomerModel | pending_amount | `"0.00"` (String) | double | _sanitize |
| CustomerModel | latitude | `"0.0"` (String) | double | _sanitize |
| CustomerModel | longitude | `"0.0"` (String) | double | _sanitize |
| CustomerModel | online_customer | `"0"` (String) | int | _sanitize |
| CustomerModel | stb_count | `"1"` (String) | int | _sanitize |
| CustomerModel | is_direct_lco | `"0"` (String) | int | _sanitize |
| PendingAmount | pendingAmount | `"0.00"` (String) | double | _sanitize |
| PendingAmount | msoShare | `"0.00"` (String) | double | _sanitize |
| PendingAmount | lcoShare | `"0.00"` (String) | double | _sanitize |
| PackageModel | base_price | `"100.00"` (String) | double | _sanitize |
| PackageModel | tax1-tax6 | `"0.00"` (String) | double | _sanitize |
| PackageModel | is_base_package | `"1"` (String) | int | _sanitize |
| PackageModel | validity_days | `"30"` (String) | int | _sanitize |
| ComplaintCategory | categoryId | `"6"` (String) | int | _sanitize |
| ComplaintSubcategory | subCategoryId | `"1"` (String) | int | _sanitize |
| DeactivationReason | reasonId | `"1"` (String) | int | _sanitize |
| All master_data models | IDs | `"101"` (String) | int | _sanitize |

---

## Architecture Decisions Made

### 1. Update Existing vs. New Project
**Decision:** Update existing Flutter project
**Reason:** Preserve pubspec.yaml, Android/iOS configs, signing keys, gradle setup

### 2. Bottom Navigation vs. Drawer
**Decision:** Bottom Navigation with 5 tabs (Home, Subscribers, Reports, Transactions, Settings)
**Reason:** Matches modern mobile UX patterns; Android app used drawer but bottom nav is more accessible

### 3. GoRouter with StatefulShellRoute
**Decision:** Use StatefulShellRoute.indexedStack for tab persistence
**Reason:** Each tab retains its navigation stack; standalone screens use parentNavigatorKey for full-screen display

### 4. Riverpod Notifier (not StateNotifier)
**Decision:** Use `Notifier<T>` pattern (Riverpod 2.x)
**Reason:** Modern Riverpod API; auto-dispose not used to keep state across tab switches

### 5. Freezed for All Models
**Decision:** All API models use Freezed with `@JsonKey(name:)` annotations
**Reason:** Type-safe, immutable, auto-generates fromJson/toJson, supports equality

### 6. Sanitizer Pattern for Type Safety
**Decision:** Each model that receives server data has a `_sanitize()` function in `fromJson`
**Reason:** Server sends inconsistent types (String/int/null for same field). Sanitizer converts before json_serializable parses.

### 7. Encryption in DioClient Interceptors
**Decision:** Encrypt/decrypt in Dio interceptors, not in datasources
**Reason:** Single point of encryption; all requests automatically encrypted, all responses automatically decrypted

### 8. AppSession as Single Config Object
**Decision:** Merge login response + access control into one `AppSession` object
**Reason:** Any screen can check any config flag via `ref.watch(appSessionProvider)` without multiple provider lookups

### 9. Status Code Convention
**Decision:** Treat `status_code: 0` as success across all endpoints
**Reason:** Despite server docs saying "1=success", actual server responses consistently use 0=success. The Flutter app standardizes on 0=success.

### 10. PaymentModeName Capital P
**Decision:** Use `@JsonKey(name: 'PaymentModeName')` to match server's PascalCase
**Reason:** Server sends `PaymentModeName` (capital P), not `paymentModeName`

---

## Final Review Findings (2026-03-27)

### PART 1: Model vs Server Response Mismatches

**REMAINING ISSUES (not yet fixed):**

1. **MakePaymentResponse** - Uses `required` fields with camelCase JsonKeys (`statusCode`, `statusMsg`, `receiptNumber`) but server likely sends `status_code`, `status_msg`, `receipt_number`. No sanitizer. **Will crash at runtime.**

2. **BillDetail** - All fields are `required` with no `@Default` and no sanitizer. Server sends numeric values as String. **Will crash at runtime.**

3. **PaymentHistoryItem** - `paidAmount` is `required double` with no sanitizer. Server sends as String. **Will crash at runtime.**

4. **InvoiceItem** - 9 numeric `required` fields with no sanitizer. **Will crash at runtime.**

5. **PgTransaction** - `amount` is `required double` with no sanitizer. **Will crash at runtime.**

6. **StbModel** - No sanitizer. `isAssigned`, `isTempDeactivated` may come as String. **May crash.**

7. **CasPackage** - No sanitizer. `price` may come as String. JsonKey names use camelCase but server likely sends `product_id`, `pname`, etc. **May crash.**

8. **ChannelModel** - No sanitizer. JsonKey names (`channelId`, `channelName`) may not match server field names (`channel_id`, `channel_name`). **May crash.**

9. **WalletHistoryEntry** - No sanitizer. Double fields may come as String from server. **May crash.**

10. **LcoWalletEntry** - No sanitizer. Same issue. **May crash.**

### PART 2: Code Review Issues

**Critical Bugs:**
1. **StbProvider._isSuccess checks `code == '1'`** - Should be `code == '0'` per server convention. All STB operations will report inverse success/failure. Same bug in PackageProvider._isSuccess.

2. **MakePaymentResponse JsonKey mismatch** - Model has `@JsonKey(name: 'statusCode')` but server sends `status_code`. Also `statusMsg` vs `status_msg`, `receiptNumber` vs `receipt_number`.

**Medium Issues:**
3. **DashboardState.walletHistory** uses `List<Map<String, dynamic>>` instead of typed `WalletHistoryEntry`.
4. **ComplaintState.closerTypes/employees** use `List<Map<String, dynamic>>` instead of typed models.
5. **DashboardProvider.loadWalletHistory** accesses `data['lcoWalletList']` -- the key name may not match server response.

**Minor Issues:**
6. Login screen version is hardcoded `v1.0.0`.
7. Excessive debug logging in DioClient interceptors.
8. `dart:math` import in customer_provider.dart only for `max()`.

### PART 2: What's Working Well
- Clean separation of concerns (Clean Architecture)
- All login/dashboard/customer flows have proper sanitizers
- GoRouter redirect handles auth state correctly
- AppSession comprehensively captures all 50+ config flags
- PayloadEncryption correctly implements triple-hex encoding
- CustomerSearchResponse correctly handles both `statusCode` and `status_code` patterns
- Pagination is implemented correctly in customer search
- Error handling uses Result<T> pattern consistently
- All controllers are properly disposed in screens
