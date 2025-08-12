import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class GameProvider extends ChangeNotifier {
  List<int> _cardNumbers = []; // Store card numbers here
  List<int> get cardNumbers => _cardNumbers;

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
    print("body_" + body);

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

  Future<void> fetchCardNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString("userId");

    if (token == null || userId == null) {
      debugPrint("⚠️ Token or UserID missing");
      return;
    }

    final url = Uri.parse(
      'https://vpsdomain.katbingo.net/api/bingo-card/$userId/card-ids',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token, // ✅ token in the headers now
        },
      );

      debugPrint("📨 Card ID fetch status: ${response.statusCode}");
      debugPrint("📥 Response: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _cardNumbers.clear();
        notifyListeners();
        _cardNumbers = data.map((e) => int.parse(e.toString())).toSet().toList()
          ..sort(); // This will remove duplicates

        notifyListeners();
      } else {
        debugPrint("❌ Failed to load cards: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error getting card IDs: $e");
    }
  }

  Map<String, dynamic> currentCard = {};
  Future<void> fetchCardById(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString("userId");

    if (token == null || userId == null) {
      debugPrint("⚠️ Token or UserID missing");
      return;
    }

    final url = Uri.parse(
      'https://vpsdomain.katbingo.net/api/bingo-card/$userId/$cardId',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      debugPrint("📨 Fetch card by ID status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        currentCard = data;
        print("currentcard" + currentCard.toString());
        notifyListeners();
      } else {
        currentCard = {};
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Error fetching card by ID: $e");
      currentCard = {};
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> fetchUserBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');
    double package = prefs.getDouble('package') ?? 0.0;

    if (token == null || userId == null) {
      debugPrint("⚠️ Token or UserID missing");
      return null;
    }

    final url = Uri.parse(
      'https://backend2.katbingo.net/api/user/user-balance',
    );

    final body = jsonEncode({'userId': userId, 'balance': package});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: body,
      );

      debugPrint("📨 User balance fetch status: ${response.statusCode}");
      debugPrint("📥 Response: ${response.body}");

      if (response.statusCode == 200) {
        print("resposnse" + response.body);
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Check if balance exists and update package in prefs
        if (data.containsKey('balance')) {
          final newBalance = (data['balance'] is int)
              ? (data['balance'] as int).toDouble()
              : (data['balance'] is double)
              ? data['balance']
              : 0.0;

          if (newBalance != package) {
            await prefs.setDouble('package', newBalance);
            debugPrint("✅ Package balance updated to $newBalance");
          }
        }

        return data;
      } else {
        debugPrint("❌ Failed to fetch user balance: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Error fetching user balance: $e");
      return null;
    }
  }
}
