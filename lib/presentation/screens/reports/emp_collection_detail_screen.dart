import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/report_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../data/models/report/emp_collection_detail.dart';

/// Employee Collection Detail screen.
/// Shows individual customer payments for a selected employee.
class EmpCollectionDetailScreen extends ConsumerWidget {
  final String employeeName;

  const EmpCollectionDetailScreen({
    super.key,
    required this.employeeName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final state = ref.watch(reportProvider);
    final details = state.empCollectionDetails;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text(
          'Collection Details',
          style: TextStyle(
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
          // ── Employee name header ─────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: colors.card,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colors.purpleSoft,
                  child: Text(
                    employeeName.isNotEmpty
                        ? employeeName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.purple,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  employeeName,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.ink10),

          // ── Body ─────────────────────────────────────────────────────
          Expanded(
            child: _buildBody(context, colors, state, details),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppColors colors,
    ReportState state,
    List<EmpCollectionDetail> details,
  ) {
    if (state.isDetailLoading) {
      return Center(
        child: CircularProgressIndicator(color: colors.red),
      );
    }

    if (state.detailError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.alertCircle, size: 40, color: colors.red),
              const SizedBox(height: 12),
              Text(
                state.detailError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  color: colors.ink60,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (details.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.amberSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(LucideIcons.fileSearch, size: 32, color: colors.amber),
            ),
            const SizedBox(height: 16),
            Text(
              'No Details Found',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No customer collection details for this employee',
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

    final total = details.fold<double>(0.0, (sum, d) => sum + d.paidAmount);

    return Column(
      children: [
        // ── List ───────────────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            itemCount: details.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final detail = details[index];
              return _DetailRow(detail: detail, colors: colors);
            },
          ),
        ),

        // ── Footer: Total ──────────────────────────────────────────────
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
                'Total',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.ink,
                ),
              ),
              Text(
                formatCurrency(total),
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

        // ── Print button ───────────────────────────────────────────────
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
}

// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final EmpCollectionDetail detail;
  final AppColors colors;

  const _DetailRow({required this.detail, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.ink10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer name + amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  detail.customerName,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatCurrency(detail.paidAmount),
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date + Payment mode chips
          Row(
            children: [
              Icon(LucideIcons.calendar, size: 13, color: colors.ink40),
              const SizedBox(width: 4),
              Text(
                formatApiDateForDisplay(detail.paidOn),
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  color: colors.ink40,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.blueSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  detail.paymentMode,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
