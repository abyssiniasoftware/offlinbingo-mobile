import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _userToken;
  String? _userEmail;

  String? get user => _userEmail;
  bool get isLoggedIn => _userToken != null;

  Future<String?> login(String username, String password) async {
    final result = await ApiService.login(username, password);

    print("login result: ${jsonEncode(result)}");

    if (result.containsKey('token')) {
      _userToken = result['token'];
      _userEmail = username;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("_username", username);
      await prefs.setString("_password", password);
      await prefs.setString('uname', username);
      await prefs.setString('token', result['token']);
      await prefs.setString('username', username!);
      await prefs.setString('role', result['role'] ?? '');
      await prefs.setString('userId', result['id'] ?? '');
      await prefs.setString('houseId', result['houseId'] ?? '');
      // await prefs.setInt('package', (result['package'] ?? 0).toInt());
      await prefs.setDouble(
        'package',
        (result['package'] is int)
            ? (result['package'] as int).toDouble()
            : (result['package'] ?? 0.0) as double,
      );


      notifyListeners();
      return null; // success
    } else {
      return "Login failed: ${result['message'] ?? 'Unknown error'}";
    }
  }

  Future<void> getBingoCardsOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final email = prefs.getString('email');

    if (token != null && email != null) {
      try {
        // Get userId (you may already have it or extract from login result)
        final userId = await getUserIdFromToken(
          token,
        ); // implement this if needed
        // final cards = await ApiService.fetchBingoCards(token, userId!);

        // Do something with cards
        // print("Fetched cards: $cards");
      } catch (e) {
        print("Error fetching cards: $e");
      }
    }
  }

  String? getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = jsonDecode(payload);
      return data['id']?.toString(); // adjust key based on your token payload
    } catch (_) {
      return null;
    }
  }

  Future<void> reserveCard(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final result = await ApiService.postReservedCard(token, payload);
      print("Reservation result: $result");
    }
  }

  void logout() async {
    _userToken = null;
    _userEmail = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _userToken = prefs.getString('token');
    _userEmail = prefs.getString('username');
    await prefs.setString('username', _userEmail ?? "");

    print("Auto login user: $_userEmail, token: $_userToken");
    print(
      "Role: ${prefs.getString('role')}, House ID: ${prefs.getString('houseId')}",
    );

    notifyListeners();
  }

  Future<void> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString("_username");
    final savedPassword = prefs.getString("_password");

    if (savedUsername != null && savedPassword != null) {
      // Try login again
      await login(savedUsername, savedPassword);
    }
  }
}