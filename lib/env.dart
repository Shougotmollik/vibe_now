import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvHandler {
  EnvHandler._();

  static String google_map_api_key = dotenv.env['MAP_API_KEY']!;
}
