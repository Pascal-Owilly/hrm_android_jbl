import 'package:flutter/material.dart';
import '../../api/api_service.dart'; 
import '../users/detail_user.dart';

class AdminListScreen extends StatefulWidget {
  const AdminListScreen({super.key});

  @override
  _AdminListScreenState createState() => _AdminListScreenState();
}

class _AdminListScreenState extends State<AdminListScreen> {
  late Future<List<dynamic>> futureAdmins;

  @override
  void initState() {
    super.initState();
    futureAdmins = ApiService.fetchAdmins();
  }

  @override
  Widget build(BuildContext context) {
    // Define text styles
    const TextStyle kTitleTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );

    const TextStyle kSubtitleTextStyle = TextStyle(
      color: Colors.grey,
      fontSize: 16.0,
    );

    const TextStyle kBodyTextStyle = TextStyle(
      color: Colors.black87,
      fontSize: 14.0,
    );

    const TextStyle kButtonTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 12.0,
    );

    // Define button styles
    final ButtonStyle kButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFDEB3D),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      textStyle: kButtonTextStyle,
    );

    // Define container decorations
    const BoxDecoration kCardDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey,
          blurRadius: 5.0,
          offset: Offset(0, 2),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin List | JBL', style: kTitleTextStyle),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureAdmins,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: kBodyTextStyle));
          } else {
            final admins = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: admins.length,
              itemBuilder: (context, index) {
                final admin = admins[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: admin['thumb'] != null
                          ? NetworkImage(admin['thumb'])
                          : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                      radius: 30,
                    ),
                    title: Text('${admin['first_name']} ${admin['last_name']}', style: kSubtitleTextStyle),
                    subtitle: Text(admin['email'], style: kBodyTextStyle),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailScreen(userId: admin['id']),
                          ),
                        );
                      },
                      style: kButtonStyle,
                      child: const Text('View', style: kButtonTextStyle),
                    ),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

