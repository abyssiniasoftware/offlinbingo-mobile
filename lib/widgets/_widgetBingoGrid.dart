// import 'package:flutter/material.dart';

// class BingoGrid extends StatelessWidget {
//   final List<int> selectedNumbers;
//   final bool useRowLayout;
//   final bool isPortrait;

//   const BingoGrid({
//     super.key,
//     required this.selectedNumbers,
//     required this.useRowLayout,
//     required this.isPortrait,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final List<List<String>> data = _generateBingoData();

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         Widget bingoContent;

//         if (useRowLayout) {
//           /// === ROW-BASED ===
//           bingoContent = Column(
//             children: List.generate(5, (row) {
//               return Row(
//                 children: List.generate(16, (col) {
//                   if (col == 0) {
//                     // BINGO label on left
//                     return Container(
//                       width: 24,
//                       height: 24,
//                       alignment: Alignment.center,
//                       margin: const EdgeInsets.all(1),
//                       decoration: BoxDecoration(
//                         color: const Color.fromARGB(255, 33, 47, 87),
//                         borderRadius: BorderRadius.circular(3),
//                       ),
//                       child: Text(
//                         "BINGO"[row],
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: Colors.white,
//                         ),
//                       ),
//                     );
//                   }

//                   final number = int.parse(data[row][col - 1]);
//                   final isSelected = selectedNumbers.contains(number);

//                   return Container(
//                     width: 24,
//                     height: 24,
//                     alignment: Alignment.center,
//                     margin: const EdgeInsets.all(1),
//                     decoration: BoxDecoration(
//                       color: isSelected ? Colors.green : Colors.grey[850],
//                       borderRadius: BorderRadius.circular(3),
//                       border: Border.all(color: Colors.white24),
//                     ),
//                     child: Text(
//                       number.toString(),
//                       style: const TextStyle(fontSize: 10, color: Colors.white),
//                     ),
//                   );
//                 }),
//               );
//             }),
//           );
//         } else {
//           /// === COLUMN-BASED ===
//           final header = _buildBingoHeader();

//           final grid = _buildColumnBingoGrid(data);

//           bingoContent = isPortrait
//               ? Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [header, const SizedBox(height: 4), grid],
//                 )
//               : Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     RotatedBox(quarterTurns: 3, child: header),
//                     const SizedBox(width: 8),
//                     grid,
//                   ],
//                 );
//         }

//         return SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             margin: const EdgeInsets.all(1),
//             child: bingoContent,
//           ),
//         );
//       },
//     );
//   }

//   /// Column-based BINGO header
//   Widget _buildBingoHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: List.generate(5, (col) {
//         return Container(
//           width: 30,
//           height: 30,
//           margin: const EdgeInsets.all(1),
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: Colors.blueGrey[700],
//             borderRadius: BorderRadius.circular(4),
//           ),
//           child: Text(
//             "BINGO"[col],
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//               color: Colors.white,
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   /// Column layout for BINGO grid
//   Widget _buildColumnBingoGrid(List<List<String>> data) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(5, (col) {
//         return Column(
//           children: List.generate(15, (row) {
//             final number = int.parse(data[col][row]);
//             final isSelected = selectedNumbers.contains(number);

//             return Container(
//               width: 30,
//               height: 30,
//               margin: const EdgeInsets.all(1),
//               alignment: Alignment.center,

//               decoration: BoxDecoration(
//                 color: isSelected ? Colors.green : Colors.grey[850],
//                 borderRadius: BorderRadius.circular(4),
//                 border: Border.all(color: const Color.fromARGB(60, 70, 51, 51)),
//               ),
//               child: Text(
//                 number.toString(),
//                 style: const TextStyle(fontSize: 12, color: Colors.white),
//               ),
//             );
//           }),
//         );
//       }),
//     );
//   }

//   /// Row layout style data: 5 rows, 15 columns
//   List<List<String>> _generateBingoData() {
//     List<List<String>> data = [];

//     for (int row = 0; row < 5; row++) {
//       List<String> rowData = [];
//       int start = row * 15 + 1;
//       for (int i = 0; i < 15; i++) {
//         rowData.add('${start + i}');
//       }
//       data.add(rowData);
//     }

//     return data;
//   }
// }

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class BingoGrid extends StatefulWidget {
  final List<int> selectedNumbers;
  final bool useRowLayout;
  final bool isPortrait;
  final bool isShuffling;

  const BingoGrid({
    super.key,
    required this.selectedNumbers,
    required this.useRowLayout,
    required this.isPortrait,
    required this.isShuffling,
  });

  @override
  State<BingoGrid> createState() => _BingoGridState();
}

class _BingoGridState extends State<BingoGrid> {
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

  Map<int, Color> animatedColors = {};
  Timer? _shuffleTimer;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    if (widget.isShuffling) {
      _startShufflingAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant BingoGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShuffling && !_isAnimating) {
      _startShufflingAnimation();
    }
  }

  void _startShufflingAnimation() {
    _isAnimating = true;
    const duration = Duration(seconds: 3);
    const tick = Duration(milliseconds: 200);
    final random = Random();

    _shuffleTimer = Timer.periodic(tick, (timer) {
      setState(() {
        animatedColors = {
          for (var i = 1; i <= 75; i++)
            i: shuffleColors[random.nextInt(shuffleColors.length)],
        };
      });
    });

    Future.delayed(duration, () {
      _shuffleTimer?.cancel();
      setState(() {
        _isAnimating = false;
      });
    });
  }

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    super.dispose();
  }

  Color _getColor(int number) {
    if (_isAnimating && widget.isShuffling) {
      return animatedColors[number] ?? Colors.grey[800]!;
    }
    return widget.selectedNumbers.contains(number)
        ? Colors.green
        : Colors.grey[850]!;
  }

  @override
  Widget build(BuildContext context) {
    final List<List<String>> data = _generateBingoData();

    return LayoutBuilder(
      builder: (context, constraints) {
        Widget bingoContent;

        if (widget.useRowLayout) {
          bingoContent = Column(
            children: List.generate(5, (row) {
              return Row(
                children: List.generate(16, (col) {
                  if (col == 0) {
                    return _buildHeaderCell("BINGO"[row]);
                  }
                  final number = int.parse(data[row][col - 1]);
                  return _buildNumberCell(number);
                }),
              );
            }),
          );
        } else {
          final header = _buildBingoHeader();
          final grid = _buildColumnBingoGrid(data);

          bingoContent = widget.isPortrait
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [header, const SizedBox(height: 4), grid],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RotatedBox(quarterTurns: 3, child: header),
                    const SizedBox(width: 8),
                    grid,
                  ],
                );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(1),
            child: bingoContent,
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String letter) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 33, 47, 87),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNumberCell(int number) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: _getColor(number),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        number.toString(),
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
    );
  }

  Widget _buildBingoHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(5, (col) {
        return Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.all(1),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blueGrey[700],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "BINGO"[col],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildColumnBingoGrid(List<List<String>> data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (col) {
        return Column(
          children: List.generate(15, (row) {
            final number = int.parse(data[col][row]);
            return Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.all(1),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _getColor(number),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color.fromARGB(60, 70, 51, 51)),
              ),
              child: Text(
                number.toString(),
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            );
          }),
        );
      }),
    );
  }

  List<List<String>> _generateBingoData() {
    List<List<String>> data = [];
    for (int row = 0; row < 5; row++) {
      List<String> rowData = [];
      int start = row * 15 + 1;
      for (int i = 0; i < 15; i++) {
        rowData.add('${start + i}');
      }
      data.add(rowData);
    }
    return data;
  }
}
