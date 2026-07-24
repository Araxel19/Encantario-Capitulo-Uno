enum ChallengeType {
  openQuestion,
  multipleChoice,
  miniGame,
  confession,
}

class DayChallenge {
  final int dayNumber;
  final String title;
  final String prompt;
  final String category; // 'Conexión', 'Reto Especial', 'Minijuego', 'Trivias', 'Confesión'
  final ChallengeType type;
  final bool isMilestone;
  final String? milestoneTitle;
  
  // Opciones para selección múltiple
  final List<String>? options;
  final int? correctOptionIndex;

  // Parámetros para minijuegos
  final String? gameType;

  bool isCompleted;
  String? userAnswer;
  String? imagePath;

  DayChallenge({
    required this.dayNumber,
    required this.title,
    required this.prompt,
    required this.category,
    this.type = ChallengeType.openQuestion,
    this.isMilestone = false,
    this.milestoneTitle,
    this.options,
    this.correctOptionIndex,
    this.gameType,
    this.isCompleted = false,
    this.userAnswer,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'isCompleted': isCompleted,
        'userAnswer': userAnswer,
        'imagePath': imagePath,
      };

  factory DayChallenge.fromJson(Map<String, dynamic> json, DayChallenge base) {
    return DayChallenge(
      dayNumber: base.dayNumber,
      title: base.title,
      prompt: base.prompt,
      category: base.category,
      type: base.type,
      isMilestone: base.isMilestone,
      milestoneTitle: base.milestoneTitle,
      options: base.options,
      correctOptionIndex: base.correctOptionIndex,
      gameType: base.gameType,
      isCompleted: json['isCompleted'] ?? false,
      userAnswer: json['userAnswer'],
      imagePath: json['imagePath'],
    );
  }
}
