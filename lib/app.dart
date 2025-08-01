import 'package:flutter/material.dart';
import 'package:offlinebingo/pages/Autho/login_page.dart';
import 'package:offlinebingo/pages/HomePage.dart';
import 'package:offlinebingo/providers/autho_provider.dart';
import 'package:offlinebingo/theme/app_theme.dart';
import 'package:provider/provider.dart';

class BingoApp extends StatefulWidget {
  const BingoApp({super.key});

  @override
  State<BingoApp> createState() => _BingoAppState();
}

class _BingoAppState extends State<BingoApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.tryAutoLogin();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Offline Bingo Game - Powered by Abbisniya Soft',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isLoggedIn ? NumberSelectionScreen() :  LoginScreen();
        },
      ),
      routes: {
        '/game': (context) => NumberSelectionScreen(),
      },
    );
  }
}
