import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../screens/quick_action/quick_action_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tab definition
// ─────────────────────────────────────────────────────────────────────────────

/// Icons for bottom-nav tabs in display order.
const _allTabIcons = [
  LucideIcons.home,
  LucideIcons.users,
  LucideIcons.barChart3,
  LucideIcons.receipt,
  LucideIcons.settings,
];

/// Returns localized labels for tabs using AppLocalizations.
List<String> _allTabLabels(AppLocalizations l) => [
  l.home,
  l.subscribers,
  l.reports,
  l.transactions,
  l.settings,
];

/// Indices into [_allTabs].
const _idxHome = 0;
const _idxSubscribers = 1;
const _idxReports = 2;
const _idxTransactions = 3;
const _idxSettings = 4;

// ─────────────────────────────────────────────────────────────────────────────
// AppShell — wraps StatefulShellRoute's navigation shell
// ─────────────────────────────────────────────────────────────────────────────

/// The root shell widget that provides the bottom navigation bar, the AI FAB,
/// and tab persistence via [StatefulNavigationShell].
///
/// Tabs are conditionally shown/hidden based on [AppSession] access flags:
/// - **Reports**: visible for non-distributors, or when the session explicitly
///   grants report access.
/// - **Transactions**: visible when `paymentHistPageAccess == 1`.
class AppShell extends ConsumerWidget {
  /// The [StatefulNavigationShell] provided by GoRouter's
  /// [StatefulShellRoute.indexedStack].
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  // ── Visibility logic ───────────────────────────────────────────────────────

  /// Returns the list of _logical tab indices_ (into [_allTabs]) that should
  /// be rendered for the current session.
  static List<int> visibleTabIndices(AppSession? session) {
    final tabs = <int>[_idxHome, _idxSubscribers];

    // Reports: visible for non-distributor OR when explicitly granted.
    if (session == null || !session.isDistributor) {
      tabs.add(_idxReports);
    }

    // Transactions: visible when payment history access is granted.
    if (session != null && session.canAccessPaymentHistory) {
      tabs.add(_idxTransactions);
    }

    tabs.add(_idxSettings);
    return tabs;
  }

  /// Maps a visible-tab list index to the shell branch index used by GoRouter.
  /// The branch indices always match [_allTabs] ordering (0-4) regardless of
  /// which tabs are hidden.
  void _onTabTapped(List<int> visible, int tappedVisibleIndex) {
    final branchIndex = visible[tappedVisibleIndex];
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  /// Converts the current GoRouter branch index into the corresponding
  /// visible-tab list index, falling back to 0 (Home) if the active branch is
  /// currently hidden.
  int _activeVisibleIndex(List<int> visible) {
    final idx = visible.indexOf(navigationShell.currentIndex);
    return idx == -1 ? 0 : idx;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final colors = Theme.of(context).extension<AppColors>()!;
    final visible = visibleTabIndices(session);
    final activeIdx = _activeVisibleIndex(visible);

    return Scaffold(
      body: navigationShell,
      // Prevent the body from resizing when the keyboard appears.
      resizeToAvoidBottomInset: false,
      extendBody: true,
      floatingActionButton: _AiFab(colors: colors),
      bottomNavigationBar: _BottomNavBar(
        colors: colors,
        visibleTabs: visible,
        activeIndex: activeIdx,
        onTap: (i) => _onTabTapped(visible, i),
        tabLabels: _allTabLabels(AppLocalizations.of(context)!),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Navigation Bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final AppColors colors;
  final List<int> visibleTabs;
  final int activeIndex;
  final ValueChanged<int> onTap;
  final List<String> tabLabels;

  const _BottomNavBar({
    required this.colors,
    required this.visibleTabs,
    required this.activeIndex,
    required this.onTap,
    required this.tabLabels,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // Glass cues, not literal transparency: extendBody is true, so the
        // customer list scrolls behind this bar. Real translucency without
        // blur would show sharp rows through it, and BackdropFilter would
        // re-blur on every scroll frame — the one thing to avoid here.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? Color.lerp(colors.card, Colors.white, 0.05)! : colors.card,
            isDark
                ? Color.lerp(colors.card, Colors.black, 0.12)!
                : Color.lerp(colors.card, colors.ink, 0.02)!,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: isDark
                ? colors.ink.withValues(alpha: 0.10)
                : colors.ink05,
            width: 1,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000), // rgba(0,0,0,0.04)
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: 56,
        child: Row(
          children: List.generate(visibleTabs.length, (i) {
            final tabIdx = visibleTabs[i];
            final isActive = i == activeIndex;

            return Expanded(
              child: _NavItem(
                icon: _allTabIcons[tabIdx],
                label: tabLabels[tabIdx],
                isActive: isActive,
                colors: colors,
                onTap: () => onTap(i),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single navigation item
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final AppColors colors;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive ? colors.red : colors.ink40;
    final labelColor = isActive ? colors.red : colors.ink40;
    final containerBg = isActive ? colors.redSoft : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container: 28x28, border-radius 8
          // AnimatedScale owns its controller in its OWN State, so ticks
          // rebuild only this subtree — never AppShell, and therefore never
          // navigationShell / the customer list. Driven by the existing
          // isActive flag, so no new state and nothing to dispose.
          // Transform-based: paint-only, so bar height, item width and the
          // opaque hit area of the parent GestureDetector are unaffected.
          AnimatedScale(
            scale: isActive ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: containerBg,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
          const SizedBox(height: 2),
          // Label: 9px
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: labelColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Floating Action Button
// ─────────────────────────────────────────────────────────────────────────────

class _AiFab extends StatelessWidget {
  final AppColors colors;

  const _AiFab({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Position above the bottom nav (~70px from bottom of screen).
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        width: 52,
        height: 52,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Gradient circle button
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.red, colors.redDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.red.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const QuickActionSheet(),
                    );
                  },
                  child: const Center(
                    child: Icon(
                      LucideIcons.bot,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // BETA badge
            Positioned(
              top: -4,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5A623), // amber
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  'BETA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
