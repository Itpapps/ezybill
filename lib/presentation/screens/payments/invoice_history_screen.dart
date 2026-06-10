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
import '../../../data/models/payment/invoice_item.dart';
import '../../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

class _InvoiceHistoryState {
  final bool isLoading;
  final String? error;
  final List<InvoiceItem> items;

  const _InvoiceHistoryState({
    this.isLoading = false,
    this.error,
    this.items = const [],
  });

  _InvoiceHistoryState copyWith({
    bool? isLoading,
    String? error,
    List<InvoiceItem>? items,
  }) =>
      _InvoiceHistoryState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        items: items ?? this.items,
      );
}

class _InvoiceHistoryNotifier extends ChangeNotifier {
  _InvoiceHistoryState _state = const _InvoiceHistoryState();
  _InvoiceHistoryState get state => _state;

  final Ref _ref;
  final String customerId;

  _InvoiceHistoryNotifier(this._ref, this.customerId);

  Future<void> load() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();
    try {
      final session = _ref.read(appSessionProvider);
      final ds = _ref.read(paymentRemoteDatasourceProvider);
      final data = await ds.getInvoiceHistory(
        authtoken: session?.token ?? '',
        customerId: customerId,
        dealerId: session?.dealerId ?? 0,
      );
      final list = parseList<InvoiceItem>(
        data['invoice_details'],
        InvoiceItem.fromJson,
      );
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

final _invoiceHistoryProvider =
    Provider.autoDispose.family<_InvoiceHistoryNotifier, String>(
  (ref, customerId) {
    final notifier = _InvoiceHistoryNotifier(ref, customerId);
    ref.onDispose(notifier.dispose);
    return notifier;
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class InvoiceHistoryScreen extends ConsumerStatefulWidget {
  final String customerId;

  const InvoiceHistoryScreen({super.key, required this.customerId});

  @override
  ConsumerState<InvoiceHistoryScreen> createState() =>
      _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends ConsumerState<InvoiceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(_invoiceHistoryProvider(widget.customerId)).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final tt = Theme.of(context).textTheme;
    final notifier = ref.watch(_invoiceHistoryProvider(widget.customerId));
    final historyState = notifier.state;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.invoiceHistory,
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
      AppColors c, TextTheme tt, _InvoiceHistoryState historyState) {
    if (historyState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (historyState.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.alertCircle, size: 48, color: c.ink40),
            const SizedBox(height: 12),
            Text(historyState.error!,
                style: tt.bodyMedium?.copyWith(color: c.ink60)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  ref.read(_invoiceHistoryProvider(widget.customerId)).load(),
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (historyState.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.fileText, size: 48, color: c.ink40),
            const SizedBox(height: 12),
            Text('No invoices found',
                style: tt.bodyMedium?.copyWith(color: c.ink60)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(_invoiceHistoryProvider(widget.customerId)).load(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: historyState.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = historyState.items[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.ink10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.pname,
                        style: tt.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      formatCurrency(item.totalAmount),
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: c.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 14, color: c.ink40),
                    const SizedBox(width: 4),
                    Text(
                      formatApiDateForDisplay(item.billDate),
                      style: tt.bodySmall?.copyWith(color: c.ink60),
                    ),
                    const SizedBox(width: 16),
                    Text('Due: ${formatApiDateForDisplay(item.dueDate)}',
                        style: tt.bodySmall?.copyWith(color: c.ink40)),
                  ],
                ),
                if (item.pendingAmount > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Pending: ${formatCurrency(item.pendingAmount)}',
                    style: tt.bodySmall?.copyWith(
                      color: c.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
