import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/storage_service.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final TextEditingController _searchController = TextEditingController();

  List<Note> _allNotes = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initNotes() async {
    final loaded = await _storageService.loadNotes();
    setState(() {
      _allNotes = loaded;
      _isLoading = false;
    });
  }

  // Dynamic filtering using .where() and .toLowerCase()
  List<Note> get _filteredNotes {
    if (_searchQuery.trim().isEmpty) return _allNotes;

    final query = _searchQuery.toLowerCase();
    return _allNotes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openEditor({Note? note}) async {
    final Note? result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(existingNote: note)),
    );

    if (result == null) return;

    setState(() {
      final index = _allNotes.indexWhere((n) => n.id == result.id);
      if (index != -1) {
        _allNotes[index] = result;
      } else {
        _allNotes.insert(0, result);
      }
    });

    await _storageService.saveNotes(_allNotes);
  }

  Future<void> _deleteNote(String id) async {
    setState(() {
      _allNotes.removeWhere((note) => note.id == id);
    });
    await _storageService.saveNotes(_allNotes);
  }

  @override
  Widget build(BuildContext context) {
    final visibleNotes = _filteredNotes;

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : visibleNotes.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No notes yet. Tap + to create one.'
                          : 'No matching notes found.',
                    ),
                  )
                : ListView.builder(
                    itemCount: visibleNotes.length,
                    itemBuilder: (context, index) {
                      final note = visibleNotes[index];
                      return ListTile(
                        title: Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _openEditor(note: note),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteNote(note.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
