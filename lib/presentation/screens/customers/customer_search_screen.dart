import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/customer_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/customer/customer_model.dart';
import '../../common/widgets/app_search_bar.dart';
import '../../common/widgets/subscriber_card.dart';
import '../../common/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../../router/route_names.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Origin enum — determines where a customer tap navigates
// ─────────────────────────────────────────────────────────────────────────────

enum CustomerSearchOrigin {
  customerMgmt,
  payments,
  complaintMgmt,
  packageMgmt,
  stbOps,
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class CustomerSearchScreen extends ConsumerStatefulWidget {
  const CustomerSearchScreen({
    super.key,
    this.origin = CustomerSearchOrigin.customerMgmt,
  });

  final CustomerSearchOrigin origin;

  @override
  ConsumerState<CustomerSearchScreen> createState() =>
      _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends ConsumerState<CustomerSearchScreen> {
  final _searchController = TextEditingController();
  CustomerSearchField _selectedField = CustomerSearchField.customerName;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Search ──────────────────────────────────────────────────────────────

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    ref.read(customerSearchProvider.notifier).searchCustomers(
          query,
          _selectedField,
        );
  }

  // ── Navigation on card tap ──────────────────────────────────────────────

  void _onCustomerTap(CustomerModel customer) {
    final extra = {
      'customerId': customer.customerId,
      'customerName': customer.customerName,
      'mobileNumber': customer.mobileNumber ?? '',
    };

    switch (widget.origin) {
      case CustomerSearchOrigin.customerMgmt:
        context.push(
          RouteNames.customerProfile.replaceFirst(':id', customer.customerId),
          extra: extra,
        );
      case CustomerSearchOrigin.payments:
        context.push(RouteNames.makePayment, extra: extra);
      case CustomerSearchOrigin.complaintMgmt:
        context.push(RouteNames.complaints, extra: extra);
      case CustomerSearchOrigin.packageMgmt:
        context.push(RouteNames.packageOperations, extra: extra);
      case CustomerSearchOrigin.stbOps:
        context.push(RouteNames.stbOperations, extra: extra);
    }
  }

  // ── Large count warning dialog ──────────────────────────────────────────

  void _showLargeCountDialog(int count) {
    final c = Theme.of(context).extension<AppColors>()!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
        title: Text(
          'Too Many Results',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: c.ink,
          ),
        ),
        content: Text(
          'Your search returned $count customers. '
          'Please refine your search criteria to narrow the results below 10,000.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: c.ink60,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: c.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final searchState = ref.watch(customerSearchProvider);

    // Show large-count dialog reactively when count exceeds 10,000
    ref.listen<CustomerSearchState>(customerSearchProvider, (prev, next) {
      if (!next.isLoading &&
          next.totalCount >= 10000 &&
          (prev?.totalCount ?? 0) < 10000) {
        _showLargeCountDialog(next.totalCount);
      }
    });

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.customerSearch,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.ink,
          ),
        ),
        backgroundColor: c.card,
        foregroundColor: c.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search header ──────────────────────────────────────
            _SearchHeader(
              controller: _searchController,
              selectedField: _selectedField,
              colors: c,
              onFieldChanged: (field) =>
                  setState(() => _selectedField = field),
              onSearch: _performSearch,
            ),

