import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/result.dart';
import '../../data/datasources/remote/customer_remote_datasource.dart';
import '../../data/models/customer/customer_model.dart';
import '../../data/models/customer/customer_search_response.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/repositories/customer_repository.dart';
import 'core_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Datasource & Repository providers
// ─────────────────────────────────────────────────────────────────────────────

final customerRemoteDatasourceProvider =
    Provider<CustomerRemoteDatasource>((ref) {
  return CustomerRemoteDatasource(dio: ref.watch(dioClientProvider));
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(ref.watch(customerRemoteDatasourceProvider), ref.watch(dioClientProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// Search field enum
// ─────────────────────────────────────────────────────────────────────────────

/// The six search fields supported by the customer search API.
enum CustomerSearchField {
  customerNumber('Customer #'),
  customerName('Name'),
  mobileNumber('Mobile'),
  boxNumber('STB #'),
  lcoCustomerId('LCO ID'),
  cafNumber('CAF #');

  final String label;
  const CustomerSearchField(this.label);
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

/// Items returned per page — matches Android's NUM_ITEMS_PAGE = 100.
const int kCustomerPageSize = 100;

class CustomerSearchState {
  final bool isLoading;
  final String? errorMessage;
  final List<CustomerModel> customers;
  final int totalCount;
  final int currentPage;
  final String searchQuery;
  final CustomerSearchField searchField;

  const CustomerSearchState({
    this.isLoading = false,
    this.errorMessage,
    this.customers = const [],
    this.totalCount = 0,
    this.currentPage = 0,
    this.searchQuery = '',
    this.searchField = CustomerSearchField.customerName,
  });

  /// Total pages, at least 1 when there are results.
  int get totalPages =>
      totalCount == 0 ? 0 : (totalCount / kCustomerPageSize).ceil();

  bool get hasNextPage => currentPage < totalPages - 1;
  bool get hasPrevPage => currentPage > 0;
  bool get hasResults => customers.isNotEmpty;

  CustomerSearchState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<CustomerModel>? customers,
    int? totalCount,
    int? currentPage,
    String? searchQuery,
    CustomerSearchField? searchField,
  }) {
    return CustomerSearchState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      customers: customers ?? this.customers,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      searchField: searchField ?? this.searchField,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class CustomerSearchNotifier extends Notifier<CustomerSearchState> {
  late CustomerRepository _repo;

  @override
  CustomerSearchState build() {
    _repo = ref.watch(customerRepositoryProvider);
    return const CustomerSearchState();
  }

  /// Main search entry point.  Gets count first, then fetches page 0.
  Future<void> searchCustomers(
    String query,
    CustomerSearchField field, {
    int page = 0,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      searchQuery: trimmed,
      searchField: field,
      currentPage: page,
    );

    try {
      final params = _buildParams(trimmed, field);

      // ── Get count (only on first page to avoid redundant calls) ──
      int totalCount = state.totalCount;
      if (page == 0) {
        final countResult = await _repo.getCustomerDetailsCount(
          customerNumber: params['customerNumber'],
          customerName: params['customerName'],
          mobileNumber: params['mobileNumber'],
          boxNumber: params['boxNumber'],
          lcoCustomerId: params['lcoCustomerId'],
        );

        switch (countResult) {
          case Success(:final data):
            totalCount = _parseInt(data['customerCount']);
          case Failure(:final message):
            state = state.copyWith(
              isLoading: false,
              errorMessage: message,
            );
            return;
        }

        if (totalCount == 0) {
          state = state.copyWith(
            isLoading: false,
            customers: [],
            totalCount: 0,
          );
          return;
        }

        debugPrint('[CUST-SEARCH] Count: $totalCount');
      }

      // ── Fetch page ──
      final startValue = page * kCustomerPageSize;
      final searchResult = await _repo.searchCustomers(
        customerNumber: params['customerNumber'],
        customerName: params['customerName'],
        mobileNumber: params['mobileNumber'],
        boxNumber: params['boxNumber'],
        lcoCustomerId: params['lcoCustomerId'],
        cafNumber: params['cafNumber'],
        startValue: startValue,
        endValue: kCustomerPageSize,
      );

      switch (searchResult) {
        case Success(:final CustomerSearchResponse data):
          state = state.copyWith(
            isLoading: false,
            customers: data.existCustomerDetails,
            totalCount: totalCount,
            currentPage: page,
          );
        case Failure(:final message):
          state = state.copyWith(
            isLoading: false,
            errorMessage: message,
          );
      }
    } catch (e) {
      debugPrint('[CUST-SEARCH] Error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }

  // ── Pagination helpers ──────────────────────────────────────────────────

  Future<void> nextPage() async {
    if (!state.hasNextPage || state.isLoading) return;
    await searchCustomers(
      state.searchQuery,
      state.searchField,
      page: state.currentPage + 1,
    );
  }

  Future<void> prevPage() async {
    if (!state.hasPrevPage || state.isLoading) return;
    await searchCustomers(
      state.searchQuery,
      state.searchField,
      page: state.currentPage - 1,
    );
  }

  Future<void> firstPage() async {
    if (state.currentPage == 0 || state.isLoading) return;
    await searchCustomers(
      state.searchQuery,
      state.searchField,
      page: 0,
    );
  }

  Future<void> lastPage() async {
    final last = max(0, state.totalPages - 1);
    if (state.currentPage == last || state.isLoading) return;
    await searchCustomers(
      state.searchQuery,
      state.searchField,
      page: last,
    );
  }

  void clear() {
    state = const CustomerSearchState();
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  Map<String, String?> _buildParams(String query, CustomerSearchField field) {
    switch (field) {
      case CustomerSearchField.customerNumber:
        return {'customerNumber': query};
      case CustomerSearchField.customerName:
        return {'customerName': query};
      case CustomerSearchField.mobileNumber:
        return {'mobileNumber': query};
      case CustomerSearchField.boxNumber:
        return {'boxNumber': query};
      case CustomerSearchField.lcoCustomerId:
        return {'lcoCustomerId': query};
      case CustomerSearchField.cafNumber:
        return {'cafNumber': query};
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

final customerSearchProvider =
    NotifierProvider<CustomerSearchNotifier, CustomerSearchState>(
  CustomerSearchNotifier.new,
);
