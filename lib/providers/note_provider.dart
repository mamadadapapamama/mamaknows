import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteProvider extends ChangeNotifier {
  final List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<Note> get notes => List.unmodifiable(_notes);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> refreshNotes() async {
    try {
      _isLoading = true;
      notifyListeners();

      final noteService = NoteService();
      final updatedNotes = await noteService.getAllNotes();
      
      _notes.clear();
      _notes.addAll(updatedNotes);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load notes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(Note note) async {
    try {
      if (!_notes.any((n) => n.id == note.id)) {
        _notes.add(note);
        _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to add note: $e';
      notifyListeners();
    }
  }

  Future<void> updateNote(Note updatedNote) async {
    try {
      final index = _notes.indexWhere((note) => note.id == updatedNote.id);
      if (index != -1) {
        _notes[index] = updatedNote;
        _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update note: $e';
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }
}