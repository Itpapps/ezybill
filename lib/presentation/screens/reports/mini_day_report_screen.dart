import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/report_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../l10n/app_localizations.dart';

/// Mini Day Report — shows today's collection totals grouped by payment mode.
/// Auto-fetches on load (no date picker per spec).
class MiniDayReportScreen extends ConsumerStatefulWidget {
  const MiniDayReportScreen({super.key});

  @override
  ConsumerState<MiniDayReportScreen> createState() =>
      _MiniDayReportScreenState();
}

class _MiniDayReportScreenState extends ConsumerState<MiniDayReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReport();
    });
  }

  void _fetchReport() {
    final session = ref.read(appSessionProvider);
    if (session == null) return;
    final dateStr = formatApiDate(DateTime.now());
    ref.read(reportProvider.notifier).loadDailyReport(
          dateStr,
          dealerId: session.dealerId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>()!;
    final state = ref.watch(reportProvider);
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(
          l.miniDayReport,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: colors.card,
        foregroundColor: colors.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // ── Date header ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: colors.card,
            child: Row(
              children: [
                Icon(LucideIcons.calendar, size: 16, color: colors.ink40),
                const SizedBox(width: 8),
                Text(
                  'Report for: ${formatDisplayDate(today)}',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.ink80,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.ink10),

          // ── Body ─────────────────────────────────────────────────────────
          Expanded(
            child: _buildBody(colors, state),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppColors colors, ReportState state) {
    // Loading
    if (state.isDailyLoading) {
      return Center(
        child: CircularProgressIndicator(color: colors.red),
      );
    }

    // Error
    if (state.dailyError != null) {
      return _buildError(colors, state.dailyError!);
    }

    // Empty
    if (state.miniDayReport.isEmpty) {
      return _buildEmpty(colors);
    }

    // Data
    final rows = state.miniDayReport;
    final grandTotal = rows.fold<double>(0.0, (sum, r) => sum + r.total);

    return Column(
      children: [
        // ── List ─────────────────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final row = rows[index];
              return _ReportRow(
                paymentMode: row.paymentMode,
                custCount: row.custCount,
                total: row.total,
                colors: colors,
              );
            },
          ),
        ),

        // ── Footer: Grand Total ──────────────────────────────────────────
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: colors.redSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.red.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.grandTotal,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.ink,
                ),
              ),
              Text(
                formatCurrency(grandTotal),
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.red,
                ),
              ),
            ],
          ),
        ),

        // ── Print button ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('BLE print coming soon'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(LucideIcons.printer, size: 18),
              label: const Text(
                'Print Report',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colors.red,
                foregroundColor: colors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.blueSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(LucideIcons.fileBarChart, size: 32, color: colors.blue),
          ),
          const SizedBox(height: 16),
          Text(
            'No Collections Found',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Report appears when collections are done',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: colors.ink40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AppColors colors, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.redSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(LucideIcons.alertCircle, size: 32, color: colors.red),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load report',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: colors.ink40,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _fetchReport,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: Text(AppLocalizations.of(context)!.retry),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.red,
                side: BorderSide(color: colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Row widget
// ─────────────────────────────────────────────────────────────────────────────

class _ReportRow extends StatelessWidget {
  final String paymentMode;
  final int custCount;
  final double total;
  final AppColors colors;

  const _ReportRow({
    required this.paymentMode,
    required this.custCount,
    required this.total,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.ink10),
      ),
      child: Row(
        children: [
          // Payment mode
          Expanded(
            flex: 3,
            child: Text(
              paymentMode,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.ink,
              ),
            ),
          ),

          // Customer count
          SizedBox(
            width: 50,
            child: Text(
              '$custCount',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.ink60,
              ),
            ),
          ),

          // Total amount
          Expanded(
            flex: 3,
            child: Text(
              formatCurrency(total),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
