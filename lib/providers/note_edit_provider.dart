import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'note_list_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'note_provider.dart';

class NoteEditProvider extends ChangeNotifier {
  final NoteService _noteService;
  Note? _currentNote;
  bool _isSaving = false;

  NoteEditProvider(this._noteService);
  
  Note? get currentNote => _currentNote;
  bool get isSaving => _isSaving;

  Future<void> initializeWithImage() async {
    final noteService = NoteService();
    final imagePath = await noteService.pickImage();
    if (imagePath != null) {
      _currentNote = await noteService.createEmptyNoteWithImage(imagePath);
      notifyListeners();
    }
  }

  Future<bool> saveNote(BuildContext context) async {
    try {
      if (_currentNote == null) {
        // 새 노트 생성
        _currentNote = Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: '',
          images: [],
          createdAt: DateTime.now(),
        );
      }

      // 내용이나 이미지가 있는 경우에만 저장
      if ((_currentNote!.content?.isNotEmpty == true) || 
          (_currentNote!.images?.isNotEmpty == true)) {
        
        final savedNote = await _noteService.saveNote(_currentNote!);
        print('Note saved successfully: ${savedNote.id}');  // 디버그용
        
        // NoteProvider를 통해 노트 목록 갱신
        await context.read<NoteProvider>().refreshNotes();
        return true;
      } else {
        print('Note is empty, not saving');  // 디버그용
        return false;
      }
    } catch (e) {
      print('Error in saveNote: $e');  // 디버그용
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save note: $e')),
      );
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
          id: DateTime.now().toString(), // 임시 ID
          content: '',
          images: [image.path],
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
}
