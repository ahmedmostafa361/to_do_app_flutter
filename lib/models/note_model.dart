class NoteModel {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime createdAt;
  final String? summary;
  final String symbol;
  final int accentColorValue;
  final bool isCompleted; // ✅ NEW

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
    this.summary,
    required this.symbol,
    required this.accentColorValue,
    this.isCompleted = false, // ✅ defaults to false
  });

  // ✅ NEW: needed by toggleComplete
  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? tags,
    DateTime? createdAt,
    String? summary,
    String? symbol,
    int? accentColorValue,
    bool? isCompleted,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      summary: summary ?? this.summary,
      symbol: symbol ?? this.symbol,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Keep your existing toJson/fromJson — just add isCompleted to both:
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
    'summary': summary,
    'symbol': symbol,
    'accentColorValue': accentColorValue,
    'isCompleted': isCompleted, // ✅ NEW
  };

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    tags: List<String>.from(json['tags'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
    summary: json['summary'],
    symbol: json['symbol'] ?? 'work',
    accentColorValue: json['accentColorValue'] ?? 0xff7C3AED,
    isCompleted: json['isCompleted'] ?? false, // ✅ NEW
  );
}
