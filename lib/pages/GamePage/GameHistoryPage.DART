import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameHistoryPage extends StatefulWidget {
  const GameHistoryPage({Key? key}) : super(key: key);

  @override
  State<GameHistoryPage> createState() => _GameHistoryPageState();
}

class _GameHistoryPageState extends State<GameHistoryPage> {
  List<Map<String, dynamic>> _gameHistory = [];

  @override
  void initState() {
    super.initState();
    _loadGameHistory();
  }

  Future<void> _loadGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList("gameHistory") ?? [];

    // Decode each JSON string into a Map
    final decodedHistory = historyList.map((entry) {
  try {
    return Map<String, dynamic>.from(jsonDecode(entry) as Map);
  } catch (e) {
    return <String, dynamic>{};
  }
}).where((element) => element.isNotEmpty).toList();


    setState(() {
      _gameHistory = decodedHistory;
    });
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game History"),
      ),
      body: _gameHistory.isEmpty
          ? const Center(
              child: Text("No game history found."),
            )
          : ListView.separated(
              itemCount: _gameHistory.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final game = _gameHistory[index];

                final stakeAmount = game["stakeAmount"] ?? "N/A";
                final numberOfPlayers = game["numberOfPlayers"] ?? "N/A";
                final cutAmountPercent = game["cutAmountPercent"] ?? "N/A";
                final dateTime = game["dateTime"] ?? "";
                final balance = game["balance"] ?? "N/A";

                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(
                      "Stake: $stakeAmount | Players: $numberOfPlayers | Cut: $cutAmountPercent%"),
                  subtitle: Text("Played at: ${_formatDate(dateTime)}\nBalance: $balance"),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}
