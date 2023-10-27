import 'dart:ui';

import 'package:notes/objects/IModel.dart';
import 'package:notes/objects/Note.dart';
import 'package:notes/pages/home.dart';
import 'package:sqflite/sqflite.dart';

import 'User.dart';

class Category implements IModel {
  Category({
    required this.id,
     this.name,
     this.color,
     this.createdBy,
  });

  int id;
  String? name;
  Color? color;
  User? createdBy;
  List<Note> noteList = List<Note>.empty();

  static create(Database db) {
      db.execute(
        "CREATE TABLE IF NOT EXISTS Category ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "name TEXT, "
            "color TEXT,"
            "createdBy INTEGER)",
      );
  }

  @override
  Map<String, Object> getContentValues() {
    return ({
      "name": name!,
      "color": color!.value,
      "createdBy": createdBy!.id
    });
  }
}
