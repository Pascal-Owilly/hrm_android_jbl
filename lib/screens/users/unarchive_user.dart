import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../screens/constant.dart';

class UnarchiveUserScreen extends StatelessWidget {
  final String userId;

  const UnarchiveUserScreen({super.key, required this.userId});

  Future<void> unarchiveUser(BuildContext context) async {
    try {
      var url = Uri.parse('${BASE_URL}/api/users/$userId/unarchive/');
      var response = await http.post(url);

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        print('Failed to unarchive user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error unarchiving user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unarchive User | JBL'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Are you sure you want to unarchive this user?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => unarchiveUser(context),
              child: const Text('Unarchive User'),
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
