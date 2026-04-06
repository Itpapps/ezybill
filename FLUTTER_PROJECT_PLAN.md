# EzyBill Flutter App - Project Plan (REST API v2)

## 1. Project Overview

**App Name:** EzyBill
**Platform:** Flutter (Android + iOS)
**Architecture:** Clean Architecture (4-layer)
**API Protocol:** REST API v2 ONLY (no SOAP/KSoap2)
**Base URL:** `http://itpworld.linkpc.net:81/developers/satyam/ezybmsys/app/index.php`
**REST Base:** `{BASE_URL}/customerRestservices/`

---

## 2. Tech Stack

| Category | Technology | Version |
|----------|-----------|---------|
| Framework | Flutter | SDK ^3.11.1 |
| State Management | Riverpod | ^3.0.0 |
| Routing | GoRouter | ^15.0.0 |
| HTTP Client | Dio | ^5.8.0 |
| Code Generation | Freezed + json_serializable | Latest |
| Local Storage | SharedPreferences | ^2.5.0 |
| Secure Storage | flutter_secure_storage | ^9.2.0 |
| Forms | flutter_form_builder + form_builder_validators | Latest |
| Maps | google_maps_flutter | ^2.12.0 |
| Location | geolocator | ^13.0.0 |
| Barcode Scanner | mobile_scanner | ^6.0.0 |
| Charts | fl_chart | ^0.70.0 |
| Icons | lucide_icons | ^0.300.0 |
| Fonts | google_fonts (DM Sans, Inter) | Latest |
| Image Caching | cached_network_image | ^3.4.0 |
| Connectivity | connectivity_plus | ^6.1.0 |
| PDF/Export | printing | ^5.13.0 |
| Date Formatting | intl | ^0.20.0 |
| Permissions | permission_handler | ^11.3.0 |

---

## 3. Architecture - Clean Architecture (4 Layers)

