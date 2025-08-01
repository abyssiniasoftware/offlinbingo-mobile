 
  List<List<int>> convertCardToGrid(Map<String, dynamic> card) {
    return List.generate(5, (index) {
      return [
        card['b${index + 1}'],
        card['i${index + 1}'],
        card['n${index + 1}'],
        card['g${index + 1}'],
        card['o${index + 1}'],
      ];
    });
  }
