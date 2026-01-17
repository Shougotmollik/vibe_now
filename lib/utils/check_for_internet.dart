part of '../utils.dart';

Future<bool> hasInternet({bool showError = false}) async {
  final List<ConnectivityResult> connectivityResult = await (Connectivity()
      .checkConnectivity());
  if (connectivityResult.contains(ConnectivityResult.none)) {
    if (showError) {
      debugPrint('No Internet Connection');
    }

    return false;
  } else {
    return true;
  }
}
