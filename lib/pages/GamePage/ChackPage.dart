import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:offlinebingo/config/wining_pattern.dart';
import 'package:offlinebingo/utils/_convertCardToGride.dart';
import 'package:offlinebingo/utils/_getPatternLinesByName.dart';
import 'package:offlinebingo/utils/_getLangLoseandwinSoundPath.dart';
import 'package:offlinebingo/widgets/_patternGrid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedNumbersPage extends StatefulWidget {
  final List<int> selectedNumbers;
  final List<Map<String, dynamic>> cards;
  final List<int> generatedNumbers;

  const SelectedNumbersPage({
    super.key,
    required this.selectedNumbers,
    required this.cards,
    required this.generatedNumbers,
  });

  @override
  State<SelectedNumbersPage> createState() => _SelectedNumbersPageState();
}

class _SelectedNumbersPageState extends State<SelectedNumbersPage> {
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Map<String, dynamic>? _foundCard;
  String? _winningPatternName;
  int? _lastSearchedId;
  List<String> _blacklist = [];
  bool _isBlacklisted = false;

  // Get the saved pattern name from SharedPreferences
  Future<String?> _getSavedPatternName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedPattern');
  }

  // Load blacklist from SharedPreferences
  Future<void> _loadBlacklist() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _blacklist = prefs.getStringList("blacklisted_card_ids") ?? [];
    });
  }

  bool isPatternCompleted(List<String> pattern, Map<String, dynamic> card) {
    for (final cell in pattern) {
      // Skip the FREE center space
      if (cell == "n3") continue;

      final number = card[cell];
      if (number == null || !widget.generatedNumbers.contains(number)) {
        return false;
      }
    }
    return true;
  }

  Future<void> searchCard1(String input) async {
    final id = int.tryParse(input);
    if (id == null || id == _lastSearchedId) return;
    _lastSearchedId = id;

    // Check blacklist first
    if (!_blacklist.contains(input)) {
      setState(() {
        _foundCard = null;
        _winningPatternName = null;
        _isBlacklisted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚫 This card is blacklisted due to previous loss."),
        ),
      );
      return;
    } else {
      _isBlacklisted = false;
    }

    if (!widget.selectedNumbers.contains(id)) {
      setState(() {
        _foundCard = null;
        _winningPatternName = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Card number not found.")));
      return;
    }

    final card = widget.cards.firstWhere(
      (c) => c['cardId'] == id,
      orElse: () => {},
    );

    if (card.isEmpty) {
      setState(() {
        _foundCard = null;
        _winningPatternName = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Card data not found.")));
      return;
    }

    final savedPatternName = await _getSavedPatternName();

    if (savedPatternName == null) {
      setState(() {
        _foundCard = card;
        _winningPatternName = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No saved pattern found.")));
      return;
    }

    final patternLines = GetPatternLinesByName(savedPatternName);

    if (patternLines == null) {
      setState(() {
        _foundCard = card;
        _winningPatternName = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Saved pattern '$savedPatternName' not recognized."),
        ),
      );
      return;
    }

    bool isWinner = false;
    for (final line in patternLines) {
      if (isPatternCompleted(line, card)) {
        isWinner = true;
        break;
      }
    }

    setState(() {
      _foundCard = card;
      _winningPatternName = isWinner ? savedPatternName : null;
    });

    final prefs = await SharedPreferences.getInstance();
    final selectedLang =
        prefs.getString('selected_language')?.toLowerCase() ?? 'on';

    final sound = isWinner
        ? getLangWinnerSoundPath(selectedLang)
        : getLangLoseSoundPath(selectedLang);

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(sound);
      _audioPlayer.play();
    } catch (e) {
      debugPrint("Audio error: $e");
    }

    // If not winner, add to blacklist SharedPreferences
    if (!isWinner) {
      if (!_blacklist.contains(input)) {
        _blacklist.add(input);
        await prefs.setStringList("blacklisted_card_ids", _blacklist);
      }
      setState(() {
        _isBlacklisted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(" Not a winner. Added to blacklist.")),
      );
    } else {
      setState(() {
        _isBlacklisted = false;
      });
    }
  }

  Future<void> searchCard(String input) async {
    final id = int.tryParse(input);
    if (id == null || id == _lastSearchedId) return;
    _lastSearchedId = id;

    final prefs = await SharedPreferences.getInstance();
    _blacklist = prefs.getStringList("blacklisted_card_ids") ?? [];

    if (_blacklist.contains(input)) {
      setState(() {
        _foundCard = null;
        _winningPatternName = null;
        _isBlacklisted = true;
      });
      return;
    } else {
      setState(() {
        _isBlacklisted = false;
      });
    }
    // Check if card exists in selectedNumbers
    if (!widget.selectedNumbers.contains(id)) {
      setState(() {
        _foundCard = null;
        _winningPatternName = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Card number not found.")));
      return;
    }

    final card = widget.cards.firstWhere(
      (c) => c['cardId'] == id,
      orElse: () => {},
    );

    if (card.isEmpty) {
      setState(() {
        _foundCard = null;
        _winningPatternName = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Card data not found.")));
      return;
    }

    final savedPatternName = await _getSavedPatternName();
    if (savedPatternName == null) {
      setState(() {
        _foundCard = card;
        _winningPatternName = null;
      });
      return;
    }

    final patternLines = GetPatternLinesByName(savedPatternName);
    if (patternLines == null) {
      setState(() {
        _foundCard = card;
        _winningPatternName = null;
      });
      return;
    }

    // Check winning condition
    bool isWinner = false;
    for (final line in patternLines) {
      if (isPatternCompleted(line, card)) {
        isWinner = true;
        break;
      }
    }

    setState(() {
      _foundCard = card;
      _winningPatternName = isWinner ? savedPatternName : null;
    });

    // Play sound
    final selectedLang =
        prefs.getString('selected_language')?.toLowerCase() ?? 'on';
    final sound = isWinner
        ? getLangWinnerSoundPath(selectedLang)
        : getLangLoseSoundPath(selectedLang);

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(sound);
      _audioPlayer.play();
    } catch (e) {
      debugPrint("Audio error: $e");
    }

    // If not winner, add to blacklist AFTER showing once
    if (!isWinner) {
      _blacklist.add(input);
      await prefs.setStringList("blacklisted_card_ids", _blacklist);
    }

    _isBlacklisted = false; // because we're still showing this attempt
  }

  String? _savedPatternName;

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedPattern();
    _loadBlacklist();
  }

  void _loadSavedPattern() async {
    final name = await _getSavedPatternName();
    setState(() {
      _savedPatternName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final grid = _foundCard != null ? convertCardToGrid(_foundCard!) : null;
    final screenWidth = MediaQuery.of(context).size.width;
    final gridWidth = screenWidth * 0.9;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        title: const Text("Search Bingo Card"),
        backgroundColor: const Color(0xFF1E1E2E),
        foregroundColor: Colors.amberAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      _savedPatternName != null
                          ? Icons.check_circle
                          : Icons.warning_amber_rounded,
                      color: _savedPatternName != null
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _savedPatternName != null
                            ? "  Pattern Name: $_savedPatternName"
                            : "❗ No Pattern Selected",
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextField(
              controller: _controller,
              onChanged: searchCard,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "🔍 Enter Card ID",
                labelStyle: const TextStyle(color: Colors.amberAccent),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Show blacklist message if blacklisted
            if (_isBlacklisted)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.2),
                  border: Border.all(color: Colors.redAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      color: Colors.redAccent,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "This card is blocked",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        List<String> blacklist =
                            prefs.getStringList("blacklisted_card_ids") ?? [];

                        final inputId = _controller.text.trim();
                        if (blacklist.contains(inputId)) {
                          blacklist.remove(inputId);
                          await prefs.setStringList(
                            "blacklisted_card_ids",
                            blacklist,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Card #$inputId removed from blacklist.",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );

                          setState(() {
                            _isBlacklisted = false;
                            _blacklist = blacklist;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Remove from Blacklist",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_foundCard != null && grid != null)
              Container(
                width: gridWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    PatternGrid(
                      pattern: grid,
                      generatedNumbers: widget.generatedNumbers,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _winningPatternName != null
                          ? " Winner - Pattern type\n$_winningPatternName"
                          : "No Winner",
                      style: TextStyle(
                        fontSize: 18,
                        color: _winningPatternName != null
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final inputId = _controller.text.trim();
                        if (inputId.isEmpty) return;

                        final prefs = await SharedPreferences.getInstance();
                        List<String> blacklist =
                            prefs.getStringList("blacklisted_card_ids") ?? [];

                        if (!blacklist.contains(inputId)) {
                          blacklist.add(inputId);
                          await prefs.setStringList(
                            "blacklisted_card_ids",
                            blacklist,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Card #$inputId added to blacklist.",
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );

                          setState(() {
                            _isBlacklisted = true;
                            _blacklist = blacklist;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Card is already in blacklist."),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.block, color: Colors.white),
                      label: const Text(
                        "Add to Blacklist",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
