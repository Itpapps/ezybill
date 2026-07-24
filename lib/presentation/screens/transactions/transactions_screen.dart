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
import '../../../data/models/payment/payment_history_item.dart';
import '../../../data/models/payment/pg_transaction.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Payment History tab provider
// ─────────────────────────────────────────────────────────────────────────────

class _DealerPaymentHistoryState {
  final bool isLoading;
  final String? error;
  final List<PaymentHistoryItem> items;

  const _DealerPaymentHistoryState({
    this.isLoading = false,
    this.error,
    this.items = const [],
  });

  _DealerPaymentHistoryState copyWith({
    bool? isLoading,
    String? error,
    List<PaymentHistoryItem>? items,
  }) =>
      _DealerPaymentHistoryState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        items: items ?? this.items,
      );
}

class _DealerPaymentHistoryNotifier
    extends Notifier<_DealerPaymentHistoryState> {
  @override
  _DealerPaymentHistoryState build() {
    return const _DealerPaymentHistoryState();
  }

  Future<void> load({String? fromDate, String? toDate}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = ref.read(appSessionProvider);
      final ds = ref.read(paymentRemoteDatasourceProvider);
      final data = await ds.getPaymentHistory(
        authtoken: session?.token ?? '',
        customerId: session?.dealerId.toString() ?? '',
        dealerId: session?.dealerId ?? 0,
        fromDate: fromDate,
        toDate: toDate,
      );
      final list = parseList<PaymentHistoryItem>(
        data['payment_details'],
        PaymentHistoryItem.fromJson,
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

final _dealerPaymentHistoryProvider = NotifierProvider<
    _DealerPaymentHistoryNotifier, _DealerPaymentHistoryState>(
  _DealerPaymentHistoryNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// PG Transactions tab provider
// ─────────────────────────────────────────────────────────────────────────────

class _DealerPgTransactionState {
  final bool isLoading;
  final String? error;
  final List<PgTransaction> items;

  const _DealerPgTransactionState({
    this.isLoading = false,
    this.error,
    this.items = const [],
  });

  _DealerPgTransactionState copyWith({
    bool? isLoading,
    String? error,
    List<PgTransaction>? items,
  }) =>
      _DealerPgTransactionState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        items: items ?? this.items,
      );
}

class _DealerPgTransactionNotifier
    extends Notifier<_DealerPgTransactionState> {
  @override
  _DealerPgTransactionState build() {
    return const _DealerPgTransactionState();
  }

  Future<void> load({String paymentStatus = '-1'}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = ref.read(appSessionProvider);
      final ds = ref.read(paymentRemoteDatasourceProvider);
      final data = await ds.getPgTransactionLogs(
        authtoken: session?.token ?? '',
        dealerId: session?.dealerId ?? 0,
        paymentStatus: paymentStatus,
      );
      final list = parseList<PgTransaction>(
        data['paymentresult'],
        PgTransaction.fromJson,
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

final _dealerPgTransactionProvider = NotifierProvider<
    _DealerPgTransactionNotifier, _DealerPgTransactionState>(
  _DealerPgTransactionNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Status filter enum
// ─────────────────────────────────────────────────────────────────────────────

enum _PgStatusFilter {
  all('-1', 'All'),
  success('1', 'Success'),
  failed('2', 'Failed');

  final String value;
  final String label;
  const _PgStatusFilter(this.value, this.label);
}

// ─────────────────────────────────────────────────────────────────────────────
// Transactions Screen
// ─────────────────────────────────────────────────────────────────────────────

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Payment History filters
  DateTime? _payFromDate;
  DateTime? _payToDate;

  // PG Transaction filters
  DateTime? _pgFromDate;
  DateTime? _pgToDate;
  _PgStatusFilter _pgStatus = _PgStatusFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentHistory();
      _loadPgTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPaymentHistory() {
    ref.read(_dealerPaymentHistoryProvider.notifier).load(
          fromDate: _payFromDate != null ? formatApiDate(_payFromDate!) : null,
          toDate: _payToDate != null ? formatApiDate(_payToDate!) : null,
        );
  }

  void _loadPgTransactions() {
    ref
        .read(_dealerPgTransactionProvider.notifier)
        .load(paymentStatus: _pgStatus.value);
  }

  Future<void> _pickDate(bool isFrom, bool isPaymentTab) async {
    final initial = isFrom
        ? (isPaymentTab ? _payFromDate : _pgFromDate) ??
            DateTime.now().subtract(const Duration(days: 30))
        : (isPaymentTab ? _payToDate : _pgToDate) ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isPaymentTab) {
          if (isFrom) {
            _payFromDate = picked;
          } else {
            _payToDate = picked;
          }
        } else {
          if (isFrom) {
            _pgFromDate = picked;
          } else {
            _pgToDate = picked;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text('Transactions',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Payment History'),
            Tab(text: 'PG Transactions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaymentHistoryTab(c, tt),
          _buildPgTransactionsTab(c, tt),
        ],
      ),
    );
  }

  // ── Payment History Tab ─────────────────────────────────────────────────

  Widget _buildPaymentHistoryTab(AppColors c, TextTheme tt) {
    final payState = ref.watch(_dealerPaymentHistoryProvider);

    return Column(
      children: [
        _buildDateFilter(c, tt, isPaymentTab: true),
        Divider(height: 1, color: c.ink05),
        Expanded(child: _buildPaymentList(c, tt, payState)),
      ],
    );
  }

  Widget _buildPaymentList(
      AppColors c, TextTheme tt, _DealerPaymentHistoryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return _CenterMessage(
        icon: LucideIcons.alertCircle,
        iconColor: c.red,
        title: state.error!,
        subtitle: 'Tap to retry',
        onTap: _loadPaymentHistory,
        colors: c,
        textTheme: tt,
      );
    }

    if (state.items.isEmpty) {
      return _CenterMessage(
        icon: LucideIcons.receipt,
        iconColor: c.ink20,
        title: 'No payment history',
        subtitle: 'Payment records will appear here.',
        colors: c,
        textTheme: tt,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadPaymentHistory(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = state.items[index];
          return _PaymentHistoryListTile(
            item: item,
            colors: c,
            textTheme: tt,
          );
        },
      ),
    );
  }

  // ── PG Transactions Tab ─────────────────────────────────────────────────

  Widget _buildPgTransactionsTab(AppColors c, TextTheme tt) {
    final pgState = ref.watch(_dealerPgTransactionProvider);

    return Column(
      children: [
        _buildPgFilters(c, tt),
        Divider(height: 1, color: c.ink05),
        Expanded(child: _buildPgList(c, tt, pgState)),
      ],
    );
  }

  Widget _buildPgFilters(AppColors c, TextTheme tt) {
    return Container(
      color: c.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DateBtn(
                  label: 'From',
                  value: _pgFromDate != null
                      ? formatDisplayDate(_pgFromDate!)
                      : 'Select',
                  onTap: () => _pickDate(true, false),
                  colors: c,
                  textTheme: tt,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateBtn(
                  label: 'To',
                  value: _pgToDate != null
                      ? formatDisplayDate(_pgToDate!)
                      : 'Select',
                  onTap: () => _pickDate(false, false),
                  colors: c,
                  textTheme: tt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: c.ink10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<_PgStatusFilter>(
                      value: _pgStatus,
                      isExpanded: true,
                      style: tt.bodyMedium,
                      icon: Icon(LucideIcons.chevronDown,
                          size: 16, color: c.ink40),
                      items: _PgStatusFilter.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _pgStatus = value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _loadPgTransactions,
                icon: const Icon(LucideIcons.search, size: 16),
                label: const Text('Search'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPgList(
      AppColors c, TextTheme tt, _DealerPgTransactionState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return _CenterMessage(
        icon: LucideIcons.alertCircle,
        iconColor: c.red,
        title: state.error!,
        subtitle: 'Tap to retry',
        onTap: _loadPgTransactions,
        colors: c,
        textTheme: tt,
      );
    }

    if (state.items.isEmpty) {
      return _CenterMessage(
        icon: LucideIcons.creditCard,
        iconColor: c.ink20,
        title: 'No PG transactions',
        subtitle: 'Transaction records will appear here.',
        colors: c,
        textTheme: tt,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadPgTransactions(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = state.items[index];
          return _PgTransactionListTile(
            item: item,
            colors: c,
            textTheme: tt,
          );
        },
      ),
    );
  }

  // ── Shared date filter bar ──────────────────────────────────────────────

  Widget _buildDateFilter(AppColors c, TextTheme tt,
      {required bool isPaymentTab}) {
    final from = isPaymentTab ? _payFromDate : _pgFromDate;
    final to = isPaymentTab ? _payToDate : _pgToDate;

    return Container(
      color: c.card,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _DateBtn(
              label: 'From',
              value: from != null ? formatDisplayDate(from) : 'Select',
              onTap: () => _pickDate(true, isPaymentTab),
              colors: c,
              textTheme: tt,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DateBtn(
              label: 'To',
              value: to != null ? formatDisplayDate(to) : 'Select',
              onTap: () => _pickDate(false, isPaymentTab),
              colors: c,
              textTheme: tt,
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed:
                isPaymentTab ? _loadPaymentHistory : _loadPgTransactions,
            icon: const Icon(LucideIcons.search, size: 16),
            label: const Text('Search'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment History List Tile
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentHistoryListTile extends StatelessWidget {
  final PaymentHistoryItem item;
  final AppColors colors;
  final TextTheme textTheme;

  const _PaymentHistoryListTile({
    required this.item,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: colors.ink.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Left: date + receipt
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatApiDateForDisplay(item.paidOn),
                  style: textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Receipt: ${item.receiptNo}',
                  style: textTheme.labelSmall?.copyWith(color: colors.ink40),
                ),
                if (item.employeeName != null &&
                    item.employeeName!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.employeeName!,
                    style: textTheme.labelSmall?.copyWith(color: colors.ink40),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Payment mode chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colors.blueSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.paymentMode,
              style: textTheme.labelSmall?.copyWith(
                color: colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Amount
          Text(
            formatCurrency(item.paidAmount),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PG Transaction List Tile
// ─────────────────────────────────────────────────────────────────────────────

class _PgTransactionListTile extends StatelessWidget {
  final PgTransaction item;
  final AppColors colors;
  final TextTheme textTheme;

  const _PgTransactionListTile({
    required this.item,
    required this.colors,
    required this.textTheme,
  });

  bool get _isSuccess {
    final s = item.status.toLowerCase();
    return s == 'success' || s == '1' || s == 'completed';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _isSuccess ? colors.green : colors.red;
    final statusBg = _isSuccess ? colors.greenSoft : colors.redSoft;
    final statusLabel = _isSuccess ? 'Success' : 'Failed';

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: colors.ink.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: TXN ID + status
          Row(
            children: [
              Expanded(
                child: Text(
                  'TXN: ${item.transactionId}',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.ink80,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Details row
          Row(
            children: [
              Text(
                'Cust: ${item.customerId}',
                style: textTheme.labelSmall?.copyWith(color: colors.ink40),
              ),
              const SizedBox(width: 12),
              Text(
                item.gateway,
                style: textTheme.labelSmall?.copyWith(color: colors.ink40),
              ),
              const Spacer(),
              Text(
                formatCurrency(item.amount),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.ink80,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            formatApiDateForDisplay(item.transactionDate),
            style: textTheme.labelSmall?.copyWith(color: colors.ink20),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _DateBtn extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final AppColors colors;
  final TextTheme textTheme;

  const _DateBtn({
    required this.label,
    required this.value,
    required this.onTap,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: colors.ink10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.calendar, size: 14, color: colors.ink40),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.ink40,
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    value,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterMessage extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final AppColors colors;
  final TextTheme textTheme;

  const _CenterMessage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colors.ink60),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(color: colors.ink20),
            ),
          ],
        ),
      ),
    );
  }
}
