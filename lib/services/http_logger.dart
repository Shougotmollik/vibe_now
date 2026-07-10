import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// ═════════════════════════════════════════════════════════════════════
///  📡  HTTP LOGGER  v10.0  —  Rich API Insight Logger
///
///  Clean Unicode box-drawing on ALL platforms (iOS, macOS, Android).
///  ANSI background colors as bonus on macOS/Linux desktop targets.
///
///  JSON syntax highlighting (ANSI only):
///    🔹 Keys          → cyan
///    🔸 String values → green
///    🔸 Numbers       → yellow
///    🔸 Booleans/null → magenta
///
///  ── Quick Glance ─────────────────────────────────────────────
///  ╔╣ 🚀  [GET]  /api/users
///  ║  http://api.example.com/users
///  ╟ 🆔: a1b2
///  ╟─ 📦 Headers ─────────────────────────────────────────────
///  ║   Content-Type: application/json
///  ╚═══════════════════════════════════════════════════════════╝
///
///  ╔╣ ✅  [GET]  /api/users  ·  200  ·  42ms
///  ║  http://api.example.com/users
///  ╟─ 📦 Response Body ───────────────────────────────────────
///  ║   { "success": true }
///  ╚═══════════════════════════════════════════════════════════╝
///  ◀  [GET]  /api/users  →  ✅ 200  (42ms)
/// ═════════════════════════════════════════════════════════════════════

/// True on desktop where ANSI renders. False on mobile (iOS/Android)
/// where Apple's os_log strips the \x1B byte.
bool get _supportsAnsi {
  try {
    return !Platform.isIOS && !Platform.isAndroid;
  } catch (_) {
    return false;
  }
}

// ────────────────────────────────────────────────────────────────────
//  ⚙️  CONFIG
// ────────────────────────────────────────────────────────────────────

class HttpLoggerConfig {
  bool showEmoji = true;
  bool showHeaders = true;
  bool showRequestBody = true;
  bool showResponseBody = true;
  bool showTiming = true;
  bool showRequestId = true;
  bool useTrimming = true;
  bool enableJsonHighlight = true;
  int listLimit = 3;
  int stackTraceLimit = 8;
  int urlMaxLength = 90;
  int maxWidth = 90;
  int slowThresholdMs = 2000;
  bool maskAuthTokens = true;
}

// ────────────────────────────────────────────────────────────────────
//  📡  LOGGER
// ────────────────────────────────────────────────────────────────────

class HttpLogger {
  HttpLogger._();

  static final HttpLoggerConfig config = HttpLoggerConfig();
  static final Map<String, DateTime> _timings = {};

  static void _print(String message) {
    if (kDebugMode) debugPrint(message);
  }

  /// ── helpers ────────────────────────────────────────────────────

  static int get _w => config.maxWidth;

  /// Header line: `╔╣ 🚀  [GET]  /api/users`
  static String _header(String content) {
    if (_supportsAnsi) return '\n\x1B[48;5;208m\x1B[37m╔╣ $content \x1B[0m';
    return '\n╔╣ $content ';
  }

  /// Header line with tier-based background color (for responses/errors).
  static String _headerColored(String content, String bgCode) {
    if (_supportsAnsi) return '\n$bgCode\x1B[37m╔╣ $content \x1B[0m';
    return '\n╔╣ $content ';
  }

  /// Content row: `║  $content`
  static String _line(String content) => '║  $content';

  /// Key-value row: `╟ $label: $value`
  static String _kv(String label, String value) => '╟ $label: $value';

  /// Section divider: `╟─ $label ──────────────────────────`
  static String _section(String label) {
    final text = '─ $label ';
    final fill = '─' * (_w - text.length - 3);
    return '╟$text$fill';
  }

  /// Footer: `╚══════════════════════════════════════════════╝`
  static String _footer() => '╚${'═' * (_w - 1)}╝';

