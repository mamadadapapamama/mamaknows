import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/note_service.dart';
import 'providers/note_edit_provider.dart';
import 'providers/note_provider.dart';
import 'screens/note_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();  // Flutter 바인딩 초기화 추가
  
  final noteService = NoteService();  // NoteService 인스턴스 생성
  final noteProvider = NoteProvider();  // NoteProvider 인스턴스 생성
  
  runApp(
    MultiProvider(
      providers: [
        Provider.value(
          value: noteService,
        ),
        ChangeNotifierProvider.value(
          value: noteProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => NoteEditProvider(noteService),
        ),
      ],
      child: MyApp(),  // const 제거
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NoteListScreen(),  // const 제거
    );
  }
}
