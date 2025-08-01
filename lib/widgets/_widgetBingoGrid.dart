import 'package:flutter/material.dart';

class BingoGrid extends StatelessWidget {
  final List<int> selectedNumbers;
  final bool useRowLayout; // 🔁 switch between row or column
  final bool isPortrait;

  const BingoGrid({
    super.key,
    required this.selectedNumbers,
    required this.useRowLayout,
    required this.isPortrait,
  });

  @override
  Widget build(BuildContext context) {
    final List<List<String>> data = _generateBingoData();

    return LayoutBuilder(
      builder: (context, constraints) {
        Widget bingoContent;

        if (useRowLayout) {
          /// === ROW-BASED ===
          bingoContent = Column(
            children: List.generate(5, (row) {
              return Row(
                children: List.generate(16, (col) {
                  if (col == 0) {
                    // BINGO label on left
                    return Container(
                      width: 24,
                      height: 30,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 33, 47, 87),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        "BINGO"[row],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  final number = int.parse(data[row][col - 1]);
                  final isSelected = selectedNumbers.contains(number);

                  return Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.grey[850],
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      number.toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  );
                }),
              );
            }),
          );
        } else {
          /// === COLUMN-BASED ===
          final header = _buildBingoHeader();

          final grid = _buildColumnBingoGrid(data);

          bingoContent = isPortrait
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

  /// Column-based BINGO header
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

  /// Column layout for BINGO grid
  Widget _buildColumnBingoGrid(List<List<String>> data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (col) {
        return Column(
          children: List.generate(15, (row) {
            final number = int.parse(data[col][row]);
            final isSelected = selectedNumbers.contains(number);

            return Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.all(1),
              alignment: Alignment.center,

              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.grey[850],
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

  /// Row layout style data: 5 rows, 15 columns
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