            // ── Error bar ──────────────────────────────────────────
            if (searchState.errorMessage != null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: c.redSoft,
                child: Text(
                  searchState.errorMessage!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: c.red,
                  ),
                ),
              ),

            // ── Results count strip ────────────────────────────────
            if (searchState.totalCount > 0 && !searchState.isLoading)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: c.card,
                child: Text(
                  '${searchState.totalCount} result(s) '
                  '\u2022 Page ${searchState.currentPage + 1} of ${searchState.totalPages}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: c.ink40,
                  ),
                ),
              ),

            // ── Body ───────────────────────────────────────────────
            Expanded(
              child: searchState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : searchState.customers.isEmpty
                      ? _EmptyState(colors: c)
                      : _ResultsList(
                          customers: searchState.customers,
                          colors: c,
                          onTap: _onCustomerTap,
                        ),
            ),

            // ── Pagination bar ─────────────────────────────────────
            if (searchState.totalPages > 1 && !searchState.isLoading)
              _PaginationBar(
                currentPage: searchState.currentPage,
                totalPages: searchState.totalPages,
                colors: c,
                onFirst: () =>
                    ref.read(customerSearchProvider.notifier).firstPage(),
                onPrev: () =>
                    ref.read(customerSearchProvider.notifier).prevPage(),
                onNext: () =>
                    ref.read(customerSearchProvider.notifier).nextPage(),
                onLast: () =>
                    ref.read(customerSearchProvider.notifier).lastPage(),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Header (search bar + field chips)
// ─────────────────────────────────────────────────────────────────────────────

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.selectedField,
    required this.colors,
    required this.onFieldChanged,
    required this.onSearch,
  });

  final TextEditingController controller;
  final CustomerSearchField selectedField;
  final AppColors colors;
  final ValueChanged<CustomerSearchField> onFieldChanged;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.card,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search bar
          AppSearchBar(
            controller: controller,
            placeholder: _placeholderFor(selectedField),
            onSubmitted: (_) => onSearch(),
          ),
          const SizedBox(height: 10),

          // Search field chips
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: CustomerSearchField.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final field = CustomerSearchField.values[index];
                final isActive = field == selectedField;
                return GestureDetector(
                  onTap: () => onFieldChanged(field),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    height: 34,
                    decoration: BoxDecoration(
                      color: isActive ? colors.red : colors.ink05,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      field.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? colors.card : colors.ink40,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _placeholderFor(CustomerSearchField field) {
    switch (field) {
      case CustomerSearchField.customerNumber:
        return 'Enter customer number...';
      case CustomerSearchField.customerName:
        return 'Enter customer name...';
      case CustomerSearchField.mobileNumber:
        return 'Enter mobile number...';
      case CustomerSearchField.boxNumber:
        return 'Enter STB / serial number...';
      case CustomerSearchField.lcoCustomerId:
        return 'Enter LCO customer ID...';
      case CustomerSearchField.cafNumber:
        return 'Enter CAF number...';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Results List
// ─────────────────────────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.customers,
    required this.colors,
    required this.onTap,
  });

  final List<CustomerModel> customers;
  final AppColors colors;
  final ValueChanged<CustomerModel> onTap;

  String _statusLabel(CustomerModel c) {
    final s = c.status;
    if (s == '1' || s.toLowerCase() == 'active') return 'active';
    if (s.toLowerCase() == 'fresh' || s.toLowerCase() == 'new') return 'fresh';
    return 'deactivated';
  }

  String _dueText(CustomerModel c) {
    if (c.pendingAmount <= 0) return '';
    return '\u20B9${c.pendingAmount.toStringAsFixed(0)} due';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: customers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final customer = customers[index];
        final status = _statusLabel(customer);
        final due = _dueText(customer);

        return SubscriberCard(
          name: customer.customerName.trim().isEmpty
              ? 'Unknown'
              : customer.customerName.trim(),
          mobile: customer.mobileNumber ?? '',
          stbCode: customer.serialNumber ?? customer.cafNumber ?? '',
          status: status,
          dueText: due.isNotEmpty ? due : null,
          onTap: () => onTap(customer),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: colors.redSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(LucideIcons.search, size: 32, color: colors.red),
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context)!.noCustomersFound,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Search by name, mobile, STB number, or customer ID',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.ink40,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pagination Bar
// ─────────────────────────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.colors,
    required this.onFirst,
    required this.onPrev,
    required this.onNext,
    required this.onLast,
  });

  final int currentPage;
  final int totalPages;
  final AppColors colors;
  final VoidCallback onFirst;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onLast;

  @override
  Widget build(BuildContext context) {
    final hasPrev = currentPage > 0;
    final hasNext = currentPage < totalPages - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(top: BorderSide(color: colors.ink10)),
        boxShadow: [
          BoxShadow(
            color: colors.ink.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PaginationButton(
            label: 'First',
            icon: LucideIcons.chevronsLeft,
            enabled: hasPrev,
            colors: colors,
            onTap: onFirst,
          ),
          const SizedBox(width: 6),
          _PaginationButton(
            label: 'Prev',
            icon: LucideIcons.chevronLeft,
            enabled: hasPrev,
            colors: colors,
            onTap: onPrev,
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: colors.ink05,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Page ${currentPage + 1} of $totalPages',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _PaginationButton(
            label: 'Next',
            icon: LucideIcons.chevronRight,
            enabled: hasNext,
            colors: colors,
            onTap: onNext,
            iconRight: true,
          ),
          const SizedBox(width: 6),
          _PaginationButton(
            label: 'Last',
            icon: LucideIcons.chevronsRight,
            enabled: hasNext,
            colors: colors,
            onTap: onLast,
            iconRight: true,
          ),
        ],
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.colors,
    required this.onTap,
    this.iconRight = false,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final AppColors colors;
  final VoidCallback onTap;
  final bool iconRight;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? colors.red : colors.ink20;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: enabled ? colors.redSoft : colors.ink05,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? colors.red.withValues(alpha: 0.2) : colors.ink10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!iconRight) Icon(icon, size: 14, color: color),
            if (!iconRight) const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (iconRight) const SizedBox(width: 4),
            if (iconRight) Icon(icon, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
