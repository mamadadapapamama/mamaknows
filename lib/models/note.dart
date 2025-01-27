import 'package:flutter/foundation.dart';

class Note {
  final String? id;
  final String? content;
  final List<String>? images;
  final DateTime createdAt;

  Note({
    this.id,
    this.content,
    this.images,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  // 복사본 생성을 위한 copyWith 메서드 추가
  Note copyWith({
    String? id,
    String? content,
    List<String>? images,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // JSON 직렬화를 위한 메서드들도 필요하다면 추가
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      content: json['content'],
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}