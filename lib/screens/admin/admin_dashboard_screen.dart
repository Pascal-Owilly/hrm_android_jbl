import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../widgets/common_layout.dart';
import '../../screens/sidebar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int allUsersCount = 0;
  int hrManagersCount = 0;
  int accountManagersCount = 0;
  int clientsCount = 0;
  int employeesCount = 0;
  int administratorsCount = 0;

  Future<void> fetchData() async {
try {
    var allUsersUrl = Uri.parse('http://127.0.0.1:8000/api/users/');
    var response = await http.get(allUsersUrl);
    if (response.statusCode == 200) {
      var userData = jsonDecode(response.body);
      var userCount = userData['count'];

      setState(() {
        allUsersCount = userCount;
      });
    } 
      var hrManagersUrl = Uri.parse('http://127.0.0.1:8000/api/hr-managers/');
      var accountManagersUrl = Uri.parse('https://your-django-api/account_managers');
      var clientsUrl = Uri.parse('https://your-django-api/clients');
      var employeesUrl = Uri.parse('https://your-django-api/employees');
      var administratorsUrl = Uri.parse('https://your-django-api/administrators');

      var allUsersResponse = await http.get(allUsersUrl);
      var hrManagersResponse = await http.get(hrManagersUrl);
      var accountManagersResponse = await http.get(accountManagersUrl);
      var clientsResponse = await http.get(clientsUrl);
      var employeesResponse = await http.get(employeesUrl);
      var administratorsResponse = await http.get(administratorsUrl);
      var allUsersData = jsonDecode(allUsersResponse.body);
      var hrManagersData = jsonDecode(hrManagersResponse.body);
      var accountManagersData = jsonDecode(accountManagersResponse.body);
      var clientsData = jsonDecode(clientsResponse.body);
      var employeesData = jsonDecode(employeesResponse.body);
      var administratorsData = jsonDecode(administratorsResponse.body);

      setState(() {
        hrManagersCount = hrManagersData['count'];
        accountManagersCount = accountManagersData['count'];
        clientsCount = clientsData['count'];
        employeesCount = employeesData['count'];
        administratorsCount = administratorsData['count'];
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: 'Jawabu Best Limited Administration',
      titleStyle: const TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.bold,
        color: Color(0xFFD9D9D9),
      ),
      drawer: const CustomSidebar(),
      child: Builder(
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: const Text('Hello'),
                ),
                const SizedBox(height: 20.0),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    viewportFraction: 0.8,
                  ),
                  items: [
                    CardWidget(
                      icon: MdiIcons.accountMultiple,
                      title: 'All Users',
                      count: allUsersCount.toString(),
                      url: '/users',
                    ),
                    CardWidget(
                      icon: MdiIcons.accountAlert,
                      title: 'HR Managers',
                      count: hrManagersCount.toString(),
                      url: '/hr_list',
                    ),
                    CardWidget(
                      icon: MdiIcons.accountCog,
                      title: 'Account Managers',
                      count: accountManagersCount.toString(),
                      url: '/account_manager_all',
                    ),
                    CardWidget(
                      icon: MdiIcons.accountGroup,
                      title: 'Clients',
                      count: clientsCount.toString(),
                      url: '/list_clients',
                    ),
                    CardWidget(
                      icon: MdiIcons.accountBoxMultiple,
                      title: 'Employees',
                      count: employeesCount.toString(),
                      url: '/list_employees',
                    ),
                    CardWidget(
                      icon: MdiIcons.accountSupervisor,
                      title: 'Administrators',
                      count: administratorsCount.toString(),
                      url: '/admin_list',
                    ),
                  ].map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: i,
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20.0),
 
              ],
            ),
          );
        },
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String count;
  final String url;

  const CardWidget({super.key, 
    required this.icon,
    required this.title,
    required this.count,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, url);
      },
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        color: const Color.fromARGB(255, 249, 250, 251),
        shadowColor: const Color.fromRGBO(249, 249, 249, 0.7),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: const Color(0xFF773697), size: 40.0),
              const SizedBox(height: 10.0),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF773697),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007BFF),
                ),
              ),
              const SizedBox(height: 5.0),
              const Text(
                'Total Count',
                style: TextStyle(
                  color: Color(0xFFC2C2C2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

