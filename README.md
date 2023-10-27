# Flutter Notes App


## Overview
The Flutter Notes App is a mobile application for managing and organizing notes in different categories. Users can create, edit, and delete notes within specific categories. The app provides a user-friendly interface for efficient note management.

## Prerequisites

* Flutter SDK
* Dart: Dart is the programming language used for developing Flutter apps. It is included with the Flutter SDK.
* Android Studio
* Physical Device

## Main Application

* **_main.dart:_** The entry point for the Flutter application. It sets up the MaterialApp and defines the Home widget as the starting point.

* _**home.dart:**_ The core of the application, containing the Home widget. This widget is the main user interface for managing categories and notes. It includes category creation, deletion, and navigation to the CategoryNotes widget for each category.

## Authentication

**_auth.dart:_** This code handles user authentication and registration. It consists of the AuthPage widget, which allows users to log in or register accounts. User information, including name, surname, birthdate, login, and password, is collected and managed.

## Category Management

* _**category_notes.dart:**_ Manages categories and their associated notes. The CategoryNotes widget displays a list of notes within a specific category, and it allows users to add, edit, and delete notes.

* _**add_note.dart:**_ Provides functionality for adding new notes. Users can enter a note's title and text. The new note is associated with a selected category and is saved to the database.

* _**edit_note.dart:**_ Enables users to edit existing notes. The EditNotePage widget allows users to update the title and text of a note. The updated information is saved to the database.

* _**all_notes.dart:**_ Displays all notes in descending order based on their creation date. Notes are grouped by date, and each group is displayed with a header showing the date. This widget is accessible through the bottom navigation bar.

## Database Interaction

_**db.dart:**_ Manages interactions with the SQLite database. It includes methods for creating, querying, updating, and deleting records related to users, categories, and notes.

## Note Search

_**note_search.dart:**_ Provides a search functionality for notes. Users can search for specific notes based on the note title. The NoteSearchDelegate widget extends Flutter's SearchDelegate and allows for searching and selecting notes.


## Functionality

* Users can add, edit, and delete categories to organize their notes.

* Within each category, users can create, edit, and delete notes.

* The app provides a search feature to find specific notes by title.

* Notes are stored locally using the SQLite database.


## Conclusion

The Flutter Notes App is a simple yet powerful tool for organizing and managing your notes. It provides a user-friendly interface for creating, editing, and deleting notes within different categories. Feel free to explore and enhance the app to suit your specific needs. Happy note-taking!
