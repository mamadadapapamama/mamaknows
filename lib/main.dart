import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/note_service.dart';
import 'providers/note_edit_provider.dart';
import 'providers/note_provider.dart';
import 'screens/note_list_screen.dart';

void main() {
  final noteService = NoteService();
  final noteProvider = NoteProvider();
  final noteEditProvider = NoteEditProvider(noteService);
  
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: noteService),
        ChangeNotifierProvider.value(value: noteProvider),
        ChangeNotifierProvider.value(value: noteEditProvider),
      ],
      child: MyApp(),
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
