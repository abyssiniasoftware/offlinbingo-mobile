// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';

// class BingoShufflePage extends StatefulWidget {
//   final bool useRowLayout;
//   final bool isPortrait;

//   const BingoShufflePage({
//     super.key,
//     required this.useRowLayout,
//     required this.isPortrait,
//   });

//   @override
//   State<BingoShufflePage> createState() => _BingoShufflePageState();
// }

// class _BingoShufflePageState extends State<BingoShufflePage> {
//   List<int> gridNumbers = [];
//   int shuffleTicks = 0;
//   final int totalShuffleTicks = 30;
//   Timer? _shuffleTimer;
//   bool isShuffling = true;

//   @override
//   void initState() {
//     super.initState();
//     _startShuffling();
//   }

//   void _startShuffling() {
//     setState(() {
//       isShuffling = true;
//       shuffleTicks = 0;
//       gridNumbers = List.generate(75, (i) => i + 1);
//     });

//     _shuffleTimer?.cancel(); // cancel any previous timer

//     _shuffleTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//       setState(() {
//         gridNumbers.shuffle();
//         shuffleTicks++;
//       });

//       if (shuffleTicks >= totalShuffleTicks) {
//         timer.cancel();
//         setState(() {
//           isShuffling = false;
//           gridNumbers = _generateBingoOrderedList();
//         });
//       }
//     });
//   }

//   List<int> _generateBingoOrderedList() {
//     return List<int>.generate(75, (index) => index + 1);
//   }

//   @override
//   void dispose() {
//     _shuffleTimer?.cancel();
//     Navigator.pop(context);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1E1E2E),

//       body: Center(
//         child: BingoGridshuffle(
//           numbers: gridNumbers,
//           useRowLayout: widget.useRowLayout,
//           isPortrait: widget.isPortrait,
//           isShuffling: isShuffling,
//         ),
//       ),
//     );
//   }
// }

// // ======= BingoGrid Widget Here ==========
// class BingoGridshuffle extends StatelessWidget {
//   final List<int> numbers;
//   final bool useRowLayout;
//   final bool isPortrait;
//   final bool isShuffling;

//   BingoGridshuffle({
//     super.key,
//     required this.numbers,
//     required this.useRowLayout,
//     required this.isPortrait,
//     required this.isShuffling,
//   });

//   final List<Color> shuffleColors = [
//     Colors.redAccent,
//     Colors.blueAccent,
//     Colors.greenAccent,
//     Colors.orangeAccent,
//     Colors.purpleAccent,
//     Colors.tealAccent,
//     Colors.yellowAccent,
//     Colors.pinkAccent,
//     Colors.cyanAccent,
//   ];

//   Color _getColumnColor(int col) {
//     switch (col) {
//       case 0:
//         return Colors.orange; // B
//       case 1:
//         return Colors.orange; // I
//       case 2:
//         return Colors.orange; // N
//       case 3:
//         return Colors.orange; // G
//       case 4:
//         return Colors.orange; // O
//       default:
//         return Colors.orange;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Prepare 5 columns of 15 items each:
//     List<List<int>> columns = List.generate(5, (_) => []);

//     for (int i = 0; i < 75; i++) {
//       int colIndex = i ~/ 15; // 0..4
//       columns[colIndex].add(numbers[i]);
//     }

//     Widget buildHeader() {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: "BINGO".split("").map((letter) {
//           return Container(
//             width: 40,
//             height: 40,
//             alignment: Alignment.center,
//             margin: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               color: Colors.blueGrey[700],
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Text(
//               letter,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 24,
//                 color: Colors.white,
//               ),
//             ),
//           );
//         }).toList(),
//       );
//     }

//     Widget buildGrid() {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: List.generate(5, (col) {
//           Color colColor = _getColumnColor(col);
//           final random = Random();

//           return Column(
//             children: List.generate(15, (row) {
//               final number = columns[col][row];

//               // Pick random shuffle color if shuffling, else column color
//               Color bgColor = isShuffling
//                   ? shuffleColors[random.nextInt(shuffleColors.length)]
//                   : colColor.withOpacity(0.8);

//               return Container(
//                 width: 40,
//                 height: 40,
//                 alignment: Alignment.center,
//                 margin: const EdgeInsets.all(3),
//                 decoration: BoxDecoration(
//                   color: bgColor,
//                   borderRadius: BorderRadius.circular(6),
//                   border: Border.all(color: Colors.white24),
//                 ),
//                 child: Text(
//                   number.toString(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               );
//             }),
//           );
//         }),
//       );
//     }

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [buildHeader(), const SizedBox(height: 8), buildGrid()],
//     );
//   }
// }
// 📦 This is now a widget (not a full page)


import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class BingoShuffleWidget extends StatefulWidget {
  final bool useRowLayout;
  final bool isPortrait;

  const BingoShuffleWidget({
    super.key,
    required this.useRowLayout,
    required this.isPortrait,
  });

  @override
  State<BingoShuffleWidget> createState() => _BingoShuffleWidgetState();
}

class _BingoShuffleWidgetState extends State<BingoShuffleWidget> {
  List<int> gridNumbers = [];
  int shuffleTicks = 0;
  final int totalShuffleTicks = 30;
  Timer? _shuffleTimer;
  bool isShuffling = true;

  @override
  void initState() {
    super.initState();
    _startShuffling();
  }

  void _startShuffling() {
    setState(() {
      isShuffling = true;
      shuffleTicks = 0;
      gridNumbers = List.generate(75, (i) => i + 1);
    });

    _shuffleTimer?.cancel();
    _shuffleTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        gridNumbers.shuffle();
        shuffleTicks++;
      });

      if (shuffleTicks >= totalShuffleTicks) {
        timer.cancel();
        setState(() {
          isShuffling = false;
          gridNumbers = _generateBingoOrderedList();
        });
      }
    });
  }

  List<int> _generateBingoOrderedList() {
    return List<int>.generate(75, (index) => index + 1);
  }

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BingoGridshuffle(
        numbers: gridNumbers,
        useRowLayout: widget.useRowLayout,
        isPortrait: widget.isPortrait,
        isShuffling: isShuffling,
      ),
    );
  }
}

class BingoGridshuffle extends StatelessWidget {
  final List<int> numbers;
  final bool useRowLayout;
  final bool isPortrait;
  final bool isShuffling;

  const BingoGridshuffle({
    super.key,
    required this.numbers,
    required this.useRowLayout,
    required this.isPortrait,
    required this.isShuffling,
  });

  final List<Color> shuffleColors = const [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.yellowAccent,
    Colors.pinkAccent,
    Colors.cyanAccent,
  ];

  Color _getColumnColor(int col) {
    return Colors.orange; // Simplified for now
  }

  @override
  Widget build(BuildContext context) {
    List<List<int>> columns = List.generate(5, (_) => []);
    for (int i = 0; i < 75; i++) {
      int colIndex = i ~/ 15;
      columns[colIndex].add(numbers[i]);
    }

    Widget buildHeader() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: "BINGO".split("").map((letter) {
          return Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blueGrey[700],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              letter,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          );
        }).toList(),
      );
    }

    Widget buildGrid() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (col) {
          Color colColor = _getColumnColor(col);
          final random = Random();

          return Column(
            children: List.generate(15, (row) {
              final number = columns[col][row];
              Color bgColor = isShuffling
                  ? shuffleColors[random.nextInt(shuffleColors.length)]
                  : colColor.withOpacity(0.8);

              return Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          );
        }),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [buildHeader(), const SizedBox(height: 8), buildGrid()],
    );
  }
}