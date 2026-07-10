import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// ════════════════════════════════════════════════════════════
///  📡  HTTP LOGGER  v7.1  —  Clean ANSI-safe Logger
///
///  • Colored headers on desktop (macOS, Linux, Windows)
///  • Clean emoji-only output on mobile (iOS, Android)
///    where ANSI escapes get mangled by the log pipeline
/// ════════════════════════════════════════════════════════════

/// True on desktop platforms where ANSI escape codes render correctly.
/// False on mobile (iOS/Android) so raw escape codes don't leak into logs.
bool get _supportsAnsi {
  try {
    return !Platform.isIOS && !Platform.isAndroid;
  } catch (_) {
    return false;
  }
}

class HttpLoggerConfig {
  bool showEmoji = true;
  bool showHeaders = true;
  bool showRequestBody = true;
  bool showResponseBody = true;
  bool showTiming = true;
  bool showRequestId = true;
  bool useTrimming = true;
  int listLimit = 3;
  int stackTraceLimit = 8;
  int urlMaxLength = 90;
}

class HttpLogger {
  HttpLogger._();

  static final HttpLoggerConfig config = HttpLoggerConfig();
  static final Map<String, DateTime> _timings = {};

  /// Width for band-line fill calculations.
  static const int _boxWidth = 62;

  /// Build a full-width double-line band with embedded text.
  /// Used on non-ANSI platforms to simulate a header background.
  static String _bandLine(String text) {
    final prefix = '  ══ $text  ';
    final fillLen = _boxWidth - prefix.length;
    if (fillLen <= 0) return prefix;
    return '$prefix${'═' * fillLen}';
  }

  static void _print(String message) {
    if (kDebugMode) debugPrint(message);
  }

  // ═══════════════════════════════════════════
  //  🚀 REQUEST
  // ═══════════════════════════════════════════

