// Helper: get pattern lines by pattern name, from your BingoPatterns config
  import 'package:offlinebingo/config/wining_pattern.dart';

List<List<String>>? GetPatternLinesByName(String name) {
    switch (name) {
      case "Rows":
        return BingoPatterns.row;
      case "Columns":
        return BingoPatterns.column;
      case "Diagonals":
        return BingoPatterns.diagonal;
      case "Four Corners":
        return BingoPatterns.fourCorners;
      case "One Line":
        return BingoPatterns.oneLine;
      case "Inner Corners":
        return BingoPatterns.innerCorners;
      case "Inner or Four Corners":
        return BingoPatterns.innerOrFourCorners;
      case "L Pattern":
        return BingoPatterns.lPattern;
      case "Reverse L":
        return BingoPatterns.reverseL;
      case "T Pattern":
        return BingoPatterns.tPattern;
      case "Reverse T":
        return BingoPatterns.reverseT;
      case "Plus":
        return BingoPatterns.plus;
      case "Square":
        return BingoPatterns.square;
      case "X Pattern":
        return BingoPatterns.xPattern;
      case "U Pattern":
        return BingoPatterns.uPattern;
      case "Cross":
        return BingoPatterns.cross;
      case "Diamond":
        return BingoPatterns.diamond;
      case "Postage Stamp":
        return BingoPatterns.postageStamp;
      case "Big Diamond":
        return BingoPatterns.bigDiamond;
      case "Letter H":
        return BingoPatterns.letterH;
      case "Letter C":
        return BingoPatterns.letterC;
      case "Letter E":
        return BingoPatterns.letterE;
      case "Smiley Face":
        return BingoPatterns.smileyFace;
      case "Triangle":
        return BingoPatterns.triangle;
      case "Zigzag":
        return BingoPatterns.zigzag;
      case "Crescent":
        return BingoPatterns.crescent;
      case "Lightning Bolt":
        return BingoPatterns.lightningBolt;
      case "Any Two Line":
        return BingoPatterns.anyTwoLine;
      default:
        return null;
    }
  }
