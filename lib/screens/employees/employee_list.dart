import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../screens/constant.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const EmployeeListScreen(),
    },
  ));
}

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<dynamic> employees = [];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      var url = Uri.parse('${BASE_URL}/api/employees/');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List;
        setState(() {
          employees = data;
        });
      } else {
        print('Failed to fetch employees');
      }
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Employees | JBL'),
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
                    child: Breadcrumb(),
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
                        'All Employees',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(),
                    if (employees.isNotEmpty)
                      ListView.builder(
			  shrinkWrap: true,
			  physics: const NeverScrollableScrollPhysics(),
			  itemCount: employees.length,
			  itemBuilder: (context, index) {
			    var employee = employees[index];
			    return EmployeeCard(employee: employee);
			  },
			)

                    else
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text('No employees found.'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (employees.isNotEmpty)
                const Pagination(), // Assuming pagination needs to be shown when employees are present
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
              Navigator.pushNamed(context, '/admin_dashboard');
            },
            child: const Text('Dashboard'),
          ),
          const SizedBox(width: 10),
          const Text(
            'Employee',
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

class EmployeeCard extends StatelessWidget {
  final dynamic employee;

  const EmployeeCard({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(employee['avatar'] ?? 'default_image_url'),
        ),
        title: Text('${employee['first_name']} ${employee['last_name']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employee['email'] ?? 'No email provided'),
            Text(employee['mobile'] ?? 'No mobile number provided'),
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

