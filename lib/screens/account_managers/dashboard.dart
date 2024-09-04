import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../../screens/sidebar.dart';
import '../../screens/constant.dart';
import '../../location_service.dart'; 
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<dynamic> _clients = []; // List of clients
  DateTime selectedDate = DateTime.now();
  String keyword = '';
  double? latitude;
  double? longitude;
  bool clockedIn = false;
  List<dynamic> clockIns = []; 
  String? userId;
  String? imei;
  
Future<bool> isSdk30OrHigher() async {
  AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
  return build.version.sdkInt >= 30;
 }

Future<void> _getIMEI() async {
  if (await Permission.phone.request().isGranted) {
   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
   setState(() {
         imei = androidInfo.id; // Using unique device ID as IMEI alternative
   });
   } else {
    print('Phone permission not granted');
  }
}


  @override
  void initState() {
    super.initState();
    _fetchDashboardData(); // Fetch dashboard data
    _getIMEI(); 
    fetchUserData();
    _getCurrentLocation();
    fetchClockIns();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<String?> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }
  
  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
      if (userId?.isNotEmpty ?? false) {
        print('User ID: $userId');
      } else {
        print('No user ID found');
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }
Future<void> _clockInOrOut() async {
  final url = Uri.parse('${BASE_URL}/api/admin_clock-in/');
  final token = await getToken();

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
      await fetchClockIns();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Clock in/out successful!')),
      );
    } else {
      final errorResponse = jsonDecode(response.body);
      final errorMessage = errorResponse['error'] ?? 'Failed to clock in/out. Failed to clock in/out. Ensure your location services are enabled then try again';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Network error. Please try again later.')),
    );
  }
}


// Inside _DashboardPageState class

Future<void> fetchClockIns() async {
  String apiUrl = '${BASE_URL}/api/clients_employee/employee-clock-in/';
  final token = await getToken();

  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        clockIns = jsonDecode(response.body);
      });
    } else {
      final errorResponse = jsonDecode(response.body);
      final errorMessage = errorResponse['message'] ?? 'Failed to load clock-ins.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Network error. Please try again later.')),
    );
  }
}


  Future<void> _fetchDashboardData() async {
    try {
      String? token = await getToken(); // Retrieve the authentication token

      final response = await http.get(
        Uri.parse('${BASE_URL}/api/clients/assigned-to-me/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Decode the response body
        List<dynamic> responseData = json.decode(response.body);

        // Print the fetched clients for verification
        print('Fetched Clients:');
        responseData.forEach((client) {
          print('Client Name: ${client['name']}');
          print('Client Branch: ${client['branch']}');
          print('---');
        });

        // Update the state to reflect the fetched clients
        setState(() {
          _clients = responseData;
        });
      } else if (response.statusCode == 401) {
        // Unauthorized, attempt to refresh token
        await refreshToken();
        // Retry fetching data
        await _fetchDashboardData();
      } else {
        // Handle other HTTP status codes
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching client details: $e');
      // Handle errors here, such as setting _clients to empty list to avoid null reference
      setState(() {
        _clients = [];
      });
    }
  }

  Future<void> refreshToken() async {
    try {
      String? refreshToken = await getRefreshToken(); // Get refresh token from SharedPreferences

      final response = await http.post(
        Uri.parse('${BASE_URL}/api/token/refresh/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        // Update SharedPreferences with new access token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String newToken = json.decode(response.body)['access'];
        await prefs.setString('authToken', newToken);
        // After token refresh, re-fetch dashboard data
        await _fetchDashboardData();
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello,',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF773697), // Purple color
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Clients Assigned to You',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF007BFF), // Blue color
              ),
            ),
            SizedBox(height: 8.0),
            Divider(
              color: Colors.black, // You can adjust the color of the divider as needed
              thickness: 1.5, // Adjust the thickness of the divider
            ),
            _buildClientList(), // Assuming _buildClientList() builds the list of clients
          ],
        ),
      ),
    );
  }

  Widget _buildClientList() {
  
    if (_clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.warning, size: 50.0, color: Colors.grey),
            SizedBox(height: 20.0),
            Text(
              'No clients assigned yet',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            _clients.length,
            (index) {
              var client = _clients[index];

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  elevation: 3,
                  child: Container(
                    width: 250, // Adjust the width of the card as needed
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client['name'],
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF773697), // Purple color
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          client['branch'],
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/single_client',
                              arguments: client['id'].toString(),
                            );
                          },
                          child: Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF007BFF), // Blue background color
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
  final locationService = Provider.of<LocationService>(context);

    // Access latitude and longitude from LocationService
    latitude = locationService.latitude;
    longitude = locationService.longitude;

   return Scaffold(
  appBar: AppBar(
    title: const Text('Account Manager Dashboard'),
    actions: [
      if (latitude != null && longitude != null)
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Center(
            child: Text(
              'Lat: ${latitude!.toStringAsFixed(2)}, Long: ${longitude!.toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFF2F8E92), fontSize: 13),
            ),
          ),
        ),
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () {
          setState(() {}); // Reload the page
        },
      ),
    ],
  ),
  drawer: const CustomSidebar(),
  body: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clients assigned under you',
            style: TextStyle(color: Colors.blue),
          ),
          const SizedBox(height: 16.0),
          _buildClientList(),
          const SizedBox(height: 16.0),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: _clockInOrOut,
                    icon: clockedIn ? const Icon(Icons.logout) : const Icon(Icons.check),
                    label: Text(clockedIn ? 'Clock Out' : 'Clock In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'List of your employees clock-ins today',
                    style: TextStyle(color: Colors.blue),
                  ),
                  const SizedBox(height: 16.0),
                  _buildAttendanceTable(),
                  const SizedBox(height: 16.0),
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

// Inside _DashboardPageState class

Widget _buildAttendanceTable() {
if (clockIns.isEmpty) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline, color: Colors.grey),
        const SizedBox(width: 8),
        Text('No clock-in data available'),
      ],
    );
  }

  // Filter clockIns based on user ID (assuming 'user' field in clockIn matches userId)
  List<dynamic> filteredClockIns = clockIns.where((clockIn) {
    return clockIn['user'] == userId;
  }).toList();

  return Column(
    children: [
      Table(
        border: TableBorder.all(),
        children: [
          TableRow(
            children: [
              _buildHeaderCell('Date'),
              _buildHeaderCell('First-In (Arrival)'),
              _buildHeaderCell('Last-Out (Departure)'),
            ],
          ),
          ...filteredClockIns.map((clockIn) {
            return TableRow(
              children: [
                _buildDataCell(clockIn['date'] ?? ''),
                _buildDataCell(clockIn['first_in'] ?? ''),
                _buildDataCell(clockIn['last_out'] ?? ''),
              ],
            );
          }).toList(),
        ],
      ),
    ],
  );
}


Widget _buildHeaderCell(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildDataCell(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(text ?? ''), // Ensure text is not null
  );
}


Widget _buildTableHeader(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildTableCell(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(text ?? ''), // Ensure text is not null
  );
}

}

class Breadcrumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/admin_dashboard');
          },
          child: Text(
            'Dashboard',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        Text(' / Attendance'),
      ],
    );
  }
}

