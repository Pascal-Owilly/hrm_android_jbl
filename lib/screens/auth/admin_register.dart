import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/constant.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String email = '';
  String password = '';
  String firstName = '';
  String lastName = '';

  Future<void> _register() async {
    final url = Uri.parse('${BASE_URL}/api/admin_register/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access', responseData['access']);
      await prefs.setString('refresh', responseData['refresh']);
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Handle error response
      print('Registration failed: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (value) {
                  setState(() {
                    username = value;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'First Name'),
                onChanged: (value) {
                  setState(() {
                    firstName = value;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Last Name'),
                onChanged: (value) {
                  setState(() {
                    lastName = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _register();
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
