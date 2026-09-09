import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/app_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/widgets/wallet_bar.dart';

/// Sticky header matching the POC design:
///
/// - Avatar (initials, red gradient) + LCO name + business code
/// - Action buttons: theme toggle, language
/// - Wallet bar below
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.session,
    required this.walletBalance,
    this.lastRechargeText,
    this.showWallet = true,
    this.onThemeToggle,
    this.onLanguage,
    this.onWalletTopUp,
    this.onWalletHistory,
    this.onRefresh,
  });

  final AppSession session;
  final String walletBalance;
  final String? lastRechargeText;
  final bool showWallet;
  final VoidCallback? onThemeToggle;
  final VoidCallback? onLanguage;
  final VoidCallback? onWalletTopUp;
  final VoidCallback? onWalletHistory;
  final VoidCallback? onRefresh;

  String _getInitials() {
    final f = session.firstName.isNotEmpty
        ? session.firstName[0].toUpperCase()
        : '';
    final l =
        session.lastName.isNotEmpty ? session.lastName[0].toUpperCase() : '';
    return '$f$l'.isNotEmpty ? '$f$l' : '?';
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: c.card,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Identity Row ───────────────────────────────────────
          Row(
            children: [
              // Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [c.red, c.redDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _getInitials(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Name + business code
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.businessName.isNotEmpty
                          ? session.businessName
                          : session.displayName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: c.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _buildSubtitle(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: c.ink40,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action buttons
              _ActionButton(
                // Shows the CURRENT theme, not the pending action:
                // light -> sun, dark -> moon.
                icon: isDark ? LucideIcons.moon : LucideIcons.sun,
                onTap: onThemeToggle,
              ),
              const SizedBox(width: 6),
              _ActionButton(
                icon: LucideIcons.globe,
                onTap: onLanguage,
              ),
            ],
          ),

          // ── Wallet Bar ─────────────────────────────────────────
          if (showWallet) ...[
            const SizedBox(height: 10),
            WalletBar(
              balance: walletBalance,
              lastRechargeText: lastRechargeText,
              onTopUp: onWalletTopUp,
              onHistory: onWalletHistory,
            ),
          ],
        ],
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (session.lcoCode.isNotEmpty) parts.add('LCO-${session.lcoCode}');
    if (session.lcoLocation.isNotEmpty) parts.add(session.lcoLocation);
    return parts.join(' \u00B7 ');
  }
}

// ── Action Button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: c.ink40),
      ),
    );
  }
}
