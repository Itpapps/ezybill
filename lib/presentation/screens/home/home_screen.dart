import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/auth_provider.dart';
import '../../../application/providers/stb_provider.dart';
import '../../../data/models/customer/customer_model.dart';
import '../../../application/providers/dashboard_customer_list_provider.dart';
import '../../../application/providers/dashboard_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../common/widgets/alphabet_sidebar.dart';
import '../../common/widgets/app_toast.dart';
import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/pill_tab_bar.dart';
import '../../common/widgets/section_label.dart';
import '../../common/widgets/subscriber_card.dart';
import '../../common/widgets/language_selector.dart';
import '../../router/route_names.dart';
import 'widgets/alert_chips.dart';
import 'widgets/app_header.dart';
import 'widgets/overview_donut.dart';
import 'widgets/overview_legend.dart';
import 'widgets/wallet_history_panel.dart';
import '../../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  String _searchQuery = '';
  String? _activeLetter;
  bool _walletHistoryOpen = false;
  bool _overviewExpanded = true;

  /// Pill tab index: 0=Active, 1=Inactive, 2=Fresh, 3=Assigned
  int _selectedTabIndex = 0;

  /// Sort mode: 0=Name, 1=Due Date, 2=Area
  int _sortMode = 0;

  List<String> _sortLabels(AppLocalizations l) => [l.name, l.dueDate, l.area];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load dashboard stats (counts from dashBoardDetailsRest).
      ref.read(dashboardProvider.notifier).loadDashboard();
      // Load first 20 active customers for the subscriber list.
      ref
          .read(dashboardCustomerListProvider.notifier)
          .selectTab(CustomerFilterTab.active);
    });
  }

  bool _loadingStb = false;

  /// Fetch STB details for a customer, then navigate to target screen.
  Future<void> _navigateWithStb(
      String customerId, String customerName, String targetRoute) async {
    if (_loadingStb) return;
    setState(() => _loadingStb = true);

    try {
      final stbDs = ref.read(stbRemoteDatasourceProvider);
      final token = ref.read(appSessionProvider)?.token ?? '';
      final rawResult = await stbDs.getCustomerBoxDetails(
        authtoken: token,
        customerId: customerId,
      );

      if (!mounted) return;

      final boxList = rawResult['customerBoxList'];
      if (boxList == null || boxList is! List || boxList.isEmpty) {
        setState(() => _loadingStb = false);
        AppToast.show(context,
            message: 'No STB found for this customer',
            variant: ToastVariant.info);
        return;
      }

      final boxes = boxList.cast<Map<String, dynamic>>();
      _loadingStb = false;

      // Defer navigation to next frame to avoid navigator lock conflict
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (boxes.length == 1) {
          final stb = boxes.first;
          context.push(targetRoute, extra: {
            'customerId': customerId,
            'customerName': customerName,
            'serialNumber': stb['serial_number']?.toString() ?? '',
            'vcNumber': stb['vc_number']?.toString() ?? '',
            'stockId': stb['stock_id']?.toString() ?? '',
            'deviceId': stb['device_id']?.toString() ?? '',
            'backendSetupId': stb['backend_setup_id']?.toString() ?? '',
          });
        } else {
          _showStbPicker(customerId, customerName, boxes, targetRoute);
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loadingStb = false);
        AppToast.show(context,
            message: 'Error loading STB: $e', variant: ToastVariant.info);
      }
    }
  }

  void _showStbPicker(String customerId, String customerName,
      List<Map<String, dynamic>> boxes, String targetRoute) {
    final c = Theme.of(context).extension<AppColors>()!;
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select STB',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 17, fontWeight: FontWeight.w800, color: c.ink)),
            const SizedBox(height: 12),
            ...boxes.map((stb) {
              final serial = stb['serial_number']?.toString() ?? '';
              final vc = stb['vc_number']?.toString() ?? '';
              final casName = stb['cas_display_name']?.toString() ?? '';
              return ListTile(
                leading: Icon(LucideIcons.tv, color: c.ink60),
                title: Text(serial,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('VC: $vc • $casName',
                    style: TextStyle(fontSize: 11, color: c.ink40)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push(targetRoute, extra: {
                    'customerId': customerId,
                    'customerName': customerName,
                    'serialNumber': serial,
                    'vcNumber': vc,
                    'stockId': stb['stock_id']?.toString() ?? '',
                    'deviceId': stb['device_id']?.toString() ?? '',
                    'backendSetupId': stb['backend_setup_id']?.toString() ?? '',
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Back press → logout confirmation ─────────────────────────────────────

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final c = Theme.of(ctx).extension<AppColors>()!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.cardBR,
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: c.ink,
            ),
          ),
          content: Text(
            AppLocalizations.of(ctx)!.logoutConfirm,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: c.ink60,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.ink40,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Logout',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: c.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      ref.read(authProvider.notifier).logout();
    }
    return false; // never pop — we handle logout ourselves
  }

  // ── Tab helpers ──────────────────────────────────────────────────────────

  CustomerFilterTab _tabFromIndex(int index) {
    switch (index) {
      case 0:
        return CustomerFilterTab.active;
      case 1:
        return CustomerFilterTab.inactive;
      case 2:
        return CustomerFilterTab.fresh;
      case 3:
        return CustomerFilterTab.assigned;
      default:
        return CustomerFilterTab.active;
    }
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
      _searchQuery = '';
      _activeLetter = null;
      _searchController.clear();
      _overviewExpanded = false; // Collapse overview when tab tapped
    });
    if (index < 3) {
      ref
          .read(dashboardCustomerListProvider.notifier)
          .selectTab(_tabFromIndex(index));
    }
  }

  // ── Filter ───────────────────────────────────────────────────────────────

  List<CustomerModel> _filterCustomers(
    List<CustomerModel> customers,
  ) {
    var filtered = customers;

    if (_activeLetter != null && _activeLetter != '#') {
      filtered = filtered.where((c) {
        final name = c.customerName.trim().toUpperCase();
        return name.startsWith(_activeLetter!);
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((c) {
        final name = c.customerName.toLowerCase();
        final stb = (c.serialNumber ?? '').toLowerCase();
        final vc = (c.vcNumber ?? '').toLowerCase();
        final mobile = (c.mobileNumber ?? '').toLowerCase();
        final acct = (c.accountNumber ?? '').toLowerCase();
        return name.contains(q) ||
            stb.contains(q) ||
            vc.contains(q) ||
            mobile.contains(q) ||
            acct.contains(q);
      }).toList();
    }

    return filtered;
  }

  Set<String> _lettersWithItems(List<CustomerModel> customers) {
    final letters = <String>{};
    for (final c in customers) {
      final name = c.customerName.trim();
      if (name.isNotEmpty) {
        letters.add(name[0].toUpperCase());
      }
    }
    return letters;
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final session = ref.watch(appSessionProvider);
    final dashboard = ref.watch(dashboardProvider);
    final listState = ref.watch(dashboardCustomerListProvider);
    final c = Theme.of(context).extension<AppColors>()!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onWillPop();
      },
      child: Scaffold(
        backgroundColor: c.bg,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Header (pinned) ──────────────────────────────────
            SliverToBoxAdapter(
              child: AppHeader(
                session: session ?? AppSession.empty(),
                walletBalance: _formatAmount(dashboard.walletBalance),
                lastRechargeText: 'Last: ₹5,000 on 22 Mar 2026',  // TODO: fetch from wallet history API
                showWallet: session?.showWallet ?? false,
                onThemeToggle: () {
                  // Theme toggle — no provider yet
                },
                onLanguage: () => showLanguageSelector(context, ref),
                onNotifications: () {},
                onWalletTopUp: () {
                  context.push(RouteNames.lcoTopup);
                },
                onWalletHistory: () {
                  context.push(RouteNames.lcoWalletHistory);
                },
                onRefresh: () =>
                    ref.read(dashboardProvider.notifier).loadDashboard(),
              ),
            ),

            // ── Divider ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Divider(height: 1, color: c.ink05),
            ),

            // ── Loading state ────────────────────────────────────
            if (dashboard.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (dashboard.errorMessage != null)
              SliverToBoxAdapter(
                child: _buildErrorState(dashboard.errorMessage!),
              )
            else ...[
              // ── OVERVIEW label + inline ticker when collapsed ────
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () => setState(() => _overviewExpanded = !_overviewExpanded),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      children: [
                        Text(
                          l.overview,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).extension<AppColors>()!.ink20,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _overviewExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                          size: 14,
                          color: Theme.of(context).extension<AppColors>()!.ink20,
                        ),
                        // Inline stats ticker when collapsed
                        if (!_overviewExpanded) ...[
                          const SizedBox(width: 8),
                          Expanded(child: _buildInlineTicker(dashboard, listState)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // ── Overview: Donut + Legend ────────────────────────
              if (_overviewExpanded) SliverToBoxAdapter(
                child: Builder(builder: (context) {
                  // Use customer list count as fallback when dashboard returns 0
                  final activeCount = dashboard.totalActiveCustomers > 0
                      ? dashboard.totalActiveCustomers
                      : listState.totalCount;
                  final inactiveCount = dashboard.totalDeactiveCustomers;
                  final freshCount = dashboard.freshCount;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        OverviewDonut(
                          active: activeCount,
                          inactive: inactiveCount,
                          fresh: freshCount,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OverviewLegend(
                            active: activeCount,
                            inactive: inactiveCount,
                            fresh: freshCount,
                            healthPercent: dashboard.healthPercent,
                            onTapActive: () => _selectTab(0),
                            onTapInactive: () => _selectTab(1),
                            onTapFresh: () => _selectTab(2),
                            onTapHealth: () {},
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              // ── Alert Chips ────────────────────────────────────
              if (_overviewExpanded) SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: AlertChips(
                    rechargedCount: dashboard.totalPaidCustomers,
                    expiring7dCount: dashboard.expiring7dCount,
                    walletRechargeCount: dashboard.walletHistory.length,
                    overdueCount: dashboard.totalUnPaidCustomers,
                    onWalletTap: () {
                      setState(
                          () => _walletHistoryOpen = !_walletHistoryOpen);
                      if (_walletHistoryOpen &&
                          dashboard.walletHistory.isEmpty) {
                        ref
                            .read(dashboardProvider.notifier)
                            .loadWalletHistory();
                      }
                    },
                  ),
                ),
              ),

              // ── Wallet History Panel ───────────────────────────
              if (_overviewExpanded) SliverToBoxAdapter(
                child: WalletHistoryPanel(
                  visible: _walletHistoryOpen,
                  isLoading: dashboard.walletHistoryLoading,
                  entries: dashboard.walletHistory,
                ),
              ),

              // ── Search Bar ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: AppSearchBar(
                    controller: _searchController,
                    placeholder: l.searchPlaceholder,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    onSubmitted: (_) {
                      // Trigger API search when user submits
                      final query = _searchController.text.trim();
                      if (query.isNotEmpty) {
                        ref
                            .read(dashboardCustomerListProvider.notifier)
                            .searchByQuery(query);
                      }
                    },
                  ),
                ),
              ),

              // ── Pill Tabs ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: PillTabBar(
                    tabs: [
                      PillTab(
                        label: l.active,
                        count: dashboard.totalActiveCustomers > 0
                            ? dashboard.totalActiveCustomers
                            : listState.totalCount,
                        activeBg: const Color(0xFFE6F9EE),
                        activeText: const Color(0xFF059669),
                      ),
                      PillTab(
                        label: l.inactive,
                        count: dashboard.totalDeactiveCustomers,
                        activeBg: const Color(0xFFFEE2E2),
                        activeText: const Color(0xFFDC2626),
                      ),
                      PillTab(
                        label: l.fresh,
                        count: dashboard.totalUnAssignedStbs,
                        activeBg: const Color(0xFFD1FAE5),
                        activeText: const Color(0xFF047857),
                      ),
                      PillTab(
                        label: l.assigned,
                        count: null,
                        activeBg: const Color(0xFFFEF3C7),
                        activeText: const Color(0xFFB45309),
                      ),
                    ],
                    selectedIndex: _selectedTabIndex,
                    onTabChanged: _selectTab,
                  ),
                ),
              ),

              // ── Sort + View toggle + result count ──────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: _buildSortBar(listState),
                ),
              ),

              // ── Subscriber List with Alpha Sidebar ─────────────
              SliverToBoxAdapter(
                child: _buildSubscriberSection(listState, dashboard),
              ),

              // ── Bottom spacer ──────────────────────────────────
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Inline Stats Ticker (same row as OVERVIEW label) ──────────────────

  Widget _buildInlineTicker(DashboardState dashboard, DashboardCustomerListState listState) {
    final c = Theme.of(context).extension<AppColors>()!;
    final activeCount = dashboard.totalActiveCustomers > 0
        ? dashboard.totalActiveCustomers
        : listState.totalCount;

    final ll = AppLocalizations.of(context)!;
    final items = <_TickerItem>[
      _TickerItem(ll.active, '$activeCount', c.greenDot),
      _TickerItem(ll.inactive, '${dashboard.totalDeactiveCustomers}', c.red),
      _TickerItem(ll.totalStbs, '${dashboard.totalAssignedStbs + dashboard.totalUnAssignedStbs}', c.blue),
      _TickerItem(ll.fresh, '${dashboard.totalUnAssignedStbs}', c.amber),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                '${item.label}:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: c.ink40,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                item.value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: item.color,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // ── Sort Bar ─────────────────────────────────────────────────────────────

  Widget _buildSortBar(DashboardCustomerListState listState) {
    final l = AppLocalizations.of(context)!;
    final c = Theme.of(context).extension<AppColors>()!;
    final count = listState.allCustomers.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sort button
        GestureDetector(
          onTap: () => setState(() => _sortMode = (_sortMode + 1) % 3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: c.ink05),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.arrowDownUp, size: 11, color: c.ink40),
                const SizedBox(width: 4),
                Text(
                  _sortLabels(l)[_sortMode],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: c.ink60,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),

        // View toggle (list mode)
        GestureDetector(
          onTap: () {
            // Toggle list/card — currently only list view
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: c.ink05),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.list, size: 11, color: c.ink40),
                const SizedBox(width: 4),
                Text(
                  l.list,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: c.ink60,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Count
        Text(
          l.showingCount(count),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: c.ink20,
          ),
        ),
      ],
    ),
    );
  }

  // ── Subscriber Section ───────────────────────────────────────────────────

  Widget _buildSubscriberSection(
    DashboardCustomerListState listState,
    DashboardState dashboard,
  ) {
    final c = Theme.of(context).extension<AppColors>()!;

    // Misc tab — no list
    if (_selectedTabIndex == 3) {
      return _buildPlaceholderState('Misc', c);
    }

    // Loading
    if (listState.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // Error
    if (listState.errorMessage != null) {
      return _buildErrorState(listState.errorMessage!);
    }

    // Tabs without list endpoint
    if (!listState.selectedTab.hasListEndpoint &&
        _selectedTabIndex != 0 &&
        _selectedTabIndex != 1) {
      return _buildPlaceholderState(
        listState.selectedTab.label,
        c,
        count: _getCountForTab(listState.selectedTab, dashboard),
      );
    }

    // Empty
    if (listState.allCustomers.isEmpty) {
      return _buildEmptyState(listState.selectedTab.label);
    }

    // Filtered list
    final allCustomers = listState.allCustomers;
    final filtered = _filterCustomers(allCustomers);
    final letters = _lettersWithItems(allCustomers);
    final isActive = listState.selectedTab == CustomerFilterTab.active;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main list
          Expanded(
            child: Column(
              children: [
                // Active letter chip
                if (_activeLetter != null && _activeLetter != '#')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Text(
                          '${filtered.length} of ${allCustomers.length}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: c.ink40,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _activeLetter = null),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: c.redSoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _activeLetter!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: c.red,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(LucideIcons.x,
                                    size: 8, color: c.red),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Subscriber cards
                ...filtered.map((customer) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildSubscriberCard(
                        customer,
                        isActive: isActive,
                      ),
                    )),

                // Loading more
                if (listState.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),

                // Load more button
                if (listState.hasMore && !listState.isLoadingMore)
                  GestureDetector(
                    onTap: () => ref
                        .read(dashboardCustomerListProvider.notifier)
                        .loadMore(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: c.card,
                        borderRadius: AppRadius.smBR,
                        border: Border.all(color: c.ink10),
                      ),
                      child: Center(
                        child: Text(
                          'Load More',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: c.red,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Alpha sidebar
          const SizedBox(width: 2),
          AlphabetSidebar(
            activeLetter: _activeLetter,
            lettersWithItems: letters,
            onLetterTap: (letter) {
              setState(() {
                _activeLetter =
                    _activeLetter == letter ? null : letter;
              });
            },
          ),
        ],
      ),
    );
  }

  // ── Subscriber Card Builder ──────────────────────────────────────────────

  Widget _buildSubscriberCard(
    CustomerModel customer, {
    required bool isActive,
  }) {
    final name = customer.customerName.trim().isNotEmpty
        ? customer.customerName.trim()
        : 'Unknown';
    final mobile = customer.mobileNumber ?? '';
    final stbCode = customer.serialNumber ?? '';
    final customerId = customer.customerId;
    final status = isActive ? 'active' : 'deactivated';

    // Determine due text
    String? dueText;
    final pendingNum = customer.pendingAmount;
    if (pendingNum > 0) {
      dueText = '\u20B9$pendingNum due';
    }

    // Check if this is a Fresh/Unassigned STB (no customer_id)
    final isFresh = customerId.isEmpty || customerId == 'null' || customerId == '0'
        || ref.read(dashboardCustomerListProvider).selectedTab == CustomerFilterTab.fresh;
    final vcNumber = customer.vcNumber ?? '';
    final serialNumber = customer.serialNumber ?? stbCode;

    // For fresh boxes, get CAS type from the raw data
    final casType = customer.baid ?? ''; // baid field stores cas from dashboard list

    return SubscriberCard(
      name: isFresh ? 'STB: $serialNumber' : name,
      mobile: isFresh ? 'VC: $vcNumber' : (mobile.isNotEmpty ? mobile : '--'),
      stbCode: isFresh ? 'CAS: $casType' : (stbCode.isNotEmpty ? stbCode : '--'),
      status: isFresh ? 'fresh' : status,
      dueText: isFresh ? 'Tap to assign' : dueText,
      onTap: () {
        if (isFresh) {
          // Navigate to new customer creation with STB pre-filled
          context.push(
            RouteNames.newCustomer,
            extra: {
              'serialNumber': serialNumber,
              'vcNumber': vcNumber,
              'stbCode': stbCode,
            },
          );
        } else if (customerId.isNotEmpty) {
          context.push(
            '/customer/$customerId',
            extra: {'customerId': customerId, 'customerName': name},
          );
        }
      },
      actions: isFresh
          ? SubscriberCardActions(
              onActivate: () {
                context.push(
                  RouteNames.newCustomer,
                  extra: {
                    'serialNumber': serialNumber,
                    'vcNumber': vcNumber,
                    'stbCode': stbCode,
                  },
                );
              },
            )
          : SubscriberCardActions(
        onRecharge: () {
          if (customerId.isNotEmpty) {
            context.push(
              RouteNames.makePayment,
              extra: {'customerId': customerId, 'customerName': name},
            );
          }
        },
        onRefresh: () {
          AppToast.show(context, message: 'Refresh signal sent to ${customer.cafNumber ?? customerId}', variant: ToastVariant.success);
        },
        onUpgrade: () {
          if (customerId.isNotEmpty) {
            _navigateWithStb(customerId, name, RouteNames.packageOperations);
          }
        },
        onDeactivate: () {
          if (customerId.isNotEmpty) {
            _navigateWithStb(customerId, name, RouteNames.stbOperations);
          }
        },
      ),
    );
  }

  // ── Helper Builders ──────────────────────────────────────────────────────

  Widget _buildErrorState(String error) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.redSoft,
          borderRadius: AppRadius.cardBR,
        ),
        child: Column(
          children: [
            Icon(LucideIcons.alertTriangle, size: 22, color: c.red),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: c.red,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () =>
                  ref.read(dashboardProvider.notifier).loadDashboard(),
              child: Text(
                AppLocalizations.of(context)!.tapToRetry,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String tabLabel) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: AppRadius.cardBR,
          border: Border.all(color: c.ink10),
        ),
        child: Center(
          child: Text(
            'No ${tabLabel.toLowerCase()} customers found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: c.ink40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderState(String tabLabel, AppColors c, {int count = 0}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: AppRadius.cardBR,
          border: Border.all(color: c.ink10),
        ),
        child: Column(
          children: [
            Icon(
              tabLabel == 'Misc' ? LucideIcons.box : LucideIcons.userPlus,
              size: 24,
              color: c.ink40,
            ),
            const SizedBox(height: 8),
            Text(
              count > 0
                  ? '$count ${tabLabel.toLowerCase()} items'
                  : '$tabLabel section',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.ink60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCountForTab(CustomerFilterTab tab, DashboardState dashboard) {
    switch (tab) {
      case CustomerFilterTab.active:
        return dashboard.totalActiveCustomers;
      case CustomerFilterTab.inactive:
        return dashboard.totalDeactiveCustomers;
      case CustomerFilterTab.fresh:
        return dashboard.totalUnAssignedStbs;
      case CustomerFilterTab.assigned:
        return dashboard.totalAssignedStbs;
    }
  }

  String _formatAmount(double amount) {
    if (amount == 0) return '0';
    final s = amount.toStringAsFixed(0);
    return s.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

class _TickerItem {
  final String label;
  final String value;
  final Color color;
  const _TickerItem(this.label, this.value, this.color);
}
