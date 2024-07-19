
// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../screens/constant.dart';

class ApiService {
  static Future<List<dynamic>> fetchAdmins() async {
    final response = await http.get(Uri.parse('${BASE_URL}/admins'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load admins');
    }
  }
}
