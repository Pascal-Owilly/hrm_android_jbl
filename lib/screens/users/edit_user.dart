import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/user_model.dart';
import '../../screens/constant.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;

  const EditUserScreen({super.key, required this.userId});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late User user; // Declare user as type User
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      var url = Uri.parse('${BASE_URL}/api/users/${widget.userId}/');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> fetchedUser = jsonDecode(response.body);
        setState(() {
          user = User.fromJson(fetchedUser);
          isLoading = false;
        });
      } else {
        print('Failed to fetch user details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  Future<void> updateUser() async {
    try {
      var url = Uri.parse('${BASE_URL}/api/users/${widget.userId}/');
      var response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user.toJson()), // Use toJson method to convert user object to JSON
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        print('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User | JBL'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: user.getUsername(),
                        decoration: const InputDecoration(labelText: 'Username'),
                        onChanged: (value) {
                          setState(() {
                            user.setUsername(value);
                          });
                        },
                      ),
                      TextFormField(
                        initialValue: user.getFirstName(),
                        decoration: const InputDecoration(labelText: 'First Name'),
                        onChanged: (value) {
                          setState(() {
                            user.setFirstName(value);
                          });
                        },
                      ),
                      TextFormField(
                        initialValue: user.getLastName(),
                        decoration: const InputDecoration(labelText: 'Last Name'),
                        onChanged: (value) {
                          setState(() {
                            user.setLastName(value);
                          });
                        },
                      ),
                      TextFormField(
                        initialValue: user.getEmail(),
                        decoration: const InputDecoration(labelText: 'Email'),
                        onChanged: (value) {
                          setState(() {
                            user.setEmail(value);
                          });
                        },
                      ),
                      TextFormField(
                        initialValue: user.getPhoneNumber(),
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                        onChanged: (value) {
                          setState(() {
                            user.setPhoneNumber(value);
                          });
                        },
                      ),
                      TextFormField(
                        initialValue: user.getAddress(),
                        decoration: const InputDecoration(labelText: 'Address'),
                        onChanged: (value) {
                          setState(() {
                            user.setAddress(value);
                          });
                        },
                      ),
                      DropdownButtonFormField(
                        value: user.getClockinPrivileges(),
                        decoration: const InputDecoration(labelText: 'Clock-in Privileges'),
                        items: user.getClockinPrivilegesOptions().map<DropdownMenuItem<String>>((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            user.setClockinPrivileges(value.toString());
                          });
                        },
                      ),
                      DropdownButtonFormField(
                        value: user.getClient(),
                        decoration: const InputDecoration(labelText: 'Client'),
                        items: user.getClientOptions().map<DropdownMenuItem<String>>((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            user.setClient(value.toString());
                          });
                        },
                      ),
                      TextFormField(
                        initialValue: user.getEmergencyContact(),
                        decoration: const InputDecoration(labelText: 'Emergency Contact'),
                        onChanged: (value) {
                          setState(() {
                            user.setEmergencyContact(value);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: updateUser,
                        child: const Text('Update User'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

