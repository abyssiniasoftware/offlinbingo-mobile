import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String baseUrl = "http://vpsdomain.katbingo.net/api";
  static const String baseUrl = "https://vpsdomain.katbingo.net/api/auth/login";

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl");
    final response = await http.post(
      url,
      body: {"username": username, "password": password},
    );

  
    if (response.statusCode == 200) {
      try {

        final data = jsonDecode(response.body);
        print("respsose data"+data.toString());
        return data;
      } catch (e) {
        throw Exception("Failed to parse response JSON: ${response.body}");
      }
    } else {
      throw Exception(
        "Request failed with status: ${response.statusCode}, body: ${response.body}",
      );
    }
  }

  static Future<Map<String, dynamic>> postReservedCard(
    String token,
    Map<String, dynamic> payload,
  ) async {
    final url = Uri.parse("$baseUrl/game/create");
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    return jsonDecode(response.body);
  }
}
