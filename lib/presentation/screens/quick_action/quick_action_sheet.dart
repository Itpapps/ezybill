import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/core_providers.dart';
import '../../../application/providers/dashboard_provider.dart';
import '../../../application/providers/quick_action_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../router/route_names.dart';

/// Quick Action bottom sheet — a floating overlay that lets field operators
/// search and act on STBs in one place without navigating away.
class QuickActionSheet extends ConsumerStatefulWidget {
  const QuickActionSheet({super.key});

  @override
  ConsumerState<QuickActionSheet> createState() => _QuickActionSheetState();
}

class _QuickActionSheetState extends ConsumerState<QuickActionSheet> {
  final _searchController = TextEditingController();
  final _aiController = TextEditingController();
  bool _aiExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    _aiController.dispose();
    super.dispose();
  }

  void _doSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    ref.read(quickActionProvider.notifier).search(query);
  }

  void _doAiSearch() {
    // TODO: Wire to AI natural language tool calling
    // For now, route AI input to normal search
    final query = _aiController.text.trim();
    if (query.isEmpty) return;
    // Simple heuristic: extract numbers/identifiers from the AI prompt
    _searchController.text = query;
    ref.read(quickActionProvider.notifier).search(query);
    _aiController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>()!;
    final state = ref.watch(quickActionProvider);
    final session = ref.watch(appSessionProvider);
    final dashState = ref.watch(dashboardProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Listen for action results and show snackbar
    ref.listen<QuickActionState>(quickActionProvider, (prev, next) {
      if (next.actionResult != null && prev?.actionResult != next.actionResult) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(next.actionResult!),
              backgroundColor: next.actionSuccess ? colors.green : colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        ref.read(quickActionProvider.notifier).clearActionResult();
      }
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Drag handle ──
          Container(
            color: const Color(0xFF1E2537),
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // ── Header bar ──
          _HeaderBar(
            colors: colors,
            l: l,
            lcoCode: session?.lcoCode ?? '',
            walletBalance: dashState.walletBalance,
            currencySymbol: session?.currencySymbol ?? '\u20B9',
            onClose: () => Navigator.of(context).pop(),
            onTopUp: () {
              Navigator.of(context).pop();
              context.push(RouteNames.lcoTopup);
            },
            onLedger: () {
              Navigator.of(context).pop();
              context.push(RouteNames.lcoWalletHistory);
            },
          ),

          // ── AI Assistant placeholder ──
          _AiAssistantSection(
            colors: colors,
            l: l,
            expanded: _aiExpanded,
            controller: _aiController,
            onToggle: () => setState(() => _aiExpanded = !_aiExpanded),
            onSearch: _doAiSearch,
            onChipTap: (text) {
              _searchController.text = text;
              _doSearch();
            },
          ),

          // ── Search bar ──
          _SearchBar(
            colors: colors,
            l: l,
            controller: _searchController,
            searchField: state.searchField,
            isSearching: state.isSearching,
            onFieldChanged: (field) {
              ref.read(quickActionProvider.notifier).setSearchField(field);
            },
            onSearch: _doSearch,
          ),

          // ── Content ──
          Expanded(
            child: Container(
              color: colors.bg,
              child: state.isSearching
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? _ErrorView(colors: colors, error: state.error!)
                    : state.hasResult
                        ? _ResultCard(
                            colors: colors,
                            l: l,
                            state: state,
                            session: session,
                            onRecharge: () {
                              Navigator.of(context).pop();
                              // TODO: Navigate to payment screen with customer data
                            },
                            onDeactivate: () => _showDeactivateDialog(context, ref, colors, l),
                            onActivate: () {
                              ref.read(quickActionProvider.notifier).activate();
                            },
                            onTempActivate: () {
                              ref.read(quickActionProvider.notifier).temporaryActivate();
                            },
                            onRefresh: () {
                              ref.read(quickActionProvider.notifier).refresh();
                            },
                            onNewCustomer: () {
                              final s = ref.read(quickActionProvider);
                              Navigator.of(context).pop();
                              context.push(
                                RouteNames.newCustomer,
                                extra: {
                                  'serialNumber': s.serialNumber ?? '',
                                  'vcNumber': s.vcNumber ?? '',
                                },
                              );
                            },
                          )
                        : _EmptyView(colors: colors, l: l),
          ),
          ),

          // ── Footer ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: 10,
              bottom: bottomPadding + 10,
            ),
            child: Text(
              l.poweredByEzybill,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: colors.ink40,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(
    BuildContext context,
    WidgetRef ref,
    AppColors colors,
    AppLocalizations l,
  ) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deactivateStb),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.confirmDeactivate),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: l.remarks,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              // Use reason_id "1" as default; in production this would come
              // from a reason dropdown
              ref.read(quickActionProvider.notifier).deactivate(
                    '1',
                    reasonController.text.trim(),
                  );
            },
            child: Text(l.deactivate, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Header Bar
// =============================================================================

class _HeaderBar extends StatelessWidget {
  final AppColors colors;
  final AppLocalizations l;
  final String lcoCode;
  final double walletBalance;
  final String currencySymbol;
  final VoidCallback onClose;
  final VoidCallback onTopUp;
  final VoidCallback? onLedger;

  const _HeaderBar({
    required this.colors,
    required this.l,
    required this.lcoCode,
    required this.walletBalance,
    required this.currencySymbol,
    required this.onClose,
    required this.onTopUp,
    this.onLedger,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF1E2537),
      child: Row(
        children: [
          // Lightning icon + title + LCO badge.
          //
          // The title is the ONLY element in this Row allowed to shrink: it is
          // the sole Flexible inside the Expanded group, so it absorbs the
          // whole shortfall and ellipsises, while the wallet / TOP UP / close
          // controls always lay out at their natural size. Previously the
          // wallet was the only Flexible here and a Spacer competed with it
          // for the leftover space, so on phone widths the balance was scaled
          // away to nothing — it only survived on tablets.
          const Icon(LucideIcons.zap, size: 18, color: Color(0xFFF5A623)),
          const SizedBox(width: 6),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    l.quickAction,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // LCO badge
                if (lcoCode.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lcoCode,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Wallet balance (tappable → opens ledger)
          GestureDetector(
            onTap: onLedger,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.wallet,
                      size: 12, color: Color(0xFF2ECC71)),
                  const SizedBox(width: 4),
                  Text(
                    '$currencySymbol${walletBalance.toStringAsFixed(0)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (onLedger != null) ...[
                    const SizedBox(width: 2),
                    const Icon(LucideIcons.history,
                        size: 10, color: Colors.white54),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // TOPUP pill
          GestureDetector(
            onTap: onTopUp,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.plus, size: 10, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    l.topUp.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Close button
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
              child: const Icon(LucideIcons.x, size: 16, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// AI Assistant Section (Coming Soon)
// =============================================================================

class _AiAssistantSection extends StatelessWidget {
  final AppColors colors;
  final AppLocalizations l;
  final bool expanded;
  final TextEditingController controller;
  final VoidCallback onToggle;
  final VoidCallback onSearch;
  final ValueChanged<String> onChipTap;

  const _AiAssistantSection({
    required this.colors,
    required this.l,
    required this.expanded,
    required this.controller,
    required this.onToggle,
    required this.onSearch,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colors.purpleSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.purple.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Toggle header
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(LucideIcons.bot, size: 16, color: colors.purple),
                  const SizedBox(width: 6),
                  Text(
                    l.aiAssistant,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.purple,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.purple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l.comingSoon,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: colors.purple,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 16,
                    color: colors.purple,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (expanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI text field
                  // TODO: Wire to AI natural language tool calling
                  TextField(
                    controller: controller,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: l.describeAction,
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: colors.ink40,
                      ),
                      filled: true,
                      fillColor: colors.card,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.ink10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.ink10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(LucideIcons.send, size: 18, color: colors.purple),
                        onPressed: onSearch,
                      ),
                    ),
                    onSubmitted: (_) => onSearch(),
                  ),
                  const SizedBox(height: 8),

                  // Example chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _exampleChip(l.exampleRecharge, colors),
                      _exampleChip(l.exampleDeactivate, colors),
                      _exampleChip(l.exampleStatus, colors),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _exampleChip(String text, AppColors colors) {
    return GestureDetector(
      onTap: () => onChipTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.ink10),
        ),
        child: Text(
          '"$text"',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: colors.ink60,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Search Bar
// =============================================================================

class _SearchBar extends StatelessWidget {
  final AppColors colors;
  final AppLocalizations l;
  final TextEditingController controller;
  final QuickSearchField searchField;
  final bool isSearching;
  final ValueChanged<QuickSearchField> onFieldChanged;
  final VoidCallback onSearch;

  const _SearchBar({
    required this.colors,
    required this.l,
    required this.controller,
    required this.searchField,
    required this.isSearching,
    required this.onFieldChanged,
    required this.onSearch,
  });

  String _hintForField(QuickSearchField field, AppLocalizations l) {
    switch (field) {
      case QuickSearchField.stbNo:
        return l.enterStbNo;
      case QuickSearchField.vcNo:
        return l.enterVcNo;
      case QuickSearchField.mobile:
        return l.enterMobile;
      case QuickSearchField.name:
        return l.enterName;
      case QuickSearchField.accountNo:
        return l.enterAccountNo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Unified pill search bar (matches dashboard AppSearchBar) ──
          Container(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(100), // pill
              border: Border.all(color: colors.ink10, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: colors.ink.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Filter dropdown (inside pill, left side)
                Container(
                  padding: const EdgeInsets.only(left: 4),
                  child: PopupMenuButton<QuickSearchField>(
                    onSelected: onFieldChanged,
                    offset: const Offset(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            searchField.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.red,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(LucideIcons.chevronDown, size: 12, color: colors.red),
                        ],
                      ),
                    ),
                    itemBuilder: (_) => QuickSearchField.values
                        .map((f) => PopupMenuItem(
                              value: f,
                              child: Row(
                                children: [
                                  Icon(
                                    f == searchField ? LucideIcons.check : LucideIcons.search,
                                    size: 14,
                                    color: f == searchField ? colors.red : colors.ink40,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    f.label,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: f == searchField ? FontWeight.w700 : FontWeight.w500,
                                      color: f == searchField ? colors.red : colors.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),

                // Divider line
                Container(width: 1, height: 24, color: colors.ink10),

                // Text input
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.ink,
                    ),
                    decoration: InputDecoration(
                      hintText: _hintForField(searchField, l),
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: colors.ink20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: InputBorder.none,
                      suffixIcon: controller.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                controller.clear();
                              },
                              child: Icon(LucideIcons.x, size: 16, color: colors.ink20),
                            )
                          : null,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSearch(),
                  ),
                ),

                // Circular red search button (matches dashboard)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: GestureDetector(
                    onTap: isSearching ? null : onSearch,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.red.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(LucideIcons.arrowRight, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              l.pressEnterOrSearch,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: colors.ink20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Result Card
// =============================================================================

class _ResultCard extends StatelessWidget {
  final AppColors colors;
  final AppLocalizations l;
  final QuickActionState state;
  final dynamic session;
  final VoidCallback onRecharge;
  final VoidCallback onDeactivate;
  final VoidCallback onActivate;
  final VoidCallback onTempActivate;
  final VoidCallback onRefresh;
  final VoidCallback onNewCustomer;

  const _ResultCard({
    required this.colors,
    required this.l,
    required this.state,
    required this.session,
    required this.onRecharge,
    required this.onDeactivate,
    required this.onActivate,
    required this.onTempActivate,
    required this.onRefresh,
    required this.onNewCustomer,
  });

  @override
  Widget build(BuildContext context) {
    final status = state.stbStatus ?? '';
    final isFresh = status == 'FRESH';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── STB header + status ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Serial + status badge row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isFresh
                            ? (state.customerName ?? 'Customer')
                            : (state.serialNumber ?? 'N/A'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colors.ink,
                        ),
                      ),
                    ),
                    _StatusBadge(status: status, colors: colors),
                  ],
                ),

                if (!isFresh) ...[
                  const SizedBox(height: 8),

                  // VC + CAS row
                  Row(
                    children: [
                      Icon(LucideIcons.tv, size: 13, color: colors.ink40),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'VC: ${state.vcNumber ?? 'N/A'} · ${state.casName ?? ''}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: colors.ink60,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Customer name + phone
                  Row(
                    children: [
                      Icon(LucideIcons.user, size: 13, color: colors.ink40),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          state.customerName ?? 'N/A',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.ink,
                          ),
                        ),
                      ),
                      Icon(LucideIcons.phone, size: 13, color: colors.ink40),
                      const SizedBox(width: 4),
                      Text(
                        state.mobileNumber ?? 'N/A',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: colors.ink60,
                        ),
                      ),
                    ],
                  ),

                  // Due amount + due date (for active boxes)
                  if (status.toUpperCase() == 'ACTIVE') ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.redSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.indianRupee, size: 14, color: colors.red),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Due: \u20B9${state.dueAmount ?? '0.00'}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: colors.red,
                                  ),
                                ),
                                if (state.dueDate != null && state.dueDate!.isNotEmpty)
                                  Text(
                                    'Due Date: ${state.dueDate}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      color: colors.ink60,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Compact info
                  _InfoRow(label: l.activated, value: state.activationDate ?? 'N/A', colors: colors),
                  _InfoRow(label: l.lco, value: state.lcoName ?? 'N/A', colors: colors),
                  if (state.stbType != null && state.stbType!.isNotEmpty)
                    _InfoRow(label: l.stbType, value: '${state.stbType} · ${state.stbModel ?? ''}'.trim(), colors: colors),
                ] else ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(LucideIcons.tv, size: 13, color: colors.ink40),
                      const SizedBox(width: 5),
                      Text(
                        'VC: ${state.vcNumber ?? 'N/A'}',
                        style: GoogleFonts.jetBrainsMono(fontSize: 11, color: colors.ink60),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Packages section ──
          if (!isFresh && (state.activePackages.isNotEmpty || state.deactivatedPackages.isNotEmpty)) ...[
            const SizedBox(height: 12),

            // Active packages
            if (state.activePackages.isNotEmpty) ...[
              _SectionLabel(
                label: l.activePackagesLabel,
                color: colors.green,
                colors: colors,
              ),
              const SizedBox(height: 6),
              ...state.activePackages.map((pkg) => _PackageRow(
                    pkg: pkg,
                    isActive: true,
                    colors: colors,
                  )),
            ],

            // Deactivated packages
            if (state.deactivatedPackages.isNotEmpty) ...[
              const SizedBox(height: 10),
              _SectionLabel(
                label: l.lastDeactivatedPackages,
                color: colors.red,
                colors: colors,
              ),
              const SizedBox(height: 6),
              ...state.deactivatedPackages.take(5).map((pkg) => _PackageRow(
                    pkg: pkg,
                    isActive: false,
                    colors: colors,
                  )),
            ],
          ],

          // ── Action buttons ──
          const SizedBox(height: 16),
          if (state.isActioning)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else
            _ActionButtons(
              status: status,
              colors: colors,
              l: l,
              onRecharge: onRecharge,
              onDeactivate: onDeactivate,
              onActivate: onActivate,
              onTempActivate: onTempActivate,
              onRefresh: onRefresh,
              onNewCustomer: onNewCustomer,
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// =============================================================================
// Status Badge
// =============================================================================

class _StatusBadge extends StatelessWidget {
  final String status;
  final AppColors colors;

  const _StatusBadge({required this.status, required this.colors});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label = status;

    switch (status.toUpperCase()) {
      case 'ACTIVE':
        bgColor = colors.greenSoft;
        textColor = colors.green;
        break;
      case 'DE-ACTIVE':
      case 'DEACTIVE':
      case 'INACTIVE':
        bgColor = colors.redSoft;
        textColor = colors.red;
        label = 'DE-ACTIVE';
        break;
      case 'TEMPORARY DE-ACTIVE':
      case 'TEMP DEACTIVATED':
        bgColor = colors.amberSoft;
        textColor = colors.amber;
        label = 'TEMP DEACTIVATED';
        break;
      case 'FRESH':
        bgColor = colors.blueSoft;
        textColor = colors.blue;
        break;
      default:
        bgColor = colors.ink05;
        textColor = colors.ink60;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}

// =============================================================================
// Info Row
// =============================================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final AppColors colors;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.ink40,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: colors.ink80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Section Label
// =============================================================================

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  final AppColors colors;

  const _SectionLabel({
    required this.label,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: colors.ink60,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Package Row
// =============================================================================

class _PackageRow extends StatelessWidget {
  final Map<String, dynamic> pkg;
  final bool isActive;
  final AppColors colors;

  const _PackageRow({
    required this.pkg,
    required this.isActive,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final name = (pkg['product_name'] ?? pkg['productName'] ?? pkg['package_name'] ?? pkg['packageName'] ?? 'Unknown').toString();
    final date = isActive
        ? (pkg['activation_date'] ?? pkg['activationDate'] ?? pkg['start_date'] ?? '').toString()
        : (pkg['deactivation_date'] ?? pkg['deactivationDate'] ?? pkg['end_date'] ?? '').toString();
    final price = (pkg['product_price'] ?? pkg['productPrice'] ?? pkg['price'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.ink05),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.ink80,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (date.isNotEmpty)
                  Text(
                    date,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: colors.ink40,
                    ),
                  ),
              ],
            ),
          ),
          if (price.isNotEmpty)
            Text(
              '\u20B9$price',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? colors.green : colors.ink40,
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Action Buttons
// =============================================================================

class _ActionButtons extends StatelessWidget {
  final String status;
  final AppColors colors;
  final AppLocalizations l;
  final VoidCallback onRecharge;
  final VoidCallback onDeactivate;
  final VoidCallback onActivate;
  final VoidCallback onTempActivate;
  final VoidCallback onRefresh;
  final VoidCallback onNewCustomer;

  const _ActionButtons({
    required this.status,
    required this.colors,
    required this.l,
    required this.onRecharge,
    required this.onDeactivate,
    required this.onActivate,
    required this.onTempActivate,
    required this.onRefresh,
    required this.onNewCustomer,
  });

  @override
  Widget build(BuildContext context) {
    // FRESH → New Customer only
    if (status == 'FRESH') {
      return _actionButton(
        label: l.newCustomer.toUpperCase(),
        icon: LucideIcons.userPlus,
        color: colors.green,
        onTap: onNewCustomer,
      );
    }

    // ACTIVE → Recharge, Deactivate, Add Package, Refresh
    if (status.toUpperCase() == 'ACTIVE') {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _actionButton(
                label: l.recharge.toUpperCase(),
                icon: LucideIcons.zap,
                color: colors.green,
                onTap: onRecharge,
              )),
              const SizedBox(width: 8),
              Expanded(child: _actionButton(
                label: l.deactivate.toUpperCase(),
                icon: LucideIcons.powerOff,
                color: colors.red,
                onTap: onDeactivate,
              )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _actionButton(
                label: l.addPackage.toUpperCase(),
                icon: LucideIcons.packagePlus,
                color: colors.purple,
                onTap: onActivate, // Navigate to package operations
              )),
              const SizedBox(width: 8),
              Expanded(child: _actionButton(
                label: l.refresh.toUpperCase(),
                icon: LucideIcons.refreshCw,
                color: colors.blue,
                onTap: onRefresh,
              )),
            ],
          ),
        ],
      );
    }

    // INACTIVE / DE-ACTIVE → Recharge, Activate
    if (['DE-ACTIVE', 'DEACTIVE', 'INACTIVE'].contains(status.toUpperCase())) {
      return Row(
        children: [
          Expanded(child: _actionButton(
            label: l.recharge.toUpperCase(),
            icon: LucideIcons.zap,
            color: colors.green,
            onTap: onRecharge,
          )),
          const SizedBox(width: 8),
          Expanded(child: _actionButton(
            label: l.activate.toUpperCase(),
            icon: LucideIcons.power,
            color: colors.greenDot,
            onTap: onActivate,
          )),
        ],
      );
    }

    // TEMP DEACTIVATED → Recharge, Temp Activate
    if (['TEMPORARY DE-ACTIVE', 'TEMP DEACTIVATED'].contains(status.toUpperCase())) {
      return Row(
        children: [
          Expanded(child: _actionButton(
            label: l.recharge.toUpperCase(),
            icon: LucideIcons.zap,
            color: colors.green,
            onTap: onRecharge,
          )),
          const SizedBox(width: 8),
          Expanded(child: _actionButton(
            label: l.tempActivate.toUpperCase(),
            icon: LucideIcons.zap,
            color: colors.amber,
            onTap: onTempActivate,
          )),
        ],
      );
    }

    // Default fallback
    return _actionButton(
      label: l.activate.toUpperCase(),
      icon: LucideIcons.power,
      color: colors.green,
      onTap: onActivate,
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Empty View
// =============================================================================

class _EmptyView extends StatelessWidget {
  final AppColors colors;
  final AppLocalizations l;

  const _EmptyView({required this.colors, required this.l});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.search, size: 48, color: colors.ink20),
          const SizedBox(height: 12),
          Text(
            l.searchPlaceholder,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: colors.ink40,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Error View
// =============================================================================

class _ErrorView extends StatelessWidget {
  final AppColors colors;
  final String error;

  const _ErrorView({required this.colors, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.alertTriangle, size: 40, color: colors.amber),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: colors.ink60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
