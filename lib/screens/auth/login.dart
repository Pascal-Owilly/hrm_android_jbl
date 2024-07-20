import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/constant.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({Key? key}) : super(key: key);

  Future<void> loginUser(BuildContext context) async {
    String url = '${BASE_URL}/api/login/';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'username': usernameController.text,
          'password': passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('JSON response: $jsonResponse'); 

        String token = jsonResponse['token'];
        String username = jsonResponse['username'];
        String role = jsonResponse['role'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        await prefs.setString('username', username);
        await prefs.setString('role', role);

        String roleLower = role.toLowerCase();
        switch (roleLower) {
          case 'superuser':
            Navigator.pushNamed(context, '/attendance_admin_view');
            break;
          case 'employee':
            Navigator.pushNamed(context, '/employee/dashboard');
            break;
          case 'account_manager':
            Navigator.pushNamed(context, '/account_manager_dashboard');
            break;
          case 'human_resource_manager':
            Navigator.pushNamed(context, '/attendance_admin_view');
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unknown role. Please contact support.'),
              ),
            );
            break;
        }
      } else {
        Map<String, dynamic> errorResponse = jsonDecode(response.body);
        String errorMessage = errorResponse['non_field_errors']?.first ?? 'Failed to login. Please try again.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error. Please connect and try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showPasswordResetModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Password Reset'),
          content: const Text(
            'Please use the web app to reset your password. Once successful, return here to log in.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        backgroundColor: const Color(0xFFfdeb3d),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  filled: true,
                  fillColor: const Color(0xFFd1c62a).withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: const Color(0xFFd1c62a).withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => loginUser(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFfdeb3d),
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              GestureDetector(
                onTap: () => showPasswordResetModal(context),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFF773697),
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

