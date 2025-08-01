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
  int currentPatternIndex = 0;

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


  late final List<Map<String, dynamic>> patterns = bingoPatternMap.entries.map((
    entry,
  ) {
    final name = entry.key;
    final lines = entry.value;

    final positions = lines
        .expand((line) => line.map(cellIdToGridPos))
        .where((pos) => pos[0] != -1)
        .toList();

    return {"name": name, "positions": positions};
  }).toList();

  Future<void> _loadSelectedPattern() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPattern = prefs.getString('selectedPattern');
    if (savedPattern != null) {
      final index = patterns.indexWhere(
        (pattern) => pattern['name'] == savedPattern,
      );
      if (index != -1) {
        setState(() {
          currentPatternIndex = index;
        });
      }
    }
  }

  Future<void> _saveSelectedPattern(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedPattern', patterns[index]['name']);
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedPattern();
  }

  @override
  Widget build(BuildContext context) {
    final currentPattern = patterns[currentPatternIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Select Patterns"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Card(
              color: Colors.blueGrey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.grid_on, color: Colors.white70),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: currentPatternIndex,
                          dropdownColor: Colors.blueGrey[900],
                          iconEnabledColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          items: List.generate(
                            patterns.length,
                            (index) => DropdownMenuItem<int>(
                              value: index,
                              child: Text(patterns[index]["name"]),
                            ),
                          ),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                currentPatternIndex = val;
                              });
                              _saveSelectedPattern(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
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
            ),
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
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

                    bool isActive = currentPattern["positions"].any(
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
              ),
            ),
            const SizedBox(height: 20),
            
            Card(
              color: Colors.blueGrey.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 1,
              shadowColor: Colors.tealAccent.withOpacity(0.4),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await _saveSelectedPattern(currentPatternIndex);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Pattern selected successfully"),
                      backgroundColor: Colors.teal,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Colors.teal, Colors.tealAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
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
            ),
          ],
        ),
      ),
    );
  }
}