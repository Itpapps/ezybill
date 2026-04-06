import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/payment_remote_datasource.dart';
import '../../data/models/payment/make_payment_request.dart';
import '../../data/models/payment/make_payment_response.dart';
import '../../data/models/payment/payment_mode.dart';
import '../../data/models/payment/pending_amount.dart';
import '../../data/models/payment/receipt_range.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../core/utils/result.dart';
import 'core_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Repository wiring
// ─────────────────────────────────────────────────────────────────────────────

final paymentRemoteDatasourceProvider =
    Provider<PaymentRemoteDatasource>((ref) {
  return PaymentRemoteDatasource(dio: ref.watch(dioClientProvider));
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(ref.watch(paymentRemoteDatasourceProvider), ref.watch(dioClientProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

enum PaymentPhase {
  idle,
  loadingModes,
  loadingPending,
  readyToPay,
  processing,
  success,
  error,
}

class PaymentState {
  final PaymentPhase phase;
  final String? errorMessage;
  final String? successMessage;

  // Stage 1 — payment modes
  final List<PaymentMode> paymentModes;
  final PaymentMode? selectedMode;

  // Stage 2 — pending amount / customer info
  final PendingAmount? pendingAmount;

  // Receipt ranges (auto-receipt mode)
  final List<ReceiptRange> receiptRanges;
  final ReceiptRange? selectedReceiptRange;

  // Stage 3 — payment result
  final MakePaymentResponse? paymentResult;

  const PaymentState({
    this.phase = PaymentPhase.idle,
    this.errorMessage,
    this.successMessage,
    this.paymentModes = const [],
    this.selectedMode,
    this.pendingAmount,
    this.receiptRanges = const [],
    this.selectedReceiptRange,
    this.paymentResult,
  });

  bool get isLoading =>
      phase == PaymentPhase.loadingModes ||
      phase == PaymentPhase.loadingPending ||
      phase == PaymentPhase.processing;

  PaymentState copyWith({
    PaymentPhase? phase,
    String? errorMessage,
    String? successMessage,
    List<PaymentMode>? paymentModes,
    PaymentMode? selectedMode,
    bool clearSelectedMode = false,
    PendingAmount? pendingAmount,
    List<ReceiptRange>? receiptRanges,
    ReceiptRange? selectedReceiptRange,
    bool clearSelectedReceiptRange = false,
    MakePaymentResponse? paymentResult,
  }) {
    return PaymentState(
      phase: phase ?? this.phase,
      errorMessage: errorMessage,
      successMessage: successMessage,
      paymentModes: paymentModes ?? this.paymentModes,
      selectedMode:
          clearSelectedMode ? null : (selectedMode ?? this.selectedMode),
      pendingAmount: pendingAmount ?? this.pendingAmount,
      receiptRanges: receiptRanges ?? this.receiptRanges,
      selectedReceiptRange: clearSelectedReceiptRange
          ? null
          : (selectedReceiptRange ?? this.selectedReceiptRange),
      paymentResult: paymentResult ?? this.paymentResult,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class PaymentNotifier extends Notifier<PaymentState> {
  late PaymentRepository _repo;

  @override
  PaymentState build() {
    _repo = ref.watch(paymentRepositoryProvider);
    return const PaymentState();
  }

  // ── Stage 1: Load payment modes ──────────────────────────────────────────

  Future<void> loadPaymentModes() async {
    state = state.copyWith(phase: PaymentPhase.loadingModes);
    final result = await _repo.getPaymentModes();
    switch (result) {
      case Success(:final data):
        final defaultMode = data.isNotEmpty ? data.first : null;
        state = state.copyWith(
          phase: PaymentPhase.idle,
          paymentModes: data,
          selectedMode: defaultMode,
        );
      case Failure(:final message):
        state = state.copyWith(
          phase: PaymentPhase.error,
          errorMessage: message,
        );
    }
  }

  // ── Stage 2: Load pending amount ─────────────────────────────────────────

  Future<void> loadPendingAmount(String customerId, {String? serialNo}) async {
    state = state.copyWith(phase: PaymentPhase.loadingPending);
    final result = await _repo.getPendingAmount(
      altCustomerId: customerId,
      serialNo: serialNo,
    );
    switch (result) {
      case Success(:final data):
        state = state.copyWith(
          phase: PaymentPhase.readyToPay,
          pendingAmount: data,
        );
      case Failure(:final message):
        state = state.copyWith(
          phase: PaymentPhase.error,
          errorMessage: message,
        );
    }
  }

  // ── Load receipt ranges (auto-receipt mode) ──────────────────────────────

  Future<void> loadReceiptRanges() async {
    final result = await _repo.getReceiptRanges();
    switch (result) {
      case Success(:final data):
        final rawList = data['ReceiptRanges'] as List<dynamic>? ?? [];
        final ranges = rawList
            .map((e) => ReceiptRange.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(receiptRanges: ranges);
      case Failure(:final message):
        state = state.copyWith(errorMessage: message);
    }
  }

  // ── Stage 3: Make payment ────────────────────────────────────────────────

  Future<bool> makePayment(MakePaymentRequest request) async {
    state = state.copyWith(phase: PaymentPhase.processing);
    final result = await _repo.makePayment(
      altCustomerId: request.altCustomerId,
      amount: request.amount.toString(),
      modeType: request.modeType,
      receiptNumber: request.receiptNumber,
      altReceiptNumber: request.altReceiptNumber,
      remarks: request.remarks,
      billingId: request.billingId,
      chequeNo: request.chequeNo,
      bank: request.bank,
      branch: request.branch,
      chequeDate: request.chequeDate,
      rrnNo: request.rrnNo,
      cardholderName: request.cardholderName,
      cardType: request.cardType,
      voucherCode: request.voucherCode,
    );
    switch (result) {
      case Success(:final data):
        state = state.copyWith(
          phase: PaymentPhase.success,
          paymentResult: data,
          successMessage: data.statusMsg,
        );
        return true;
      case Failure(:final message):
        state = state.copyWith(
          phase: PaymentPhase.error,
          errorMessage: message,
        );
        return false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void selectPaymentMode(PaymentMode mode) {
    state = state.copyWith(selectedMode: mode);
  }

  void selectReceiptRange(ReceiptRange range) {
    state = state.copyWith(selectedReceiptRange: range);
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }

  void reset() {
    state = const PaymentState();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final paymentProvider =
    NotifierProvider<PaymentNotifier, PaymentState>(PaymentNotifier.new);
