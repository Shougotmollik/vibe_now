class AppCredentials {
  AppCredentials._();

  static const String domain = "http://10.10.12.62:7006";

  static String fixurl(String? path) {
    if (path == null || path.isEmpty) return '';

    // avoid double slashes
    if (path.startsWith('http')) return path;

    return '$domain$path';
  }
}
