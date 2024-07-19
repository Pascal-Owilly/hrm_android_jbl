import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import DateFormat from intl package
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../screens/sidebar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../screens/constant.dart';

Future<void> storeUserData(String token, String userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('authToken', token);
  await prefs.setString('userId', userId);
}

Future<String?> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}

// Retrieve the token
Future<String?> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('authToken');
}

Future<void> fetchUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
}

Future<void> _downloadFile(String url, String filename) async {
  try {
    final http.Response response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename';
      final file = File(path);
      
      await file.writeAsBytes(response.bodyBytes);
      print('File downloaded to $path');
    } else {
      print('Failed to download file: ${response.statusCode}');
    }
  } catch (e) {
    print('Error downloading file: $e');
  }
}


class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime selectedDate = DateTime.now();
  String keyword = '';
  double? latitude;
  double? longitude;
  bool clockedIn = false;
  List<dynamic> clockIns = [];
  List<dynamic> presentStaffers = [];
  
  int allUsersCount = 0;
  int hrManagersCount = 0;
  int accountManagersCount = 0;
  int clientsCount = 0;
  int employeesCount = 0;
  int administratorsCount = 0;


  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
      fetchClockIns();
      fetchUserData();
  }

Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    } catch (e) {
      print('Error getting location: $e');
      // Optionally, show a user-friendly error message
    }
  }
  
Future<void> fetchData() async {
try {
    var allUsersUrl = Uri.parse('${BASE_URL}/api/users/');

    var response = await http.get(allUsersUrl);
    if (response.statusCode == 200) {
      var userData = jsonDecode(response.body);
      var userCount = userData['count'];

      setState(() {
        allUsersCount = userCount;
      });
    } 
      var hrManagersUrl = Uri.parse('${BASE_URL}/api/hr-managers/');
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


  
Future<void> fetchClockIns() async {
  String apiUrl = '${BASE_URL}/api/clock_in_all/';
  final token = await getToken();

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    setState(() {
      presentStaffers = jsonDecode(response.body);
    });
  } else {
    print('Failed to load clock-ins: ${response.statusCode}');
  }
}


  Future<void> _clockInOrOut() async {
    final url = Uri.parse('${BASE_URL}/api/admin_clock-in/');
    final token = await getToken(); // Replace with your method to get the token

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'first_in': DateFormat('HH:mm:ss').format(DateTime.now()),
          'last_out': DateFormat('HH:mm:ss').format(DateTime.now()),
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          clockedIn = !clockedIn;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clock in/out successful!')),
        );
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['message'] ?? 'Failed to clock in/out. Ensure your location services are enabled then try again';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please connect and try again.')),
      );
    }
  }



@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Jawabu Best Limited Administration'),
      titleTextStyle: const TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2f8e92),
      ),
    ),
    drawer: const CustomSidebar(), 
    body: SingleChildScrollView(
  child: Container(
    decoration: BoxDecoration(
      color: const Color(0xFFf9f9f9), // Set the background color here
    ),
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 20.0),
        const Breadcrumb(),
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
              url: '/users',
            ),
            CardWidget(
              icon: MdiIcons.accountAlert,
              title: 'HR Managers',
              url: '/hr_list',
            ),

            CardWidget(
              icon: MdiIcons.accountGroup,
              title: 'Clients',
              url: '/list_clients',
            ),
            CardWidget(
              icon: MdiIcons.accountBoxMultiple,
              title: 'Employees',
              url: '/list_employees',
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

        const SizedBox(height: 16.0),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (clockedIn) ...[
                  ElevatedButton.icon(
                    onPressed: _clockInOrOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Clock Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF), // Use backgroundColor instead of primary
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: _clockInOrOut,
                    icon: const Icon(Icons.check),
                    label: const Text('Clock In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF), // Use backgroundColor instead of primary
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16.0),
                const Text(
                  'List of employee(s) that clocked-in today',
                  style: TextStyle(color: Colors.blue),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: _downloadPDF,
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.red), // PDF icon with red color
                      tooltip: 'Download PDF',
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      onPressed: _downloadExcel,
                      icon: const Icon(Icons.file_download, color: Colors.green), // Excel icon with green color
                      tooltip: 'Download Excel',
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildFilterForm(),
                const SizedBox(height: 16.0),
                _buildAttendanceTable(),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
),

  );
}

  Widget _buildFilterForm() {
    return Form(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
 children: [
  const Row(
    children: [
      Icon(Icons.date_range, color: Colors.blue), // Date range icon
      SizedBox(width: 8.0),
      Text(
        'Filter by Date',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    ],
  ),
  const SizedBox(height: 8.0),
  SizedBox(
    width: 150,
    child: InputDecorator(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
      ),
      isEmpty: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('yyyy-MM-dd').format(selectedDate),
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.blue), // Calendar icon
            onPressed: () async {
              DateTime? date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (date != null) {
                setState(() {
                  selectedDate = date;
                });
                _filterByDate(date);
              }
            },
          ),
        ],
      ),
    ),
  ),
],

          ),
          //Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            //children: [
              //Text('Search by name'),
              //SizedBox(height: 8.0),
              //Container(
                //width: 150,
                //child: TextFormField(
                  //decoration: InputDecoration(
                    //border: OutlineInputBorder(),
                    //suffixIcon: IconButton(
                    //  icon: Icon(Icons.search),
                     // onPressed: () {
                     //   _searchByName(keyword);
                    //  },
                   // ),
                 // ),
                  //onChanged: (value) {
                   // setState(() {
                     // keyword = value;
                    //});
                  //},
               // ),
             // ),
           // ],
         // ),
        ],
      ),
    );
  }

