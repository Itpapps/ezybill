import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/complaint_provider.dart';
import '../../../application/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/string_extensions.dart';
import '../../../data/models/complaint/complaint_category.dart';
import '../../../data/models/complaint/complaint_model.dart';
import '../../../data/models/complaint/complaint_subcategory.dart';
import '../../../l10n/app_localizations.dart';
import '../../router/route_names.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Status → Color mapping (5-color scheme from Android spec)
// ─────────────────────────────────────────────────────────────────────────────

Color _statusColor(String status) {
  switch (status.toLowerCase().trim()) {
    case 'assigned':
    case 'resolved':
      return const Color(0xFF08C889);
    case 'inprocess':
    case 'in process':
      return const Color(0xFF00BEB7);
    case 'onhold':
    case 'on hold':
      return const Color(0xFFE67E22);
    case 'closed':
      return const Color(0xFFE74C3C);
    default:
      return const Color(0xFF0875C8);
  }
}

Color _statusBgColor(String status) {
  return _statusColor(status).withOpacity(0.12);
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ComplaintScreen extends ConsumerStatefulWidget {
  final String? custId;
  final String? custName;

  const ComplaintScreen({
    super.key,
    this.custId,
    this.custName,
  });

  @override
  ConsumerState<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends ConsumerState<ComplaintScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(appSessionProvider);
      if (session == null || !session.canAccessComplaints) return;

      final notifier = ref.read(complaintProvider.notifier);
      notifier.loadComplaints(
        loginUsersType: session.userType,
      );
      notifier.loadCategories();

      // Employee list: only load when patch_information gate allows it
      if (isPatchGated(session.patchInformation)) {
        notifier.loadEmployees(session.dealerId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final session = ref.watch(appSessionProvider);
    final colors = Theme.of(context).extension<AppColors>()!;
    final cState = ref.watch(complaintProvider);

    // Access gate: access_for_complaints == 1
    if (session == null || !session.canAccessComplaints) {
      return Scaffold(
        backgroundColor: colors.bg,
        appBar: AppBar(
          title: Text(l.complaints,
              style: const TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w700)),
          backgroundColor: colors.card,
          foregroundColor: colors.ink,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.shieldOff, size: 48, color: colors.ink40),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.ink),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to view complaints.',
                style: TextStyle(
                    fontFamily: 'DM Sans', fontSize: 13, color: colors.ink60),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(
          l.complaints,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: colors.card,
        foregroundColor: colors.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.red,
          unselectedLabelColor: colors.ink40,
          labelStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          indicatorColor: colors.red,
          indicatorWeight: 3,
          tabs: [
            Tab(text: '${l.openComplaints} (${cState.openComplaints.length})'),
            Tab(text: l.createNew),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OpenComplaintsTab(
            complaints: cState.openComplaints,
            isLoading: cState.isLoading,
            errorMessage: cState.errorMessage,
            employees: cState.employees,
            isTeamLead: session.isTeamLead,
            colors: colors,
          ),
          _CreateComplaintTab(
            custId: widget.custId,
            custName: widget.custName,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Open Complaints Tab
// ─────────────────────────────────────────────────────────────────────────────

class _OpenComplaintsTab extends ConsumerStatefulWidget {
  final List<ComplaintModel> complaints;
  final bool isLoading;
  final String? errorMessage;
  final List<Map<String, dynamic>> employees;
  final bool isTeamLead;
  final AppColors colors;

  const _OpenComplaintsTab({
    required this.complaints,
    required this.isLoading,
    this.errorMessage,
    required this.employees,
    required this.isTeamLead,
    required this.colors,
  });

  @override
  ConsumerState<_OpenComplaintsTab> createState() => _OpenComplaintsTabState();
}

class _OpenComplaintsTabState extends ConsumerState<_OpenComplaintsTab> {
  int? _selectedEmployeeFilter;

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;

    if (widget.isLoading) {
      return Center(child: CircularProgressIndicator(color: c.red));
    }

    if (widget.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.alertCircle, size: 48, color: c.red),
              const SizedBox(height: 16),
              Text(
                widget.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  color: c.ink60,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  final session = ref.read(appSessionProvider);
                  if (session != null) {
                    ref.read(complaintProvider.notifier).loadComplaints(
                          loginUsersType: session.userType,
                        );
                  }
                },
                icon: Icon(LucideIcons.refreshCw, size: 16, color: c.red),
                label: Text(AppLocalizations.of(context)!.retry,
                    style: TextStyle(
                        fontFamily: 'DM Sans', color: c.red, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    // TEAMLEAD: filter complaints by service employee
    List<ComplaintModel> filtered = widget.complaints;
    if (widget.isTeamLead && _selectedEmployeeFilter != null) {
      filtered = widget.complaints
          .where((c) =>
              c.assignedTo ==
              _selectedEmployeeFilter.toString())
          .toList();
    }

    return Column(
      children: [
        // TEAMLEAD: show service employee filter at top of open complaints list
        if (widget.isTeamLead && widget.employees.isNotEmpty)
          Container(
            color: c.card,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: DropdownButtonFormField<int?>(
              value: _selectedEmployeeFilter,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Filter by Service Employee',
                labelStyle: TextStyle(fontFamily: 'DM Sans', color: c.ink40),
                prefixIcon: Icon(LucideIcons.filter, size: 18, color: c.ink40),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.ink10),
                ),
                filled: true,
                fillColor: c.bg,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(
                  fontFamily: 'DM Sans', fontSize: 14, color: c.ink),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Employees',
                      style: TextStyle(
                          fontFamily: 'DM Sans', fontSize: 14, color: c.ink)),
                ),
                ...widget.employees.map((emp) {
                  final id = int.tryParse(
                          emp['employeeId']?.toString() ??
                          emp['lco_employee_id']?.toString() ?? '') ??
                      0;
                  final name = emp['employeeName']?.toString() ??
                      emp['lco_employee_name']?.toString() ??
                      emp['firstName']?.toString() ??
                      'Employee $id';
                  return DropdownMenuItem<int?>(
                    value: id,
                    child: Text(name,
                        style: TextStyle(
                            fontFamily: 'DM Sans', fontSize: 14, color: c.ink)),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() => _selectedEmployeeFilter = val);
              },
            ),
          ),

        // Complaint list
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState(c)
              : RefreshIndicator(
                  onRefresh: () async {
                    final session = ref.read(appSessionProvider);
                    if (session != null) {
                      await ref
                          .read(complaintProvider.notifier)
                          .loadComplaints(loginUsersType: session.userType);
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _ComplaintCard(
                        complaint: filtered[index],
                        colors: c,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppColors c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: c.amberSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(LucideIcons.alertTriangle, size: 36, color: c.amber),
          ),
          const SizedBox(height: 16),
          Text(
            'No Open Complaints',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: c.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No open complaints found',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: c.ink60,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Complaint Card
// ─────────────────────────────────────────────────────────────────────────────

class _ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final AppColors colors;

  const _ComplaintCard({
    required this.complaint,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final statusClr = _statusColor(complaint.status);
    final statusBg = _statusBgColor(complaint.status);
    // Strip BOTH Android and Flutter suffixes on display
    final strippedDescription = complaint.complaint.stripComplaintSuffix();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.ink10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: ticket + status chip
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(LucideIcons.ticket, size: 18, color: statusClr),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${complaint.ticketNumber}',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: c.ink,
                        ),
                      ),
                      Text(
                        complaint.customerName,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: c.ink60,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    complaint.status.isNotEmpty ? complaint.status : 'N/A',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusClr,
                    ),
                  ),
                ),
              ],
            ),

            // Row 2: category + date
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 52),
                if (complaint.category.isNotEmpty)
                  Expanded(
                    child: Text(
                      complaint.categoryName ?? complaint.category,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: c.ink40,
                      ),
                    ),
                  ),
                Text(
                  complaint.createdDate,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: c.ink40,
                  ),
                ),
              ],
            ),

            // Row 3: stripped description
            if (strippedDescription.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: Text(
                  strippedDescription.truncate(100),
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: c.ink60,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            // Row 4: Update button
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 32,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(
                      RouteNames.updateComplaint,
                      extra: {
                        'complaint': complaint,
                      },
                    );
                  },
                  icon: Icon(LucideIcons.edit3, size: 14, color: c.red),
                  label: Text(
                    AppLocalizations.of(context)!.update,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: c.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: c.red.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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

// ─────────────────────────────────────────────────────────────────────────────
// Create Complaint Tab
// ─────────────────────────────────────────────────────────────────────────────

class _CreateComplaintTab extends ConsumerStatefulWidget {
  final String? custId;
  final String? custName;
  final AppColors colors;

  const _CreateComplaintTab({
    this.custId,
    this.custName,
    required this.colors,
  });

  @override
  ConsumerState<_CreateComplaintTab> createState() =>
      _CreateComplaintTabState();
}

class _CreateComplaintTabState extends ConsumerState<_CreateComplaintTab> {
  late TextEditingController _customerIdController;
  late TextEditingController _descriptionController;
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  int? _selectedEmployeeId;

  @override
  void initState() {
    super.initState();
    _customerIdController =
        TextEditingController(text: widget.custId ?? '');
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final customerId = _customerIdController.text.trim();
    final description = _descriptionController.text.trim();
    final c = widget.colors;

    if (customerId.isEmpty) {
      _showSnack('Please enter a Customer ID', c.red);
      return;
    }
    if (description.isEmpty) {
      _showSnack('Please enter a description', c.red);
      return;
    }

    // Category selection logic from Android spec:
    // If subcategory is selected, send its ID as the `category` param.
    // Otherwise send the parent category ID.
    final category = _selectedSubcategoryId ?? _selectedCategoryId;
    if (category == null) {
      _showSnack('Please select a category', c.red);
      return;
    }

    final ticketNumber =
        await ref.read(complaintProvider.notifier).createComplaint(
              customerId: customerId,
              complaint: description,
              category: category,
              assignedTo: _selectedEmployeeId,
              error: '0',
            );

    if (!mounted) return;

    if (ticketNumber != null) {
      _showSuccessDialog(ticketNumber);
      _descriptionController.clear();
      setState(() {
        _selectedCategoryId = null;
        _selectedSubcategoryId = null;
        _selectedEmployeeId = null;
      });
      // Reload complaints
      final session = ref.read(appSessionProvider);
      if (session != null) {
        ref
            .read(complaintProvider.notifier)
            .loadComplaints(loginUsersType: session.userType);
      }
    } else {
      final error =
          ref.read(complaintProvider).errorMessage ?? 'Failed to create';
      _showSnack(error, c.red);
    }
  }

  void _showSnack(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(fontFamily: 'DM Sans')),
        backgroundColor: bgColor,
      ),
    );
  }

  void _showSuccessDialog(String ticketNumber) {
    final c = widget.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(LucideIcons.checkCircle, color: c.green, size: 24),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.complaintCreated,
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your complaint has been submitted successfully.',
                style: TextStyle(
                    fontFamily: 'DM Sans', fontSize: 14, color: c.ink60)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.greenSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.ticketNumber,
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: c.ink40)),
                  const SizedBox(height: 4),
                  Text(
                    ticketNumber,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: c.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.ok,
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                    color: c.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cState = ref.watch(complaintProvider);
    final session = ref.watch(appSessionProvider);
    final c = widget.colors;
    final isPreFilled = widget.custId != null && widget.custId!.isNotEmpty;

    // patch_information gating for subcategory and employee fields
    final patchInfo = session?.patchInformation ?? '';
    final showSubcategory = isPatchGated(patchInfo);
    final showEmployeeField = isEmployeePatchGated(patchInfo);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer name display (if pre-filled)
          if (isPreFilled && widget.custName != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.blueSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.user, size: 18, color: c.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.custName!,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Customer ID field
          TextField(
            controller: _customerIdController,
            readOnly: isPreFilled,
            style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: c.ink),
            decoration: InputDecoration(
              labelText: 'Customer ID',
              labelStyle: TextStyle(fontFamily: 'DM Sans', color: c.ink40),
              prefixIcon: Icon(LucideIcons.user, size: 18, color: c.ink40),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isPreFilled ? c.ink05 : c.bg,
            ),
          ),
          const SizedBox(height: 16),

          // Category dropdown — loaded via complaintCategoriesRest
          DropdownButtonFormField<int>(
            value: _selectedCategoryId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l.category,
              labelStyle: TextStyle(fontFamily: 'DM Sans', color: c.ink40),
              prefixIcon:
                  Icon(LucideIcons.layers, size: 18, color: c.ink40),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: c.bg,
            ),
            style: TextStyle(
                fontFamily: 'DM Sans', fontSize: 14, color: c.ink),
            items: cState.categories.map((cat) {
              return DropdownMenuItem<int>(
                value: cat.categoryId,
                child: Text(cat.categoryName,
                    style: TextStyle(
                        fontFamily: 'DM Sans', fontSize: 14, color: c.ink)),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedCategoryId = val;
                _selectedSubcategoryId = null;
              });
              // On category select, load subcategories (only if patch gated)
              if (val != null && showSubcategory) {
                ref
                    .read(complaintProvider.notifier)
                    .loadSubcategories(val.toString());
              }
            },
          ),
          const SizedBox(height: 16),

          // Subcategory dropdown — only visible when patch_information
          // matches "1.4.13.2", "1.4.13.3", or "1.4.13.4"
          if (showSubcategory &&
              _selectedCategoryId != null &&
              cState.subcategories.isNotEmpty) ...[
            DropdownButtonFormField<int>(
              value: _selectedSubcategoryId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l.subcategory,
                labelStyle:
                    TextStyle(fontFamily: 'DM Sans', color: c.ink40),
                prefixIcon:
                    Icon(LucideIcons.list, size: 18, color: c.ink40),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: c.bg,
              ),
              style: TextStyle(
                  fontFamily: 'DM Sans', fontSize: 14, color: c.ink),
              items: cState.subcategories.map((sub) {
                return DropdownMenuItem<int>(
                  value: sub.subCategoryId,
                  child: Text(sub.subCategoryName,
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          color: c.ink)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedSubcategoryId = val);
              },
            ),
            const SizedBox(height: 16),
          ],

          // Description
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            style:
                TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: c.ink),
            decoration: InputDecoration(
              labelText: '${l.description} *',
              labelStyle: TextStyle(fontFamily: 'DM Sans', color: c.ink40),
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child:
                    Icon(LucideIcons.fileText, size: 18, color: c.ink40),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: c.bg,
            ),
          ),
          const SizedBox(height: 16),

          // Employee assignment dropdown — patch_information "1.4.13.3"
          // gates visibility of employee field.
          if (showEmployeeField && cState.employees.isNotEmpty) ...[
            DropdownButtonFormField<int>(
              value: _selectedEmployeeId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Assign to Employee',
                labelStyle:
                    TextStyle(fontFamily: 'DM Sans', color: c.ink40),
                prefixIcon:
                    Icon(LucideIcons.userPlus, size: 18, color: c.ink40),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: c.bg,
              ),
              style: TextStyle(
                  fontFamily: 'DM Sans', fontSize: 14, color: c.ink),
              items: cState.employees.map((emp) {
                final id = int.tryParse(
                        emp['employeeId']?.toString() ??
                        emp['lco_employee_id']?.toString() ?? '') ??
                    0;
                final name = emp['employeeName']?.toString() ??
                    emp['lco_employee_name']?.toString() ??
                    emp['firstName']?.toString() ??
                    'Employee $id';
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(name,
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          color: c.ink)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedEmployeeId = val);
              },
            ),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 8),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: cState.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.red,
                foregroundColor: c.card,
                disabledBackgroundColor: c.ink20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: cState.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: c.card),
                    )
                  : Text(
                      '${l.submit} ${l.complaints}',
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
