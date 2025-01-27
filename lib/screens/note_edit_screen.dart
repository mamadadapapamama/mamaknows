import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';  // Note 모델 import
import '../providers/note_edit_provider.dart';  // 프로바이더 import
import '../providers/note_provider.dart';  // NoteProvider import

class NoteEditScreen extends StatefulWidget {
  final Note? note;
  
  const NoteEditScreen({Key? key, this.note}) : super(key: key);

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleController;
  bool _isEditingTitle = false;

  String _formatTitle(DateTime date, int noteCount) {
    try {
      final formattedDate = DateFormat('MMM dd EEE').format(date);
      // 첫 번째 노트는 번호 없이, 그 이후부터 번호 추가
      return noteCount == 0 ? formattedDate : '$formattedDate (${noteCount})';
    } catch (e) {
      print('Error formatting date: $e');
      return DateFormat('MMM dd').format(date);
    }
  }

  @override
  void initState() {
    super.initState();
    final noteProvider = context.read<NoteProvider>();
    final today = DateTime.now();
    final todayNotes = noteProvider.notes.where((note) {
      final noteDate = note.createdAt;
      return noteDate.year == today.year && 
             noteDate.month == today.month && 
             noteDate.day == today.day;
    }).length;

    final initialTitle = widget.note != null 
        ? widget.note!.title ?? _formatTitle(widget.note!.createdAt, 0)
        : _formatTitle(DateTime.now(), todayNotes);

    _titleController = TextEditingController(text: initialTitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteEditProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          style: TextStyle(color: Colors.black),  // 흰색에서 검정색으로 변경
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 15),
          ),
          autofocus: true,
          onSubmitted: (value) {
            setState(() {
              _isEditingTitle = false;
              provider.updateTitle(value);
            });
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isEditingTitle)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                setState(() {
                  _isEditingTitle = false;
                  provider.updateTitle(_titleController.text);
                });
              },
            ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              try {
                final success = await provider.saveNote(
                  context,
                  title: _titleController.text,  // 타이틀 전달
                );
                if (success) {
                  await context.read<NoteProvider>().refreshNotes();
                  Navigator.pop(context);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to save note: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Write your note...',
                  border: InputBorder.none,
                ),
                controller: TextEditingController(text: provider.currentNote?.content),
                onChanged: (value) => provider.updateContent(value),
              ),
              SizedBox(height: 16),
              if (provider.currentNote?.images != null && provider.currentNote!.images!.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: provider.currentNote!.images!.length,
                  itemBuilder: (context, index) {
                    final imagePath = provider.currentNote!.images![index];
                    return Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 200,
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(imagePath)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.white),
                                onPressed: () => provider.editImage(imagePath),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                onPressed: () => provider.deleteImage(imagePath),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => provider.addNewImage(),
                icon: Icon(Icons.add_photo_alternate),
                label: Text('Add new image'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}