  static void logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
    String? requestId,
  }) {
    if (!kDebugMode) return;

    final id = requestId ?? _shortId(url, method);
    _startTimer(id);

    final lines = <String>[];

    // 🔥 ORANGE HEADER
    if (_supportsAnsi) {
      lines.add('\n${_Ansi.bgOrange}${_Ansi.white}  🚀 OUTGOING REQUEST ➤ $method  ${_Ansi.reset}');
    } else {
      lines.add('\n${_bandLine('🚀 OUTGOING REQUEST ➤ $method')}');
    }

    lines.add(_row('URL   ', url, emoji: '🔗'));
    if (config.showRequestId) {
      lines.add(_row('ID    ', id, emoji: '🆔'));
    }

    if (config.showHeaders && headers != null && headers.isNotEmpty) {
      lines.add(_divider('📦 HEADERS'));
      lines.addAll(_jsonLines(headers));
    }

    if (config.showRequestBody && body != null) {
      lines.add(_divider('📝 BODY'));
      lines.addAll(_jsonLines(body));
    }

    lines.add('${_Ansi.white}  ${"━" * 60}${_Ansi.reset}\n');

    _print(lines.join('\n'));
  }

  // ═══════════════════════════════════════════
  //  ✅ RESPONSE
  // ═══════════════════════════════════════════

  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    required dynamic body,
    Map<String, dynamic>? headers,
    String? requestId,
  }) {
    if (!kDebugMode) return;

    final id = requestId ?? _shortId(url, method);
    final elapsed = _stopTimer(id);
    final tier = _statusTier(statusCode);
    final bgColor = _tierBgColor(tier);

    final lines = <String>[];

    // 🎯 STATUS HEADER
    final headerText = '${_tierEmoji(tier)} ${_tierLabel(tier)} · $statusCode · ⏱ $elapsed';
    if (_supportsAnsi) {
      lines.add('\n$bgColor${_Ansi.white}  $headerText  ${_Ansi.reset}');
    } else {
      lines.add('\n${_bandLine(headerText)}');
    }

    lines.add(_row('URL   ', url, emoji: '🔗'));

    if (config.showHeaders && headers != null && headers.isNotEmpty) {
      lines.add(_divider('📬 RESPONSE HEADERS'));
      lines.addAll(_jsonLines(headers));
    }

    if (config.showResponseBody && body != null) {
      lines.add(_divider('📦 RESPONSE BODY'));
      lines.addAll(
        _jsonLines(body, trim: config.useTrimming, limit: config.listLimit),
      );
    }

    lines.add('${_Ansi.white}  ${"━" * 60}${_Ansi.reset}\n');

    _print(lines.join('\n'));
  }

  // ═══════════════════════════════════════════
  //  ❌ ERROR
  // ═══════════════════════════════════════════

  static void logError({
    required String url,
    required dynamic error,
    StackTrace? stackTrace,
    String? method,
  }) {
    if (!kDebugMode) return;

    final lines = <String>[];

    // 🔥 RED HEADER
    if (_supportsAnsi) {
      lines.add('\n${_Ansi.bgRed}${_Ansi.white}  💥 HTTP ERROR EXCEPTION  ${_Ansi.reset}');
    } else {
      lines.add('\n${_bandLine('💥 HTTP ERROR EXCEPTION')}');
    }

    lines.add(_row('URL   ', url, emoji: '🔗'));
    lines.add(_row('ERROR ', error.toString(), emoji: '💬'));

    if (stackTrace != null) {
      lines.add(_divider('🧵 STACK TRACE'));
      stackTrace.toString().split('\n').take(config.stackTraceLimit).forEach((
        l,
      ) {
        lines.add('${_Ansi.white}    $l${_Ansi.reset}');
      });
    }

    lines.add('${_Ansi.white}  ${"━" * 60}${_Ansi.reset}\n');

    _print(lines.join('\n'));
  }

  // ═══════════════════════════════════════════
  //  🛠 FORMATTING
  // ═══════════════════════════════════════════

  static String _row(String label, String value, {required String emoji}) {
    return '${_Ansi.white}$emoji  ${_Ansi.bold}$label${_Ansi.reset} ${_Ansi.white}$value${_Ansi.reset}';
  }

  static String _divider(String label) {
    return '${_Ansi.white}  ┠─ $label ${"─" * (40 - label.length)}${_Ansi.reset}';
  }

  static List<String> _jsonLines(
    dynamic data, {
    bool trim = false,
    int limit = 2,
  }) {
    try {
      final obj = data is String ? jsonDecode(data) : data;
      final encoder = const JsonEncoder.withIndent('  ');

      if (trim && obj is List && obj.length > limit) {
        final shown = encoder.convert(obj.take(limit).toList()).split('\n');
        return [
          ...shown.map((l) => '${_Ansi.white}    $l${_Ansi.reset}'),
          '${_Ansi.white}    ✂️ ... and ${obj.length - limit} more items${_Ansi.reset}',
        ];
      }

      return encoder
          .convert(obj)
          .split('\n')
          .map((l) => '${_Ansi.white}    $l${_Ansi.reset}')
          .toList();
    } catch (_) {
      return ['${_Ansi.white}    $data${_Ansi.reset}'];
    }
  }

  // ═══════════════════════════════════════════
  //  ⏱ LOGIC
  // ═══════════════════════════════════════════

  static void _startTimer(String key) => _timings[key] = DateTime.now();

  static String _stopTimer(String key) {
    final s = _timings.remove(key);
    if (s == null) return '0ms';
    final diff = DateTime.now().difference(s).inMilliseconds;
    return '${diff}ms';
  }

  static String _shortId(String url, String method) =>
      (url + method).hashCode.abs().toRadixString(16).substring(0, 4);

  static _Tier _statusTier(int c) => c >= 500
      ? _Tier.serverErr
      : (c >= 400
            ? _Tier.clientErr
            : (c >= 300 ? _Tier.redirect : _Tier.success));

  static String _tierLabel(_Tier t) => t == _Tier.success
      ? 'SUCCESS 🎉'
      : t == _Tier.redirect
      ? 'REDIRECT 🔁'
      : t == _Tier.clientErr
      ? 'CLIENT ERROR ⚠️'
      : 'SERVER ERROR 🔥';

  static String _tierEmoji(_Tier t) => t == _Tier.success
      ? '✅'
      : t == _Tier.redirect
      ? '↪️'
      : t == _Tier.clientErr
      ? '⚠️'
      : '🔥';

  static String _tierBgColor(_Tier t) => t == _Tier.success
      ? _Ansi.bgGreen
      : t == _Tier.redirect
      ? _Ansi.bgCyan
      : t == _Tier.clientErr
      ? _Ansi.bgYellow
      : _Ansi.bgRed;
}

// ═══════════════════════════════════════════
//  🎨 ANSI COLORS  (empty strings on mobile)
// ═══════════════════════════════════════════

class _Ansi {
  static String get reset    => _supportsAnsi ? '\x1B[0m' : '';
  static String get bold     => _supportsAnsi ? '\x1B[1m' : '';
  static String get white    => _supportsAnsi ? '\x1B[37m' : '';

  static String get bgOrange => _supportsAnsi ? '\x1B[48;5;208m' : '';
  static String get bgGreen  => _supportsAnsi ? '\x1B[42m' : '';
  static String get bgYellow => _supportsAnsi ? '\x1B[43m' : '';
  static String get bgRed    => _supportsAnsi ? '\x1B[41m' : '';
  static String get bgCyan   => _supportsAnsi ? '\x1B[46m' : '';
}

enum _Tier { success, redirect, clientErr, serverErr }
