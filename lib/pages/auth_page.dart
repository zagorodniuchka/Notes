import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notes/objects/Consts.dart';
import 'package:notes/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/DB.dart';

class AuthPage extends StatefulWidget {
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _birthdateController = TextEditingController();
  TextEditingController _loginController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true; // Флаг для переключения между режимами входа и регистрации

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _submitForm(BuildContext context) async {
    final name = _nameController.text;
    final surname = _surnameController.text;
    final birthdate = _birthdateController.text;
    final login = _loginController.text;
    final password = _passwordController.text;
    print(_isLogin.toString());
    if (_isLogin) {
      // Login existing user
      // Example: Check that login and password are not empty
      print("assds $login");
      if (login.isNotEmpty && password.isNotEmpty) {
        // Check if a user with the entered login exists in the database
        final user = (await (await DB().getInstance()).getUserByLogin(login)).firstOrNull;
        print("${user!.password!.toString()} == $password");
        if (user != null && user.password == password) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt(Consts.USER_ID, user.id);
          // If the user exists and the entered password is correct, perform login
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => Home(), // Navigate to categories window
          ));
        } else {
          // If the user does not exist or the entered password is incorrect, show an error message
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Invalid login or password.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK', style: TextStyle(color: Colors.black)), // Change text color
                ),
              ],
            ),
          );
        }
      }
    } else {
      // Register new user
      // Example: Check that all necessary fields are filled out
      if (name.isNotEmpty && surname.isNotEmpty && birthdate.isNotEmpty && login.isNotEmpty && password.isNotEmpty) {
        // Create a new account with the entered data

        // Insert the new user into the database
        (await DB().getInstance()).insert('User', {
          'name': name,
          'surname': surname,
          'birthdate': "'${DateTime.now()}'".replaceFirst(' ', 'T'),
          'login': login,
          'password': password,
        });

        // After successful registration:
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Registration Successful'),
            content: Text('You have successfully registered an account.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => AuthPage(), // Navigate to login window
                  ));
                },
                child: Text('OK', style: TextStyle(color: Colors.black)), // Change text color
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Register'),
        backgroundColor: Colors.amber,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Welcome to the Note application!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              if (!_isLogin)
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
              if (!_isLogin)
                TextFormField(
                  controller: _surnameController,
                  decoration: InputDecoration(labelText: 'Surname'),
                ),
              if (!_isLogin)
                TextFormField(
                  controller: _birthdateController,
                  decoration: InputDecoration(labelText: 'Birthdate'),
                ),
              TextFormField(
                controller: _loginController,
                decoration: InputDecoration(labelText: 'Login'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: () => _submitForm(context),
                child: Text(_isLogin ? 'Login' : 'Register'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.amber, // Change button color
                ),
              ),
              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  _isLogin ? 'Create an account' : 'I already have an account',
                  style: TextStyle(color: Colors.black), // Изменить цвет текста
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
