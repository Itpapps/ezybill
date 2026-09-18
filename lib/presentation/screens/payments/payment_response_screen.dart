import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/payment_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/parse_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentResponseState {
  final bool isLoading;
  final String? error;
  final bool? isSuccess;
  final String? transactionId;
  final String? amount;
  final String? customerName;
  final String? date;
  final String? statusMessage;

  const _PaymentResponseState({
    this.isLoading = false,
    this.error,
    this.isSuccess,
    this.transactionId,
    this.amount,
    this.customerName,
    this.date,
    this.statusMessage,
  });

  _PaymentResponseState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    String? transactionId,
    String? amount,
    String? customerName,
    String? date,
    String? statusMessage,
  }) =>
      _PaymentResponseState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isSuccess: isSuccess ?? this.isSuccess,
        transactionId: transactionId ?? this.transactionId,
        amount: amount ?? this.amount,
        customerName: customerName ?? this.customerName,
        date: date ?? this.date,
        statusMessage: statusMessage ?? this.statusMessage,
      );
}

/// Riverpod Notifier, mirroring payment_history_screen.dart.
///
/// This used to be a ChangeNotifier handed out through a plain `Provider`.
/// `ref.watch` on a plain Provider subscribes to the provider's VALUE — the
/// notifier object, which never changes — not to `notifyListeners()`. The
/// screen therefore never repainted when the transaction lookup completed:
/// the first frame's card (isSuccess == null → "Payment Failed") stayed on
/// screen regardless of what the server returned. With a Notifier,
/// `ref.watch` returns the STATE and every `state = …` rebuilds.
class _PaymentResponseNotifier extends Notifier<_PaymentResponseState> {
  final String customerId;

  _PaymentResponseNotifier(this.customerId);

  @override
  _PaymentResponseState build() => const _PaymentResponseState();

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = ref.read(appSessionProvider);
      final ds = ref.read(paymentRemoteDatasourceProvider);
      final data = await ds.getCustomerTransactionResponse(
        authtoken: session?.token ?? '',
        employeeId: session?.employeeId.toString() ?? '',
        dealerId: session?.dealerId ?? 0,
        customerId: customerId,
      );

      // Parsed the way Android's PaymentResponseActivity does (REST path,
      // :137-186). Top-level status_code only says whether a transaction
      // RECORD exists: 0 = found, 1 = "No details Found". Whether the payment
      // succeeded is decided solely by response_details.status, which the
      // gateway sets to one of three success strings.
      final statusCode = data['status_code']?.toString();
      final details = _detailsOf(data['response_details']);

      if (statusCode != '0' || details == null) {
        // Android: dialog "No  Details Found" titled status_msg.
        state = state.copyWith(
          isLoading: false,
          error: data['status_msg']?.toString() ?? 'No details found',
        );
        return;
      }

      final status = details['status']?.toString() ?? '';
      const successStatuses = {'TXN_SUCCESS', 'success', 'Txn Success'};
      final firstName = details['first_name']?.toString() ?? '';
      final lastName = details['last_name']?.toString() ?? '';
      // Empty → null so the card's existing fallback chain still applies.
      final fullName = '$firstName $lastName'.trim();

      state = state.copyWith(
        isLoading: false,
        isSuccess: successStatuses.contains(status),
        transactionId: details['transactionno']?.toString() ?? '--',
        amount: details['amount']?.toString() ?? '0',
        customerName: fullName.isEmpty ? null : fullName,
        statusMessage: details['responsemsg']?.toString(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }

  /// response_details is a JSON object; Android parses it with
  /// `new JSONObject(getString("response_details"))`, which also accepts the
  /// double-encoded (string) form. Handle both, mirroring that tolerance.
  Map<String, dynamic>? _detailsOf(dynamic raw) {
    if (raw is String) {
      try {
        return parseMap(jsonDecode(raw));
      } catch (_) {
        return null;
      }
    }
    return parseMap(raw);
  }
}

final _paymentResponseProvider = NotifierProvider.autoDispose
    .family<_PaymentResponseNotifier, _PaymentResponseState, String>(
  _PaymentResponseNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class PaymentResponseScreen extends ConsumerStatefulWidget {
  final String customerId;
  final String? customerName;

  const PaymentResponseScreen({
    super.key,
    required this.customerId,
    this.customerName,
  });

  @override
  ConsumerState<PaymentResponseScreen> createState() =>
      _PaymentResponseScreenState();
}

class _PaymentResponseScreenState
    extends ConsumerState<PaymentResponseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(_paymentResponseProvider(widget.customerId).notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final tt = Theme.of(context).textTheme;
    final respState = ref.watch(_paymentResponseProvider(widget.customerId));

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text('Payment Result',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(c, tt, respState),
    );
  }

  Widget _buildBody(
      AppColors c, TextTheme tt, _PaymentResponseState respState) {
    if (respState.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Verifying payment...',
              style: tt.bodyMedium?.copyWith(color: c.ink60),
            ),
          ],
        ),
      );
    }

    if (respState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.alertCircle, size: 64, color: c.red),
              const SizedBox(height: 16),
              Text(
                'Unable to verify payment',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                respState.error!,
                textAlign: TextAlign.center,
                style: tt.bodySmall?.copyWith(color: c.ink60),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => ref
                        .read(_paymentResponseProvider(widget.customerId).notifier)
                        .load(),
                    icon: const Icon(LucideIcons.refreshCw, size: 16),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final isSuccess = respState.isSuccess == true;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            // Status icon
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSuccess ? c.greenSoft : c.redSoft,
              ),
              child: Icon(
                isSuccess ? LucideIcons.checkCircle : LucideIcons.xCircle,
                size: 56,
                color: isSuccess ? c.green : c.red,
              ),
            ),

            const SizedBox(height: 24),

            // Status title
            Text(
              isSuccess ? 'Payment Successful' : 'Payment Failed',
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isSuccess ? c.green : c.red,
              ),
            ),

            const SizedBox(height: 8),

            // Status message
            if (respState.statusMessage != null)
              Text(
                respState.statusMessage!,
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: c.ink60),
              ),

            const SizedBox(height: 32),

            // Transaction details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: c.ink.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _ResponseDetailRow(
                    label: 'Amount',
                    value: formatCurrencyFromDynamic(respState.amount),
                    colors: c,
                    textTheme: tt,
                    isMono: true,
                  ),
                  Divider(height: 24, color: c.ink05),
                  _ResponseDetailRow(
                    label: 'Transaction ID',
                    value: respState.transactionId ?? '--',
                    colors: c,
                    textTheme: tt,
                  ),
                  Divider(height: 24, color: c.ink05),
                  _ResponseDetailRow(
                    label: 'Date',
                    value: formatApiDateForDisplay(respState.date),
                    colors: c,
                    textTheme: tt,
                  ),
                  Divider(height: 24, color: c.ink05),
                  _ResponseDetailRow(
                    label: 'Customer',
                    value: respState.customerName ??
                        widget.customerName ??
                        widget.customerId,
                    colors: c,
                    textTheme: tt,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Action buttons
            if (!isSuccess) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Go back to retry payment
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(LucideIcons.refreshCw, size: 16),
                  label: const Text('Retry Payment'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: c.red),
                    foregroundColor: c.red,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  // Pop to the root or go home
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ResponseDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final AppColors colors;
  final TextTheme textTheme;
  final bool isMono;

  const _ResponseDetailRow({
    required this.label,
    required this.value,
    required this.colors,
    required this.textTheme,
    this.isMono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: colors.ink40),
        ),
        Flexible(
          child: Text(
            value,
            style: isMono
                ? GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  )
                : textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.ink80,
                  ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