```
lib/
  core/                          # Shared utilities & config
    constants/
      api_constants.dart         # Base URLs, endpoint paths
      app_constants.dart         # SharedPrefs keys, app config
      ui_constants.dart          # Colors, text styles, dimensions
    network/
      dio_client.dart            # Dio instance, interceptors
      api_interceptor.dart       # Auth token injection
      api_exception.dart         # Custom exception classes
      network_info.dart          # Connectivity checker
    utils/
      validators.dart            # Form validators
      date_utils.dart            # Date formatting helpers
      string_utils.dart          # String helpers
    theme/
      app_theme.dart             # ThemeData (light/dark)
      app_colors.dart            # Color palette (#4361ee primary)
      app_text_styles.dart       # DM Sans / Inter typography

  data/                          # Data layer - API & local
    datasources/
      remote/
        auth_remote_datasource.dart
        dashboard_remote_datasource.dart
        customer_remote_datasource.dart
        complaint_remote_datasource.dart
        payment_remote_datasource.dart
        stb_remote_datasource.dart
        package_remote_datasource.dart
        employee_remote_datasource.dart
        report_remote_datasource.dart
        master_data_remote_datasource.dart
      local/
        auth_local_datasource.dart       # Token, user prefs
        cache_local_datasource.dart      # Offline data cache
    models/                              # JSON-serializable models
      auth/
        login_request.dart
        login_response.dart
        access_control_response.dart
      dashboard/
        dashboard_response.dart
        wallet_response.dart
        expiry_services_response.dart
      customer/
        customer_model.dart
        customer_detail_model.dart
        customer_search_response.dart
        customer_location_model.dart
      complaint/
        complaint_model.dart
        complaint_category_model.dart
        complaint_subcategory_model.dart
        complaint_list_response.dart
      payment/
        payment_model.dart
        payment_mode_model.dart
        pending_amount_model.dart
        receipt_range_model.dart
        pg_transaction_model.dart
        bill_detail_model.dart
      stb/
        stb_model.dart
        box_detail_model.dart
        deactivate_reason_model.dart
      package/
        package_model.dart
        active_package_model.dart
        unassigned_package_model.dart
      employee/
        employee_model.dart
        employee_collection_model.dart
      report/
        daily_report_model.dart
        invoice_model.dart
        payment_history_model.dart
      master/
        country_model.dart
        state_model.dart
        district_model.dart
        city_model.dart
        mandal_model.dart
        location_model.dart
        group_model.dart
        customer_type_model.dart
        id_type_model.dart
    repositories/                        # Repository implementations
      auth_repository_impl.dart
      dashboard_repository_impl.dart
      customer_repository_impl.dart
      complaint_repository_impl.dart
      payment_repository_impl.dart
      stb_repository_impl.dart
      package_repository_impl.dart
      employee_repository_impl.dart
      report_repository_impl.dart
      master_data_repository_impl.dart

  domain/                        # Business logic layer
    entities/                    # Pure Dart entity classes
      user.dart
      customer.dart
      complaint.dart
      payment.dart
      stb_box.dart
      package.dart
      employee.dart
      report.dart
    repositories/                # Abstract repository contracts
      auth_repository.dart
      dashboard_repository.dart
      customer_repository.dart
      complaint_repository.dart
      payment_repository.dart
      stb_repository.dart
      package_repository.dart
      employee_repository.dart
      report_repository.dart
      master_data_repository.dart

  application/                   # Riverpod providers & state
    providers/
      auth_provider.dart
      dashboard_provider.dart
      customer_provider.dart
      complaint_provider.dart
      payment_provider.dart
      stb_provider.dart
      package_provider.dart
      employee_provider.dart
      report_provider.dart
      master_data_provider.dart
    states/
      auth_state.dart
      dashboard_state.dart
      customer_state.dart
      async_value_extensions.dart

  presentation/                  # UI layer
    router/
      app_router.dart            # GoRouter configuration
      route_names.dart           # Named route constants
    common/
      widgets/
        app_scaffold.dart        # Common scaffold with nav
        status_bar.dart          # Custom status bar
        bottom_nav_bar.dart      # Bottom navigation pill
        loading_overlay.dart     # Loading indicator
        error_widget.dart        # Error display
        search_bar.dart          # Reusable search input
        stat_card.dart           # Summary statistic card
        empty_state.dart         # Empty list placeholder
    screens/
      auth/
        login_screen.dart
        widgets/
          login_form.dart
      home/
        home_screen.dart
        widgets/
          dashboard_stats.dart
          quick_actions.dart
          recent_activity.dart
          wallet_card.dart
      drawer/
        side_menu.dart
        widgets/
          menu_item.dart
          user_profile_header.dart
      wallet/
        wallet_history_screen.dart
      customer/
        customer_search_screen.dart
        customer_profile_screen.dart
        new_customer_screen.dart
        edit_customer_screen.dart
        widgets/
          customer_card.dart
          customer_form.dart
      complaint/
        complaint_operations_screen.dart
        new_complaint_screen.dart
        complaint_history_screen.dart
        widgets/
          complaint_card.dart
          complaint_filter.dart
      payment/
        make_payment_screen.dart
        payment_history_screen.dart
        widgets/
          payment_form.dart
          payment_card.dart
      stb/
        stb_operations_screen.dart
        stb_pair_unpair_screen.dart
        widgets/
          stb_card.dart
          scanner_widget.dart
      package/
        package_operations_screen.dart
        widgets/
          package_card.dart
          package_action_sheet.dart
      report/
        reports_screen.dart
        daily_report_screen.dart
        employee_collection_screen.dart
        pg_transactions_screen.dart
        invoice_history_screen.dart
        payment_history_report_screen.dart
      employee/
        employee_list_screen.dart
        employee_tracking_screen.dart
        widgets/
          employee_card.dart
          tracking_map.dart
      settings/
        settings_screen.dart
        widgets/
          profile_section.dart
          app_info_section.dart

  main.dart                      # App entry point
```

---

## 4. Implementation Phases

### Phase 1: Foundation (Week 1-2)
| # | Task | Priority |
|---|------|----------|
| 1.1 | Setup pubspec.yaml with all dependencies | CRITICAL |
| 1.2 | Create core/ folder structure (constants, network, theme) | CRITICAL |
| 1.3 | Implement Dio client with auth interceptor | CRITICAL |
| 1.4 | Define app theme (colors, typography from UI designs) | HIGH |
| 1.5 | Setup GoRouter with all route definitions | HIGH |
| 1.6 | Create common widgets (scaffold, nav bar, status bar) | HIGH |

