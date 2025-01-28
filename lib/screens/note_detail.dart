import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../models/note.dart';  // Note 모델 import 추가
import '../services/note_service.dart';
import '../providers/note_provider.dart';
import 'package:provider/provider.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late List<String> _images; // 이미지 리스트를 상태로 관리
  bool _isEditingTitle = false;  // 타이틀 편집 상태 추가
  final _noteService = NoteService();  // NoteService 인스턴스 추가

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _images = List<String>.from(widget.note.images ?? []); // 기존 이미지 리스트 복사
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _addImage() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        _images.add(image.path); // 새 이미지를 리스트 끝에 추가
      });
    }
  }

  Future<void> _changeImage(int index) async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        _images[index] = image.path;
      });
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Widget _buildImageList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._images.asMap().entries.map((entry) {
          final int index = entry.key;
          final String imagePath = entry.value;
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.black54,
                  ),
                  onSelected: (String choice) {
                    if (choice == 'delete') {
                      _deleteImage(index);
                    } else if (choice == 'change') {
                      _changeImage(index);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete image'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'change',
                      child: Text('Change image'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
        
        // Add new image 버튼
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton.icon(
            onPressed: _addImage,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Add new new ddong'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isEditingTitle 
          ? TextField(
              controller: _titleController,
              autofocus: true,
              onSubmitted: (newTitle) async {
                setState(() {
                  _isEditingTitle = false;
                });
                await _saveTitle(newTitle);
              },
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  _isEditingTitle = true;
                });
              },
              child: Text(
                _titleController.text,
                style: const TextStyle(color: Colors.black),
              ),
            ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isEditingTitle = true;
                });
              },
              child: Text(
                _titleController.text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Write your note...',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            _buildImageList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final updatedNote = widget.note.copyWith(
            title: _titleController.text,
            content: _contentController.text,
            images: _images,
          );
          
          try {
            await _noteService.updateNote(updatedNote);
            // Provider를 통해 노트 목록 새로고침
            await context.read<NoteProvider>().refreshNotes();
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('노트가 저장되었습니다')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to save note: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  Future<void> _saveTitle(String newTitle) async {
    try {
      if (newTitle.trim().isEmpty) return;
      
      // 전체 노트 업데이트
      final updatedNote = widget.note.copyWith(
        title: newTitle.trim(),
        content: _contentController.text,  // 현재 내용도 포함
        images: _images,  // 현재 이미지도 포함
      );
      
      await _noteService.updateNote(updatedNote);
      await context.read<NoteProvider>().refreshNotes();  // 노트 목록 새로고침
      
      setState(() {
        _titleController.text = newTitle.trim();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('제목이 저장되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('제목 저장 중 오류가 발생했습니다')),
        );
      }
    }
  }
} 