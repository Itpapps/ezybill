import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../application/providers/core_providers.dart';
import '../../../core/services/debug_log_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class DebugConsoleScreen extends ConsumerStatefulWidget {
  const DebugConsoleScreen({super.key});

  @override
  ConsumerState<DebugConsoleScreen> createState() => _DebugConsoleScreenState();
}

class _DebugConsoleScreenState extends ConsumerState<DebugConsoleScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<int> _expandedEntries = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    final colors = Theme.of(context).extension<AppColors>()!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label copied to clipboard',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
          ),
        ),
        backgroundColor: colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final debugLog = ref.watch(debugLogProvider);
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final prefs = ref.read(sharedPreferencesProvider);

    // Filter entries by search
    final entries = _searchQuery.isEmpty
        ? debugLog.entries
        : debugLog.entries
            .where((e) =>
                e.endpoint.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.method.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: colors.ink, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Debug Console',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colors.ink,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(LucideIcons.moreVertical, color: colors.ink60, size: 20),
            onSelected: (value) {
              switch (value) {
                case 'copy_text':
                  _copyToClipboard(debugLog.exportText(), 'Log text');
                  break;
                case 'copy_json':
                  _copyToClipboard(debugLog.exportJson(), 'Log JSON');
                  break;
                case 'clear':
                  debugLog.clear();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'copy_text',
                child: Row(
                  children: [
                    Icon(LucideIcons.copy, size: 16, color: colors.ink60),
                    const SizedBox(width: 8),
                    Text('Copy All (Text)',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: colors.ink,
                        )),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'copy_json',
                child: Row(
                  children: [
                    Icon(LucideIcons.braces, size: 16, color: colors.ink60),
                    const SizedBox(width: 8),
                    Text('Export JSON',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: colors.ink,
                        )),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(LucideIcons.trash2, size: 16, color: colors.red),
                    const SizedBox(width: 8),
                    Text('Clear Logs',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: colors.red,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Toggle + Search bar ────────────────────────────────────────
          Container(
            color: colors.card,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // Enable toggle
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Enable Debug Logging',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.ink,
                        ),
                      ),
                    ),
                    Switch(
                      value: debugLog.enabled,
                      activeColor: colors.red,
                      onChanged: (value) {
                        debugLog.enabled = value;
                        prefs.setBool('debug_logging_enabled', value);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Search field
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    color: colors.ink,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Filter by endpoint...',
                    hintStyle: TextStyle(color: colors.ink20, fontSize: 13),
                    prefixIcon:
                        Icon(LucideIcons.search, size: 16, color: colors.ink20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(LucideIcons.x,
                                size: 14, color: colors.ink40),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: colors.bg,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.ink10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.ink10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Entry count ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${entries.length} entries',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.ink40,
                  ),
                ),
                const Spacer(),
                if (!debugLog.enabled)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.ink05,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'LOGGING OFF',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: colors.ink40,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Log entries list ────────────────────────────────────────────
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.terminal,
                            size: 48, color: colors.ink10),
                        const SizedBox(height: 12),
                        Text(
                          debugLog.enabled
                              ? 'No API calls logged yet.\nMake a request to see it here.'
                              : 'Debug logging is disabled.\nEnable it above to start capturing.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            color: colors.ink40,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final isExpanded = _expandedEntries.contains(index);
                      return _LogEntryCard(
                        entry: entry,
                        isExpanded: isExpanded,
                        colors: colors,
                        onToggle: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedEntries.remove(index);
                            } else {
                              _expandedEntries.add(index);
                            }
                          });
                        },
                        onCopy: () {
                          _copyToClipboard(
                              entry.toFormattedText(), 'Entry');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Log Entry Card
// ─────────────────────────────────────────────────────────────────────────────

class _LogEntryCard extends StatelessWidget {
  final DebugLogEntry entry;
  final bool isExpanded;
  final AppColors colors;
  final VoidCallback onToggle;
  final VoidCallback onCopy;

  const _LogEntryCard({
    required this.entry,
    required this.isExpanded,
    required this.colors,
    required this.onToggle,
    required this.onCopy,
  });

  Color _statusColor() {
    final status = entry.httpStatus;
    if (status == null) return colors.ink40;
    if (status >= 200 && status < 300) return colors.green;
    if (status >= 400 && status < 500) return Colors.orange;
    if (status >= 500) return colors.red;
    return colors.ink40;
  }

  @override
  Widget build(BuildContext context) {
    final ts = '${entry.timestamp.hour.toString().padLeft(2, '0')}:'
        '${entry.timestamp.minute.toString().padLeft(2, '0')}:'
        '${entry.timestamp.second.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: colors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colors.ink05, width: 1),
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Collapsed header ────────────────────────────────────
              Row(
                children: [
                  // Timestamp
                  Text(
                    ts,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: colors.ink40,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Method badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry.method,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Endpoint
                  Expanded(
                    child: Text(
                      entry.endpoint,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Status code
                  if (entry.httpStatus != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: _statusColor().withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${entry.httpStatus}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(),
                        ),
                      ),
                    ),
                  ],
                  // Duration
                  const SizedBox(width: 6),
                  Text(
                    '${entry.durationMs}ms',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: colors.ink40,
                    ),
                  ),
                  // Expand icon
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 14,
                    color: colors.ink20,
                  ),
                ],
              ),

              // ── Error indicator ──────────────────────────────────────
              if (entry.error != null && !isExpanded) ...[
                const SizedBox(height: 4),
                Text(
                  entry.error!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: colors.red,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // ── Expanded detail ──────────────────────────────────────
              if (isExpanded) ...[
                const SizedBox(height: 12),
                Divider(height: 1, color: colors.ink05),
                const SizedBox(height: 12),

                // Copy button
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onCopy,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.copy, size: 12, color: colors.ink40),
                        const SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            color: colors.ink40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Request data
                if (entry.requestData.isNotEmpty) ...[
                  _SectionLabel(label: 'REQUEST DATA', colors: colors),
                  const SizedBox(height: 4),
                  _JsonBlock(
                    data: entry.requestData,
                    colors: colors,
                  ),
                  const SizedBox(height: 10),
                ],

                // Encrypted payload
                if (entry.encryptedPayload != null &&
                    entry.encryptedPayload!.isNotEmpty) ...[
                  _SectionLabel(label: 'ENCRYPTED PAYLOAD', colors: colors),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.ink05,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry.encryptedPayload!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: colors.ink60,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Response data
                if (entry.responseData != null) ...[
                  _SectionLabel(label: 'RESPONSE DATA', colors: colors),
                  const SizedBox(height: 4),
                  _JsonBlock(
                    data: entry.responseData!,
                    colors: colors,
                  ),
                  const SizedBox(height: 10),
                ],

                // Error
                if (entry.error != null) ...[
                  _SectionLabel(label: 'ERROR', colors: colors),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry.error!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Config flags
                if (entry.configFlags != null &&
                    entry.configFlags!.isNotEmpty) ...[
                  _SectionLabel(label: 'CONFIG FLAGS', colors: colors),
                  const SizedBox(height: 4),
                  _JsonBlock(
                    data: entry.configFlags!.cast<String, dynamic>(),
                    colors: colors,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final AppColors colors;

  const _SectionLabel({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: colors.ink40,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JSON Block (scrollable, mono font)
// ─────────────────────────────────────────────────────────────────────────────

class _JsonBlock extends StatelessWidget {
  final Map<String, dynamic> data;
  final AppColors colors;

  const _JsonBlock({required this.data, required this.colors});

  @override
  Widget build(BuildContext context) {
    String jsonStr;
    try {
      jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      jsonStr = data.toString();
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.ink05,
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          jsonStr,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: colors.ink,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
