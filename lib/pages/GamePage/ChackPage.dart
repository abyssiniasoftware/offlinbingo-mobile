import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:offlinebingo/config/wining_pattern.dart';
import 'package:offlinebingo/utils/_convertCardToGride.dart';
import 'package:offlinebingo/utils/_getPatternLinesByName.dart';
import 'package:offlinebingo/utils/_getLangLoseandwinSoundPath.dart';
import 'package:offlinebingo/widgets/_animatedWinnerDialog.dart';
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

  // Get the saved pattern name from SharedPreferences
  Future<String?> _getSavedPatternName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedPattern'); // FIXED KEY!
  }

  bool isPatternCompleted(List<String> pattern, Map<String, dynamic> card) {
   
    for (final cell in pattern) {
      final number = card[cell];
      if (number == null || !widget.generatedNumbers.contains(number)) {
        return false;
      }
    }
    return true;
  }


 
  Future<void> searchCard(String input) async {
    final id = int.tryParse(input);
    if (id == null || id == _lastSearchedId) return;
    _lastSearchedId = id;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(" No saved pattern found.")),
      );
      return;
    }

    // Get the pattern lines for the saved pattern
    final patternLines = GetPatternLinesByName(savedPatternName);
    String? _savedPatternName; // ✅ <-- Add this
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
  }

 
  String? _savedPatternName; // ✅ <-- Add this

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getSavedPatternName();
    _loadSavedPattern();
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
                            ? "  Pattern Name: ${_savedPatternName!}"
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
            if (_foundCard != null && grid != null)
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
                          ? " Winner - Pattern type\n${_winningPatternName!}"
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
