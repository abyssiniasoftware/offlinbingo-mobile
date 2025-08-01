import 'dart:math';
import 'package:flutter/material.dart';

class BingoShuffleGridPage extends StatefulWidget {
  const BingoShuffleGridPage({super.key});

  @override
  State<BingoShuffleGridPage> createState() => _BingoShuffleGridPageState();
}

class _BingoShuffleGridPageState extends State<BingoShuffleGridPage> {
  late List<List<int>> _bingoGrid;
  final List<String> _bingoLetters = ['B', 'I', 'N', 'G', 'O'];
  bool _useRowLayout = false;
  bool _isPortrait = true;
  final Set<int> _selectedNumbers = {};

  @override
  void initState() {
    super.initState();
    _generateInitialGrid();
  }

  void _generateInitialGrid() {
    final grid = [
      List.generate(5, (i) => i + 1),      // B: 1–5
      List.generate(5, (i) => i + 16),     // I: 16–20
      List.generate(5, (i) => i + 31),     // N: 31–35
      List.generate(5, (i) => i + 46),     // G: 46–50
      List.generate(5, (i) => i + 61),     // O: 61–65
    ];
    grid[2][2] = 0; // 🎉 Free space in center

    setState(() {
      _bingoGrid = grid;
      _selectedNumbers.clear();
    });
  }

  Future<void> _shuffleGridWithDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    _shuffleGrid();
  }

  void _shuffleGrid() {
    final random = Random();
    final List<List<int>> grid = [];

    final ranges = [
      List.generate(15, (i) => i + 1),    // B
      List.generate(15, (i) => i + 16),   // I
      List.generate(15, (i) => i + 31),   // N
      List.generate(15, (i) => i + 46),   // G
      List.generate(15, (i) => i + 61),   // O
    ];

    for (int col = 0; col < 5; col++) {
      ranges[col].shuffle(random);
      grid.add(ranges[col].take(5).toList());
    }

    grid[2][2] = 0;

    setState(() {
      _bingoGrid = grid;
      _selectedNumbers.clear();
    });
  }

  void _toggleLayout() {
    setState(() {
      _useRowLayout = !_useRowLayout;
    });
  }

  void _toggleSelection(int number) {
    if (number == 0) return;
    setState(() {
      _selectedNumbers.contains(number)
          ? _selectedNumbers.remove(number)
          : _selectedNumbers.add(number);
    });
  }

  @override
  Widget build(BuildContext context) {
    _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎱 BINGO Grid'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _shuffleGridWithDelay,
          ),
          IconButton(
            icon: Icon(_useRowLayout ? Icons.view_column : Icons.view_stream),
            onPressed: _toggleLayout,
          ),
        ],
      ),
      body: Center(
        child: _useRowLayout
            ? _buildRowLayout()
            : _buildColumnLayout(),
      ),
    );
  }

  Widget _buildColumnLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _bingoLetters.map((letter) {
            return Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blueGrey[800],
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (col) {
            return Column(
              children: List.generate(5, (row) {
                final number = _bingoGrid[col][row];
                final isSelected = _selectedNumbers.contains(number);
                return GestureDetector(
                  onTap: () => _toggleSelection(number),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: number == 0
                          ? Colors.amber
                          : isSelected
                              ? Colors.green
                              : Colors.grey[800],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      number == 0 ? '🎉' : number.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRowLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (col) {
            final number = _bingoGrid[col][row];
            final isSelected = _selectedNumbers.contains(number);
            return GestureDetector(
              onTap: () => _toggleSelection(number),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 50,
                height: 50,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: number == 0
                      ? Colors.amber
                      : isSelected
                          ? Colors.green
                          : Colors.grey[800],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24),
                ),
                alignment: Alignment.center,
                child: Text(
                  number == 0 ? '🎉' : number.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
