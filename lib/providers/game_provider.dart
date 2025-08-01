import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class GameProvider extends ChangeNotifier {
  Future<bool> createGame({
    required int stakeAmount,
    required int numberOfPlayers,
    required int cutAmountPercent,
    required int cartela,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');
    final houseId = prefs.getString('houseId');
    if (userId == null || token == null) {
      return false;
    }
    final random = Random();
    final gameId = (random.nextInt(100) + 1).toString();

    final url = Uri.parse('https://vpsdomain.katbingo.net/api/game/create');

    final body = jsonEncode({
      'houseId': houseId,
      'userId': userId,
      'stakeAmount': stakeAmount,
      'numberOfPlayers': numberOfPlayers,
      'cutAmountPercent': cutAmountPercent,
      'cartela': 1,
      'gameId': 5,
    });
    print("body_"+body);

    try {
      debugPrint(" Sending POST request to: $url");
      debugPrint(" Request body: $body");

      final response = await http.post(
        url,
        headers: {'x-auth-token': token, 'Content-Type': 'application/json'},
        body: body,
      );
      debugPrint("✅ Status Code: ${response.statusCode}");
      debugPrint("📨 Response Body: ${response.body}");

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("❌ Exception during game creation: $e");
      return false;
    }
  }
}