### Phase 2: Authentication & Dashboard (Week 2-3)
| # | Task | Priority |
|---|------|----------|
| 2.1 | Login screen UI + form validation | CRITICAL |
| 2.2 | Auth REST API integration (validateLogin) | CRITICAL |
| 2.3 | Token storage (flutter_secure_storage) | CRITICAL |
| 2.4 | Access control API (getaccesscontroll) | HIGH |
| 2.5 | Dashboard screen with stats | CRITICAL |
| 2.6 | Dashboard API (dashBoardDetails, lco_deposit_amount) | CRITICAL |
| 2.7 | LCO Wallet API (getlcowallet) | HIGH |
| 2.8 | Side menu / drawer | HIGH |
| 2.9 | Wallet history modal | MEDIUM |

### Phase 3: Customer Management (Week 3-4)
| # | Task | Priority |
|---|------|----------|
| 3.1 | Customer search screen + API (getCustomerDetailsCount, getCustomerDetails) | CRITICAL |
| 3.2 | Customer profile screen | CRITICAL |
| 3.3 | New customer creation form + API (saveCustomer, existingCustomer) | HIGH |
| 3.4 | Edit customer + API (editCustomer) | HIGH |
| 3.5 | Customer location update (updateCustomerLocation) | MEDIUM |
| 3.6 | Master data APIs (countries, states, districts, cities, mandals, groups, IDs, customer types) | HIGH |

### Phase 4: Payments (Week 4-5)
| # | Task | Priority |
|---|------|----------|
| 4.1 | Make payment screen + form | CRITICAL |
| 4.2 | Payment APIs (getPendingAmount, makePayments, getPaymentModes) | CRITICAL |
| 4.3 | Receipt ranges API (getReceiptRanges) | HIGH |
| 4.4 | Bill details API (getbilldetails) | HIGH |
| 4.5 | Payment gateway integration (mobile_paymentsview) | HIGH |
| 4.6 | Payment history screen + API (PaymentService) | MEDIUM |
| 4.7 | PG transaction logs (pgTransactionLogs) | MEDIUM |

### Phase 5: Complaints (Week 5-6)
| # | Task | Priority |
|---|------|----------|
| 5.1 | Complaint operations screen | HIGH |
| 5.2 | Complaint list API (getComplaintList, gettotalcomplaintslist) | HIGH |
| 5.3 | New complaint form + APIs (complaintCategories, getComplaintsubCategory, complaintErrors, createComplaint) | HIGH |
| 5.4 | Complaint history + close complaint API | HIGH |
| 5.5 | Assign employee to complaint (getLcoEmployeeList, getServiceEmployeeList) | MEDIUM |

### Phase 6: STB & Package Operations (Week 6-7)
| # | Task | Priority |
|---|------|----------|
| 6.1 | STB operations screen (deactivateBox, reactivateBox, temporaryActivation) | HIGH |
| 6.2 | STB pair/unpair (stbpair, stbUnpair) | HIGH |
| 6.3 | Box scanner (validateBoxInfo) | HIGH |
| 6.4 | Package operations (getCustomerPackages_split, activateService, deactivateService) | HIGH |
| 6.5 | Unassigned packages (getUnassignedPackages_split) | MEDIUM |
| 6.6 | Extend services (extendCustomerServices) | MEDIUM |
| 6.7 | CAS packages (getCasPackages) | LOW |

### Phase 7: Reports & Employee Tracking (Week 7-8)
| # | Task | Priority |
|---|------|----------|
| 7.1 | Reports dashboard screen | HIGH |
| 7.2 | Daily collection report API (dailyreport) | HIGH |
| 7.3 | Employee collection report (empCollection, empCustomerCollectionDetails) | MEDIUM |
| 7.4 | Invoice history (InvoiceService) | MEDIUM |
| 7.5 | Employee list screen (getLcoEmployeeList) | MEDIUM |
| 7.6 | Employee tracking screen with Google Maps | MEDIUM |
| 7.7 | Expiry services count (getExpiryServicesDateWiseCount) | LOW |

### Phase 8: Polish & Release (Week 8-9)
| # | Task | Priority |
|---|------|----------|
| 8.1 | Settings/profile screen | MEDIUM |
| 8.2 | App version check (appVersionCheck) | MEDIUM |
| 8.3 | OTP validation flow (customer_validationwithmobile, customer_otp_validation) | MEDIUM |
| 8.4 | Dynamic form validations (dynamicformvalidations) | LOW |
| 8.5 | Error handling & offline mode | HIGH |
| 8.6 | Performance optimization | HIGH |
| 8.7 | Testing (unit + widget tests) | HIGH |
| 8.8 | Android/iOS build & release prep | CRITICAL |

