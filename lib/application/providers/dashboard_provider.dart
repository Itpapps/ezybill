import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_session.dart';
import '../../core/utils/result.dart';
import '../../data/datasources/remote/dashboard_remote_datasource.dart';
import '../../data/models/dashboard/dashboard_response.dart';
import '../../data/models/dashboard/expiry_services_response.dart';
import '../../data/models/dashboard/wallet_response.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import 'core_providers.dart';

// ── Repository Provider ──────────────────────────────────────────────────────

final dashboardRemoteDatasourceProvider =
    Provider<DashboardRemoteDatasource>((ref) {
  return DashboardRemoteDatasource(dio: ref.watch(dioClientProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    ref.watch(dashboardRemoteDatasourceProvider),
    ref.watch(dioClientProvider),
  );
});

// ── Dashboard State ──────────────────────────────────────────────────────────

class DashboardState {
  final bool isLoading;
  final String? errorMessage;
  final DashboardResponse? dashboard;
  final WalletResponse? wallet;
  final ExpiryServicesResponse? expiryServices;
  final List<Map<String, dynamic>> walletHistory;
  final bool walletHistoryLoading;

  const DashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.dashboard,
    this.wallet,
    this.expiryServices,
    this.walletHistory = const [],
    this.walletHistoryLoading = false,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    DashboardResponse? dashboard,
    WalletResponse? wallet,
    ExpiryServicesResponse? expiryServices,
    List<Map<String, dynamic>>? walletHistory,
    bool? walletHistoryLoading,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      dashboard: dashboard ?? this.dashboard,
      wallet: wallet ?? this.wallet,
      expiryServices: expiryServices ?? this.expiryServices,
      walletHistory: walletHistory ?? this.walletHistory,
      walletHistoryLoading: walletHistoryLoading ?? this.walletHistoryLoading,
    );
  }

  // ── Convenience getters (backward-compatible) ────────────────────────────

  int get totalActiveCustomers => dashboard?.totalActiveCustomers ?? 0;
  int get totalDeactiveCustomers => dashboard?.totalDeactiveCustomers ?? 0;
  int get totalComplaints => dashboard?.totalComplaints ?? 0;
  int get totalClosedComplaints => dashboard?.totalClosedComplaints ?? 0;
  int get totalStbs => dashboard?.totalStbs ?? 0;
  int get totalAssignedStbs => dashboard?.totalAssignedStbs ?? 0;
  int get totalUnAssignedStbs => dashboard?.totalUnAssignedStbs ?? 0;
  int get totalPaidCustomers => dashboard?.totalPaidCustomers ?? 0;
  int get totalUnPaidCustomers => dashboard?.totalUnPaidCustomers ?? 0;
  double get totalDueAmount => dashboard?.totalDueAmount ?? 0;
  double get totalCurrentMonthBill => dashboard?.totalCurrentMonthBill ?? 0;
  double get outStandingAmount => dashboard?.outStandingAmount ?? 0;

  double get walletBalance => wallet?.lcoDepositAmount ?? 0;

  int get totalCustomers => totalActiveCustomers + totalDeactiveCustomers;

  /// Fresh = totalStbs - totalAssigned (unassigned STBs with no customer)
  int get freshCount => totalUnAssignedStbs;

  /// Health percentage: active / total * 100
  int get healthPercent =>
      totalCustomers > 0
          ? ((totalActiveCustomers / totalCustomers) * 100).round()
          : 0;

  /// Expiring within 7 days count
  int get expiring7dCount {
    if (expiryServices == null) return 0;
    return expiryServices!.expiryServicesList.fold<int>(
      0,
      (sum, e) => sum + e.stbCount,
    );
  }

  // ── Backward-compatible raw-data getters ─────────────────────────────────

  Map<String, dynamic>? get dashboardData => dashboard?.toJson();
  Map<String, dynamic>? get walletData => wallet?.toJson();
}

// ── Dashboard Notifier ───────────────────────────────────────────────────────

class DashboardNotifier extends Notifier<DashboardState> {
  late DashboardRepository _repo;

  @override
  DashboardState build() {
    _repo = ref.watch(dashboardRepositoryProvider);
    return const DashboardState();
  }

  /// Load dashboard, wallet, and expiry data in parallel.
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final session = ref.read(appSessionProvider);

    try {
      // Build dashboard request params from session config
      final useLcoDeposits =
          session != null ? session.useLcoDeposit.toString() : null;
      final lcoBillType =
          session != null ? session.lcoBilltype.toString() : null;

      final dashResult = await _repo.getDashboardDetails(
        useLcoDeposits: useLcoDeposits,
        lcoBillType: lcoBillType,
      );

      DashboardResponse? dashData;
      String? error;

      switch (dashResult) {
        case Success(:final data):
          dashData = data;
          debugPrint(
            '[DASHBOARD] Loaded: active=${data.totalActiveCustomers}, '
            'inactive=${data.totalDeactiveCustomers}, '
            'stbs=${data.totalStbs}',
          );
        case Failure(:final message):
          error = message;
          debugPrint('[DASHBOARD] Error: $message');
      }

      state = state.copyWith(
        isLoading: false,
        dashboard: dashData,
        errorMessage: error,
      );

      // Fire-and-forget: wallet + expiry in parallel
      if (session != null) {
        _loadWalletAndExpiry(session);
      }
    } catch (e, stack) {
      debugPrint('[DASHBOARD] Unexpected error: $e');
      debugPrint('[DASHBOARD] STACK: $stack');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _loadWalletAndExpiry(AppSession session) async {
    final futures = <Future>[];

    // Wallet — only when showWallet is true
    if (session.showWallet) {
      futures.add(_loadWallet());
    }

    // Expiry services
    futures.add(_loadExpiryServices(session.dealerId));

    await Future.wait(futures);
  }

  Future<void> _loadWallet() async {
    final result = await _repo.getLcoDepositAmount();
    switch (result) {
      case Success(:final data):
        state = state.copyWith(wallet: data);
        debugPrint('[DASHBOARD] Wallet balance: ${data.lcoDepositAmount}');
      case Failure(:final message):
        debugPrint('[DASHBOARD] Wallet error: $message');
    }
  }

  Future<void> _loadExpiryServices(int dealerId) async {
    final result = await _repo.getExpiryServicesDateWiseCount(
      dealerId: dealerId,
    );
    switch (result) {
      case Success(:final data):
        state = state.copyWith(expiryServices: data);
        debugPrint(
          '[DASHBOARD] Expiry services: ${data.expiryServicesList.length} dates',
        );
      case Failure(:final message):
        debugPrint('[DASHBOARD] Expiry error: $message');
    }
  }

  /// Load wallet history (recent recharges).
  Future<void> loadWalletHistory() async {
    final session = ref.read(appSessionProvider);
    if (session == null) return;

    state = state.copyWith(walletHistoryLoading: true);

    final result = await _repo.getLcoWallet(dealerId: session.dealerId);
    switch (result) {
      case Success(:final data):
        final list = (data['lcoWalletList'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [];
        state = state.copyWith(
          walletHistory: list,
          walletHistoryLoading: false,
        );
      case Failure(:final message):
        debugPrint('[DASHBOARD] Wallet history error: $message');
        state = state.copyWith(walletHistoryLoading: false);
    }
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final dashboardProvider =
    NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);
