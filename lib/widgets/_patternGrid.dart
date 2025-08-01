import 'package:flutter/material.dart';

class PatternGrid extends StatelessWidget {
  final List<List<int>> pattern;
  final List<int> generatedNumbers;

  const PatternGrid({
    super.key,
    required this.pattern,
    required this.generatedNumbers,
  });

  // bool get isWinner {
  //   for (int i = 0; i < pattern.length; i++) {
  //     for (int j = 0; j < pattern[i].length; j++) {
  //       if (i == 2 && j == 2) continue; // free space
  //       int num = pattern[i][j];
  //       if (num != 0 && !generatedNumbers.contains(num)) {
  //         return false;
  //       }
  //     }
  //   }
  //   return true;
  // }
  bool get isWinner {
  for (int i = 0; i < pattern.length; i++) {
    for (int j = 0; j < pattern[i].length; j++) {
      final number = pattern[i][j];
      final isCenter = (i == 2 && j == 2);

      // Always treat center as matched
      if (isCenter) continue;

      if (number != 0 && !generatedNumbers.contains(number)) {
        return false;
      }
    }
  }
  return true;
}


  // Static method to check if winning pattern
  static bool checkIsWinner(List<List<int>> pattern, List<int> generatedNumbers) {
    for (int i = 0; i < pattern.length; i++) {
      for (int j = 0; j < pattern[i].length; j++) {
        final number = pattern[i][j];
        final isCenter = (i == 2 && j == 2); // free center

        if (isCenter) continue; // free spot always counted as matched

        if (number != 0 && !generatedNumbers.contains(number)) {
          return false;
        }
      }
    }
    return true;
  }


  @override
  Widget build(BuildContext context) {
    final letters = ['B', 'I', 'N', 'G', 'O'];

    return Column(
      children: [
        // Header row with letters inside same-size cells as numbers
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: letters.map((letter) {
            return Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.all(2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.amberAccent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                letter,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,  // matches numbers font size closely
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 8),

        // Number rows
        Column(
          children: List.generate(pattern.length, (i) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pattern[i].length, (j) {
                final number = pattern[i][j];
                final isCenterCell = (i == 2 && j == 2);
                final isMatched = number != 0 && generatedNumbers.contains(number);

                return Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.all(2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: number == 0
                        ? Colors.transparent
                        : (isCenterCell
                            ? Colors.orangeAccent
                            : (isMatched ? Colors.green : Colors.blueGrey[700])),
                    borderRadius: BorderRadius.circular(6),
                    border: number != 0 ? Border.all(color: Colors.white24) : null,
                  ),
                  child: isCenterCell
                      ? const Text(
                          "FREE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        )
                      : (number == 0
                          ? const SizedBox()
                          : Text(
                              "$number",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            )),
                );
              }),
            );
          }),
        ),

        const SizedBox(height: 16),

        if (isWinner)
          const Center(
            child: Text(
              "🎉 won! 🎉",
              style: TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
