import 'package:flutter/material.dart';

class WinnerBox extends StatelessWidget {
  final List<int> selectedNumbers;
  final int amount;
  final int cutAmountPercent;

  const WinnerBox({
    Key? key,
    required this.selectedNumbers,
    required this.amount,
    required this.cutAmountPercent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int totalSelected = selectedNumbers.length;
    final int winAmount =
        (totalSelected * amount) -
        ((totalSelected * amount * cutAmountPercent) ~/ 100);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 28),
              SizedBox(width: 10),
              Text(
                "Winner",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$winAmount ETB",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.amberAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}