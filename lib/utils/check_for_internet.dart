import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';

Future<bool> hasInternet({bool showError = false}) async {
  final List<ConnectivityResult> connectivityResult = await Connectivity()
      .checkConnectivity();

  if (connectivityResult.contains(ConnectivityResult.none)) {
    if (showError) _showError();

    return false;
  }

  try {
    final result = await InternetAddress.lookup(
      'google.com',
    ).timeout(const Duration(seconds: 5));

    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    if (showError) _showError();

    return false;
  } on TimeoutException catch (_) {
    if (showError) _showError();

    return false;
  }

  if (showError) _showError();

  return false;
}

void _showError() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      AppSnackbar.show(
        message:
            "Failed to establish connection, please check your internet connection",
        type: SnackType.info,
      );
    } catch (e) {
      debugPrint("Snacko Error in hasInternet: $e");
    }
  });
}
