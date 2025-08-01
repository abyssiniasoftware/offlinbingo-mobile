 String getLangWinnerSoundPath(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'am':
        return 'assets/sounds/amvoice/amwinner.mp3';
      case 'or':
        return 'assets/sounds/orvoice/orwinner.mp3';
      case 'ti':
        return 'assets/sounds/tvoice/tvwinner.mp3';
      case 'so':
        return 'assets/sounds/svoice/swinner.mp3';
      case 'on':
        return 'assets/sounds/onvoice/winner.ogg';
      case 'g':
        return 'assets/sounds/gvoice/winner.mp3';
      case 'r':
        return 'assets/sounds/rvoice/winner.mp3';
      case 'z':
        return 'assets/sounds/zvoice/winner.mp3';
      case 'en':
      default:
        return 'assets/sounds/fnVoice/win.mp3';
    }
  }

  String getLangLoseSoundPath(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'am':
        return 'assets/sounds/amvoice/not-win.wav';
      case 'or':
        return 'assets/sounds/orvoice/not-win.wav';
      case 'ti':
        return 'assets/sounds/tvoice/not-win.mp3';
      case 'so':
        return 'assets/sounds/svoice/not-win.mp3';
      case 'on':
        return 'assets/sounds/onvoice/not-win.mp3';
      case 'g':
        return 'assets/sounds/gvoice/not-win.mp3';
      case 'r':
        return 'assets/sounds/rvoice/not-win.mp3';
      case 'z':
        return 'assets/sounds/zvoice/not-win.mp3';
      case 'en':
      default:
        return 'assets/sounds/fnVoice/no-win.mp3';
    }
  }
