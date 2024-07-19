import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserDetailScreen extends StatefulWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late Map<String, dynamic> user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      var url = Uri.parse('http://127.0.0.1:8000/api/users/${widget.userId}');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          user = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print('Failed to fetch user details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${user['first_name']} ${user['last_name']}\'s Detail'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
		Center(
		  child: user['thumb'] != null && user['thumb'].isNotEmpty 
		    ? Image.network(
			user['thumb'],
			width: 120,
			height: 120,
			fit: BoxFit.cover,
			errorBuilder: (context, error, stackTrace) {
			  return Image.network(
			    'http://127.0.0.1/default_profile.png',
			    width: 120,
			    height: 120,
			    fit: BoxFit.cover,
			  );
			},
		      )
		    : Image.network(
			'http://127.0.0.1/default_profile.png',
			width: 120,
			height: 120,
			fit: BoxFit.cover,
		      ),
		),

                  const SizedBox(height: 16),
                  Text('Username: ${user['username']}'),
                  const SizedBox(height: 8),
                  Text('Email: ${user['email']}'),
                  const SizedBox(height: 8),
                  Text('Phone Number: ${user['first_name']}'),
                  const SizedBox(height: 8),
                  Text('Address: ${user['address']}'),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('More Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Clock-in privileges: ${user['clockin_privileges']}'),
                  const SizedBox(height: 8),
                  Text('Emergency Contact: ${user['emergency_contact']}'),
                  const SizedBox(height: 8),
                  Text('Gender: ${user['gender']}'),
                  const SizedBox(height: 8),
                  Text('Department: ${user['department'] ?? 'Not assigned'}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
    );
  }
}

