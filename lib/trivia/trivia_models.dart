/// 📡 NETX Trivia Modülü - Soru Modeli

class TriviaQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctIndex; // 0: A, 1: B, 2: C, 3: D
  final int timeSeconds;
  final String? category; // "Tarih", "Edebiyat", "Coğrafya"
  final int difficulty; // 1: Kolay, 2: Orta, 3: Zor

  TriviaQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.timeSeconds = 10,
    this.category,
    this.difficulty = 1,
  });

  String get correctAnswer => options[correctIndex];

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'timeSeconds': timeSeconds,
    'category': category,
    'difficulty': difficulty,
  };

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) => TriviaQuestion(
    id: json['id'] ?? 0,
    question: json['question'] ?? '',
    options: List<String>.from(json['options'] ?? []),
    correctIndex: json['correctIndex'] ?? 0,
    timeSeconds: json['timeSeconds'] ?? 10,
    category: json['category'],
    difficulty: json['difficulty'] ?? 1,
  );
}

/// Oyun durumu enum'u
enum TriviaGameState {
  lobby,      // Bekleme odası
  countdown,  // 3-2-1 geri sayım
  question,   // Soru aktif
  reveal,     // Cevap açıklama
  finished,   // Yarışma bitti
}

/// Oyuncu durumu
class TriviaPlayer {
  final String odgrenciId;
  final String name;
  final int score;
  final bool isEliminated;
  final int correctCount;

  TriviaPlayer({
    required this.odgrenciId,
    required this.name,
    this.score = 0,
    this.isEliminated = false,
    this.correctCount = 0,
  });

  TriviaPlayer copyWith({
    int? score,
    bool? isEliminated,
    int? correctCount,
  }) {
    return TriviaPlayer(
      odgrenciId: odgrenciId,
      name: name,
      score: score ?? this.score,
      isEliminated: isEliminated ?? this.isEliminated,
      correctCount: correctCount ?? this.correctCount,
    );
  }
}
