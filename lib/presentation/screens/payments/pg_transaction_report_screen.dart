import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/payment_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../data/models/payment/pg_transaction.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

class _PgTransactionState {
  final bool isLoading;
  final String? error;
  final List<PgTransaction> items;

  const _PgTransactionState({
    this.isLoading = false,
    this.error,
    this.items = const [],
  });

  _PgTransactionState copyWith({
    bool? isLoading,
    String? error,
    List<PgTransaction>? items,
  }) =>
      _PgTransactionState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        items: items ?? this.items,
      );
}

class _PgTransactionNotifier extends Notifier<_PgTransactionState> {
  @override
  _PgTransactionState build() {
    return const _PgTransactionState();
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
      final list = (data['transactionList'] as List<dynamic>?)
              ?.map((e) => PgTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      state = state.copyWith(isLoading: false, items: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }
}

final _pgTransactionProvider =
    NotifierProvider<_PgTransactionNotifier, _PgTransactionState>(
  _PgTransactionNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Status filter
// ─────────────────────────────────────────────────────────────────────────────

enum _StatusFilter {
  all('-1', 'All'),
  success('1', 'Success'),
  failed('2', 'Failed');

  final String value;
  final String label;
  const _StatusFilter(this.value, this.label);
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class PgTransactionReportScreen extends ConsumerStatefulWidget {
  const PgTransactionReportScreen({super.key});

  @override
  ConsumerState<PgTransactionReportScreen> createState() =>
      _PgTransactionReportScreenState();
}

class _PgTransactionReportScreenState
    extends ConsumerState<PgTransactionReportScreen> {
  _StatusFilter _selectedStatus = _StatusFilter.all;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    ref
        .read(_pgTransactionProvider.notifier)
        .load(paymentStatus: _selectedStatus.value);
  }

  Future<void> _pickDate(bool isFrom) async {
    final c = Theme.of(context).extension<AppColors>()!;
    final initial = isFrom
        ? (_fromDate ?? DateTime.now().subtract(const Duration(days: 30)))
        : (_toDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final tt = Theme.of(context).textTheme;
    final pgState = ref.watch(_pgTransactionProvider);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text('PG Transactions',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: c.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(c, tt),
          Divider(height: 1, color: c.ink05),
          Expanded(child: _buildBody(c, tt, pgState)),
        ],
      ),
    );
  }

  Widget _buildFilters(AppColors c, TextTheme tt) {
    return Container(
      color: c.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date range row
          Row(
            children: [
              Expanded(
                child: _DatePickerButton(
                  label: 'From',
                  value: _fromDate != null
                      ? formatDisplayDate(_fromDate!)
                      : 'Select',
                  onTap: () => _pickDate(true),
                  colors: c,
                  textTheme: tt,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DatePickerButton(
                  label: 'To',
                  value:
                      _toDate != null ? formatDisplayDate(_toDate!) : 'Select',
                  onTap: () => _pickDate(false),
                  colors: c,
                  textTheme: tt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status filter + search button
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
                    child: DropdownButton<_StatusFilter>(
                      value: _selectedStatus,
                      isExpanded: true,
                      style: tt.bodyMedium,
                      icon:
                          Icon(LucideIcons.chevronDown, size: 16, color: c.ink40),
                      items: _StatusFilter.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(LucideIcons.search, size: 16),
                label: const Text('Search'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppColors c, TextTheme tt, _PgTransactionState pgState) {
    if (pgState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pgState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.alertCircle, size: 48, color: c.red),
              const SizedBox(height: 16),
              Text(
                pgState.error!,
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: c.ink60),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (pgState.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.creditCard, size: 56, color: c.ink20),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: tt.titleSmall?.copyWith(color: c.ink40),
            ),
            const SizedBox(height: 4),
            Text(
              'PG transaction records will appear here.',
              style: tt.bodySmall?.copyWith(color: c.ink20),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: pgState.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _PgTransactionCard(
            item: pgState.items[index],
            colors: c,
            textTheme: tt,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PG Transaction Card
// ─────────────────────────────────────────────────────────────────────────────

class _PgTransactionCard extends StatelessWidget {
  final PgTransaction item;
  final AppColors colors;
  final TextTheme textTheme;

  const _PgTransactionCard({
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.ink.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: transaction ID + status chip
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
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: colors.ink05),
          const SizedBox(height: 12),

          // Details grid
          Row(
            children: [
              Expanded(
                child: _InfoCol(
                  label: 'Customer ID',
                  value: item.customerId,
                  colors: colors,
                  textTheme: textTheme,
                ),
              ),
              Expanded(
                child: _InfoCol(
                  label: 'Amount',
                  value: formatCurrency(item.amount),
                  colors: colors,
                  textTheme: textTheme,
                  isMono: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _InfoCol(
                  label: 'Gateway',
                  value: item.gateway,
                  colors: colors,
                  textTheme: textTheme,
                ),
              ),
              Expanded(
                child: _InfoCol(
                  label: 'Date',
                  value: formatApiDateForDisplay(item.transactionDate),
                  colors: colors,
                  textTheme: textTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _DatePickerButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final AppColors colors;
  final TextTheme textTheme;

  const _DatePickerButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: colors.ink10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.calendar, size: 16, color: colors.ink40),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.ink40,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    value,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
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

class _InfoCol extends StatelessWidget {
  final String label;
  final String value;
  final AppColors colors;
  final TextTheme textTheme;
  final bool isMono;

  const _InfoCol({
    required this.label,
    required this.value,
    required this.colors,
    required this.textTheme,
    this.isMono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colors.ink40,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: isMono
              ? GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.ink80,
                )
              : textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.ink80,
                ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
