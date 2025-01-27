import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'note_list_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'note_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteEditProvider extends ChangeNotifier {
  final NoteService _noteService;
  Note? _currentNote;
  bool _isSaving = false;

  NoteEditProvider(this._noteService);
  
  Note? get currentNote => _currentNote;
  bool get isSaving => _isSaving;

  void initializeNewNote() {
    final now = DateTime.now();
    _currentNote = Note(
      id: now.millisecondsSinceEpoch.toString(),
      content: '',
      images: [],
      createdAt: now,
    );
    notifyListeners();
  }

  Future<void> initializeWithImage() async {
    final noteService = NoteService();
    final imagePath = await noteService.pickImage();
    if (imagePath != null) {
      _currentNote = await noteService.createEmptyNoteWithImage(imagePath);
      notifyListeners();
    }
  }

  Future<bool> saveNote(BuildContext context, {String? title}) async {
    try {
      if (_currentNote == null) {
        final now = DateTime.now();
        _currentNote = Note(
          id: now.millisecondsSinceEpoch.toString(),
          title: title,
          content: '',
          images: [],
          createdAt: now,
        );
      }

      final savedNote = await _noteService.saveNote(_currentNote!);
      await context.read<NoteProvider>().refreshNotes();
      return true;
    } catch (e) {
      print('Error in saveNote: $e');
      return false;
    }
  }

  void updateContent(String content) {
    _currentNote = _currentNote?.copyWith(content: content);
    notifyListeners();
  }

  Future<void> addNewImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      if (_currentNote == null) {
        _currentNote = Note(
          id: DateTime.now().toString(),
          content: '',
          images: [image.path],
          createdAt: DateTime.now(),
        );
      } else {
        final currentImages = _currentNote!.images ?? [];
        _currentNote = _currentNote!.copyWith(
          images: [...currentImages, image.path],
        );
      }
      notifyListeners();
    }
  }

  Future<void> editImage(String oldImagePath) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null && _currentNote?.images != null) {
      final newImages = List<String>.from(_currentNote!.images!);
      final index = newImages.indexOf(oldImagePath);
      if (index != -1) {
        newImages[index] = image.path;
        _currentNote = _currentNote!.copyWith(images: newImages);
        notifyListeners();
      }
    }
  }

  void deleteImage(String imagePath) {
    if (_currentNote?.images != null) {
      final newImages = List<String>.from(_currentNote!.images!)
        ..remove(imagePath);
      _currentNote = _currentNote!.copyWith(images: newImages);
      notifyListeners();
    }
  }

  void initializeNote(Note note) {
    _currentNote = note;
    notifyListeners();
  }

  void updateTitle(String title) {
    if (_currentNote != null) {
      _currentNote = _currentNote!.copyWith(title: title);
      notifyListeners();
    }
  }
}
