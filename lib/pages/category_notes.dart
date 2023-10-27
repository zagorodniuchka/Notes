import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes/data/DB.dart';
import 'package:notes/objects/Category.dart';
import 'package:notes/objects/Note.dart';
import 'package:notes/pages/home.dart';
import 'package:notes/pages/note_search.dart';
import 'package:notes/pages/edit_note.dart';
import 'package:notes/pages/add_note.dart';
import 'package:sqflite/sqflite.dart';

class CategoryNotes extends StatefulWidget {
  final Category category;
  // final int categoryIndex;
  // final Function(int, Map<String, dynamic>) updateCategory;
  // final Color categoryColor;

  CategoryNotes({
    required this.category,
    // required this.categoryIndex,
    // required this.updateCategory,
    // required this.categoryColor,
  });
  @override
  State<CategoryNotes> createState() => _CategoryNotesState(category/*, updateCategory*/);

}

class _CategoryNotesState extends State<CategoryNotes> {
  late Category _category;
  // final Function(int, Map<String, dynamic>) updateCategoryCallback;

  _CategoryNotesState(Category category/*, this.updateCategoryCallback*/)   {
  _notes = category.noteList;
    /*notes = (categoryData.noteList)!
        .map((noteJson) {
      final noteData = noteJson as Map<String, dynamic>;
      return Note(
        title: noteData['title'] as String,
        text: noteData['text'] as String,
        date: DateTime.parse(noteData['date'] as String),
      );
    })
        .toList();*/
  }

  String _noteSearchText = '';
  var _notes = List<Note>.empty();

  @override
  Widget build(BuildContext context) {

    List<Note> filteredNotes = _notes.where((note) {
      return note.title!.toLowerCase().contains(_noteSearchText.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(widget.category.color!.value),
        title: Text(widget.category.name!),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NoteSearchDelegate(_notes, (context, index) {
                  _editNoteCallback(context, index!);
                }),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, noteIndex) {
                return Card(
                  child: ListTile(
                    title: Text(filteredNotes[noteIndex].title!),
                    subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(filteredNotes[noteIndex].date!)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.black),
                      onPressed: () {
                        _deleteNoteCallback(noteIndex);
                      },
                    ),
                    onTap: () {
                      _editNoteCallback(context, noteIndex);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddNotePage(_notes, (newNote) {
                setState(()  {
                  _notes.add(newNote);
                   ( DB().getInstance()).then((value) => value.insertNote(newNote));
                });
              },
                widget.category,
              ),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.amber,
      ),
    );
  }

 /* _saveCategoryData() {
    final List<Map<String, dynamic>> serializedNotes = notes.map((note) {
      return {
        'title': note.title,
        'text': note.text,
        'date': note.date.toIso8601String(),
      };
    }).toList();

    final Map<String, dynamic> updatedCategoryData = {
      'name': widget.category.name,
      'notes': serializedNotes,
      'color': widget.category.color,
    };
    widget.updateCategory(widget.categoryIndex, updatedCategoryData);
  }*/

  _editNoteCallback(BuildContext context, int noteIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditNotePage(
          _notes[noteIndex],
              (updatedNote) {
            setState(()  {
              _notes[noteIndex] = updatedNote;
               ( DB().getInstance()).then((value) => value.updateNote(updatedNote));
            });
          },
          widget.category.color!,
        ),
      ),
    );
  }

  _deleteNoteCallback(int noteIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Note', style: TextStyle(color: Colors.amber)),
          content: Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.amber)),
            ),
            TextButton(
              onPressed: () {
                setState(()  {
                   ( DB().getInstance()).then((value) => value.delete("Note", where : "id = ?", whereArgs: [_notes[noteIndex].id]));
                  _notes.removeAt(noteIndex);
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.amber)),
            ),
          ],
        );
      },
    );
  }
}
