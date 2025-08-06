import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart'; // Replace audioplayers
import 'package:offlinebingo/config/card_pattern.dart';
import 'package:offlinebingo/config/languageLists.dart';
import 'package:offlinebingo/pages/GamePage/ChackPage.dart';
import 'package:offlinebingo/pages/GamePage/ShaffleBingoGridPage.dart';

import 'package:offlinebingo/providers/game_provider.dart';
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
  double _playbackSpeed = 1.0;

  bool isshuffled = false;

  final TextEditingController _cardNumberController = TextEditingController();

  String selectedLanguageCode = 'am';
  // Add this field in your _BingoHomePageState:
  double _drawIntervalSeconds = 2;

  Future<void> playBingoSound(int number) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedLang =
        prefs.getString('selected_language')?.toLowerCase() ?? 'en';
    final file = getSoundPath(number, selectedLang);

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(file);
      await _audioPlayer.setVolume(isMuted ? 0.0 : 1.0);
      await _audioPlayer.setSpeed(_playbackSpeed); // Set the playback speed
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing sound for $selectedLang → $file: $e');
    }
  }

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

  void _onShufflePage() {
    setState(() {
      isshuffled = !isshuffled;
    });
  }

  // void togglePauseResume() async {
  //   setState(() {
  //     isPaused = !isPaused;
  //   });

  //   if (isPaused) {
  //     // Stop any sound currently playing immediately
  //     await _audioPlayer.stop();
  //   } else {
  //     // Resume number generation when unpaused
  //     startGenerating();
  //   }
  // }

  final AudioPlayer _sfxPlayer = AudioPlayer(); // Add this near _audioPlayer

  void togglePauseResume() async {
    setState(() {
      isPaused = !isPaused;
    });

    if (isPaused) {
      // 🔇 Stop number audio immediately
      await _audioPlayer.stop();

      // 🔊 Play stop sound
      try {
        await _sfxPlayer.setAsset('assets/sounds/tvoice/tstop.mp3');
        await _sfxPlayer.setVolume(isMuted ? 0.0 : 1.0);
        await _sfxPlayer.play();
      } catch (e) {
        print('Error playing stop sound: $e');
      }
    } else {
      // 🔊 Play start sound
      try {
        await _sfxPlayer.setAsset('assets/sounds/tvoice/tstart.wav');
        await _sfxPlayer.setVolume(isMuted ? 0.0 : 1.0);
        await _sfxPlayer.play();
      } catch (e) {
        print('Error playing start sound: $e');
      }

      // ▶️ Resume generation
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

      // Support decimal durations (e.g., 3.5 seconds = 3500 ms)
      final durationInMilliseconds = (_drawIntervalSeconds * 1000).round();
      await Future.delayed(Duration(milliseconds: durationInMilliseconds));

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

  void handleShuffleComplete() {
  setState(() {
    isshuffled = false;
  });
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
        return 'assets/sounds/rvoice/${prefix}${number}.ogg';

      case 'z': // zvoice → zvoice/zb10.mp3 (assuming)
        return 'assets/sounds/zvoice/${prefix}${number}.mp3';

      case 'en': // English → fnVoice/B-10.mp3
      default:
        return 'assets/sounds/fnVoice/${prefix.toUpperCase()}-${number}.mp3';
    }
  }

  Future<void> playBingoSound1(int number) async {
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

  bool _isPortable = false;

  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double tempSpeed = _playbackSpeed; // Use temp to avoid premature apply

        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Playback Speed'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${tempSpeed.toStringAsFixed(1)}x'),
                  Slider(
                    value: tempSpeed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: '${tempSpeed.toStringAsFixed(1)}x',
                    onChanged: (value) {
                      setLocalState(() {
                        tempSpeed = value;
                      });

                      setState(() {
                        _playbackSpeed = value;
                        _audioPlayer.setSpeed(_playbackSpeed);
                      });
                    },
                  ),
                  Text("durations"),
                  Slider(
                    value: _drawIntervalSeconds,
                    min: 0.5,
                    max: 10.0,
                    divisions: 19, // for 0.5 step increments
                    label: '${_drawIntervalSeconds.toStringAsFixed(1)} seconds',
                    onChanged: (value) {
                      setState(() {
                        _drawIntervalSeconds = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text("Katbingo", style: TextStyle(color: Colors.white)),
        actions: [
          Text(languageOptions[selectedLanguageCode] ?? 'English'),
          SizedBox(width: 10),
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
          IconButton(
            icon: const Icon(Icons.speed),
            tooltip: 'Adjust Speed',
            onPressed: _showSpeedDialog,
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
                        onshuffle: _onShufflePage,
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
                                        isShuffling: isshuffled,
                                         onShuffleComplete: handleShuffleComplete,
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
                        onshuffle: _onShufflePage,
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
                          useRowLayout: true, 
                          isShuffling: isshuffled,
                           onShuffleComplete: handleShuffleComplete,
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
