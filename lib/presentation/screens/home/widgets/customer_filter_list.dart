import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../application/providers/dashboard_customer_list_provider.dart';
import '../../../../application/providers/dashboard_provider.dart';
import '../../../../data/models/customer/customer_model.dart';
import '../../../router/route_names.dart';

class CustomerFilterList extends ConsumerStatefulWidget {
  const CustomerFilterList({super.key});

  @override
  ConsumerState<CustomerFilterList> createState() => _CustomerFilterListState();
}

class _CustomerFilterListState extends ConsumerState<CustomerFilterList> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _activeLetter;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(dashboardCustomerListProvider.notifier)
          .selectTab(CustomerFilterTab.active);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Filter customers locally by search query and letter
  List<CustomerModel> _filterCustomers(
      List<CustomerModel> customers) {
    var filtered = customers;

    if (_activeLetter != null) {
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

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(dashboardCustomerListProvider);
    final dashboard = ref.watch(dashboardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter tabs
        _buildFilterTabs(listState, dashboard),
        const SizedBox(height: 8),
        // Content
        _buildContent(listState),
      ],
    );
  }

  Widget _buildFilterTabs(
    DashboardCustomerListState listState,
    DashboardState dashboard,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: CustomerFilterTab.values.map((tab) {
          final isSelected = listState.selectedTab == tab;
          final count = _getCountForTab(tab, dashboard);
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _searchQuery = '';
                  _activeLetter = null;
                  _searchController.clear();
                });
                ref
                    .read(dashboardCustomerListProvider.notifier)
                    .selectTab(tab);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? AppColors.white : AppColors.textMuted,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.white.withValues(alpha: 0.25)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
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

  Widget _buildContent(DashboardCustomerListState listState) {
    if (listState.isLoading) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (listState.errorMessage != null) {
      return _buildErrorState(listState.errorMessage!);
    }

    if (!listState.selectedTab.hasListEndpoint) {
      return _buildNoListState(listState.selectedTab);
    }

    if (listState.allCustomers.isEmpty) {
      return _buildEmptyState(listState.selectedTab);
    }

    return _buildCustomerList(listState);
  }

  Widget _buildCustomerList(DashboardCustomerListState listState) {
    final allCustomers = listState.allCustomers;
    final filtered = _filterCustomers(allCustomers);

    return Column(
      children: [
        // Search bar
        _buildSearchBar(allCustomers.length, listState.selectedTab),
        const SizedBox(height: 6),

        // Main content: list + alphabet sidebar
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer list
            Expanded(
              child: Column(
                children: [
                  // Count + refresh header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          '${filtered.length} of ${allCustomers.length}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                        if (_activeLetter != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _activeLetter = null),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _activeLetter!,
                                    style: const TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(LucideIcons.x,
                                      size: 8, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        GestureDetector(
                          onTap: () => ref
                              .read(dashboardCustomerListProvider.notifier)
                              .refresh(),
                          child: const Icon(LucideIcons.refreshCw,
                              size: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),

                  // Cards
                  ...() {
                    debugPrint('=== RENDERING CUSTOMER CARDS ===');
                    debugPrint('  selected tab: ${listState.selectedTab}');
                    debugPrint('  isActive flag for ALL cards: ${listState.selectedTab == CustomerFilterTab.active}');
                    debugPrint('  total cards: ${filtered.length}');
                    for (final c in filtered) {
                      debugPrint('  CARD → id=${c.customerId} name="${c.customerName}" '
                          'model.status=${c.status} '
                          'card_isActive=${listState.selectedTab == CustomerFilterTab.active}');
                    }
                    return filtered.map((customer) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _CompactCustomerCard(
                            customer: customer,
                            isActive:
                                listState.selectedTab == CustomerFilterTab.active,
                          ),
                        ));
                  }(),

                  // Pager
                  if (listState.pageCount > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Row(
                        children: [
                          _pagerNav(
                            label: '‹',
                            enabled: listState.currentPage > 1,
                            onTap: () => ref
                                .read(dashboardCustomerListProvider.notifier)
                                .goToPage(listState.currentPage - 1),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final p in _visiblePages(
                                    listState.currentPage,
                                    listState.pageCount,
                                  )) ...[
                                    _pageChip(
                                      page: p,
                                      selected: p == listState.currentPage,
                                      onTap: () => ref
                                          .read(dashboardCustomerListProvider.notifier)
                                          .goToPage(p),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _pagerNav(
                            label: '›',
                            enabled: listState.currentPage < listState.pageCount,
                            onTap: () => ref
                                .read(dashboardCustomerListProvider.notifier)
                                .goToPage(listState.currentPage + 1),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Alphabet sidebar
            const SizedBox(width: 2),
            _AlphabetSidebar(
              activeLetter: _activeLetter,
              onLetterTap: (letter) {
                setState(() {
                  _activeLetter = _activeLetter == letter ? null : letter;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(int totalCount, CustomerFilterTab tab) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 12,
        ),
        decoration: InputDecoration(
          hintText: 'Search ${tab.label.toLowerCase()} customers...',
          hintStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 11,
            color: AppColors.textMuted,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 8, right: 4),
            child: Icon(LucideIcons.search, size: 14, color: AppColors.textMuted),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 28, minHeight: 28),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child:
                        Icon(LucideIcons.x, size: 14, color: AppColors.textMuted),
                  ),
                )
              : null,
          suffixIconConstraints:
              const BoxConstraints(minWidth: 28, minHeight: 28),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  static List<int> _visiblePages(int current, int pageCount) {
    const window = 9;
    if (pageCount <= window) {
      return List<int>.generate(pageCount, (i) => i + 1);
    }
    final half = window ~/ 2;
    var start = current - half;
    var end = current + half;
    if (start < 1) {
      start = 1;
      end = window;
    }
    if (end > pageCount) {
      end = pageCount;
      start = pageCount - window + 1;
    }
    return [for (var p = start; p <= end; p++) p];
  }

  static Widget _pageChip({
    required int page,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          '$page',
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ).copyWith(color: selected ? Colors.white : AppColors.textMuted),
        ),
      ),
    );
  }

  static Widget _pagerNav({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.white : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: enabled ? AppColors.textMuted : AppColors.border,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.alertTriangle,
              size: 20, color: AppColors.danger),
          const SizedBox(height: 6),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () =>
                ref.read(dashboardCustomerListProvider.notifier).refresh(),
            child: const Text(
              'Tap to retry',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoListState(CustomerFilterTab tab) {
    final dashboard = ref.read(dashboardProvider);
    final count = _getCountForTab(tab, dashboard);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            tab == CustomerFilterTab.fresh
                ? LucideIcons.indianRupee
                : LucideIcons.userPlus,
            size: 22,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 6),
          Text(
            count > 0
                ? '$count ${tab.label.toLowerCase()} customers'
                : 'No ${tab.label.toLowerCase()} customers',
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => context.push(RouteNames.subscribers),
              child: const Text(
                'Search to find them',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(CustomerFilterTab tab) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          'No ${tab.label.toLowerCase()} customers found',
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ─── Compact Customer Card ───────────────────────────────────

class _CompactCustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final bool isActive;

  const _CompactCustomerCard({
    required this.customer,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final name = customer.customerName.trim().isNotEmpty
        ? customer.customerName.trim()
        : 'Unknown';
    final mobile = customer.mobileNumber ?? '';
    final acct = customer.accountNumber ?? '';
    final customerId = customer.customerId;
    final pending = customer.pendingAmount.toStringAsFixed(2);
    final status = isActive ? 'Active' : 'Inactive';

    return GestureDetector(
      onTap: () {
        if (customerId.isNotEmpty) {
          context.push(
            '/customer/$customerId',
            extra: {'customerName': name},
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Left: customer info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.successBg
                              : AppColors.dangerBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // A/C + pending
                  Row(
                    children: [
                      if (acct.isNotEmpty) ...[
                        Text(
                          'A/C: $acct',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (acct.isNotEmpty && pending != '0.00')
                        const Text(' | ',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textMuted)),
                      if (pending != '0.00')
                        Text(
                          'Due: \u20B9$pending',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.danger,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Right: quick actions
            const SizedBox(width: 8),
            // Recharge button
            _MiniAction(
              icon: LucideIcons.indianRupee,
              color: AppColors.primary,
              bgColor: AppColors.primaryLight,
              onTap: () => context.push(
                RouteNames.makePayment,
                extra: {
                  'customerId': customerId,
                  'customerName': name,
                  'address': customer.billingAddress ?? customer.installationAddress ?? '',
                  'accountNumber': acct,
                },
              ),
            ),
            const SizedBox(width: 6),
            // Call button
            if (mobile.isNotEmpty && mobile != '0')
              _MiniAction(
                icon: LucideIcons.phone,
                color: AppColors.success,
                bgColor: AppColors.successBg,
                onTap: () async {
                  final uri = Uri(scheme: 'tel', path: mobile);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _MiniAction({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 13, color: color),
      ),
    );
  }
}

// ─── Alphabet Sidebar ────────────────────────────────────────

class _AlphabetSidebar extends StatelessWidget {
  final String? activeLetter;
  final ValueChanged<String> onLetterTap;

  const _AlphabetSidebar({
    required this.activeLetter,
    required this.onLetterTap,
  });

  static const _letters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
    'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
    'U', 'V', 'W', 'X', 'Y', 'Z', '#',
  ];

  @override
  Widget build(BuildContext context) {
    // MouseRegion wrapper prevents mouse_tracker assertion on desktop
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        width: 22,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _letters.map((letter) {
            final isActive = activeLetter == letter;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onLetterTap(letter),
              child: Container(
                width: 20,
                height: 18,
                alignment: Alignment.center,
                decoration: isActive
                    ? BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      )
                    : null,
                child: Text(
                  letter,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? AppColors.white : AppColors.textMuted,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
