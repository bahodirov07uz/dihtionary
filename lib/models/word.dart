class Word {
  final String id;
  final String word;
  final String meaning;
  final String? example;
  final String? category;
  bool isLearned;
  DateTime? learnedAt;
  int reviewCount;

  Word({
    required this.id,
    required this.word,
    required this.meaning,
    this.example,
    this.category,
    this.isLearned = false,
    this.learnedAt,
    this.reviewCount = 0,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      word: json['word']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? json['manosi']?.toString() ?? '',
      example: json['example']?.toString() ?? json['misol']?.toString(),
      category: json['category']?.toString() ?? json['kategoriya']?.toString(),
      isLearned: json['isLearned'] == true || json['isLearned'] == 'true',
      learnedAt: json['learnedAt'] != null ? DateTime.tryParse(json['learnedAt']) : null,
      reviewCount: int.tryParse(json['reviewCount']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'example': example,
      'category': category,
      'isLearned': isLearned,
      'learnedAt': learnedAt?.toIso8601String(),
      'reviewCount': reviewCount,
    };
  }

  Word copyWith({
    String? id,
    String? word,
    String? meaning,
    String? example,
    String? category,
    bool? isLearned,
    DateTime? learnedAt,
    int? reviewCount,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      category: category ?? this.category,
      isLearned: isLearned ?? this.isLearned,
      learnedAt: learnedAt ?? this.learnedAt,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
