import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/payment_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatters.dart';

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

class _PaymentResponseNotifier extends ChangeNotifier {
  _PaymentResponseState _state = const _PaymentResponseState();
  _PaymentResponseState get state => _state;

  final Ref _ref;
  final String customerId;

  _PaymentResponseNotifier(this._ref, this.customerId);

  Future<void> load() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();
    try {
      final session = _ref.read(appSessionProvider);
      final ds = _ref.read(paymentRemoteDatasourceProvider);
      final data = await ds.getCustomerTransactionResponse(
        authtoken: session?.token ?? '',
        employeeId: session?.employeeId.toString() ?? '',
        dealerId: session?.dealerId ?? 0,
        customerId: customerId,
      );

      final statusCode = data['status_code'];
      final isOk = statusCode == 0 || statusCode == '0';

      _state = _state.copyWith(
        isLoading: false,
        isSuccess: isOk,
        transactionId: data['transactionId']?.toString() ?? '--',
        amount: data['amount']?.toString() ?? '0',
        customerName: data['customerName']?.toString() ?? '--',
        date: data['transactionDate']?.toString(),
        statusMessage: data['status_msg']?.toString() ??
            (isOk ? 'Payment Successful' : 'Payment Failed'),
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('ApiException: ', ''),
      );
      notifyListeners();
    }
  }
}

final _paymentResponseProvider =
    Provider.autoDispose.family<_PaymentResponseNotifier, String>(
  (ref, customerId) {
    final notifier = _PaymentResponseNotifier(ref, customerId);
    ref.onDispose(notifier.dispose);
    return notifier;
  },
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
      ref.read(_paymentResponseProvider(widget.customerId)).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final tt = Theme.of(context).textTheme;
    final respNotifier =
        ref.watch(_paymentResponseProvider(widget.customerId));
    final respState = respNotifier.state;

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
                        .read(_paymentResponseProvider(widget.customerId))
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
