import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_session.dart';
import '../../data/datasources/remote/lco_remote_datasource.dart';
import '../../data/models/lco/lco_payment_request.dart';
import '../../data/models/lco/lco_wallet_entry.dart';
import 'core_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Datasource provider
// ─────────────────────────────────────────────────────────────────────────────

final lcoRemoteDatasourceProvider = Provider<LcoRemoteDatasource>((ref) {
  return LcoRemoteDatasource(dio: ref.watch(dioClientProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

enum LcoPaymentPhase {
  idle,
  searching,
  searchSuccess,
  paying,
  paymentSuccess,
  loadingHistory,
  historyLoaded,
  error,
}

class LcoPaymentState {
  final LcoPaymentPhase phase;
  final String? errorMessage;
  final String? successMessage;

  /// Raw LCO search result from the server.
  final Map<String, dynamic>? searchResult;

  /// Raw payment result from the server.
  final Map<String, dynamic>? paymentResult;

  /// Parsed wallet history entries.
  final List<LcoWalletEntry> walletHistory;
  final bool walletHistoryLoading;

  const LcoPaymentState({
    this.phase = LcoPaymentPhase.idle,
    this.errorMessage,
    this.successMessage,
    this.searchResult,
    this.paymentResult,
    this.walletHistory = const [],
    this.walletHistoryLoading = false,
  });

  bool get isLoading =>
      phase == LcoPaymentPhase.searching ||
      phase == LcoPaymentPhase.paying ||
      phase == LcoPaymentPhase.loadingHistory;

  bool get hasSearchResult =>
      phase == LcoPaymentPhase.searchSuccess ||
      phase == LcoPaymentPhase.paymentSuccess;

  // ── Convenience getters for search result fields ────────────────────────

  String get lcoName =>
      searchResult?['businessName']?.toString() ??
      searchResult?['lcoName']?.toString() ??
      '';

  String get lcoAddress =>
      searchResult?['address']?.toString() ??
      searchResult?['lcoAddress']?.toString() ??
      '';

  double get pendingAmount {
    final raw = searchResult?['pendingAmount'] ??
        searchResult?['advanceAmountDue'] ??
        searchResult?['dueAmount'] ??
        0;
    if (raw is double) return raw;
    if (raw is int) return raw.toDouble();
    return double.tryParse(raw.toString()) ?? 0.0;
  }

  String get lcoBillingId =>
      searchResult?['lcoBillingId']?.toString() ??
      searchResult?['billingId']?.toString() ??
      '';

  LcoPaymentState copyWith({
    LcoPaymentPhase? phase,
    String? errorMessage,
    String? successMessage,
    Map<String, dynamic>? searchResult,
    bool clearSearchResult = false,
    Map<String, dynamic>? paymentResult,
    List<LcoWalletEntry>? walletHistory,
    bool? walletHistoryLoading,
  }) {
    return LcoPaymentState(
      phase: phase ?? this.phase,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchResult:
          clearSearchResult ? null : (searchResult ?? this.searchResult),
      paymentResult: paymentResult ?? this.paymentResult,
      walletHistory: walletHistory ?? this.walletHistory,
      walletHistoryLoading: walletHistoryLoading ?? this.walletHistoryLoading,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class LcoPaymentNotifier extends Notifier<LcoPaymentState> {
  late LcoRemoteDatasource _ds;

  @override
  LcoPaymentState build() {
    _ds = ref.watch(lcoRemoteDatasourceProvider);
    return const LcoPaymentState();
  }

  // ── Phase 1: Search LCO ────────────────────────────────────────────────

  Future<void> searchLco(String lcoCode) async {
    final session = ref.read(appSessionProvider);
    if (session == null) {
      state = state.copyWith(
        phase: LcoPaymentPhase.error,
        errorMessage: 'Session expired. Please login again.',
      );
      return;
    }

    state = state.copyWith(
      phase: LcoPaymentPhase.searching,
      errorMessage: null,
      successMessage: null,
      clearSearchResult: true,
    );

    try {
      final result = await _ds.searchLco(
        authtoken: session.token,
        employeeId: session.employeeId,
        lcoCode: lcoCode.trim(),
      );

      final statusCode = result['status_code'] ?? result['statusCode'] ?? -1;
      if (statusCode == 0 || result.containsKey('businessName') || result.containsKey('lcoName')) {
        state = state.copyWith(
          phase: LcoPaymentPhase.searchSuccess,
          searchResult: result,
        );
      } else {
        state = state.copyWith(
          phase: LcoPaymentPhase.error,
          errorMessage: result['status_message']?.toString() ??
              result['statusMsg']?.toString() ??
              'LCO not found.',
        );
      }
    } catch (e) {
      debugPrint('[LCO] Search error: $e');
      state = state.copyWith(
        phase: LcoPaymentPhase.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Phase 2: Make LCO Payment ──────────────────────────────────────────

  Future<bool> makeLcoPayment(LcoPaymentRequest request) async {
    final session = ref.read(appSessionProvider);
    if (session == null) {
      state = state.copyWith(
        phase: LcoPaymentPhase.error,
        errorMessage: 'Session expired. Please login again.',
      );
      return false;
    }

    state = state.copyWith(
      phase: LcoPaymentPhase.paying,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final result = await _ds.makeLcoPayment(
        authtoken: session.token,
        params: request.toJson(),
      );

      final statusCode = result['status_code'] ?? result['statusCode'] ?? -1;
      if (statusCode == 0) {
        state = state.copyWith(
          phase: LcoPaymentPhase.paymentSuccess,
          paymentResult: result,
          successMessage: result['status_message']?.toString() ??
              result['statusMsg']?.toString() ??
              'Payment successful.',
        );
        return true;
      } else {
        state = state.copyWith(
          phase: LcoPaymentPhase.error,
          errorMessage: result['status_message']?.toString() ??
              result['statusMsg']?.toString() ??
              'Payment failed.',
        );
        return false;
      }
    } catch (e) {
      debugPrint('[LCO] Payment error: $e');
      state = state.copyWith(
        phase: LcoPaymentPhase.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ── Wallet History ─────────────────────────────────────────────────────

  Future<void> loadWalletHistory({
    required String startDate,
    required String endDate,
  }) async {
    final session = ref.read(appSessionProvider);
    if (session == null) return;

    state = state.copyWith(
      phase: LcoPaymentPhase.loadingHistory,
      walletHistoryLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _ds.getLcoWalletHistory(
        authtoken: session.token,
        dealerId: session.dealerId,
        startDate: startDate,
        endDate: endDate,
      );

      final rawList =
          (result['lcoWalletList'] as List<dynamic>?) ?? <dynamic>[];
      final entries = rawList
          .map((e) => LcoWalletEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        phase: LcoPaymentPhase.historyLoaded,
        walletHistory: entries,
        walletHistoryLoading: false,
      );
    } catch (e) {
      debugPrint('[LCO] Wallet history error: $e');
      state = state.copyWith(
        phase: LcoPaymentPhase.error,
        walletHistoryLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }

  void reset() {
    state = const LcoPaymentState();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final lcoPaymentProvider =
    NotifierProvider<LcoPaymentNotifier, LcoPaymentState>(
  LcoPaymentNotifier.new,
);
