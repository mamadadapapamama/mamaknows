import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/note_list_screen.dart';
import 'providers/note_provider.dart';
import 'providers/note_edit_provider.dart';
import 'services/note_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NoteProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NoteEditProvider(NoteService()),
        ),
      ],
      child: MaterialApp(
        title: 'Note App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const NoteListScreen(),  // 초기 화면을 NoteListScreen으로 설정
      ),
    );
  }
}
