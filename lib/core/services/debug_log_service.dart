import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DebugLogEntry
// ─────────────────────────────────────────────────────────────────────────────

class DebugLogEntry {
  final DateTime timestamp;
  final String method;
  final String endpoint;
  final Map<String, dynamic> requestData;
  final String? encryptedPayload;
  final int? httpStatus;
  final Map<String, dynamic>? responseData;
  final int durationMs;
  final String? error;
  final Map<String, String>? configFlags;

  const DebugLogEntry({
    required this.timestamp,
    required this.method,
    required this.endpoint,
    this.requestData = const {},
    this.encryptedPayload,
    this.httpStatus,
    this.responseData,
    this.durationMs = 0,
    this.error,
    this.configFlags,
  });

  /// Single-entry formatted text.
  String toFormattedText() {
    final buf = StringBuffer();
    final ts = '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';

    buf.writeln('[$ts] $method $endpoint');
    buf.writeln('  Status: ${httpStatus ?? "N/A"}  |  Duration: ${durationMs}ms');

    if (requestData.isNotEmpty) {
      buf.writeln('  Request: ${_prettyJson(requestData)}');
    }
    if (encryptedPayload != null && encryptedPayload!.isNotEmpty) {
      buf.writeln('  Encrypted: ${encryptedPayload!}');
    }
    if (responseData != null) {
      buf.writeln('  Response: ${_prettyJson(responseData!)}');
    }
    if (error != null) {
      buf.writeln('  Error: $error');
    }
    if (configFlags != null && configFlags!.isNotEmpty) {
      buf.writeln('  Config: $configFlags');
    }
    return buf.toString();
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'method': method,
        'endpoint': endpoint,
        'requestData': requestData,
        'encryptedPayload': encryptedPayload,
        'httpStatus': httpStatus,
        'responseData': responseData,
        'durationMs': durationMs,
        'error': error,
        'configFlags': configFlags,
      };

  static String _prettyJson(Map<String, dynamic> map) {
    try {
      return const JsonEncoder.withIndent('  ').convert(map);
    } catch (_) {
      return map.toString();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DebugLogService — singleton-like via ChangeNotifier
// ─────────────────────────────────────────────────────────────────────────────

class DebugLogService extends ChangeNotifier {
  static final DebugLogService _instance = DebugLogService._();
  factory DebugLogService() => _instance;
  DebugLogService._();

  static const int _maxEntries = 100;

  final List<DebugLogEntry> _entries = [];
  bool _enabled = false;

  /// Whether requests and responses are being captured.
  ///
  /// Can never be switched on in a release build: the setter drops `true`
  /// there. This matters because main.dart restores the flag from
  /// SharedPreferences at startup — without this guard, a tester who enabled
  /// logging on a debug install would have capture silently re-armed after
  /// upgrading to release, with no UI left to turn it off.
  bool get enabled => _enabled;
  set enabled(bool value) => _enabled = value && kDevToolsEnabled;

  List<DebugLogEntry> get entries => List.unmodifiable(_entries);

  void log(DebugLogEntry entry) {
    if (!enabled) return;
    _entries.insert(0, entry);
    if (_entries.length > _maxEntries) {
      _entries.removeLast();
    }
    notifyListeners();
  }

  /// Update the most recent entry matching [endpoint] with response data.
  void updateLatest({
    required String endpoint,
    int? httpStatus,
    Map<String, dynamic>? responseData,
    int? durationMs,
    String? error,
  }) {
    if (!enabled) return;
    final idx = _entries.indexWhere((e) => e.endpoint == endpoint);
    if (idx == -1) return;

    final old = _entries[idx];
    _entries[idx] = DebugLogEntry(
      timestamp: old.timestamp,
      method: old.method,
      endpoint: old.endpoint,
      requestData: old.requestData,
      encryptedPayload: old.encryptedPayload,
      httpStatus: httpStatus ?? old.httpStatus,
      responseData: responseData ?? old.responseData,
      durationMs: durationMs ?? old.durationMs,
      error: error ?? old.error,
      configFlags: old.configFlags,
    );
    notifyListeners();
  }

  String exportText() {
    final buf = StringBuffer();
    buf.writeln('=== EzyBill Debug Log ===');
    buf.writeln('Exported: ${DateTime.now().toIso8601String()}');
    buf.writeln('Entries: ${_entries.length}');
    buf.writeln('');
    for (final entry in _entries) {
      buf.writeln(entry.toFormattedText());
      buf.writeln('---');
    }
    return buf.toString();
  }

  String exportJson() {
    return const JsonEncoder.withIndent('  ')
        .convert(_entries.map((e) => e.toJson()).toList());
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod provider
// ─────────────────────────────────────────────────────────────────────────────

final debugLogProvider = Provider<DebugLogService>((ref) {
  return DebugLogService();
});

/// Separate provider for the debug toggle so UI rebuilds on change.
final debugEnabledProvider = NotifierProvider<_DebugEnabledNotifier, bool>(
  _DebugEnabledNotifier.new,
);

class _DebugEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(debugLogProvider).enabled;
}
