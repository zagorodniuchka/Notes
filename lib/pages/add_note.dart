import 'package:flutter/material.dart';
import 'package:notes/objects/Category.dart';
import 'package:notes/objects/Note.dart';
import 'package:notes/objects/User.dart';
import 'package:notes/pages/home.dart';
import 'package:sqflite/sqflite.dart';

class AddNotePage extends StatefulWidget {
  final List<Note> notes;
  final Function(Note) onNoteAdded;
  final Category category;

  AddNotePage(this.notes, this.onNoteAdded, this.category);

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  late Note _note = Note(id: 0, category: widget.category, createdBy: widget.category.createdBy);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Note'),
        backgroundColor: widget.category.color,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
                _note.date =  DateTime.now();
              widget.onNoteAdded(_note);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (String value) {
                _note.title = value;
              },
              decoration: InputDecoration(
                hintText: 'Note title',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (String value) {
                _note.text = value;
              },
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Start typing your note here...',
              ),
            ),
          )],
      ),
    );
  }
}
