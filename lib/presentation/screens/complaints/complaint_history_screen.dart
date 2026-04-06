import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/complaint_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/string_extensions.dart';
import '../../../data/models/complaint/complaint_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Status → Color mapping (shared with complaint_screen)
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

class ComplaintHistoryScreen extends ConsumerStatefulWidget {
  final String customerId;

  const ComplaintHistoryScreen({
    super.key,
    required this.customerId,
  });

  @override
  ConsumerState<ComplaintHistoryScreen> createState() =>
      _ComplaintHistoryScreenState();
}

class _ComplaintHistoryScreenState
    extends ConsumerState<ComplaintHistoryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<ComplaintModel> _complaints = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await ref
          .read(complaintProvider.notifier)
          .loadHistory(widget.customerId);
      if (mounted) {
        setState(() {
          _complaints = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text(
          'Complaint History',
          style: TextStyle(
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colors.red))
          : _errorMessage != null
              ? _buildError(colors)
              : _buildContent(colors),
    );
  }

  Widget _buildError(AppColors c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.alertCircle, size: 48, color: c.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                color: c.ink60,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadHistory,
              icon: Icon(LucideIcons.refreshCw, size: 16, color: c.red),
              label: Text('Retry',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      color: c.red,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppColors c) {
    return Column(
      children: [
        // Header with total count
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: c.card,
          child: Row(
            children: [
              Icon(LucideIcons.clipboardList, size: 20, color: c.red),
              const SizedBox(width: 8),
              Text(
                'Total Complaints - ${_complaints.length}',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: c.ink,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: c.ink10),

        // List
        Expanded(
          child: _complaints.isEmpty
              ? _buildEmpty(c)
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _complaints.length,
                    itemBuilder: (context, index) {
                      return _HistoryCard(
                        complaint: _complaints[index],
                        colors: c,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmpty(AppColors c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: c.greenSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(LucideIcons.checkCircle, size: 36, color: c.green),
          ),
          const SizedBox(height: 16),
          Text(
            'No Complaints',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: c.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This customer has no complaint history',
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
// History Card
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final ComplaintModel complaint;
  final AppColors colors;

  const _HistoryCard({
    required this.complaint,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final statusClr = _statusColor(complaint.status);
    final statusBg = _statusBgColor(complaint.status);
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
            // Row 1: ticket + status
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
                  child: Text(
                    '#${complaint.ticketNumber}',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: c.ink,
                    ),
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

            // Row 3: description
            if (strippedDescription.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: Text(
                  strippedDescription.truncate(120),
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
          ],
        ),
      ),
    );
  }
}
