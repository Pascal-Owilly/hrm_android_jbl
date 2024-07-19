import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../screens/constant.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const UserListScreen(),
    },
  ));
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> users = []; // Change variable name to users

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Update method call to fetch users
  }

  Future<void> fetchUsers() async {
    try {
      var url = Uri.parse('${BASE_URL}/api/users/');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List;
        setState(() {
          users = data;
        });
      } else {
        print('Failed to fetch users'); // Adjust error message if needed
      }
    } catch (e) {
      print('Error fetching users: $e'); // Adjust error message if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users | JBL'), // Update screen title
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Breadcrumb(), // Keep breadcrumb as is if it suits your navigation
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                child: Column(
                  children: [
                    const ListTile(
                      title: Text(
                        'All Users',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(),
                    if (users.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          var user = users[index]; // Change variable name to user
                          return UserCard(user: user); // Update to UserCard
                        },
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text('No users found.'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (users.isNotEmpty)
                const Pagination(), // Assuming pagination needs to be shown when users are present
            ],
          ),
        ),
      ),
    );
  }
}


class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/attendance_admin_view');
            },
            child: const Text('Dashboard'),
          ),
          const SizedBox(width: 10),
          const Text(
            'User',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          const Text(
            'All',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final dynamic user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user['avatar'] ?? 'default_image_url'),
        ),
        title: Text('${user['first_name']} ${user['last_name']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email'] ?? 'No email provided'),
            Text(user['phone_number'] ?? 'No mobile number provided'),
          ],
        ),

      ),
    );
  }
}


class Pagination extends StatelessWidget {
  const Pagination({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {},
            child: const Text('Previous'),
          ),
          const SizedBox(width: 10),
          const Text(
            'Page 1 of 1', // Replace with dynamic page info based on API response
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () {},
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

