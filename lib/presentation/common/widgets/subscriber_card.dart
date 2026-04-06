import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'status_dot.dart';
import 'user_avatar.dart';

/// Data model for the action buttons shown in the card's bottom row.
class _ActionDef {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionDef({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
}

/// Callbacks for subscriber card actions.
class SubscriberCardActions {
  final VoidCallback? onRecharge;
  final VoidCallback? onRefresh;
  final VoidCallback? onUpgrade;
  final VoidCallback? onDeactivate;
  final VoidCallback? onActivate;
  final VoidCallback? onAddPackage;
  final VoidCallback? onPairing;

  const SubscriberCardActions({
    this.onRecharge,
    this.onRefresh,
    this.onUpgrade,
    this.onDeactivate,
    this.onActivate,
    this.onAddPackage,
    this.onPairing,
  });
}

/// A subscriber card matching the POC design.
///
/// Top row: avatar, name, mobile, STB code, status dot, due text.
/// Bottom row: context-aware action buttons that change per status.
class SubscriberCard extends StatelessWidget {
  const SubscriberCard({
    super.key,
    required this.name,
    required this.mobile,
    required this.stbCode,
    required this.status,
    this.dueText,
    this.onTap,
    this.actions = const SubscriberCardActions(),
  });

  final String name;
  final String mobile;
  final String stbCode;

  /// One of: `active`, `deactivated`, `fresh`, `suspended`.
  final String status;

  /// e.g. "13d left", "5d overdue", "New box".
  final String? dueText;

  /// Tapping the top row opens a detail sheet.
  final VoidCallback? onTap;

  final SubscriberCardActions actions;

  List<_ActionDef> _buildActions(AppColors c, AppLocalizations l) {
    switch (status.toLowerCase().trim()) {
      case 'deactivated':
      case 'inactive':
        return [
          _ActionDef(
            icon: LucideIcons.zap,
            label: l.recharge,
            color: c.red,
            onTap: actions.onRecharge,
          ),
          _ActionDef(
            icon: LucideIcons.power,
            label: l.activate,
            color: c.greenDot,
            onTap: actions.onActivate,
          ),
          _ActionDef(
            icon: LucideIcons.refreshCw,
            label: l.refresh,
            color: c.blue,
            onTap: actions.onRefresh,
          ),
          _ActionDef(
            icon: LucideIcons.packageOpen,
            label: l.upgrade,
            color: c.purple,
            onTap: actions.onUpgrade,
          ),
        ];
      case 'fresh':
      case 'new':
        return [
          _ActionDef(
            icon: LucideIcons.power,
            label: l.activate,
            color: c.greenDot,
            onTap: actions.onActivate,
          ),
          _ActionDef(
            icon: LucideIcons.packageOpen,
            label: l.addPackage,
            color: c.amber,
            onTap: actions.onAddPackage,
          ),
          _ActionDef(
            icon: LucideIcons.refreshCw,
            label: l.refresh,
            color: c.blue,
            onTap: actions.onRefresh,
          ),
          _ActionDef(
            icon: LucideIcons.link,
            label: l.pairing,
            color: c.ink40,
            onTap: actions.onPairing,
          ),
        ];
      case 'active':
      default:
        return [
          _ActionDef(
            icon: LucideIcons.zap,
            label: l.recharge,
            color: c.red,
            onTap: actions.onRecharge,
          ),
          _ActionDef(
            icon: LucideIcons.refreshCw,
            label: l.refresh,
            color: c.blue,
            onTap: actions.onRefresh,
          ),
          _ActionDef(
            icon: LucideIcons.packageOpen,
            label: l.upgrade,
            color: c.purple,
            onTap: actions.onUpgrade,
          ),
          _ActionDef(
            icon: LucideIcons.power,
            label: l.deactivate,
            color: c.redDot,
            onTap: actions.onDeactivate,
          ),
        ];
    }
  }

  /// Determine due-text color based on content.
  Color _dueColor(AppColors c) {
    if (dueText == null) return c.ink20;
    final lower = dueText!.toLowerCase();
    if (lower.contains('overdue')) return c.red;
    // Parse "Xd left" and color amber if <= 7
    final match = RegExp(r'(\d+)d\s*left').firstMatch(lower);
    if (match != null) {
      final days = int.tryParse(match.group(1)!) ?? 999;
      if (days <= 7) return c.amber;
    }
    return c.ink20;
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final l = AppLocalizations.of(context)!;
    final isFresh = status.toLowerCase().trim() == 'fresh' || status.toLowerCase().trim() == 'new';
    final actionList = isFresh ? <_ActionDef>[] : _buildActions(c, l);

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: AppRadius.cardBR,
        boxShadow: AppShadow.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top Row (tappable) ──────────────────────────
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(name: name, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: c.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                mobile,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: c.ink40,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (stbCode.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: c.ink05,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  stbCode,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: c.ink60,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isFresh)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: c.greenSoft,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(LucideIcons.userPlus, size: 14, color: c.greenDot),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StatusDot(status: status),
                        if (dueText != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            dueText!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: _dueColor(c),
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ),

          // ── Action Row (hidden for fresh) ─────────────────
          if (actionList.isNotEmpty) Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.ink05)),
            ),
            child: Row(
              children: List.generate(actionList.length, (i) {
                final action = actionList[i];
                final isLast = i == actionList.length - 1;

                return Expanded(
                  child: GestureDetector(
                    onTap: action.onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : Border(
                                right: BorderSide(color: c.ink05),
                              ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(action.icon, size: 16, color: action.color),
                          const SizedBox(height: 2),
                          Text(
                            action.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: action.label == l.recharge
                                  ? action.color
                                  : c.ink20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
