import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';  // Note 모델 import
import '../providers/note_edit_provider.dart';  // 프로바이더 import
import '../providers/note_provider.dart';  // NoteProvider import

class NoteEditScreen extends StatelessWidget {
  final Note? note;

  const NoteEditScreen({Key? key, this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteEditProvider>();
    
    // 날짜 포맷 추가
    String formattedDate = '';
    if (note != null) {
      formattedDate = DateFormat('MMM dd yyyy').format(note!.createdAt);
    } else {
      formattedDate = DateFormat('MMM dd yyyy').format(DateTime.now());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (note != null && provider.currentNote == null) {
        provider.initializeNote(note!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDate),  // 날짜 형식으로 타이틀 변경
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              final success = await provider.saveNote(context);
              if (success) {
                // 저장 성공 시 노트 리스트 갱신하고 화면 닫기
                context.read<NoteProvider>().refreshNotes();
                Navigator.pop(context);
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