import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class TemplateLoader {
  static Future<Map<String, dynamic>> loadJson(String path) async {
    final data = await rootBundle.loadString(path);
    return json.decode(data);
  }
}
