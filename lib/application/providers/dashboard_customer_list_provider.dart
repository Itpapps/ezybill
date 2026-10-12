import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../core/utils/result.dart';
import '../../data/datasources/remote/dashboard_remote_datasource.dart';
import '../../data/models/customer/customer_model.dart';
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

/// Sort order of the dashboard list. "Area" is intentionally absent:
/// getdashboardlist does not send the customer's location (`location_id` is
/// commented out of its keys, LcoRestServices.php:8371).
enum DashboardSort { name, dueDate }

/// Stable sort: ties keep the server's order, and rows without a value
/// (no name, no or invalid due date) go to the end.
List<CustomerModel> sortDashboardCustomers(
  List<CustomerModel> list,
  DashboardSort sort,
) {
  String nameKey(CustomerModel c) => c.customerName.trim().toLowerCase();
  DateTime? dueKey(CustomerModel c) {
    final d = DateTime.tryParse(c.serviceEndDate?.trim() ?? '');
    // "0000-00-00" parses to a year-0 date; treat it as no date.
    return (d == null || d.year < 1900) ? null : d;
  }

  int byName(CustomerModel a, CustomerModel b) {
    final x = nameKey(a), y = nameKey(b);
    if (x.isEmpty != y.isEmpty) return x.isEmpty ? 1 : -1;
    return x.compareTo(y);
  }

  int byDue(CustomerModel a, CustomerModel b) {
    final x = dueKey(a), y = dueKey(b);
    if ((x == null) != (y == null)) return x == null ? 1 : -1;
    if (x != null && y != null) {
      final c = x.compareTo(y);
      if (c != 0) return c;
    }
    return byName(a, b);
  }

  final indexed = list.indexed.toList();
  indexed.sort((a, b) {
    final c = sort == DashboardSort.name ? byName(a.$2, b.$2) : byDue(a.$2, b.$2);
    return c != 0 ? c : a.$1.compareTo(b.$1);
  });
  return [for (final e in indexed) e.$2];
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
  /// 1-based page index for UI pagination.
  final int currentPage;
  final DashboardSort sort;

  const DashboardCustomerListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.selectedTab = CustomerFilterTab.active,
    this.customers = const [],
    this.totalCount = 0,
    this.currentPage = 1,
    this.sort = DashboardSort.name,
  });

  /// Alias used by the widget layer.
  List<CustomerModel> get allCustomers => customers;

  /// Visible customers for display.
  List<CustomerModel> get visibleCustomers => customers;

  int get pageSize => _pageSize;

  int get pageCount {
    if (totalCount <= 0) return 1;
    final pages = (totalCount / pageSize).ceil();
    return pages <= 0 ? 1 : pages;
  }

  List<CustomerModel> get pageCustomers {
    if (customers.isEmpty) return const [];
    final safePage = currentPage.clamp(1, pageCount);
    final start = (safePage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, customers.length);
    if (start >= customers.length) return const [];
    return customers.sublist(start, end);
  }

  DashboardCustomerListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    CustomerFilterTab? selectedTab,
    List<CustomerModel>? customers,
    int? totalCount,
    int? currentPage,
    DashboardSort? sort,
  }) {
    return DashboardCustomerListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      selectedTab: selectedTab ?? this.selectedTab,
      customers: customers ?? this.customers,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      sort: sort ?? this.sort,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Dashboard list pagination size — match Android list (15 rows per page).
const int _pageSize = 15;

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
    debugPrint('=== searchByQuery TRIGGERED ===');
    debugPrint('  query: "$query"');
    debugPrint('  current tab: ${state.selectedTab}');
    debugPrint('  fromDashboard that SHOULD filter: ${state.selectedTab.fromDashboard}');
    debugPrint('  fromDashboard actually sent to API: NOTHING');
    state = state.copyWith(
      isLoading: true,
      customers: [],
      totalCount: 0,
      currentPage: 1,
      errorMessage: null,
    );

    try {
      // Try to guess the field: if digits, search by mobile; otherwise by name
      final isNumeric = RegExp(r'^\d+$').hasMatch(query.replaceAll(' ', ''));

      debugPrint('  isNumeric=$isNumeric → customerName=${isNumeric ? null : query} mobileNumber=${isNumeric ? query : null}');

      final searchResult = await _customerRepo.searchCustomers(
        customerName: isNumeric ? null : query,
        mobileNumber: isNumeric ? query : null,
        startValue: 0,
        endValue: _pageSize,
      );

      switch (searchResult) {
        case Success(:final data):
          debugPrint('=== searchByQuery RESPONSE ===');
          debugPrint('  total returned: ${data.existCustomerDetails.length}');
          for (final c in data.existCustomerDetails) {
            debugPrint('=== SEARCH RESULT CUSTOMER ===');
            debugPrint('  id=${c.customerId}');
            debugPrint('  name=${c.customerName}');
            debugPrint('  status=${c.status}');
          }
          state = state.copyWith(
            isLoading: false,
            customers:
                sortDashboardCustomers(data.existCustomerDetails, state.sort),
            totalCount: data.customerCount,
            currentPage: 1,
          );
          debugPrint('=== state.customers UPDATED ===');
          debugPrint('  new count: ${state.customers.length}');
          debugPrint('  current tab still: ${state.selectedTab}');
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
      currentPage: 1,
      errorMessage: null,
    );

    // All tabs use getdashboardlist with the appropriate from_dashboard value
    await _loadFromDashboardList(
      fromDashboard: tab.fromDashboard,
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


  /// Generic loader using getdashboardlist endpoint.
  /// from_dashboard: 1=assigned, 2=unassigned, 3=all, 4=active, 5=inactive
  Future<void> _loadFromDashboardList({
    required int fromDashboard,
  }) async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
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
          // Server returns: serial_number, mac_address, stock_id, box_number,
          // vc_number, dealer_id, reseller_id, is_assigned, assigned_date,
          // customer_name, account_number, mobile_no, customer_id, cas,
          // is_active, activate_date, installation_address, service_enddate,
          // pending_amount (if available)
          final isActive = m['is_active'];
          final statusVal = (isActive == 'YES' || isActive == '1' || isActive == 1)
              ? '1'
              : '0';
          debugPrint('[CUST-LIST] id=${m['customer_id']} name="${m['customer_name']}" '
              'raw_is_active=$isActive → status=$statusVal fromDashboard=$fromDashboard');
          // Read pending_amount from server if available, otherwise default
          final pendingAmt = m['pending_amount']?.toString() ?? '0.00';
          final normalized = <String, dynamic>{
            'customer_id': m['customer_id']?.toString() ?? '',
            'customerName': m['customer_name']?.toString() ?? '',
            'mobile_no': m['mobile_no']?.toString() ?? '',
            'installation_address': m['installation_address']?.toString() ?? '',
            'billing_address': m['billing_address']?.toString() ??
                m['installation_address']?.toString() ?? '',
            'account_number': m['account_number']?.toString() ?? '',
            'status': statusVal,
            'caf_no': m['account_number']?.toString() ?? '',
            'stb_count': '1',
            'pending_amount': pendingAmt,
            'reseller_id': m['reseller_id']?.toString() ?? '',
            'is_direct_lco': '0',
            'latitude': '0.0',
            'longitude': '0.0',
            // STB info from dashboard list
            'serial_number': m['serial_number']?.toString() ?? '',
            'vc_number': m['vc_number']?.toString() ?? '',
            // CAS type stored in baid field for fresh box display
            'baid': m['cas']?.toString() ?? '',
            // Due date — drives the "Due date" sort.
            'service_enddate': m['service_enddate']?.toString(),
          };
          return CustomerModel.fromJson(normalized);
        } catch (e) {
          debugPrint('[CUST-LIST] Parse error: $e');
          return null;
        }
      }).whereType<CustomerModel>().toList();

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        customers: sortDashboardCustomers(allRecords, state.sort),
        totalCount: allRecords.length,
        currentPage: 1,
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


  /// Re-sorts the loaded list and returns to page 1. The choice is kept in
  /// state, so tab switches and refreshes come back sorted the same way.
  void setSort(DashboardSort sort) {
    if (sort == state.sort) return;
    state = state.copyWith(
      sort: sort,
      customers: sortDashboardCustomers(state.customers, sort),
      currentPage: 1,
      errorMessage: state.errorMessage,
    );
  }

  void goToPage(int page) {
    if (state.customers.isEmpty) return;
    final safe = page.clamp(1, state.pageCount);
    if (safe == state.currentPage) return;
    state = state.copyWith(currentPage: safe);
  }

  /// Refresh current tab.
  Future<void> refresh() async {
    final tab = state.selectedTab;
    state = state.copyWith(
      customers: [],
      totalCount: 0,
      currentPage: 1,
    );
    // Force reload — works for all tabs (active, inactive, fresh, assigned).
    await _loadFromDashboardList(fromDashboard: tab.fromDashboard);
  }

}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final dashboardCustomerListProvider = NotifierProvider<
    DashboardCustomerListNotifier,
    DashboardCustomerListState>(DashboardCustomerListNotifier.new);
