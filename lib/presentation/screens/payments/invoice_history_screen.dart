import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class _InvoiceHistoryNotifier extends Notifier<_InvoiceHistoryState> {
  final String customerId;

  _InvoiceHistoryNotifier(this.customerId);

  @override
  _InvoiceHistoryState build() => const _InvoiceHistoryState();

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = ref.read(appSessionProvider);
      final ds = ref.read(paymentRemoteDatasourceProvider);
      final data = await ds.getInvoiceHistory(
        authtoken: session?.token ?? '',
        customerId: customerId,
        dealerId: session?.dealerId ?? 0,
      );
      final list = parseList<InvoiceItem>(
        data['invoice_details'],
        InvoiceItem.fromJson,
      );
      state = state.copyWith(isLoading: false, items: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }
}

final _invoiceHistoryProvider = NotifierProvider.autoDispose
    .family<_InvoiceHistoryNotifier, _InvoiceHistoryState, String>(
  _InvoiceHistoryNotifier.new,
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
      ref.read(_invoiceHistoryProvider(widget.customerId).notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final tt = Theme.of(context).textTheme;
    final historyState = ref.watch(_invoiceHistoryProvider(widget.customerId));

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
                  ref.read(_invoiceHistoryProvider(widget.customerId).notifier).load(),
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

    final session = ref.read(appSessionProvider);
    final hideBoxPending = (session?.enableBoxWisePayment ?? 0) == 1;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(_invoiceHistoryProvider(widget.customerId).notifier).load(),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          16, 16, 16,
          16 + 56 + MediaQuery.of(context).padding.bottom,
        ),
        itemCount: historyState.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = historyState.items[index];
          final isAdhoc = item.isAdhoc == 1;
          return _InvoiceCard(
            item: item,
            isAdhoc: isAdhoc,
            hideBoxPending: hideBoxPending,
            colors: c,
            textTheme: tt,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Invoice Card — matches Android InvoiceAdapter field order
// ─────────────────────────────────────────────────────────────────────────────

class _InvoiceCard extends StatelessWidget {
  final InvoiceItem item;
  final bool isAdhoc;
  final bool hideBoxPending;
  final AppColors colors;
  final TextTheme textTheme;

  const _InvoiceCard({
    required this.item,
    required this.isAdhoc,
    required this.hideBoxPending,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.ink10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Package name + Total amount
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isAdhoc ? 'NA' : item.pname,
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  formatCurrency(item.totalAmount),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.red,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.ink10),
          // Detail rows — Android field order
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              children: [
                _row('Serial Number', isAdhoc ? 'NA' : item.serialNumber),
                _row('VC Number', isAdhoc ? 'NA' : item.macVcNumber),
                _row('Invoice Number', item.billingId),
                _row('Invoice Date', formatApiDateForDisplay(item.billDate)),
                _row('Quantity', item.quantity.toString()),
                _row('Due Date', formatApiDateForDisplay(item.dueDate)),
                _row('Base Price', formatCurrency(item.basePrice)),
                _row('Bill Amount', formatCurrency(item.billAmount)),
                _row('Tax Amount', formatCurrency(item.taxAmount)),
                if (!hideBoxPending)
                  _row('Pending Amount', formatCurrency(item.pendingAmount)),
                _row('Pending MSO Share', formatCurrency(item.msoShare)),
                _row('Discount Amount', formatCurrency(item.discountAmount)),
                _row('Bill Start Date',
                    _formatDatetime(item.billPeriodStartDate)),
                _row('Bill End Date', _formatDatetime(item.billPeriodEndDate)),
                _row('Remarks', item.remarks),
                _row('Adhoc Bills', isAdhoc ? 'Yes' : 'No'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(color: colors.ink40),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500, color: colors.ink80),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDatetime(String value) {
    if (value.isEmpty) return '-';
    final dateOnly = value.contains(' ') ? value.split(' ').first : value;
    return formatApiDateForDisplay(dateOnly);
  }
}
