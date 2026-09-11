import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/report_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../data/models/report/emp_collection_summary.dart';
import '../../common/widgets/app_shell.dart';
import '../../router/route_names.dart';

/// Employee Collection Summary list.
/// Receives dates via navigation extras; reads summary data from the provider.
class EmpCollectionListScreen extends ConsumerWidget {
  final String fromDate;
  final String toDate;

  const EmpCollectionListScreen({
    super.key,
    required this.fromDate,
    required this.toDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final state = ref.watch(reportProvider);
    final summaries = state.empCollectionSummary;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text(
          'Collection Report',
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
          // ── Date range header ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: colors.card,
            child: Row(
              children: [
                Icon(LucideIcons.calendar, size: 16, color: colors.ink40),
                const SizedBox(width: 8),
                Text(
                  '${formatApiDateForDisplay(fromDate)} to ${formatApiDateForDisplay(toDate)}',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.ink80,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.ink10),

          // ── Body ─────────────────────────────────────────────────────
          Expanded(
            child: _buildBody(context, ref, colors, state, summaries),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AppColors colors,
    ReportState state,
    List<EmpCollectionSummary> summaries,
  ) {
    if (state.isCollectionLoading) {
      return Center(
        child: CircularProgressIndicator(color: colors.red),
      );
    }

    if (state.collectionError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.alertCircle, size: 40, color: colors.red),
              const SizedBox(height: 12),
              Text(
                state.collectionError!,
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

    if (summaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.purpleSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child:
                  Icon(LucideIcons.users, size: 32, color: colors.purple),
            ),
            const SizedBox(height: 16),
            Text(
              'No Collection Data',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No employee collections found for this period',
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

    final grandTotal = summaries.fold<double>(0.0, (sum, s) => sum + s.amt);

    return Column(
      children: [
        // ── List ───────────────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            itemCount: summaries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final emp = summaries[index];
              return _EmployeeRow(
                employee: emp,
                colors: colors,
                onTap: () => _onEmployeeTap(context, ref, emp),
              );
            },
          ),
        ),

        // ── Footer: Grand Total ────────────────────────────────────────
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
                'Grand Total',
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

        // ── Print button ───────────────────────────────────────────────
        Padding(
          // The shell hosts this route with extendBody:true, so the Column's
          // last child would otherwise sit behind the nav bar and AI button.
          // This is not a scroll view, so the reserve also shortens the
          // ListView above it rather than adding scrollable slack.
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20 + shellBottomClearance(context),
          ),
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

  /// Row tap: fetch collection details and navigate.
  /// Note: employee_id is NOT sent per server contract.
  Future<void> _onEmployeeTap(
    BuildContext context,
    WidgetRef ref,
    EmpCollectionSummary employee,
  ) async {
    final session = ref.read(appSessionProvider);
    if (session == null) return;

    await ref.read(reportProvider.notifier).loadEmpCollectionDetails(
          fromDate,
          toDate,
          dealerId: session.dealerId,
        );

    if (!context.mounted) return;

    final state = ref.read(reportProvider);
    if (state.detailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.detailError!)),
      );
      return;
    }

    context.push(
      RouteNames.empCollectionDetail,
      extra: {
        'employeeName': employee.name,
        'employeeId': employee.employeeId,
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmployeeRow extends StatelessWidget {
  final EmpCollectionSummary employee;
  final AppColors colors;
  final VoidCallback onTap;

  const _EmployeeRow({
    required this.employee,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.ink10),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.purpleSoft,
                child: Text(
                  employee.name.isNotEmpty
                      ? employee.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.purple,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  employee.name,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                ),
              ),
              Text(
                formatCurrency(employee.amt),
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.ink,
                ),
              ),
              const SizedBox(width: 6),
              Icon(LucideIcons.chevronRight, size: 16, color: colors.ink20),
            ],
          ),
        ),
      ),
    );
  }
}