  // ──────────────────────────────────────────────────────────────────
  //  🚀  REQUEST
  // ──────────────────────────────────────────────────────────────────

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
    final path = _extractPath(url);
    final maskedHeaders = _maskSensitiveHeaders(headers);
    final lines = <String>[];

    lines.add(_header('🚀  [$method]  $path'));
    lines.add(_line(url));

    if (config.showRequestId && id.isNotEmpty) {
      lines.add(_kv('🆔', id));
    }

    if (config.showHeaders && maskedHeaders != null && maskedHeaders.isNotEmpty) {
      lines.add(_section('📦 Headers'));
      lines.addAll(_formatMap(maskedHeaders));
    }

    if (config.showRequestBody && body != null) {
      lines.add(_section('📝 Body'));
      lines.addAll(_formatBody(body, trim: config.useTrimming, limit: config.listLimit));
    }

    lines.add(_footer());
    _print(lines.join('\n'));
  }

  // ──────────────────────────────────────────────────────────────────
  //  ✅  RESPONSE
  // ──────────────────────────────────────────────────────────────────

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
    final bg = _tierBgCode(tier);
    final path = _extractPath(url);
    final isSlow = config.slowThresholdMs > 0 && _parseMs(elapsed) > config.slowThresholdMs;
    final maskedHeaders = _maskSensitiveHeaders(headers);

    final lines = <String>[];

    // Header with optional slow flag
    final headerSuffix = isSlow ? '  ⚠️' : '';
    lines.add(_headerColored(
      '${_tierEmoji(tier)}  [$method]  $path  ·  $statusCode  ·  $elapsed$headerSuffix',
      bg,
    ));
    lines.add(_line(url));

    if (config.showRequestId && id.isNotEmpty) {
      lines.add(_kv('🆔', id));
    }

    // For errors, show the error message if body has one
    if (tier == _Tier.clientErr || tier == _Tier.serverErr) {
      final errorMsg = _extractErrorMessage(body);
      if (errorMsg != null) {
        lines.add(_kv('💬', errorMsg));
      }
    }

    if (config.showHeaders && maskedHeaders != null && maskedHeaders.isNotEmpty) {
      lines.add(_section('📬 Response Headers'));
      lines.addAll(_formatMap(maskedHeaders));
    }

    if (config.showResponseBody && body != null) {
      lines.add(_section('📦 Response Body'));
      lines.addAll(_formatBody(body, trim: config.useTrimming, limit: config.listLimit));
    }

    lines.add(_footer());

    // ── Summary line ──────────────────────────────────────────────
    final slowTag = isSlow ? '  ⚠️ slow' : '';
    lines.add(' ◀  [$method]  $path  →  ${_tierEmoji(tier)} $statusCode  ($elapsed)$slowTag');

    _print(lines.join('\n'));
  }

  // ──────────────────────────────────────────────────────────────────
  //  ❌  ERROR
  // ──────────────────────────────────────────────────────────────────

  static void logError({
    required String url,
    required dynamic error,
    StackTrace? stackTrace,
    String? method,
  }) {
    if (!kDebugMode) return;

    final path = _extractPath(url);
    final methodBadge = method != null ? ' [$method]' : '';
    final lines = <String>[];

    lines.add(_headerColored('🔥 HTTP ERROR$methodBadge  $path', _Ansi.bgRed));
    lines.add(_line(url));
    lines.add(_kv('💬', error.toString()));

    if (stackTrace != null) {
      lines.add(_section('🧵 Stack Trace'));
      final frames = stackTrace.toString().split('\n').take(config.stackTraceLimit);
      for (final line in frames) {
        lines.add('║    $line');
      }
    }

    lines.add(_footer());

    // ── Summary line ──────────────────────────────────────────────
    final errStr = error.toString().split('\n').first;
    final maxErrLen = 60;
    final trimmedErr = errStr.length > maxErrLen
        ? '${errStr.substring(0, maxErrLen)}…'
        : errStr;
    lines.add(' ✕$methodBadge  $path  →  🔥 $trimmedErr');

    _print(lines.join('\n'));
  }

  // ──────────────────────────────────────────────────────────────────
  //  🛠  FORMATTING HELPERS
  // ──────────────────────────────────────────────────────────────────

  /// Format a Map into indented JSON lines with auth token masking.
  static List<String> _formatMap(Map data) {
    try {
      final encoder = const JsonEncoder.withIndent('  ');
      final lines = encoder.convert(data).split('\n');
      return lines.map((l) => '║  ${_colorizeJsonLine(l)}').toList();
    } catch (_) {
      return ['║  $data'];
    }
  }

  /// Format body (Map, List, String) into indented lines.
  static List<String> _formatBody(dynamic data, {bool trim = false, int limit = 2}) {
    try {
      final obj = data is String ? jsonDecode(data) : data;
      final encoder = const JsonEncoder.withIndent('  ');

      if (trim && obj is List && obj.length > limit) {
        final shown = encoder.convert(obj.take(limit).toList()).split('\n');
        return [
          ...shown.map((l) => '║  ${_colorizeJsonLine(l)}'),
          '║  ✂️  …and ${obj.length - limit} more',
        ];
      }

      return encoder
          .convert(obj)
          .split('\n')
          .map((l) => '║  ${_colorizeJsonLine(l)}')
          .toList();
    } catch (_) {
      return ['║  $data'];
    }
  }

  /// Colorize a single JSON line with syntax highlighting.
  ///
  /// On ANSI-supported platforms:
  ///   • Keys        → cyan   (\x1B[36m)
  ///   • String vals → green  (\x1B[32m)
  ///   • Numbers     → yellow (\x1B[33m)
  ///   • Booleans    → magenta(\x1B[35m)
  ///   • null        → magenta(\x1B[35m)
  ///
  /// On mobile / non-ANSI the line is returned unchanged.
  static String _colorizeJsonLine(String line) {
    if (!_supportsAnsi || !config.enableJsonHighlight) return line;

    // Match: optional whitespace + "key" + : + value[,]
    final kvPattern = RegExp(r'''^(\s*)("[^"]+")\s*:\s*(.*)$''');
    final kvMatch = kvPattern.firstMatch(line);
    if (kvMatch != null) {
      final indent = kvMatch.group(1)!;
      final key = kvMatch.group(2)!;
      final rawValue = kvMatch.group(3)!;

      // Strip trailing comma for type detection, re-append after coloring
      final hasComma = rawValue.endsWith(',');
      final value = hasComma
          ? rawValue.substring(0, rawValue.length - 1).trimRight()
          : rawValue.trimRight();

      final coloredValue = _colorizeJsonValue(value);
      final comma = hasComma ? ',' : '';

      return '$indent${_Ansi.fgCyan}$key${_Ansi.reset}: $coloredValue$comma';
    }

    return line;
  }

  /// Colorize a JSON value string based on its type.
  static String _colorizeJsonValue(String value) {
    if (value.startsWith('"')) {
      return '${_Ansi.fgGreen}$value${_Ansi.reset}';
    }
    if (value == 'true' || value == 'false') {
      return '${_Ansi.fgMagenta}$value${_Ansi.reset}';
    }
    if (value == 'null') {
      return '${_Ansi.fgMagenta}$value${_Ansi.reset}';
    }
    if (RegExp(r'^-?\d+\.?\d*([eE][+-]?\d+)?$').hasMatch(value)) {
      return '${_Ansi.fgYellow}$value${_Ansi.reset}';
    }
    // Fallback: object/array brackets or raw text — leave uncolored
    return value;
  }

  /// Extract just the path portion from a URL string.
  static String _extractPath(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      if (uri.query.isNotEmpty) return '$path?${uri.query}';
      return path;
    } catch (_) {
      // If parsing fails, return last 60 chars of URL
      return url.length > 60 ? '…${url.substring(url.length - 60)}' : url;
    }
  }

  /// Mask sensitive headers like Authorization Bearer tokens.
  static Map<String, dynamic>? _maskSensitiveHeaders(Map<String, dynamic>? headers) {
    if (headers == null || !config.maskAuthTokens) return headers;

    final masked = <String, dynamic>{};
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'authorization' &&
          entry.value is String &&
          (entry.value as String).startsWith('Bearer ')) {
        final token = (entry.value as String).substring(7);
        if (token.length > 20) {
          masked[entry.key] =
              'Bearer ${token.substring(0, 8)}…${token.substring(token.length - 4)}';
        } else {
          masked[entry.key] = entry.value;
        }
      } else {
        masked[entry.key] = entry.value;
      }
    }
    return masked;
  }

  /// Try to extract a human-readable error message from a response body.
  static String? _extractErrorMessage(dynamic body) {
    try {
      final obj = body is String ? jsonDecode(body) : body;
      if (obj is Map) {
        return (obj['message'] ?? obj['error'] ?? obj['detail'] ?? obj['msg'] ?? '') as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Parse "632ms" string to int milliseconds.
  static int _parseMs(String elapsed) {
    try {
      return int.parse(elapsed.replaceAll('ms', ''));
    } catch (_) {
      return 0;
    }
  }

  // ──────────────────────────────────────────────────────────────────
  //  ⏱  TIMING
  // ──────────────────────────────────────────────────────────────────

  static void _startTimer(String key) => _timings[key] = DateTime.now();

  static String _stopTimer(String key) {
    final s = _timings.remove(key);
    if (s == null) return '0ms';
    return '${DateTime.now().difference(s).inMilliseconds}ms';
  }

  static String _shortId(String url, String method) =>
      (url + method).hashCode.abs().toRadixString(16).substring(0, 4);

  // ──────────────────────────────────────────────────────────────────
  //  📊  TIER LOGIC
  // ──────────────────────────────────────────────────────────────────

  static _Tier _statusTier(int c) =>
      c >= 500 ? _Tier.serverErr : (c >= 400 ? _Tier.clientErr : (c >= 300 ? _Tier.redirect : _Tier.success));

  static String _tierEmoji(_Tier t) => switch (t) {
        _Tier.success   => '✅',
        _Tier.redirect  => '↪️',
        _Tier.clientErr => '⚠️',
        _Tier.serverErr => '🔥',
      };

  static String _tierBgCode(_Tier t) => switch (t) {
        _Tier.success   => _Ansi.bgGreen,
        _Tier.redirect  => _Ansi.bgCyan,
        _Tier.clientErr => _Ansi.bgYellow,
        _Tier.serverErr => _Ansi.bgRed,
      };
}

// ────────────────────────────────────────────────────────────────────
//  🎨  ANSI COLORS  (empty strings on mobile)
// ────────────────────────────────────────────────────────────────────

class _Ansi {
  // Background colors
  static String get bgGreen  => _supportsAnsi ? '\x1B[42m' : '';
  static String get bgYellow => _supportsAnsi ? '\x1B[43m' : '';
  static String get bgRed    => _supportsAnsi ? '\x1B[41m' : '';
  static String get bgCyan   => _supportsAnsi ? '\x1B[46m' : '';

  // Foreground colors  —  for JSON syntax highlighting
  static String get reset     => _supportsAnsi ? '\x1B[0m' : '';
  static String get fgCyan    => _supportsAnsi ? '\x1B[36m' : '';
  static String get fgGreen   => _supportsAnsi ? '\x1B[32m' : '';
  static String get fgYellow  => _supportsAnsi ? '\x1B[33m' : '';
  static String get fgMagenta => _supportsAnsi ? '\x1B[35m' : '';
}

enum _Tier { success, redirect, clientErr, serverErr }
