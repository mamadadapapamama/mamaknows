
class Note {
  final String id;
  final String? title;
  final String? content;
  final List<String>? images;
  final DateTime createdAt;

  const Note({
    required this.id,
    this.title,
    this.content,
    this.images,
    required this.createdAt,
  });

  // 복사본 생성을 위한 copyWith 메서드 추가
  Note copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? images,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // JSON 직렬화를 위한 메서드들도 필요하다면 추가
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String?,
      content: json['content'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}