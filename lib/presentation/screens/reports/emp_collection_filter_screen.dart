import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/report_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../router/route_names.dart';

/// Employee Collection date-filter screen.
/// Two date pickers (from / to), both default to today. Validates no future
/// dates and end >= start, then fetches collection summary.
class EmpCollectionFilterScreen extends ConsumerStatefulWidget {
  const EmpCollectionFilterScreen({super.key});

  @override
  ConsumerState<EmpCollectionFilterScreen> createState() =>
      _EmpCollectionFilterScreenState();
}

class _EmpCollectionFilterScreenState
    extends ConsumerState<EmpCollectionFilterScreen> {
  late DateTime _fromDate;
  late DateTime _toDate;

  @override
  void initState() {
    super.initState();
    _fromDate = DateTime.now();
    _toDate = DateTime.now();
  }

  Future<void> _pickFromDate() async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: colors.red,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
        // Ensure toDate is not before fromDate
        if (_toDate.isBefore(_fromDate)) {
          _toDate = _fromDate;
        }
      });
    }
  }

  Future<void> _pickToDate() async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: colors.red,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _toDate = picked);
    }
  }

  Future<void> _search() async {
    final session = ref.read(appSessionProvider);
    if (session == null) return;

    final fromStr = formatApiDate(_fromDate);
    final toStr = formatApiDate(_toDate);

    await ref.read(reportProvider.notifier).loadEmpCollection(
          fromStr,
          toStr,
          dealerId: session.dealerId,
        );

    if (!mounted) return;

    final state = ref.read(reportProvider);
    if (state.collectionError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.collectionError!)),
      );
      return;
    }

    context.push(
      RouteNames.empCollectionList,
      extra: {
        'fromDate': fromStr,
        'toDate': toStr,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final state = ref.watch(reportProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text(
          'Collection Report',
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select date range',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.ink60,
              ),
            ),
            const SizedBox(height: 16),

            // From date
            _DatePickerButton(
              label: 'From Date',
              date: _fromDate,
              colors: colors,
              onTap: _pickFromDate,
            ),
            const SizedBox(height: 12),

            // To date
            _DatePickerButton(
              label: 'To Date',
              date: _toDate,
              colors: colors,
              onTap: _pickToDate,
            ),
            const SizedBox(height: 28),

            // Search button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: state.isCollectionLoading ? null : _search,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.red,
                  foregroundColor: colors.card,
                  disabledBackgroundColor: colors.ink20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: state.isCollectionLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colors.card,
                        ),
                      )
                    : const Text(
                        'Search',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
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

class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final AppColors colors;
  final VoidCallback onTap;

  const _DatePickerButton({
    required this.label,
    required this.date,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.ink10),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.calendar, size: 18, color: colors.red),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: colors.ink40,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDisplayDate(date),
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(LucideIcons.chevronDown, size: 18, color: colors.ink20),
          ],
        ),
      ),
    );
  }
}
