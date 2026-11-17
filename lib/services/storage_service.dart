import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

class StorageService {
  static const String _notesKey = 'saved_notes_v2';

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString(_notesKey);

    if (rawJson == null || rawJson.isEmpty) return [];

    final List<dynamic> decodedList = jsonDecode(rawJson);
    return decodedList
        .map((item) => Note.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      notes.map((note) => note.toJson()).toList(),
    );
    await prefs.setString(_notesKey, encodedList);
  }
}
