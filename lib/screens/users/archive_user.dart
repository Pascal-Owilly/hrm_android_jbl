import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../screens/constant.dart';

class ArchiveUserScreen extends StatelessWidget {
  final String userId;

  const ArchiveUserScreen({super.key, required this.userId});

  Future<void> archiveUser(BuildContext context) async {
    try {
      var url = Uri.parse('${BASE_URL}/api/users/$userId/archive/');
      var response = await http.post(url);

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        print('Failed to archive user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error archiving user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive User | HRMS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Are you sure you want to archive this user?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => archiveUser(context),
              child: const Text('Archive User'),
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
