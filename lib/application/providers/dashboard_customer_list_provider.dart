import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../core/utils/result.dart';
import '../../data/datasources/remote/dashboard_remote_datasource.dart';
import '../../data/models/customer/customer_model.dart';
import '../../data/models/customer/customer_search_response.dart';
import '../../domain/repositories/customer_repository.dart';
import 'core_providers.dart';
import 'customer_provider.dart';
import 'dashboard_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tab filter types for dashboard customer list
// ─────────────────────────────────────────────────────────────────────────────

enum CustomerFilterTab {
  active('Active'),
  inactive('Inactive'),
  fresh('Fresh'),
  assigned('Assigned');

  final String label;
  const CustomerFilterTab(this.label);

  /// Maps to getdashboardlist from_dashboard param.
  int get fromDashboard => switch (this) {
    CustomerFilterTab.active => 4,
    CustomerFilterTab.inactive => 5,
    CustomerFilterTab.fresh => 2, // Unassigned/Fresh STBs
    CustomerFilterTab.assigned => 1,
  };

  bool get hasListEndpoint => true; // All tabs now use getdashboardlist
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class DashboardCustomerListState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final CustomerFilterTab selectedTab;
  final List<CustomerModel> customers;
  final int totalCount;
  final int currentPage;
  final bool hasMore;

