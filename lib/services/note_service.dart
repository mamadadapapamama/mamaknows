import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note.dart';  // Note 모델 import

class NoteService {
  static final NoteService _instance = NoteService._internal();
  factory NoteService() => _instance;
  NoteService._internal();  // private constructor

  final Map<String, Note> _notes = {};  // 메모리 저장소

  Future<String?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }

  Future<Note> createNote({
    String? content,
    List<String>? images,
  }) async {
    final note = Note(
      content: content,
      images: images,
      createdAt: DateTime.now(),
    );
    
    // ... 저장 로직 ...
    
    return note;
  }

  Future<Note> updateNote(Note note) async {
    // ... 업데이트 로직 ...
    return note;
  }

  Future<Note> saveNote(Note note) async {
    try {
      // ID가 없으면 새로 생성
      final id = note.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      final savedNote = note.copyWith(id: id);
      
      // 저장
      _notes[id] = savedNote;
      print('Note saved: ${savedNote.id}, content: ${savedNote.content}, images: ${savedNote.images}');  // 디버그용
      
      return savedNote;
    } catch (e) {
      print('Error saving note: $e');  // 디버그용
      throw e;
    }
  }

  Future<Note?> getNote(String id) async {
    return _notes[id];
  }

  Future<List<Note>> getAllNotes() async {
    try {
      final notesList = _notes.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      print('Retrieved ${notesList.length} notes');  // 디버그용
      return notesList;
    } catch (e) {
      print('Error getting notes: $e');  // 디버그용
      return [];
    }
  }

  Future<Note> createEmptyNoteWithImage(String imagePath) async {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '',
      images: [imagePath],
      createdAt: DateTime.now(),
    );
    return saveNote(note);
  }
}
