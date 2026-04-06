import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/app_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../router/route_names.dart';

/// Single-row horizontal scrollable quick actions.
///
/// Visibility of each action is gated by config flags from [AppSession]:
/// - **Recharge**: `intBulkPayment == 1`
/// - **STB Ops** (Deactivate): `intStbActivation == 1 || intStbDeactivation == 1 || intStbReactivation == 1`
/// - **Upgrade** (Package Ops): `intStbActivation == 1 || intStbDeactivation == 1`
/// - **Complaints** (Assign): `accessForComplaints == 1`
/// - **Customer Search** / **New Customer**: always visible
class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);

    // Build the list of visible action chips based on config flags.
    final actions = <Widget>[];

    // Recharge — gated by intBulkPayment == 1
    if (session != null && session.canBulkPay) {
      actions.add(
        _ActionChip(
          icon: LucideIcons.indianRupee,
          label: 'Recharge',
          color: AppColors.primary,
          bgColor: AppColors.primaryLight,
          onTap: () => context.push(RouteNames.makePayment),
        ),
      );
    }

    // STB Operations — gated by intStbActivation==1 || intStbDeactivation==1 || intStbReactivation==1
    if (session != null &&
        (session.canActivateStb ||
            session.canDeactivateStb ||
            session.canReactivateStb)) {
      actions.add(
        _ActionChip(
          icon: LucideIcons.powerOff,
          label: 'STB Ops',
          color: AppColors.danger,
          bgColor: AppColors.dangerBg,
          onTap: () => context.push(RouteNames.stbOperations),
        ),
      );
    }

    // Package Operations / Upgrade — gated by intStbActivation==1 || intStbDeactivation==1
    if (session != null &&
        (session.canActivateStb || session.canDeactivateStb)) {
      actions.add(
        _ActionChip(
          icon: LucideIcons.arrowUpCircle,
          label: 'Upgrade',
          color: AppColors.success,
          bgColor: AppColors.successBg,
          onTap: () => context.push(RouteNames.packageOperations),
        ),
      );
    }

    // Extend — same gate as Package Operations
    if (session != null &&
        (session.canActivateStb || session.canDeactivateStb)) {
      actions.add(
        _ActionChip(
          icon: LucideIcons.calendarPlus,
          label: 'Extend',
          color: AppColors.warning,
          bgColor: AppColors.warningBg,
          onTap: () => context.push(RouteNames.packageOperations),
        ),
      );
    }

    // Pair STB — gated by stbPairing==1 || stbUnpairing==1
    if (session != null &&
        (session.stbPairing == 1 || session.stbUnpairing == 1)) {
      actions.add(
        _ActionChip(
          icon: LucideIcons.link,
          label: 'Pair STB',
          color: AppColors.info,
          bgColor: AppColors.infoBg,
          onTap: () => context.push(RouteNames.stbOperations),
        ),
      );
    }

    // Complaints — gated by accessForComplaints == 1
    if (session != null && session.canAccessComplaints) {
      actions.add(
        _ActionChip(
          icon: LucideIcons.userPlus,
          label: 'Complaints',
          color: AppColors.orange,
          bgColor: AppColors.orangeBg,
          onTap: () => context.push(RouteNames.complaints),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 62,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: actions,
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
