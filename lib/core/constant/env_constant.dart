import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConstant {
  static String mapApiKey = dotenv.env['MAP_API_KEY']!;
}
