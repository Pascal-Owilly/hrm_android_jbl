import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('authToken');

  // Navigate to the login screen
  Navigator.of(context).pushReplacementNamed('/login');
}

class CustomSidebar extends StatefulWidget {
  const CustomSidebar({Key? key}) : super(key: key);

@override
  _CustomSidebarState createState() => _CustomSidebarState();
}


class _CustomSidebarState extends State<CustomSidebar> {
  String username = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? role = prefs.getString('role');

    setState(() {
      this.username = username ?? '';
      this.role = role ?? '';
    });
  }

  Map<String, dynamic> _decodeToken(String token) {
    List<String> parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }
    
    String payload = parts[1];
    String normalized = base64Url.normalize(payload);
    String decoded = utf8.decode(base64Url.decode(normalized));
    print("Decoded payload: $decoded"); // Debugging
    return jsonDecode(decoded);
  }

  List<Widget> _buildSidebarItems() {
    List<Widget> items = [];

    // Always show Home link
    items.add(ListTile(
      leading: Icon(Icons.home, color: Color(0xFF773697)),
      title: Text('Home', style: TextStyle(color: Colors.black)),
      onTap: () {
        Navigator.pushReplacementNamed(context, '/home');
      },
    ));

    // Show Dashboard link for superuser and human resource manager
    if (role == 'superuser' || role == 'human_resource_manager') {
      items.add(ListTile(
        leading: Icon(Icons.dashboard, color: Color(0xFF773697)),
        title: Text('Dashboard', style: TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.pushReplacementNamed(context, '/attendance_admin_view');
        },
      ));
      items.add(ListTile(
        leading: Icon(Icons.people, color: Color(0xFF773697)),
        title: Text('Employees', style: TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.pushReplacementNamed(context, '/list_employees');
        },
      ));

    }
    
        if (role == 'employee') {
      items.add(ListTile(
        leading: Icon(Icons.dashboard, color: Color(0xFF773697)),
        title: Text('Dashboard', style: TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.pushReplacementNamed(context, '/employee/dashboard');
        },
      ));


    }
    

    // Show Attendance link for superuser and employee
    if (role == 'human_resource_manager') {
      items.add(ListTile(
        leading: Icon(Icons.calendar_today, color: Color(0xFF773697)),
        title: Text('Attendance', style: TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.pushReplacementNamed(context, '/attendance_admin_view');
        },
      ));
            items.add(ExpansionTile(
        leading: Icon(Icons.business, color: Color(0xFF773697)),
        title: Text('Clients', style: TextStyle(color: Colors.black)),
        children: [
          ListTile(
            leading: Icon(Icons.view_list, color: Color(0xFF773697), size: 15.0),
            title: Text('View All Clients', style: TextStyle(fontSize: 12.0)),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/list_clients');
            },
          ),

        ],
      ));
    }

    // Show Clients link for superuser and account manager
    if (role == 'superuser') {
      items.add(ExpansionTile(
        leading: Icon(Icons.business, color: Color(0xFF773697)),
        title: Text('Clients', style: TextStyle(color: Colors.black)),
        children: [
          ListTile(
            leading: Icon(Icons.view_list, color: Color(0xFF773697), size: 15.0),
            title: Text('View All Clients', style: TextStyle(fontSize: 12.0)),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/list_clients');
            },
          ),
          ListTile(
            leading: Icon(Icons.add_business, color: Color(0xFF773697), size: 15.0),
            title: Text('New Client', style: TextStyle(fontSize: 12.0)),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/create_client');
            },
          ),
        ],
      ));
    }
    
     // Show Clients link for  account manager
    if (role == 'account_manager') {
       items.add(ListTile(
        leading: Icon(Icons.dashboard, color: Color(0xFF773697)),
        title: Text('Dashboard', style: TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.pushReplacementNamed(context, '/account_manager_dashboard');
        },
      ));
      
    }

    // Always show Registration links for superuser
    if (role == 'superuser') {
      items.add(ExpansionTile(
        leading: Icon(Icons.assignment, color: Color(0xFF773697)),
        title: Text('Registration', style: TextStyle(color: Colors.black)),
        children: [
          ListTile(
            leading: Icon(Icons.app_registration, color: Color(0xFF773697), size: 15.0),
            title: Text('Register Admin', style: TextStyle(fontSize: 12.0)),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin_register');
            },
          ),
         
          
        ],
      ));
    }

    // Always show Logout link
    items.add(ListTile(
      title: Container(
        decoration: BoxDecoration(
          color: Color(0xFF773697), // Background color of the button
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.white, size: 18.0),
              SizedBox(width: 8.0), // Space between icon and text
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white, // Text color
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.pushReplacementNamed(context, '/home');
      },
    ));

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF773697), Color(0xFF773697)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30.0,
                  backgroundImage: AssetImage('assets/images/default_profile.svg'),
                ),
                SizedBox(height: 10.0),
                Text(
                  username,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                Text(
                  '${role[0].toUpperCase()}${role.substring(1).toLowerCase()}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: _buildSidebarItems(), // Call the method to build sidebar items
            ),
          ),
        ],
      ),
    );
  }
}

