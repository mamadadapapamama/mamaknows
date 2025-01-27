import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note.dart';  // Note 모델 import
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';  // 올바른 방식

class NoteService {
  static final NoteService _instance = NoteService._internal();
  factory NoteService() => _instance;
  NoteService._internal();  // private constructor

  final String _storageKey = 'notes';
  final Map<String, Note> _notes = {};

  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString(_storageKey);
      if (notesJson != null) {
        final notesMap = json.decode(notesJson) as Map<String, dynamic>;
        _notes.clear();
        notesMap.forEach((key, value) {
          _notes[key] = Note.fromJson(value);
        });
      }
    } catch (e) {
      print('Error loading notes: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesMap = _notes.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      await prefs.setString(_storageKey, json.encode(notesMap));
    } catch (e) {
      print('Error saving notes to storage: $e');
    }
  }

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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      images: images,
      createdAt: DateTime.now(),
    );
    
    // 노트를 저장소에 저장
    await saveNote(note);
    
    return note;
  }

  Future<Note> updateNote(Note note) async {
    // ... 업데이트 로직 ...
    return note;
  }

  String _generateTitle(DateTime date, int noteCount) {
    final formattedDate = DateFormat('MMM dd EEE').format(date);
    return noteCount == 0 ? formattedDate : '$formattedDate (${noteCount})';
  }

  Future<Note> saveNote(Note note) async {
    if (note.id.isEmpty) {
      throw Exception('Note id cannot be empty');
    }

    try {
      final savedNote = Note(
        id: note.id,
        title: note.title ?? _generateTitle(note.createdAt, _notes.length),
        content: note.content ?? '',
        images: note.images ?? [],
        createdAt: note.createdAt,
      );
      _notes[note.id] = savedNote;
      await _saveToStorage();  // 저장소에 저장
      return savedNote;
    } catch (e) {
      throw Exception('Failed to save note: $e');
    }
  }

  Future<List<Note>> getAllNotes() async {
    await _loadNotes();  // 저장소에서 로드
    return _notes.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<Note?> getNote(String id) async => _notes[id];

  Future<Note> createEmptyNoteWithImage(String imagePath) async {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '',
      images: [imagePath],
      createdAt: DateTime.now(),
    );
    return saveNote(note);
  }

  Future<void> deleteNote(String id) async => _notes.remove(id);
}
