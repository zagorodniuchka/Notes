import 'package:notes/objects/IModel.dart';
import 'package:sqflite/sqflite.dart';

class User {
  User({
    required this.id,
     this.login,
     this.password,
     this.name,
     this.surname,
     this.birthdate,
  });

  int id;
  String? login;
  String? password;
  String? name;
  String? surname;
  DateTime? birthdate = DateTime.now();

  static create(Database db) {
  print("precreate");
    // if (db.isOpen) {
  print("create");
      db.execute(
        "CREATE TABLE IF NOT EXISTS User ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "name TEXT, "
        "surname TEXT,"
        "birthdate DATETIME,"
        "login TEXT,"
        "password TEXT)",
      );
    // }
  }
}
