import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:vibe_now/controller/auth_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/services/http_logger.dart';
import 'package:vibe_now/services/local_storage.dart';
import 'package:vibe_now/utils.dart';
import 'package:vibe_now/utils/check_for_internet.dart';

class CustomHttpResult {
  final dynamic data;
  final int status_code;
  final String? error;
  final bool ok;

  const CustomHttpResult({
    this.data,
    required this.status_code,
    this.error,
    required this.ok,
  });
}

enum _HttpMethod { post, put, patch, delete }

class CustomHttp {
  CustomHttp._();

  static Future<CustomHttpResult> get({
    required String endpoint,
    bool show_floating_error = true,
    bool need_auth = true,
    Map<String, String>? headers,
    Map<String, dynamic>? queries,
  }) async {
    if (!await hasInternet(showError: true)) {
      return const CustomHttpResult(
        ok: false,
        status_code: -1,
        error: 'No internet! Please check your internet connection.',
      );
    }

    late String url;

    try {
      final resolved_headers = await _build_headers(
        need_auth: need_auth,
        extra: headers,
      );

      if (resolved_headers == null) {
        return const CustomHttpResult(
          ok: false,
          status_code: 401,
          error: 'Session expired. Please log in again.',
        );
      }

      url = _build_url('${AppCredentials.domain}/api$endpoint', queries);

      HttpLogger.logRequest(method: 'GET', url: url, headers: resolved_headers);

      final response = await http.get(
        Uri.parse(url),
        headers: resolved_headers,
      );

      return await _handle_response(
        response,
        show_floating_error,
        // This tells the handler: "If you fail with 401, run this 'get' again"
        retryAction: need_auth
            ? () => get(
                endpoint: endpoint,
                show_floating_error: show_floating_error,
                need_auth: need_auth,
                headers: headers,
                queries: queries,
              )
            : null,
      );
      ;
    } catch (e, stackTrace) {
      _log_error('GET', url, e, stackTrace);

      return CustomHttpResult(status_code: -2, error: e.toString(), ok: false);
    }
  }

  static Future<CustomHttpResult> post({
    required String endpoint,
    bool add_api_prefix = true,
    Map<String, String>? headers,
    dynamic body,
    bool show_floating_error = true,
    bool need_auth = true,
    Map<String, dynamic>? queries,
  }) async {
    return _send_with_body(
      method: _HttpMethod.post,
      endpoint: endpoint,
      add_api_prefix: add_api_prefix,
      headers: headers,
      body: body,
      show_floating_error: show_floating_error,
      need_auth: need_auth,
      queries: queries,
    );
  }

  static Future<CustomHttpResult> put({
    required String endpoint,
    required bool add_api_prefix,
    Map<String, String>? headers,
    dynamic body,
    bool show_floating_error = true,
    bool need_auth = true,
    Map<String, dynamic>? queries,
  }) async {
    return _send_with_body(
      method: _HttpMethod.put,
      endpoint: endpoint,
      add_api_prefix: add_api_prefix,
      headers: headers,
      body: body,
      show_floating_error: show_floating_error,
      need_auth: need_auth,
      queries: queries,
    );
  }

  static Future<CustomHttpResult> patch({
    required String endpoint,
    bool add_api_prefix = true,
    Map<String, String>? headers,
    dynamic body,
    bool show_floating_error = true,
    bool need_auth = true,
    Map<String, dynamic>? queries,
  }) async {
    return _send_with_body(
      method: _HttpMethod.patch,
      endpoint: endpoint,
      add_api_prefix: add_api_prefix,
      headers: headers,
      body: body,
      show_floating_error: show_floating_error,
      need_auth: need_auth,
      queries: queries,
    );
  }

  static Future<CustomHttpResult> delete({
    required String endpoint,
    bool add_api_prefix = true,
    Map<String, String>? headers,
    dynamic body,
    bool show_floating_error = true,
    bool need_auth = true,
    Map<String, dynamic>? queries,
  }) async {
    return _send_with_body(
      method: _HttpMethod.delete,
      endpoint: endpoint,
      add_api_prefix: add_api_prefix,
      headers: headers,
      body: body,
      show_floating_error: show_floating_error,
      need_auth: need_auth,
      queries: queries,
    );
  }

  static Future<CustomHttpResult> multipart({
    required String endpoint,
    required String fieldName,

    String? filePath,
    List<String>? filePaths,

    Map<String, String>? fields,
    Map<String, dynamic>? queries,
    String method = 'POST',
    bool need_auth = true,
    bool show_floating_error = true,
    Map<String, String>? headers,
  }) async {
    if (!await hasInternet(showError: true)) {
      return const CustomHttpResult(
        ok: false,
        status_code: -1,
        error: 'No internet! Please check your internet connection.',
      );
    }

    String url = '';

    try {
      final resolved_headers = await _build_headers(
        need_auth: need_auth,
        extra: headers,
      );

      if (resolved_headers == null) {
        return const CustomHttpResult(
          ok: false,
          status_code: 401,
          error: 'Session expired. Please log in again.',
        );
      }

      url = _build_url('${AppCredentials.domain}/api$endpoint', queries);

      final uri = Uri.parse(url);

      final request = http.MultipartRequest(method, uri);

      final multipartHeaders = Map<String, String>.from(resolved_headers);

      multipartHeaders.remove('Content-Type');

      request.headers.addAll(multipartHeaders);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      /// Single file
      if (filePath != null && fieldName.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(fieldName, filePath),
        );
      }

      /// Multiple files
      if (filePaths != null && filePaths.isNotEmpty) {
        for (final path in filePaths) {
          request.files.add(await http.MultipartFile.fromPath(fieldName, path));
        }
      }

      HttpLogger.logRequest(
        method: method,
        url: url,
        headers: multipartHeaders,
        body: {
          'filePath': filePath,
          'filePaths': filePaths,
          'fieldName': fieldName,
          if (fields != null) ...fields,
        },
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      return _handle_response(response, show_floating_error);
    } catch (e, stackTrace) {
      _log_error(method, url, e, stackTrace);

      return CustomHttpResult(status_code: -2, error: e.toString(), ok: false);
    }
  }

