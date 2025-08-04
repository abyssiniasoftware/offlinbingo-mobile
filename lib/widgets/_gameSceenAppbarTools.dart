import 'package:flutter/material.dart';
import 'package:offlinebingo/pages/GamePage/PatternShowPage.dart';
import 'package:offlinebingo/pages/GamePage/ShaffleBingoGridPage.dart';


class TopControlsBar extends StatelessWidget {
  final bool isPaused;
  final bool isMuted;
  final bool isLoading;
  final TextEditingController controller;
  final VoidCallback togglePauseResume;
  final VoidCallback toggleMute;

  final void Function({int? openCardNumber}) onSearch;

  const TopControlsBar({
    super.key,
    required this.isPaused,
    required this.isMuted,
    required this.isLoading,
    required this.controller,
    required this.togglePauseResume,
    required this.toggleMute,

    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int buttonCount = 4;
    final double buttonWidth =
        screenWidth / buttonCount - 20; // -20 for padding/gap

    return Container(
      width: screenWidth,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _iconTextButton(
            icon: isPaused ? Icons.play_circle : Icons.pause_circle,
            label: isPaused ? "Start" : "Stop",
            color: Colors.amber,
            onPressed: togglePauseResume,
            width: buttonWidth,
          ),
          _iconTextButton(
            icon: isMuted ? Icons.volume_off : Icons.volume_up,
            label: isMuted ? "Muted" : "Sound",
            color: Colors.cyanAccent,
            onPressed: toggleMute,
            width: buttonWidth,
          ),
          _iconTextButton(
            icon: Icons.pattern,
            label: "Pattern",
            color: Colors.deepOrangeAccent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PatternShowPage()),
              );
            },
            width: buttonWidth,
          ),
          _iconTextButton(
            icon: Icons.shuffle,
            label: "shuffle",
            color: Colors.deepOrangeAccent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BingoShufflePage(
                    useRowLayout: true,
                    isPortrait: true,
                  ),
                ),
              );
            },
            width: buttonWidth,
          ),
          _iconTextButton(
            icon: Icons.search,
            label: "Check",
            color: Colors.deepPurpleAccent,
            onPressed: () {
              if (!isPaused) togglePauseResume();
              final input = controller.text.trim();
              final number = int.tryParse(input);
              controller.clear();
              onSearch(openCardNumber: number);
            },
            width: buttonWidth,
          ),
        ],
      ),
    );
  }

  Widget _iconTextButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: color, size: 26),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
