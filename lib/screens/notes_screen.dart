import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/note.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _dbHelper.getNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _addNote() async {
    if (_formKey.currentState!.validate()) {
      final newNote = Note(
        content: _noteController.text.trim(),
        date: DateTime.now().toString(),
      );
      await _dbHelper.insertNote(newNote);
      _noteController.clear();
      _loadNotes(); // Оновлюємо список нотаток
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Enter note',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Note cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addNote,
                    child: Text('Add'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _notes.isEmpty
                ? Center(child: Text('No notes yet'))
                : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return ListTile(
                  title: Text(note.content),
                  subtitle: Text(note.date),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