---

## 5. Key Design Decisions

### 5.1 REST API v2 Only
- All SOAP/KSoap2 endpoints from the old Android app will be called via their REST v2 equivalents
- The server already supports REST endpoints for all major operations at `/customerRestservices/`
- Authentication uses token-based auth (`authtoken` field in POST body)

### 5.2 Authentication Flow
1. User enters credentials on login screen
2. POST to `validateLogin` endpoint
3. Server returns auth token + user details (dealer_id, employee_id, user type)
4. Token stored in flutter_secure_storage
5. All subsequent API calls include `authtoken` in POST body via Dio interceptor
6. Access control fetched via `getaccesscontroll` to show/hide features

### 5.3 State Management
- Riverpod 3.0 with code generation
- AsyncNotifier for API-driven state
- StateNotifier for local UI state
- Providers organized by feature module

### 5.4 Navigation
- GoRouter with named routes
- Shell routes for bottom navigation
- Auth guard redirect for unauthenticated users
- Deep linking support

### 5.5 UI/UX Design Tokens
| Token | Value |
|-------|-------|
| Primary | #4361EE |
| Primary Dark | #3651D4 |
| Primary Light | #EEF1FD |
| Background | #F6F7F8 |
| White | #FFFFFF |
| Text Primary | #1A1A1A |
| Text Secondary | #6B7280 |
| Text Muted | #9CA3AF |
| Border | #E5E7EB |
| Success | #22C55E |
| Danger | #EF4444 |
| Warning | #F59E0B |
| Info | #6366F1 |
| Font Primary | DM Sans |
| Font Secondary | Inter |

---

## 6. API Architecture (Verified from Server Code)

**Server Controller:** `LcoRestServices.php` (70 REST endpoints, all POST except 1 GET)
**Server Framework:** CodeIgniter REST_Controller
**All endpoints are REST** - the server has `*Rest` suffixed methods for every operation. No SOAP needed.

### Key Server-Side Details:
1. **Payload Encryption:** Server uses `Encryption_lib->checkPayload()` to decrypt payloads. Flutter must implement matching encryption.
2. **JWT Auth:** Token sent via HTTP header, server uses `getJwtTokenData()` to verify.
3. **Auto-derived IDs:** `employeeId` and `dealerId` are extracted from JWT by server - many endpoints don't need these in body.
4. **IP Restriction:** Server validates client IP via `iprestriction_check()`.
5. **Parallel Login:** If dealer has `ENABLE_PARALLEL_LOGIN` enabled, only one session per employee.

### Endpoint Naming Convention:
```
POST {BASE_URL}/customerRestservices/{methodName}
```
Examples:
- Login: `/customerRestservices/validateLogin`
- Dashboard: `/customerRestservices/dashBoardDetailsRest`
- Customer Search: `/customerRestservices/getCustomerDetailsCountRest`
- Make Payment: `/customerRestservices/makePaymentsRest`

### Endpoint Counts by Category:
| Category | Count |
|----------|-------|
| Authentication | 2 |
| Dashboard | 5 |
| Customer Management | 6 |
| Payments | 8 |
| Complaints | 9 |
| STB/Box Operations | 10 |
| Package/Service Ops | 10 |
| Reports | 7 |
| Employees | 2 |
| Master Data | 11 |
| **Total** | **70** |

See `REST_API_V2_SERVICE_DOCUMENT.md` for complete endpoint reference with exact parameter names and response fields verified from server source code.

---

## 7. UI Screens (15 Designed)

1. Login Screen
2. Home Screen / Dashboard
3. Side Menu / Drawer
4. Wallet History Modal
5. Search Customer
6. Customer Profile
7. New Customer Form
8. Make Payment
9. Complaint Operations
10. STB Operations
11. Package Operations
12. Reports
13. Settings / Profile
14. Employee List
15. Employee Tracking

All screen designs are available in the `.pen` UI file at:
`D:\ITP2026\android\Flutter_ezybill\Flutter_ezybill_UI`
