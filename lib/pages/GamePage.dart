import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart'; // Replace audioplayers
import 'package:offlinebingo/config/card_pattern.dart';
import 'package:offlinebingo/pages/GamePage/ChackPage.dart';

import 'package:offlinebingo/providers/game_provider.dart';
import 'package:offlinebingo/widgets/_patternShowPage.dart';
import 'package:offlinebingo/widgets/_widgetBingoGrid.dart' show BingoGrid;
import 'package:offlinebingo/widgets/_widgetWinnerBox.dart';
import 'package:offlinebingo/widgets/_gameSceenAppbarTools.dart';
import 'package:offlinebingo/widgets/_patternGrid.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BingoHomePage extends StatefulWidget {
  final List<int> selectedNumbers;
  final int amount;
  final int cutAmountPercent;

  const BingoHomePage({
    super.key,
    required this.selectedNumbers,
    required this.amount,
    required this.cutAmountPercent,
  });

  @override
  State<BingoHomePage> createState() => _BingoHomePageState();
}

class _BingoHomePageState extends State<BingoHomePage> {
  List<int> generatedNumbers = [];
  List<int> allNumbers = List.generate(75, (i) => i + 1)..shuffle();
  Timer? _timer;
  bool isPaused = true;
  bool isMuted = false;
  bool _isLoading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool hasStarted = false;

  final TextEditingController _cardNumberController = TextEditingController();
  
  String selectedLanguageCode = 'am';

  final Map<String, String> languageOptions = {
    'en': 'E Voice',
    'am': 'A voice',
    'or': 'R voice',
    'on': 'O voice',
    'ti': 't voice',
    'so': 'F voice',
    'g': 'G Voice',
    'r': 'R Voice',
    'z': 'Z Voice',
  };

