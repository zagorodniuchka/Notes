import 'dart:ui';

import 'package:notes/objects/Consts.dart';
import 'package:notes/objects/IModel.dart';
import 'package:notes/objects/Note.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../objects/Category.dart';
import '../objects/User.dart';

 class DB {
  static Database? _db = null;

  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'notes.db'),
      onCreate: (db, version) {
        User.create(db);
        Category.create(db);
        Note.create(db);
      },
      version: 1,
    );
  }

   Future<DB> getInstance() async {
    if (_db == null) _db = await database();
    return this;
  }

  Future<void> insert(String table, Map<String, Object> data) async {
    await _db!.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    return _db!.query(table);
  }

  Future<List<User>> getUserByLogin(String login) async {
    final userMap = await _db!.query(
      'User',
      where: 'login = ?',
      whereArgs: [login],
    );
    final List<User> list = [];
print(login);
    for (var el in userMap) {
      final user = User(
        id: int.parse(el['id'].toString()),
        login: el['login'].toString(),
        password: el['password'].toString(),
        name: el['name'].toString(),
        surname: el['surname'].toString(),
        birthdate: /*DateTime.parse(el['birthdate'].toString())*/
        DateTime.now(),
      );
      print("name = ${user.name}");
      print("name = ${user.login}");
      print("name = ${user.password}");
      list.add(user);
    }
    return list;
  }

  static Future<List<Map<String, dynamic>>> getUserById(int id) async {
    return await _db!.query(
      'User',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<int> delete(String tableName,
      {String? where, List<dynamic>? whereArgs}) async {
    return _db!.delete(tableName, where: where, whereArgs: whereArgs
    );
  }

  updateNote(Note note) async {
    await _db!.update("Note", note.getContentValues(),
        where: "id = ?", whereArgs: [note.id]);
  }

  insertCategory(Category category) async {
    final _name = category.name;
    final _userId =
        (await SharedPreferences.getInstance()).getInt(Consts.USER_ID);
    await (await DB().getInstance())
        .insert("Category", category.getContentValues());
  }

  Future<List<Note>> getNotes([int categoryId = 0]) async {
    List<Note> list = [];

   var map;
    if (categoryId > 0)
      map = (await _db!.query("Note", where:"categoryId = ?", whereArgs: [categoryId]));
    else
      map = (await _db!.query("Note"));
    for (final el in map) {
      final note = Note(
        id: int.parse(el['id'].toString()),
        title: el['title'].toString(),
        text: el['text'].toString(),
        category: Category(id : int.parse(el['categoryId'].toString())),
        // date: DateTime.parse(el['date'].toString()),
        createdBy: User(id : int.parse(el['createdBy'].toString()))
      );
      list.add(note);
    }
    return list;
  }
  insertNote(Note note) async {
    await  _db!.insert("Note", note.getContentValues());
  }
  getCategories(int currentUserId) async {
    List<Category> list = [];

   var map;
      map = (await _db!.query("Category", where:"createdBy = ?", whereArgs: [currentUserId]));
    for (final el in map) {
    final note = Category(
    id: int.parse(el['id'].toString()),
    name: el['name'].toString(),
    color: Color(int.parse(el['color'].toString())),
    createdBy: User(id : int.parse(el['createdBy'].toString()))
    );
    list.add(note);
    }
    return list;
  }

}
