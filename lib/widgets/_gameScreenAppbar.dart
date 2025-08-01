import 'package:flutter/material.dart';

PreferredSizeWidget buildCustomAppBar() {
  return AppBar(
    foregroundColor: Colors.white,
    title: const Text("ቢንጎ ጨዋታ", style: TextStyle(color: Colors.white)),
    backgroundColor: const Color(0xFF1E1E2E),
    elevation: 2,
  );
}