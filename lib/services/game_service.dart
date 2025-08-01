import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GameService {
  static const String _baseUrl = 'https://vpsdomain.katbingo.net/api';

  static Future<bool> createGame({
    required int stakeAmount,
    required int numberOfPlayers,
    required int cutAmountPercent,
    required int cartela,
    String gameId = "01",
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');
    final houseId = prefs.getString('houseId');

    if (userId == null || token == null) return false;

    final url = Uri.parse('$_baseUrl/game/create');
    final body = jsonEncode({
      'houseId': houseId,
      'userId': userId,
      'stakeAmount': stakeAmount,
      'numberOfPlayers': numberOfPlayers,
      'cutAmountPercent': cutAmountPercent,
      'cartela': cartela,
      'gameId': gameId,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Failed to create game: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating game: $e');
      return false;
    }
  }
}
