import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NotesApp());
}

class Note {
  String title;
  String body;

  Note({required this.title, required this.body});

  Map<String, dynamic> toJson() => {'title': title, 'body': body};

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(title: json['title'] ?? '', body: json['body'] ?? '');
  }
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const NotesHomePage(),
    );
  }
}

// ==========================================
// PAGE 1: NOTES LIST SCREEN
// ==========================================
class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  var _notes = <Note>[];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('my_notes');

    if (savedData != null) {
      final decoded = jsonDecode(savedData) as List;
      setState(() {
        _notes = decoded.map((item) => Note.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode(_notes.map((n) => n.toJson()).toList());
    await prefs.setString('my_notes', encodedData);
  }

  // Navigate to Page 2 and wait for the saved Note to come back
  Future<void> _openEditor({int? editIndex}) async {
    final isEditing = editIndex != null;

    final Note? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NoteEditorPage(existingNote: isEditing ? _notes[editIndex] : null),
      ),
    );

    // If the user tapped Save (instead of the back arrow), update the list
    if (result != null) {
      setState(() {
        if (isEditing) {
          _notes[editIndex] = result;
        } else {
          _notes.insert(0, result);
        }
      });
      _saveNotes();
    }
  }

  Future<void> _deleteNote(int index) async {
    final noteTitle = _notes[index].title;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Note?'),
          content: Text('Are you sure you want to delete "$noteTitle"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Cancel
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Confirm
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        _notes.removeAt(index);
      });
      _saveNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      body: _notes.isEmpty
          ? const Center(child: Text('No notes yet. Tap + below to add one!'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      note.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      note.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _openEditor(editIndex: index),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteNote(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==========================================
// PAGE 2: FULL-SCREEN NOTE EDITOR
// ==========================================
class NoteEditorPage extends StatefulWidget {
  final Note? existingNote;

  const NoteEditorPage({super.key, this.existingNote});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingNote?.title ?? '',
    );
    _bodyController = TextEditingController(
      text: widget.existingNote?.body ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _saveAndClose() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty && body.isEmpty) {
      Navigator.pop(context); // Close without saving if both are blank
      return;
    }

    final savedNote = Note(
      title: title.isEmpty ? 'Untitled' : title,
      body: body,
    );

    // Send the savedNote back to NotesHomePage
    Navigator.pop(context, savedNote);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingNote != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _saveAndClose,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  hintText: 'Write your note...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
