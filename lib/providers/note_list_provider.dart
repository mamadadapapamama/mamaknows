import 'package:flutter/foundation.dart';
import '../models/note.dart';

class NoteListProvider extends ChangeNotifier {
  List<Note> _notes = [];
  List<Note> get notes => _notes;

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }
}