Widget _buildAttendanceTable() {
if (presentStaffers.isEmpty) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline, color: Colors.grey),
        const SizedBox(width: 8),
        Text('No clock-in data available'),
      ],
    );
  }

  return Column(
    children: [
      Table(
        border: TableBorder.all(),
        children: [
          TableRow(
            children: [
              _buildTableHeader('Name'),
              _buildTableHeader('Date'),
              _buildTableHeader('First-In (Arrival)'),
              _buildTableHeader('Last-Out (Departure)'),

            ],
          ),
          ...presentStaffers.map((staff) {
            return TableRow(
              children: [
                _buildTableCell(staff['name'] ?? 'N/A'),
                _buildTableCell(staff['date'] ?? 'N/A'),
                _buildTableCell(staff['first_in'] ?? 'N/A'),
                _buildTableCell(staff['last_out'] ?? 'N/A'),

              ],
            );
          }),
        ],
      ),
      // Add pagination controls if needed
    ],
  );
}


Widget _buildTableHeader(String headerText) {
  return Padding(
    padding: const EdgeInsets.all(3.0),
    child: Text(
      headerText,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14.0,
        color: Color(0xFF773697), 
      ),
    ),
  );
}

Widget _buildTableCell(String cellText) {
  return Padding(
    padding: const EdgeInsets.all(3.0),
    child: Text(
      cellText,
      style: const TextStyle(
        fontSize: 14.0,
        color: Color(0xFF2C2C2C), 
      ),
    ),
  );
}



  void _printAttendance() {
    // Implement print logic
  }

Future<void> _downloadPDF() async {
    final token = await getToken();
    final String apiUrl = '${BASE_URL}/api/download-pdf/?date=${DateFormat('yyyy-MM-dd').format(selectedDate)}&keyword=$keyword';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/attendance.pdf';
      final file = File(path);
      await file.writeAsBytes(bytes);

      OpenFile.open(path);
    } else {
      print('Failed to download PDF: ${response.statusCode}');
    }
  }

  Future<void> _downloadExcel() async {
    final token = await getToken();
    final String apiUrl = '${BASE_URL}/api/download-excel/?date=${DateFormat('yyyy-MM-dd').format(selectedDate)}&keyword=$keyword';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/attendance.xlsx';
      final file = File(path);
      await file.writeAsBytes(bytes);

      OpenFile.open(path);
    } else {
      print('Failed to download Excel: ${response.statusCode}');
    }
  }


void _filterByDate(DateTime date) {
  setState(() {
    selectedDate = date;
  });
  // Optionally, fetch data based on the selected date
}

void _searchByName(String keyword) {
  setState(() {
    this.keyword = keyword;
  });
  // Optionally, fetch data based on the keyword
}
}

class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/attendance_admin_view');
          },
          child: const Text(
            'Dashboard',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        const Text(' / Attendance'),
      ],
    );
  }
}

class Employee {
  final String date;
  final String firstIn;
  final String lastOut;
  final String name;

  Employee({
    required this.date,
    required this.firstIn,
    required this.lastOut,
    required this.name,
  });
}

 class CardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  //final String count;
  final String url;

  const CardWidget({super.key, 
    required this.icon,
    required this.title,
    //required this.count,
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
              
              const SizedBox(height: 5.0),
              const Text(
                'List',
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

