List<List<int>> convertCardToGridReversed(Map<String, dynamic> card) {
  return List.generate(5, (index) {
    // index goes from 0 to 4, corresponding to the rows in your original grid
    return [
      card['b${index + 1}'],
      card['i${index + 1}'],
      card['n${index + 1}'],
      card['g${index + 1}'],
      card['o${index + 1}'],
    ];
  });
}
