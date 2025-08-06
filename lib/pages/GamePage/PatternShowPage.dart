import 'package:flutter/material.dart';
import 'package:offlinebingo/config/wining_pattern.dart';
import 'package:offlinebingo/utils/_bingoPatternMap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatternShowPage extends StatefulWidget {
  const PatternShowPage({super.key});

  @override
  State<PatternShowPage> createState() => _PatternShowPageState();
}

class _PatternShowPageState extends State<PatternShowPage> {
  String? pattern1Name;
  String? pattern2Name;
  String combinationType = 'Single'; 

  final List<String> combinationTypes = ['OR','Single', 'AND'];

  List<int> cellIdToGridPos(String cellId) {
    if (cellId.length != 2) return [-1, -1];
    final colChar = cellId[0].toLowerCase();
    final rowChar = cellId[1];
    const colMap = {'b': 0, 'i': 1, 'n': 2, 'g': 3, 'o': 4};
    if (!colMap.containsKey(colChar)) return [-1, -1];
    final col = colMap[colChar]!;
    final row = int.tryParse(rowChar);
    if (row == null || row < 1 || row > 5) return [-1, -1];
    return [row - 1, col];
  }

  List<String> get allPatternNames => bingoPatternMap.keys.toList();
  List<List<String>> combineOr(List<List<String>> a, List<List<String>> b) {
    final setA = a.expand((line) => line).toSet();
    final setB = b.expand((line) => line).toSet();
    final intersect = setA.intersection(setB).toList();

    // Return as one combined pattern line (list of cell IDs)
    return [intersect];
  }

  List<List<String>> combineAnd(List<List<String>> a, List<List<String>> b) {
    final setA = a.expand((line) => line).toSet();
    final setB = b.expand((line) => line).toSet();
    final union = setA.union(setB).toList();

    // Return as one combined pattern line (list of cell IDs)
    return [union];
  }

  List<List<String>> getSelectedPatternLines() {
    if (combinationType == 'Single' && pattern1Name != null) {
      return bingoPatternMap[pattern1Name!] ?? [];
    } else if (pattern1Name != null && pattern2Name != null) {
      final first = bingoPatternMap[pattern1Name!]!;
      final second = bingoPatternMap[pattern2Name!]!;
      return combinationType == 'OR'
          ? combineOr(first, second)
          : combineAnd(first, second);
    }
    return [];
  }

  List<List<int>> get selectedPositions {
    return getSelectedPatternLines()
        .expand((line) => line.map(cellIdToGridPos))
        .where((pos) => pos[0] != -1)
        .toList();
  }

  Future<void> _saveSelectedPattern() async {
    final prefs = await SharedPreferences.getInstance();
    String patternName;
    if (combinationType == 'Single') {
      patternName = pattern1Name ?? '';
    } else {
      patternName =
          '$combinationType: ${pattern1Name ?? ''} + ${pattern2Name ?? ''}';
    }
    await prefs.setString('selectedPattern', patternName);
  }

  @override
  void initState() {
    super.initState();
    pattern1Name = bingoPatternMap.keys.first;
    pattern2Name = bingoPatternMap.keys.elementAt(1);
  }

  @override
  Widget build(BuildContext context) {
    final positions = selectedPositions;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Select Patterns"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              _buildDropdownCard("Pattern 1", pattern1Name!, (value) {
                setState(() {
                  pattern1Name = value;
                });
              }),
              if (combinationType != 'Single')
                _buildDropdownCard("Pattern 2", pattern2Name!, (value) {
                  setState(() {
                    pattern2Name = value;
                  });
                }),
              _buildDropdownCard("Combination", combinationType, (value) {
                setState(() {
                  combinationType = value;
                });
              }, options: combinationTypes),
              const SizedBox(height: 24),
              _buildBingoHeader(),
              const SizedBox(height: 8),
              _buildGrid(positions),
              const SizedBox(height: 20),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownCard(
    String label,
    String selected,
    Function(String) onChanged, {
    List<String>? options,
  }) {
    return Card(
      color: Colors.blueGrey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.grid_on, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selected,
                  dropdownColor: Colors.blueGrey[900],
                  iconEnabledColor: Colors.white,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  items: (options ?? allPatternNames).map((name) {
                    return DropdownMenuItem(value: name, child: Text(name));
                  }).toList(),
                  onChanged: (val) => onChanged(val!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBingoHeader() {
    return SizedBox(
      width: 320,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: "BINGO".split('').map((letter) {
          return Text(
            letter,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.tealAccent,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black87,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGrid(List<List<int>> positions) {
    return SizedBox(
      width: 320,
      height: 320,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: 25,
        itemBuilder: (context, index) {
          int row = index ~/ 5;
          int col = index % 5;
          int number = 25 - (row * 5 + col);

          bool isActive = positions.any(
            (pos) => pos[0] == row && pos[1] == col,
          );

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isActive ? Colors.greenAccent : Colors.grey[800],
              border: Border.all(color: Colors.white54),
              borderRadius: BorderRadius.circular(10),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.6),
                        spreadRadius: 2,
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                "$number",
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return Card(
      color: Colors.blueGrey.shade700,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      shadowColor: Colors.tealAccent.withOpacity(0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await _saveSelectedPattern();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Pattern selected successfully"),
              backgroundColor: Colors.teal,
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save_alt, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Save Pattern',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black38,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
