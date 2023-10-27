import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:notes/objects/Consts.dart';
import 'package:notes/objects/Category.dart';
import 'package:notes/objects/User.dart';
import 'package:notes/pages/category_notes.dart';
import 'package:notes/pages/all_notes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../data/DB.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late var currentUserId;

  // void initFirebase() async {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   await Firebase.initializeApp();
  // }

  late String _CategoryName;
  List<Category> categoryList = [];
  Color _selectedColor = Colors.amber;
  String _categorySearchText = '';

  @override
  void initState() {
    qw();
    // initFirebase();
    super.initState();
    // _loadCategoryList();
    print("jopa");
  }

  qw() async {
    currentUserId =
        (await SharedPreferences.getInstance()).getInt(Consts.USER_ID);
  }

  _loadCategoryList() async {
    print("siska");
    var list = await (await DB().getInstance()).getCategories(currentUserId);
    print("hui ${list.length}");
    return list;
  }

  void _addCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickerColor = _selectedColor; // Хранит выбранный цвет

        return AlertDialog(
          title: const Text('Add a Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: TextField(
                  onChanged: (String value) {
                    setState(() {
                      _CategoryName = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Category name',
                    border: InputBorder.none,
                  ),
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Pick a Color'),
                            content: SingleChildScrollView(
                              child: BlockPicker(
                                pickerColor: pickerColor,
                                onColorChanged: (Color color) {
                                  setState(() {
                                    pickerColor = color;
                                  });
                                },
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedColor = pickerColor;
                                  });
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                ),
                                child: Text('Select'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: Text('Change'),
                  ),
                  SizedBox(width: 20),
                  // Добавляем расстояние между кнопкой и квадратиком
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  (DB().getInstance()).then((value) async {
                    await value.insertCategory(Category(
                        id: 0,
                        name: _CategoryName,
                        color: _selectedColor,
                        createdBy: User(id: currentUserId)));
                    _loadCategoryList();
                  });
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  _openCategoryNotes(BuildContext context, int categoryIndex) async {
    var categoryData = categoryList[categoryIndex];
    // Color categoryColor = categoryData.color;
    var noteList = await (await DB().getInstance()).getNotes(categoryData.id);
    categoryData.noteList = noteList;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CategoryNotes(
        category: categoryData,
        // categoryIndex: categoryIndex,
        // updateCategory: _updateCategory,
        // categoryColor: categoryColor,
      ),
    ));
  }

  _deleteCategory(int categoryIndex) async {
    setState(() {
      var categoryId = categoryList[categoryIndex].id;
      (DB().getInstance().then((value) async {
        await value.delete("Category", where : "id = ?", whereArgs: [categoryId] );
        await value.delete("Note", where : "categoryId = ?", whereArgs: [categoryId] );
        categoryList.removeAt(categoryIndex);
      }));
    });
  }

/*
  _updateCategory(int categoryIndex, Map<String, dynamic> updatedData) {
    setState(() {
      categoryList[categoryIndex] = updatedData;
      _saveCategoryList();
    });
  }*/
  callAsync() async {
    categoryList = await _loadCategoryList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: callAsync(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          var filteredCategoryList = categoryList.where((category) {
            return category.name!
                .toLowerCase()
                .contains(_categorySearchText.toLowerCase());
          }).toList();
          print("${filteredCategoryList.length}");

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text("Notes"),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              centerTitle: true,
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (String value) {
                      setState(() {
                        _categorySearchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search Categories',
                      hintStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: filteredCategoryList.length,
                    itemBuilder: (BuildContext context, int categoryIndex) {
                      Color? categoryColor;
                      categoryColor = Color(
                          filteredCategoryList[categoryIndex].color!.value);
                      // Отрисовка квадрата с выбранным цветом
                      Widget categoryTile = Container(
                        color: categoryColor,
                        child: Center(
                          child: Text(
                            filteredCategoryList[categoryIndex].name!,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );

                      return GestureDetector(
                        onTap: () {
                          _openCategoryNotes(context, categoryIndex);
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 5,
                          child: Stack(
                            children: [
                              categoryTile,
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteCategory(categoryIndex);

                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.amber,
              onPressed: () {
                _addCategoryDialog(context);
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.category),
                  label: 'Categories',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.note),
                  label: 'All Notes',
                ),
              ],
              currentIndex: 0,
              selectedItemColor: Colors.amber,
              onTap: (int index) async {
                if (index == 0) {
                  // Navigate to the category screen
                } else if (index == 1) {
                  var noteList = await (await DB().getInstance()).getNotes();
                  // Navigate to the all notes screen
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AllNotes(noteList),
                  ));
                }
              },
            ),
          );
        });
    categoryList = _loadCategoryList();
    var filteredCategoryList = categoryList.where((category) {
      return category.name!
          .toLowerCase()
          .contains(_categorySearchText.toLowerCase());
    }).toList();
    print("${filteredCategoryList.length}");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Notes"),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (String value) {
                setState(() {
                  _categorySearchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search Categories',
                hintStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.search, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: filteredCategoryList.length,
              itemBuilder: (BuildContext context, int categoryIndex) {
                Color? categoryColor;
                categoryColor =
                    Color(filteredCategoryList[categoryIndex].color!.value);
                // Отрисовка квадрата с выбранным цветом
                Widget categoryTile = Container(
                  color: categoryColor,
                  child: Center(
                    child: Text(
                      filteredCategoryList[categoryIndex].name!,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );

                return GestureDetector(
                  onTap: () {
                    _openCategoryNotes(context, categoryIndex);
                  },
                  child: Card(
                    color: Colors.white,
                    elevation: 5,
                    child: Stack(
                      children: [
                        categoryTile,
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteCategory(categoryIndex);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          _addCategoryDialog(context);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'All Notes',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.amber,
        onTap: (int index) async {
          if (index == 0) {
            // Navigate to the category screen
          } else if (index == 1) {
            var noteList = await (await DB().getInstance()).getNotes();
            // Navigate to the all notes screen
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AllNotes(noteList),
            ));
          }
        },
      ),
    );
  }
}
