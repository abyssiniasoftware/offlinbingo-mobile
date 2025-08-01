offline bingo game powerd by Abbisniya soft

offline_bingo_game/
│
├── assets/
│   ├── images/
│   │   └── logo.png
│   └── sounds/
│       ├── call.mp3
│       └── win.mp3
|       |__ numbers
│
├── lib/
│   ├── main.dart
│   ├── app.dart                     # App entry point with routing & theming
│
│   ├── config/
│   │   └── constants.dart           # Game constants like max number, grid size
│
│   ├── models/
│   │   └── bingo_number.dart        # Data model for a bingo number
│   │   └── player.dart              # (if multiplayer, track players or game state)
│
│   ├── pages/
│   │   ├── home_page.dart
│   │   ├── game_page.dart
│   │   └── settings_page.dart
│
│   ├── widgets/
│   │   ├── bingo_grid.dart          # Grid of numbers
│   │   ├── number_tile.dart         # Each number box/tile
│   │   ├── control_panel.dart       # Buttons: Start, Reset, Auto/Manual
│   │   └── number_history.dart      # Shows previously called numbers
│
│   ├── providers/
│   │   └── game_provider.dart       # Using ChangeNotifier or Riverpod for state
│
│   ├── utils/
│   │   ├── number_generator.dart    # Random logic without repeats
│   │   └── game_checker.dart        # Check winning patterns
│
│   └── theme/
│       └── app_theme.dart           # Light/Dark theme config
│
├── test/
│   ├── widget_test.dart
│   └── game_logic_test.dart
│
├── pubspec.yaml
├── README.md
└── .gitignore
# offlineBingo
# offlinbingo-mobile
