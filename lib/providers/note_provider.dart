import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/note_service.dart';

class NoteProvider extends ChangeNotifier {
  final List<Note> _notes = [];
  List<Note> get notes => List.unmodifiable(_notes);

  Future<void> refreshNotes() async {
    try {
      final noteService = NoteService();
      final updatedNotes = await noteService.getAllNotes();
      _notes.clear();
      _notes.addAll(updatedNotes);
      notifyListeners();
    } catch (e) {
      print('Error refreshing notes: $e');
    }
  }

  void addNote(Note note) {
    if (!_notes.any((n) => n.id == note.id)) {
      _notes.add(note);
      _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
  }

  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }
}