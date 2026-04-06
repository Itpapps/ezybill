import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/payment_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../data/models/payment/payment_history_item.dart';
import '../../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentHistoryState {
  final bool isLoading;
  final String? error;
  final List<PaymentHistoryItem> items;

  const _PaymentHistoryState({
    this.isLoading = false,
    this.error,
    this.items = const [],
  });

  _PaymentHistoryState copyWith({
    bool? isLoading,
    String? error,
    List<PaymentHistoryItem>? items,
  }) =>
      _PaymentHistoryState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        items: items ?? this.items,
      );
}

class _PaymentHistoryNotifier extends ChangeNotifier {
  _PaymentHistoryState _state = const _PaymentHistoryState();
  _PaymentHistoryState get state => _state;

  final Ref _ref;
  final String customerId;

  _PaymentHistoryNotifier(this._ref, this.customerId);

  Future<void> load({String? fromDate, String? toDate}) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();
    try {
      final session = _ref.read(appSessionProvider);
      final ds = _ref.read(paymentRemoteDatasourceProvider);
      final data = await ds.getPaymentHistory(
        authtoken: session?.token ?? '',
        customerId: customerId,
        fromDate: fromDate,
        toDate: toDate,
      );
      final list = (data['paymentList'] as List<dynamic>?)
              ?.map((e) =>
                  PaymentHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      _state = _state.copyWith(isLoading: false, items: list);
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

final _paymentHistoryProvider =
    Provider.autoDispose.family<_PaymentHistoryNotifier, String>(
  (ref, customerId) {
    final notifier = _PaymentHistoryNotifier(ref, customerId);
    ref.onDispose(notifier.dispose);
    return notifier;
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  final String customerId;

  const PaymentHistoryScreen({super.key, required this.customerId});

  @override
  ConsumerState<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  final Set<int> _expandedIndices = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(_paymentHistoryProvider(widget.customerId)).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final tt = Theme.of(context).textTheme;
    final historyNotifier = ref.watch(_paymentHistoryProvider(widget.customerId));
    final historyState = historyNotifier.state;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.paymentHistory,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: c.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(c, tt, historyState),
    );
  }

  Widget _buildBody(
      AppColors c, TextTheme tt, _PaymentHistoryState historyState) {
    if (historyState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (historyState.error != null) {
      return _ErrorView(
        message: historyState.error!,
        onRetry: () => ref
            .read(_paymentHistoryProvider(widget.customerId))
            .load(),
        colors: c,
        textTheme: tt,
      );
    }

    if (historyState.items.isEmpty) {
      return _EmptyView(colors: c, textTheme: tt);
    }

    return Column(
      children: [
        // Count label
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '${historyState.items.length} payment(s) found',
            style: tt.bodySmall?.copyWith(color: c.ink60),
          ),
        ),
        Divider(height: 1, color: c.ink05),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref
                .read(_paymentHistoryProvider(widget.customerId))
                .load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: historyState.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = historyState.items[index];
                final isExpanded = _expandedIndices.contains(index);
                return _PaymentCard(
                  item: item,
                  isExpanded: isExpanded,
                  onToggle: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedIndices.remove(index);
                      } else {
                        _expandedIndices.add(index);
                      }
                    });
                  },
                  onPrint: () => _showStubToast('Print'),
                  onShare: () => _showStubToast('Share'),
                  colors: c,
                  textTheme: tt,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showStubToast(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action feature coming soon'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Card
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final PaymentHistoryItem item;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onPrint;
  final VoidCallback onShare;
  final AppColors colors;
  final TextTheme textTheme;

  const _PaymentCard({
    required this.item,
    required this.isExpanded,
    required this.onToggle,
    required this.onPrint,
    required this.onShare,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.ink.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: date + amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatApiDateForDisplay(item.paidOn),
                          style: textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Receipt: ${item.receiptNo}',
                          style:
                              textTheme.bodySmall?.copyWith(color: colors.ink40),
                        ),
                      ],
                    ),
                    Text(
                      formatCurrency(item.paidAmount),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(height: 1, color: colors.ink05),
                const SizedBox(height: 12),

                // Middle row: payment mode chip + employee name
                Row(
                  children: [
                    _PaymentModeChip(
                      mode: item.paymentMode,
                      colors: colors,
                      textTheme: textTheme,
                    ),
                    const SizedBox(width: 12),
                    if (item.employeeName != null &&
                        item.employeeName!.isNotEmpty)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(LucideIcons.user,
                                size: 14, color: colors.ink40),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.employeeName!,
                                style: textTheme.bodySmall
                                    ?.copyWith(color: colors.ink60),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    // Action buttons
                    _IconBtn(
                      icon: LucideIcons.printer,
                      onTap: onPrint,
                      colors: colors,
                    ),
                    const SizedBox(width: 8),
                    _IconBtn(
                      icon: LucideIcons.share2,
                      onTap: onShare,
                      colors: colors,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded
                          ? LucideIcons.chevronUp
                          : LucideIcons.chevronDown,
                      size: 18,
                      color: colors.ink40,
                    ),
                  ],
                ),

                // Expandable remarks
                if (isExpanded && item.remarks != null && item.remarks!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remarks',
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.ink40,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.remarks!,
                            style: textTheme.bodySmall
                                ?.copyWith(color: colors.ink80),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (isExpanded &&
                    (item.remarks == null || item.remarks!.isEmpty))
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'No remarks',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.ink20,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentModeChip extends StatelessWidget {
  final String mode;
  final AppColors colors;
  final TextTheme textTheme;

  const _PaymentModeChip({
    required this.mode,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.blueSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        mode,
        style: textTheme.labelSmall?.copyWith(
          color: colors.blue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final AppColors colors;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: colors.ink40),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final AppColors colors;
  final TextTheme textTheme;

  const _EmptyView({required this.colors, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.receipt, size: 56, color: colors.ink20),
          const SizedBox(height: 16),
          Text(
            'No payment history',
            style: textTheme.titleSmall?.copyWith(color: colors.ink40),
          ),
          const SizedBox(height: 4),
          Text(
            'Payment records will appear here.',
            style: textTheme.bodySmall?.copyWith(color: colors.ink20),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final AppColors colors;
  final TextTheme textTheme;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.alertCircle, size: 48, color: colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colors.ink60),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}
