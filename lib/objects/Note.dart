import 'dart:math';
import 'dart:ui';

import 'package:notes/objects/Category.dart';
import 'package:notes/objects/IModel.dart';
import 'package:notes/objects/User.dart';
import 'package:sqflite/sqflite.dart';

class Note implements IModel {
  Note({
     this.id,
     this.title,
     this.text,
     this.category,
     this.createdBy,
  });

  int? id;
  String? title;
  String? text;
  DateTime? date = DateTime.now().add(Duration(minutes: Random().nextInt(10)));
  Category? category;
  User? createdBy;

  static create(Database db) {
      db.execute(
        "CREATE TABLE IF NOT EXISTS Note ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "title TEXT, "
            "text TEXT, "
            "date DATETIME,"
            "categoryId INTEGER,"
            "createdBy INTEGER)"
      );
  }

  @override
  Map<String, Object> getContentValues() {
    return ({
      // "id" : id!,
      "title" : title!,
      "text" : text!,
      // "date" : DateTime.now().add(Duration(minutes: Random().nextInt(10))),
      "categoryId" : category!.id,
      "createdBy" : createdBy!.id,
    });
  }
}