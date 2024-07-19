import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../screens/constant.dart';

class DeleteUserScreen extends StatelessWidget {
  final String userId;

  const DeleteUserScreen({super.key, required this.userId});

  Future<void> deleteUser(BuildContext context) async {
    try {
      var url = Uri.parse('${BASE_URL}/api/users/$userId/');
      var response = await http.delete(url);

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        print('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete User | JBL'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Are you sure you want to delete this user?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => deleteUser(context),
              child: const Text('Delete User'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