  static Future<CustomHttpResult> _send_with_body({
    required _HttpMethod method,
    required String endpoint,
    required bool add_api_prefix,
    Map<String, String>? headers,
    dynamic body,
    required bool show_floating_error,
    required bool need_auth,
    Map<String, dynamic>? queries,
  }) async {
    if (!await hasInternet(showError: true)) {
      return const CustomHttpResult(
        ok: false,
        status_code: -1,
        error: 'No internet! Please check your internet connection.',
      );
    }
    late String url;

    try {
      final resolved_headers = await _build_headers(
        need_auth: need_auth,
        extra: headers,
      );
      if (resolved_headers == null) {
        return const CustomHttpResult(
          ok: false,
          status_code: 401,
          error: 'Session expired. Please log in again.',
        );
      }

      final prefix = add_api_prefix ? '/api' : '';
      url = _build_url('${AppCredentials.domain}$prefix$endpoint', queries);

      // Log Request
      HttpLogger.logRequest(
        method: method.name.toUpperCase(),
        url: url,
        headers: resolved_headers,
        body: body,
      );

      final encoded_body = jsonEncode(body ?? {});
      late http.Response response;

      switch (method) {
        case _HttpMethod.post:
          response = await http.post(
            Uri.parse(url),
            body: encoded_body,
            headers: resolved_headers,
          );
          break;
        case _HttpMethod.put:
          response = await http.put(
            Uri.parse(url),
            body: encoded_body,
            headers: resolved_headers,
          );
          break;
        case _HttpMethod.patch:
          response = await http.patch(
            Uri.parse(url),
            body: encoded_body,
            headers: resolved_headers,
          );
          break;
        case _HttpMethod.delete:
          response = await http.delete(
            Uri.parse(url),
            body: encoded_body,
            headers: resolved_headers,
          );
          break;
      }

      return await _handle_response(
        response,
        show_floating_error,
        // This tells the handler: "If you fail with 401, run this '_send_with_body' again"
        retryAction: need_auth
            ? () => _send_with_body(
                method: method,
                endpoint: endpoint,
                add_api_prefix: add_api_prefix,
                headers: headers,
                body: body,
                show_floating_error: show_floating_error,
                need_auth: need_auth,
                queries: queries,
              )
            : null,
      );
    } catch (e, stackTrace) {
      _log_error(method.name.toUpperCase(), url, e, stackTrace);

      return CustomHttpResult(status_code: -2, error: e.toString(), ok: false);
    }
  }

  static Future<Map<String, String>?> _build_headers({
    required bool need_auth,
    Map<String, String>? extra,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (need_auth) {
      String? access_token = await LocalStorage.access_token.get();

      // If token is missing, try to refresh immediately
      if (access_token == null || access_token.isEmpty) {
        bool success = await Get.find<AuthController>().refreshToken();
        if (!success) return null;
        access_token = await LocalStorage.access_token.get();
      }

      headers['Authorization'] = 'Bearer $access_token';
    }

    if (extra != null) headers.addAll(extra);
    return headers;
  }

  static Future<bool> _refresh_access_token() async {
    // ... (Keep your existing token refresh logic)
    return true; // Simplified for length
  }

  static String _build_url(String base, Map<String, dynamic>? queries) {
    if (queries == null || queries.isEmpty) return base;
    final buffer = StringBuffer('$base?');
    queries.forEach((key, value) => buffer.write('$key=$value&'));
    return buffer.toString().substring(0, buffer.length - 1);
  }

  static Future<CustomHttpResult> _handle_response(
    http.Response response,
    bool show_error, {
    Future<CustomHttpResult> Function()? retryAction,
  }) async {
    // IF UNAUTHORIZED
    if (response.statusCode == 401 && retryAction != null) {
      print("🚩 401 Unauthorized! Refreshing token...");

      final success = await Get.find<AuthController>().refreshToken();

      if (success) {
        print("✅ Refresh successful! Retrying request...");
        return await retryAction();
      }
    }
    final method = response.request?.method ?? 'UNKNOWN';
    final url = response.request?.url.toString() ?? 'UNKNOWN';

    dynamic data;
    try {
      data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      data = response.body;
    }

    // Call Response Logger
    HttpLogger.logResponse(
      method: method,
      url: url,
      statusCode: response.statusCode,
      body: data,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return CustomHttpResult(
        ok: true,
        status_code: response.statusCode,
        data: data,
      );
    }

    final message = _parse_error_message(response);
    if (show_error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          AppSnackbar.show(message: message, type: SnackType.info);
        } catch (e) {
          debugPrint("Snacko Error in CustomHttp: $e");
        }
      });
    }

    return CustomHttpResult(
      status_code: response.statusCode,
      error: message,
      ok: false,
    );
  }

  static String _parse_error_message(http.Response response) {
    try {
      return jsonDecode(response.body)['message'] ?? 'Error';
    } catch (_) {
      return 'Error';
    }
  }

  static void _log_error(
    String method,
    String url,
    Object error,
    StackTrace stackTrace,
  ) {
    HttpLogger.logError(url: url, error: error, stackTrace: stackTrace);
  }
}
