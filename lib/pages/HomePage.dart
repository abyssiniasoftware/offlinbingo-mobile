import 'package:flutter/material.dart';
import 'package:offlinebingo/pages/GamePage.dart';
import 'package:offlinebingo/providers/autho_provider.dart';
import 'package:offlinebingo/providers/game_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NumberSelectionScreen extends StatefulWidget {
  @override
  _NumberSelectionScreenState createState() => _NumberSelectionScreenState();
}

class _NumberSelectionScreenState extends State<NumberSelectionScreen> {
  int betAmount = 20;
  List<int> selectedNumbers = [];
  String cutAmountPercent = '10%';

  String username = '';
  double balance = 0.0;
  bool _isLoading = false;

  final TextEditingController cartelaController = TextEditingController();
  String? takenNumberMessage;

  void toggleNumber(int number) {
    setState(() {
      if (selectedNumbers.contains(number)) {
        selectedNumbers.remove(number);
      } else {
        selectedNumbers.add(number);
      }
    });
  }

  void checkCartelaID(String value) {
    final enteredNumber = int.tryParse(value.trim());
    if (enteredNumber == null || enteredNumber < 1 || enteredNumber > 80) {
      setState(() {
        takenNumberMessage = null;
      });
      return;
    }

    if (selectedNumbers.contains(enteredNumber)) {
      setState(() {
        takenNumberMessage = " Number $enteredNumber is already selected.";
      });
    } else {
      setState(() {
        takenNumberMessage = " Number $enteredNumber is available.";
      });
    }
  }

  void startGame() async {
    if (selectedNumbers.isEmpty) {
      // Optional: show error if no numbers selected
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Error", style: TextStyle(color: Colors.white)),
          content: const Text(
            "Please select at least one number.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.amber)),
            ),
          ],
        ),
      );
      return;
    }

    final cutAmount = int.tryParse(cutAmountPercent.replaceAll('%', '')) ?? 10;

    setState(() {
      _isLoading =
          true; // You will need to add this boolean in your State class
    });

    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    bool result = false;
    try {
      result = await gameProvider.createGame(
        stakeAmount: betAmount,
        numberOfPlayers: selectedNumbers.length,
        cutAmountPercent: cutAmount,
        cartela: selectedNumbers.length,
      );
    } catch (e) {
      print("Error creating game: $e");
    }

    setState(() {
      _isLoading = false;
    });

    if (result) {
      _loadBalance();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      double currentBalance = prefs.getDouble('package') ?? 0.0;
      double newBalance = currentBalance - betAmount.toDouble();

      // Prevent negative balance (optional)
      if (newBalance < 0) newBalance = 0;

      await prefs.setDouble('package', newBalance);
      // Navigate to BingoHomePage only on success
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BingoHomePage(
            selectedNumbers: selectedNumbers,
            amount: betAmount,
            cutAmountPercent: cutAmount,
          ),
        ),
      );
    } else {
      // Show error dialog on failure
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("❌ Failed", style: TextStyle(color: Colors.white)),
          content: const Text(
            "Failed to create game. Please try again.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.amber)),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    cartelaController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _loadLanguage();
  }

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

  Future<void> _selectLanguage() async {
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

  void _loadBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double package = prefs.getDouble('package') ?? 0.0;
    String usernameNEW = prefs.getString("uname") ?? "";

    setState(() {
      balance = package;
      username = usernameNEW;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2E),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: AppBar(
          backgroundColor: const Color(0xFF1E1E2E),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            side: BorderSide(color: Colors.white10, width: 1),
          ),
          flexibleSpace: Padding(
            // padding: const EdgeInsets.all() ,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Control buttons
                Row(
                  children: [
                    _buildSmallButton(
                      label: 'Start',
                      color: Colors.green,
                      onPressed: startGame,
                    ),
                    SizedBox(width: 8),
                    _buildSmallButton(
                      label: 'Reset',
                      color: Colors.red,
                      onPressed: () => setState(() => selectedNumbers.clear()),
                    ),
                  ],
                ),


                // Language selector as button
                _buildSmallButton(
                  label: languageOptions[selectedLanguageCode] ?? 'English',
                  color: Colors.blueGrey,
                  icon: Icons.language,
                  onPressed: _selectLanguage,
                ),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          buildTopControls(),
          Card(
            color: const Color(0xFF2C2C3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.amber.withOpacity(0.5), width: 1),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '$username',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Balance: ${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.amber,
                            size: 20,
                          ),
                          tooltip: 'Refresh Balance',
                          onPressed: () async {
                            if (balance > 20.0) {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              await authProvider.autoLogin();
                              _loadBalance();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Balance is sufficient"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: GridView.count(
              padding: EdgeInsets.all(16),
              crossAxisCount: 10,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List.generate(80, (index) {
                int number = index + 1;
                bool isSelected = selectedNumbers.contains(number);
                return GestureDetector(
                  onTap: () => toggleNumber(number),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$number',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                );
              }),
            ),
          ),

          if (takenNumberMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                takenNumberMessage!,
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ),
          if (_isLoading)
            Center(
              child: const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null
          ? Icon(icon, size: 16, color: Colors.white)
          : SizedBox.shrink(),
      label: Text(label, style: TextStyle(fontSize: 12, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  final List<String> percentOptions = [
    '10%',
    '20%',
    '25%',
    '30%',
    '40%',
    '50%',
  ];

  Widget buildTopControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Card(
        color: const Color(0xFF2A2A3D), // Dark card color matching theme
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text('Bet:', style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => setState(() {
                  if (betAmount > 0) betAmount = betAmount - 5;
                }),
                icon: const Icon(Icons.remove, color: Colors.white),
              ),
              Text(
                '$betAmount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  betAmount = betAmount + 5;
                }),
                icon: const Icon(Icons.add, color: Colors.white),
              ),
              const Spacer(),
              DropdownButton<String>(
                dropdownColor: Colors.grey[900],
                value: percentOptions.contains(cutAmountPercent)
                    ? cutAmountPercent
                    : percentOptions[0],
                underline: const SizedBox.shrink(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: percentOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      cutAmountPercent = val;
                    });
                  }
                },
              ),

              const Spacer(),
              SizedBox(
                width: 85,
                child: TextField(
                  controller: cartelaController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  onChanged: checkCartelaID,
                  decoration: const InputDecoration(
                    hintText: 'Cartela ID',
                    hintStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
