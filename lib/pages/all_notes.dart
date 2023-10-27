import 'package:flutter/material.dart';
import 'package:notes/objects/Category.dart';
import 'package:notes/objects/Note.dart';
import 'package:notes/pages/home.dart';
import 'package:intl/intl.dart';

class AllNotes extends StatelessWidget {
  final List<Note> noteList;

  AllNotes(this.noteList);

  @override
  Widget build(BuildContext context) {
    List<Note> allNotes = noteList;

    allNotes.sort((a, b) => b.date!.compareTo(a.date!)); // Sort by date in descending order

    return Scaffold(
      appBar: AppBar(
        title: Text('All Notes'),
        backgroundColor: Colors.amber,
      ),
      body: ListView.builder(
        itemCount: allNotes.length,
        itemBuilder: (context, noteIndex) {
          if (noteIndex == 0 || !isSameDay(allNotes[noteIndex - 1].date!, allNotes[noteIndex].date!)) {
            return Column(
              children: <Widget>[
                _buildDateHeader(allNotes[noteIndex].date!),
                _buildNoteItem(allNotes[noteIndex]),
              ],
            );
          }
          return _buildNoteItem(allNotes[noteIndex]);
        },
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "${date.day}/${date.month}/${date.year}",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNoteItem(Note note) {
    return Card(
      child: ListTile(
        title: Text(note.title!),
          subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(note.date!.toLocal())),
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
