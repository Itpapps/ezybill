import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/complaint_provider.dart';
import '../../../application/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/string_extensions.dart';
import '../../../data/models/complaint/complaint_model.dart';
import '../../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Status → Color mapping (shared with other complaint screens)
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

class UpdateComplaintScreen extends ConsumerStatefulWidget {
  final ComplaintModel complaint;

  const UpdateComplaintScreen({
    super.key,
    required this.complaint,
  });

  @override
  ConsumerState<UpdateComplaintScreen> createState() =>
      _UpdateComplaintScreenState();
}

class _UpdateComplaintScreenState
    extends ConsumerState<UpdateComplaintScreen> {
  final _commentController = TextEditingController();
  String? _selectedStatus;
  String? _selectedCloserTicketTypeId;
  String? _selectedCloserReasonId;
  int? _selectedEmployeeId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(complaintProvider.notifier);
      // Load status options from complaintTypesRest (ticket_closer_categories)
      notifier.loadCloserTypes();

      final session = ref.read(appSessionProvider);
      if (session != null) {
        // Always load employees — mandatory for TEAMLEAD, optional for others
        notifier.loadEmployees(session.dealerId);
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final session = ref.read(appSessionProvider);

    // Validate comment — mandatory per spec
    if (_commentController.text.trim().isEmpty) {
      _showSnack('Please enter a comment', colors.red);
      return;
    }

    // Validate status
    if (_selectedStatus == null) {
      _showSnack('Please select a status', colors.red);
      return;
    }

    // Validate employee for TEAMLEAD — MANDATORY per Android spec
    if (session != null && session.isTeamLead && _selectedEmployeeId == null) {
      _showSnack('Please select a service employee', colors.red);
      return;
    }

    setState(() => _isSubmitting = true);

    final success =
        await ref.read(complaintProvider.notifier).closeComplaint(
              complaintId: widget.complaint.complaintId,
              ticketNumber: widget.complaint.ticketNumber,
              comment: _commentController.text.trim(),
              status: _selectedStatus!,
              assignedEmployeeId: _selectedEmployeeId?.toString(),
              closerTicketTypeId: _selectedCloserTicketTypeId,
              closerReasonId: _selectedCloserReasonId,
            );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Complaint updated successfully',
              style: TextStyle(fontFamily: 'DM Sans')),
          backgroundColor: colors.green,
        ),
      );

      // Reload complaints and pop back
      if (session != null) {
        ref
            .read(complaintProvider.notifier)
            .loadComplaints(loginUsersType: session.userType);
      }
      Navigator.of(context).pop();
    } else {
      final error =
          ref.read(complaintProvider).errorMessage ?? 'Failed to update';
      _showSnack(error, colors.red);
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>()!;
    final cState = ref.watch(complaintProvider);
    final session = ref.watch(appSessionProvider);
    final complaint = widget.complaint;

    final statusClr = _statusColor(complaint.status);
    final statusBg = _statusBgColor(complaint.status);
    // Strip BOTH Android and Flutter suffixes on display
    final strippedDescription = complaint.complaint.stripComplaintSuffix();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(
          l.updateComplaint,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Complaint Info Card ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.ink10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer name
                  Row(
                    children: [
                      Icon(LucideIcons.user, size: 16, color: colors.ink40),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          complaint.customerName,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Ticket number
                  Row(
                    children: [
                      Icon(LucideIcons.ticket, size: 16, color: colors.ink40),
                      const SizedBox(width: 8),
                      Text(
                        'Ticket: ',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: colors.ink40),
                      ),
                      Text(
                        '#${complaint.ticketNumber}',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Current status
                  Row(
                    children: [
                      Icon(LucideIcons.activity, size: 16, color: colors.ink40),
                      const SizedBox(width: 8),
                      Text(
                        'Current Status: ',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: colors.ink40),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          complaint.status,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusClr,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Complaint text (stripped of both Android + Flutter suffixes)
                  if (strippedDescription.isNotEmpty) ...[
                    Divider(color: colors.ink10),
                    const SizedBox(height: 8),
                    Text(
                      'Complaint:',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.ink40,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strippedDescription,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: colors.ink80,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Update Form ─────────────────────────────────────────────────
            Text(
              'Update Details',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
            const SizedBox(height: 16),

            // Status dropdown (from complaintTypesRest — ticket_closer_categories)
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: '${l.status} *',
                labelStyle:
                    TextStyle(fontFamily: 'DM Sans', color: colors.ink40),
                prefixIcon:
                    Icon(LucideIcons.refreshCw, size: 18, color: colors.ink40),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colors.bg,
              ),
              style: TextStyle(
                  fontFamily: 'DM Sans', fontSize: 14, color: colors.ink),
              items: cState.closerTypes.map((type) {
                final name = type['typeName']?.toString() ??
                    type['name']?.toString() ??
                    type['complaint_type']?.toString() ??
                    '';
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name,
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          color: colors.ink)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedStatus = val;
                  // Try to capture closer_ticket_type_id and closer_reason_id
                  // from the selected closer type for the closeComplaintRest params.
                  final selectedType = cState.closerTypes.firstWhere(
                    (t) =>
                        (t['typeName']?.toString() ??
                            t['name']?.toString() ??
                            t['complaint_type']?.toString()) ==
                        val,
                    orElse: () => {},
                  );
                  _selectedCloserTicketTypeId =
                      selectedType['closer_ticket_type_id']?.toString() ??
                      selectedType['typeId']?.toString();
                  _selectedCloserReasonId =
                      selectedType['closer_reason_id']?.toString() ??
                      selectedType['reasonId']?.toString();
                });
              },
            ),
            const SizedBox(height: 16),

            // Comment field — mandatory per spec
            TextField(
              controller: _commentController,
              maxLines: 4,
              style: TextStyle(
                  fontFamily: 'DM Sans', fontSize: 14, color: colors.ink),
              decoration: InputDecoration(
                labelText: '${l.comment} *',
                labelStyle:
                    TextStyle(fontFamily: 'DM Sans', color: colors.ink40),
                alignLabelWithHint: true,
                hintText: 'Enter your comment (mandatory)',
                hintStyle: TextStyle(
                    fontFamily: 'DM Sans', fontSize: 13, color: colors.ink20),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Icon(LucideIcons.messageSquare,
                      size: 18, color: colors.ink40),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colors.bg,
              ),
            ),
            const SizedBox(height: 16),

            // Service employee dropdown — MANDATORY for TEAMLEAD, optional for others
            if (session != null && session.isTeamLead) ...[
              DropdownButtonFormField<int>(
                value: _selectedEmployeeId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Assign to Employee *',
                  labelStyle:
                      TextStyle(fontFamily: 'DM Sans', color: colors.ink40),
                  prefixIcon: Icon(LucideIcons.userPlus,
                      size: 18, color: colors.ink40),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colors.bg,
                ),
                style: TextStyle(
                    fontFamily: 'DM Sans', fontSize: 14, color: colors.ink),
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
                            color: colors.ink)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedEmployeeId = val);
                },
              ),
              const SizedBox(height: 16),
            ],

            // Non-TEAMLEAD optional employee dropdown
            if (session != null &&
                !session.isTeamLead &&
                cState.employees.isNotEmpty) ...[
              DropdownButtonFormField<int?>(
                value: _selectedEmployeeId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Assign to Employee',
                  labelStyle:
                      TextStyle(fontFamily: 'DM Sans', color: colors.ink40),
                  prefixIcon: Icon(LucideIcons.userPlus,
                      size: 18, color: colors.ink40),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colors.bg,
                ),
                style: TextStyle(
                    fontFamily: 'DM Sans', fontSize: 14, color: colors.ink),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text('None',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14,
                            color: colors.ink40)),
                  ),
                  ...cState.employees.map((emp) {
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
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              color: colors.ink)),
                    );
                  }),
                ],
                onChanged: (val) {
                  setState(() => _selectedEmployeeId = val);
                },
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 8),

            // Update button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.red,
                  foregroundColor: colors.card,
                  disabledBackgroundColor: colors.ink20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: colors.card),
                      )
                    : Text(
                        l.updateComplaint,
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
      ),
    );
  }
}
