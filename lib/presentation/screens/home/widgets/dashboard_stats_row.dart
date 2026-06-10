import 'package:flutter/material.dart';
import '../../../../application/providers/dashboard_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Compact stats pills row
class DashboardStatsRow extends StatelessWidget {
  final DashboardState dashboard;

  const DashboardStatsRow({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    if (dashboard.isLoading) {
      return const SizedBox(
        height: 36,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (dashboard.errorMessage != null) {
      return SizedBox(
        height: 36,
        child: Center(
          child: Text(
            'Failed to load: ${dashboard.errorMessage}',
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              color: AppColors.danger,
            ),
          ),
        ),
      );
    }

    final total =
        dashboard.totalActiveCustomers + dashboard.totalDeactiveCustomers;

    return Row(
      children: [
        _MiniPill(
            value: total.toString(),
            label: 'Total',
            color: AppColors.primary,
            bgColor: const Color(0xFFEEF1FD)),
        const SizedBox(width: 6),
        _MiniPill(
            value: dashboard.totalActiveCustomers.toString(),
            label: 'Active',
            color: AppColors.success,
            bgColor: AppColors.successBg),
        const SizedBox(width: 6),
        _MiniPill(
            value: dashboard.totalDeactiveCustomers.toString(),
            label: 'Inactive',
            color: AppColors.danger,
            bgColor: AppColors.dangerBg),
        const SizedBox(width: 6),
        _MiniPill(
            value: dashboard.totalUnPaidCustomers.toString(),
            label: 'Unpaid',
            color: AppColors.info,
            bgColor: AppColors.infoBg),
      ],
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color bgColor;

  const _MiniPill({
    required this.value,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