  const DashboardCustomerListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.selectedTab = CustomerFilterTab.active,
    this.customers = const [],
    this.totalCount = 0,
    this.currentPage = 0,
    this.hasMore = false,
  });

  /// Alias used by the widget layer.
  List<CustomerModel> get allCustomers => customers;

  /// Visible customers for display.
  List<CustomerModel> get visibleCustomers => customers;

  DashboardCustomerListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    CustomerFilterTab? selectedTab,
    List<CustomerModel>? customers,
    int? totalCount,
    int? currentPage,
    bool? hasMore,
  }) {
    return DashboardCustomerListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      selectedTab: selectedTab ?? this.selectedTab,
      customers: customers ?? this.customers,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Dashboard tab page size — show first 50 records per tab.
const int _serverPageSize = 50;

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class DashboardCustomerListNotifier
    extends Notifier<DashboardCustomerListState> {
  late CustomerRepository _customerRepo;
  late DashboardRemoteDatasource _dashboardDs;
  late DioClient _dio;

  @override
  DashboardCustomerListState build() {
    _customerRepo = ref.watch(customerRepositoryProvider);
    _dashboardDs = ref.watch(dashboardRemoteDatasourceProvider);
    _dio = ref.watch(dioClientProvider);
    return const DashboardCustomerListState();
  }

  String get _authtoken => _dio.authToken ?? '';

  /// Search by free text query — triggers API call.
  Future<void> searchByQuery(String query) async {
    state = state.copyWith(
      isLoading: true,
      customers: [],
      totalCount: 0,
      currentPage: 0,
      hasMore: false,
      errorMessage: null,
    );

    try {
      // Try to guess the field: if digits, search by mobile; otherwise by name
      final isNumeric = RegExp(r'^\d+$').hasMatch(query.replaceAll(' ', ''));

      final searchResult = await _customerRepo.searchCustomers(
        customerName: isNumeric ? null : query,
        mobileNumber: isNumeric ? query : null,
        startValue: 0,
        endValue: _serverPageSize,
      );

      switch (searchResult) {
        case Success(:final data):
          state = state.copyWith(
            isLoading: false,
            customers: data.existCustomerDetails,
            totalCount: data.customerCount,
            hasMore: data.existCustomerDetails.length < data.customerCount,
          );
        case Failure(:final message):
          state = state.copyWith(isLoading: false, errorMessage: message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Switch tab and load first page.
  Future<void> selectTab(CustomerFilterTab tab) async {
    if (tab == state.selectedTab && state.customers.isNotEmpty) return;

    state = state.copyWith(
      selectedTab: tab,
      customers: [],
      totalCount: 0,
      currentPage: 0,
      hasMore: false,
      errorMessage: null,
    );

    // All tabs use getdashboardlist with the appropriate from_dashboard value
    await _loadFromDashboardList(
      fromDashboard: tab.fromDashboard,
      page: 0,
    );
  }

  /// Extract a list of maps from a dashboard response.
  List<Map<String, dynamic>> _extractCustomerList(Map<String, dynamic> data) {
    for (final key in [
      'getDashboardDataList',
      'dashboardCustomerList',
      'customerDetailsList',
      'data',
    ]) {
      final items = data[key];
      if (items is List && items.isNotEmpty) {
        return items.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  /// Active tab: uses getdashboardlist with from_dashboard=4.
  Future<void> _loadActiveCustomers({required int page}) async {
    await _loadFromDashboardList(
      fromDashboard: 4, // 4 = active customers
      page: page,
    );
  }

  /// Generic loader using getdashboardlist endpoint.
  /// from_dashboard: 1=assigned, 2=unassigned, 3=all, 4=active, 5=inactive
  Future<void> _loadFromDashboardList({
    required int fromDashboard,
    required int page,
  }) async {
    final isFirstPage = page == 0;
    state = state.copyWith(
      isLoading: isFirstPage,
      isLoadingMore: !isFirstPage,
      errorMessage: null,
    );

    try {
      final session = ref.read(appSessionProvider);
      final dealerId = session?.dealerId ?? 0;

      debugPrint('[CUST-LIST] Loading from_dashboard=$fromDashboard, dealerId=$dealerId');
      final response = await _dashboardDs.getDashboardCustomerList(
        authtoken: _authtoken,
        dealerId: dealerId,
        fromDashboard: fromDashboard,
      );

      debugPrint('[CUST-LIST] Response keys: ${response.keys.toList()}');
      debugPrint('[CUST-LIST] status_code: ${response['status_code']}');
      final rawList = _extractCustomerList(response);
      debugPrint('[CUST-LIST] Got ${rawList.length} records from getdashboardlist');

      // Convert raw maps to typed CustomerModel
      final allRecords = rawList.map((m) {
        try {
          // Map getdashboardlist fields to CustomerModel fields
          final normalized = <String, dynamic>{
            'customer_id': m['customer_id']?.toString() ?? '',
            'customerName': m['customer_name']?.toString() ?? '',
            'mobile_no': m['mobile_no']?.toString() ?? '',
            'installation_address': m['installation_address']?.toString() ?? '',
            'account_number': m['account_number']?.toString() ?? '',
            'status': m['is_active'] == 'YES' ? '1' : '0',
            'caf_no': m['account_number']?.toString() ?? '',
            'stb_count': '1',
            'pending_amount': '0',
            'reseller_id': m['reseller_id']?.toString() ?? '',
            'is_direct_lco': '0',
            'latitude': '0.0',
            'longitude': '0.0',
            // STB info from dashboard list
            'serial_number': m['serial_number']?.toString() ?? '',
            'vc_number': m['vc_number']?.toString() ?? '',
            // CAS type stored in baid field for fresh box display
            'baid': m['cas']?.toString() ?? '',
          };
          return CustomerModel.fromJson(normalized);
        } catch (e) {
          debugPrint('[CUST-LIST] Parse error: $e');
          return null;
        }
      }).whereType<CustomerModel>().toList();

      // Client-side pagination
      final startIndex = page * _serverPageSize;
      final endIndex = (startIndex + _serverPageSize).clamp(0, allRecords.length);
      final pageRecords = startIndex < allRecords.length
          ? allRecords.sublist(startIndex, endIndex)
          : <CustomerModel>[];

      final allCustomers = isFirstPage
          ? pageRecords
          : [...state.customers, ...pageRecords];

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        customers: allCustomers,
        totalCount: allRecords.length,
        currentPage: page,
        hasMore: allCustomers.length < allRecords.length,
      );
    } catch (e) {
      debugPrint('[CUST-LIST] Error: $e');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }

  /// Inactive tab: uses getdashboardlist with from_dashboard=5.
  Future<void> _loadInactiveCustomers() async {
    await _loadFromDashboardList(
      fromDashboard: 5, // 5 = inactive customers
      page: 0,
    );
  }

  /// Load next page (Active tab only -- server-side pagination).
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    if (state.selectedTab == CustomerFilterTab.active) {
      await _loadActiveCustomers(page: state.currentPage + 1);
    }
  }

  /// Refresh current tab.
  Future<void> refresh() async {
    final tab = state.selectedTab;
    state = state.copyWith(
      customers: [],
      totalCount: 0,
      currentPage: 0,
      hasMore: false,
    );
    // Force reload even if same tab.
    switch (tab) {
      case CustomerFilterTab.active:
        await _loadActiveCustomers(page: 0);
      case CustomerFilterTab.inactive:
        await _loadInactiveCustomers();
      default:
        break;
    }
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final dashboardCustomerListProvider = NotifierProvider<
    DashboardCustomerListNotifier,
    DashboardCustomerListState>(DashboardCustomerListNotifier.new);
