import 'package:flutter/material.dart';

class AnimatedWinnerDialog extends StatefulWidget {
  const AnimatedWinnerDialog({super.key});

  @override
  State<AnimatedWinnerDialog> createState() => _AnimatedWinnerDialogState();
}

class _AnimatedWinnerDialogState extends State<AnimatedWinnerDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        backgroundColor: Colors.green[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text(
            "🎉 Congratulations! 🎉",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        content: const Text(
          "You have won the Bingo game!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}