  Future<void> _onLanguageSelect() async {
    final newLangCode = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose Language'),
          children: languageOptions.entries.map((entry) {
            return SimpleDialogOption(
              child: Text(entry.value), // Display full language name
              onPressed: () => Navigator.pop(context, entry.key), // Save code
            );
          }).toList(),
        );
      },
    );

    if (newLangCode != null && languageOptions.containsKey(newLangCode)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', newLangCode);
      setState(() {
        selectedLanguageCode = newLangCode;
      });
    }
  }
   Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('selected_language') ?? 'am';
    setState(() {
      selectedLanguageCode = langCode;
    });
  }
  
  void _openSelectedNumbersPage({int? openCardNumber}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectedNumbersPage(
          selectedNumbers: widget.selectedNumbers,
          cards: cards,
          generatedNumbers: generatedNumbers,
          // openCardNumber: openCardNumber,
        ),
      ),
    );
  }

  void togglePauseResume() async {
    setState(() {
      isPaused = !isPaused;
    });

    if (isPaused) {
      // Stop any sound currently playing immediately
      await _audioPlayer.stop();
    } else {
      // Resume number generation when unpaused
      startGenerating();
    }
  }

  void startGenerating() async {
    setState(() {
      isPaused = false;
      hasStarted = true; // Disable "Start" button
    });

    while (allNumbers.isNotEmpty && !isPaused) {
      final number = allNumbers.removeAt(0);

      setState(() {
        generatedNumbers.add(number);
      });

      await playBingoSound(number);

      if (isPaused) break;

      await Future.delayed(const Duration(milliseconds: 300));
      if (isPaused) break;
    }

    // Game has ended
    if (!isPaused && allNumbers.isEmpty) {
      setState(() {
        hasStarted = false; // Re-enable "Start" button
      });
    }
  }

  void stopGenerating() {
    setState(() {
      isPaused = true;
      generatedNumbers = [];
      allNumbers = List.generate(75, (i) => i + 1)..shuffle();
    });
    _timer?.cancel();
    _audioPlayer.stop();
  }

  @override
  void dispose() {
    stopGenerating();
    _audioPlayer.dispose(); // Just_audio disposal
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // startGenerating();
    _loadLanguage();
  }

  
  String getBingoPrefix(int number) {
    if (number >= 1 && number <= 15) return 'b';
    if (number >= 16 && number <= 30) return 'i';
    if (number >= 31 && number <= 45) return 'n';
    if (number >= 46 && number <= 60) return 'g';
    if (number >= 61 && number <= 75) return 'o';
    return '';
  }

  String getSoundPath(int number, String langCode) {
    String prefix = getBingoPrefix(number);
    if (prefix.isEmpty) return '';

    langCode = langCode.toLowerCase();

    switch (langCode) {
      case 'am': // Amharic → amvoice/amB10.mp3
        return 'assets/sounds/amvoice/am${prefix}${number}.mp3';

      case 'or': // Oromo → orvoice/orb10.mp3
        return 'assets/sounds/orvoice/or${prefix}${number}.mp3';

      case 'ti': // Tigrigna → tvoice/tb10.mp3
        return 'assets/sounds/tvoice/t${prefix}${number}.mp3';

      case 'so': // Somali → svoice/sb10.m4a
        return 'assets/sounds/svoice/s${prefix}${number}.m4a';

      case 'on': // Oromo new? → onvoice/b10.ogg
        return 'assets/sounds/onvoice/${prefix}${number}.ogg';

      case 'g': // G voice → gvoice/B10.mp3
        return 'assets/sounds/gvoice/${prefix.toUpperCase()}${number}.mp3';

      case 'r': // rvoice → rvoice/rb10.mp3 (assuming similar structure)
        return 'assets/sounds/rvoice/r${prefix}${number}.mp3';

      case 'z': // zvoice → zvoice/zb10.mp3 (assuming)
        return 'assets/sounds/zvoice/z${prefix}${number}.mp3';

      case 'en': // English → fnVoice/B-10.mp3
      default:
        return 'assets/sounds/fnVoice/${prefix.toUpperCase()}-${number}.mp3';
    }
  }

  Future<void> playBingoSound(int number) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedLang =
        prefs.getString('selected_language')?.toLowerCase() ?? 'en';

    final file = getSoundPath(number, selectedLang);

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(file);
      await _audioPlayer.setVolume(isMuted ? 0.0 : 1.0);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing sound for $selectedLang → $file: $e');
    }
  }

  List<List<int>> convertCardToGridReversed(Map<String, dynamic> card) {
    return List.generate(5, (index) {
      // index goes from 0 to 4, corresponding to the rows in your original grid
      return [
        card['b${index + 1}'],
        card['i${index + 1}'],
        card['n${index + 1}'],
        card['g${index + 1}'],
        card['o${index + 1}'],
      ];
    });
  }

  bool _isPortable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text("ቢንጎ ጨዋታ", style: TextStyle(color: Colors.white)),
        actions: [
           Text(languageOptions[selectedLanguageCode] ?? 'English',),
           SizedBox(width: 10,),
          IconButton(
            icon: Icon(
              _isPortable ? Icons.screen_rotation : Icons.screen_lock_rotation,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isPortable = !_isPortable;
              });
            },
            tooltip: 'Toggle Portable Mode',
          ),
           IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              setState(() {
             _onLanguageSelect();
              });
            },
            tooltip: 'choose language',
          ),
          
        ],
      ),

      body: _isPortable == false
          ? Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TopControlsBar(
                        isPaused: isPaused,
                        isMuted: isMuted,
                        isLoading: _isLoading,
                        controller: _cardNumberController,
                        togglePauseResume: togglePauseResume,
                        toggleMute: () {
                          setState(() {
                            isMuted = !isMuted;
                          });
                          _audioPlayer.setVolume(isMuted ? 0.0 : 1.0);
                        },
                      

                        onSearch: _openSelectedNumbersPage,
                      ),

                      const SizedBox(height: 5),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,

                          children: [
                            // BINGO GRID LEFT SIDE
                            Expanded(
                              flex: 3,
                              child: Container(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: BingoGrid(
                                        selectedNumbers: generatedNumbers,
                                        isPortrait:
                                            MediaQuery.of(
                                              context,
                                            ).orientation ==
                                            Orientation.portrait,
                                        useRowLayout: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),
                            // RIGHT PANEL (Latest Number & Winner Section)
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // CALLED NUMBER BOX
                                  Container(
                                    width: 150,
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey[800],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.amberAccent.withOpacity(
                                          0.6,
                                        ),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          " Latest Number",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Center(
                                          child: Text(
                                            generatedNumbers.isNotEmpty
                                                ? "${getBingoPrefix(generatedNumbers.last).toUpperCase()} ${generatedNumbers.last}"
                                                : "--",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey[800],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.pink.withOpacity(0.6),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: WinnerBox(
                                      selectedNumbers: widget.selectedNumbers,
                                      amount: widget.amount,
                                      cutAmountPercent: widget.cutAmountPercent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  ),
              ],
            )
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Column(
                    children: [
                      TopControlsBar(
                        isPaused: isPaused,
                        isMuted: isMuted,
                        isLoading: _isLoading,
                        controller: _cardNumberController,
                        togglePauseResume: togglePauseResume,
                        toggleMute: () {
                          setState(() {
                            isMuted = !isMuted;
                          });
                          _audioPlayer.setVolume(isMuted ? 0.0 : 1.0);
                        },

                        onSearch: _openSelectedNumbersPage,
                      ),

                      const SizedBox(height: 8),

                      /// Top Row: Winner + Latest Number
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Winner Box
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[800],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.amberAccent.withOpacity(0.6),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: WinnerBox(
                                  selectedNumbers: widget.selectedNumbers,
                                  amount: widget.amount,
                                  cutAmountPercent: widget.cutAmountPercent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Latest Number Box
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[800],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.amberAccent.withOpacity(0.6),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "🎯 Latest Number",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      generatedNumbers.isNotEmpty
                                          ? "${getBingoPrefix(generatedNumbers.last).toUpperCase()} ${generatedNumbers.last}"
                                          : "--",
                                      style: const TextStyle(
                                        color: Colors.amberAccent,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// BingoGrid full width below
                      Expanded(
                        child: BingoGrid(
                          selectedNumbers: generatedNumbers,
                          isPortrait:
                              MediaQuery.of(context).orientation ==
                              Orientation.portrait,
                          useRowLayout: true, // ✅ Using row layout
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  ),
              ],
            ),
    );
  }
}
