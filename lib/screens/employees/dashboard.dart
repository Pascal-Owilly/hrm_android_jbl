import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/sidebar.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../screens/constant.dart';
import '../../location_service.dart'; 
import 'package:provider/provider.dart';

Future<void> storeUserData(String token, String userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('authToken', token);
  await prefs.setString('userId', userId);
}

Future<String?> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}

Future<String?> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('authToken');
}

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({Key? key}) : super(key: key);

  @override
  _EmployeeDashboardScreenState createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {

  bool _isLoading = false;


  // Define a key for storing clockedIn state in SharedPreferences
  static const String _clockedInKey = 'clockedIn';
  DateTime selectedDate = DateTime.now();
  String keyword = '';
  double? latitude;
  double? longitude;
  bool clockedIn = false;
  List<dynamic> clockIns = [];
  String? userId;
  String? _androidId;

  Future<bool> isSdk30OrHigher() async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    return build.version.sdkInt >= 30;
  }

  // Function to get Android ID
  Future<void> _getAndroidId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    setState(() {
      _androidId = androidInfo.id; // Retrieve Android ID
    });
  }

  @override
  void initState() {
    super.initState();
    _loadClockedInState();
    fetchUserData();

    fetchClockIns();
    _getAndroidId();
  }
  
 
  Future<void> _loadClockedInState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      clockedIn = prefs.getBool(_clockedInKey) ?? false;
    });
  }
  
  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        userId = prefs.getString('userId') ?? '';
        if (userId?.isNotEmpty ?? false) {
          print('User ID: $userId');
        } else {
          print('No user ID found');
        }
      });
    }
  }

Future<void> _clockInOrOut() async {
  setState(() {
    _isLoading = true; // Start loading
  });
  final clockUrl = Uri.parse('${BASE_URL}/api/admin_clock-in/');
  final token = await getToken();

  try {
    if (clockedIn) {
      // Clock Out
      final response = await http.post(
        clockUrl,
        body: jsonEncode({
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'last_out': DateFormat('HH:mm:ss').format(DateTime.now()),
          'imei': _androidId,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          clockedIn = false;
        });
        await fetchClockIns();
        _storeClockedInState(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Clock out successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError(response.body);
      }
    } else {
      // Clock In
      final response = await http.post(
        clockUrl,
        body: jsonEncode({
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'first_in': DateFormat('HH:mm:ss').format(DateTime.now()),
          'imei': imei,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          clockedIn = true;
          _isLoading = false; // Stop loading
        });
        await fetchClockIns();
        _storeClockedInState(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Clock in successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError(response.body);
      }
    }
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Network error. Please connect and try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}



void _showError(String responseBody) {
    final errorResponse = jsonDecode(responseBody);
    final errorMessage = errorResponse['error'] ??
        'Failed to process request. Please try again.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );

    setState(() {
      _isLoading = false; // Stop loading
    });
  }


void _storeClockedInState(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_clockedInKey, value);
}

  Future<void> fetchClockIns() async {
    String apiUrl = '${BASE_URL}/api/admin_clock-in/';
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
        if (mounted) {
          setState(() {
            clockIns = jsonDecode(response.body);
          });
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage =
            errorResponse['error'] ?? 'Failed to load clock-ins.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('You have no internet connection.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
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
      title: Text('Employee Dashboard'),
      actions: [
        if (latitude != null && longitude != null)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Lat: ${latitude!.toStringAsFixed(2)}, Long: ${longitude!.toStringAsFixed(2)}',
                style: TextStyle(color: Color(0xFF2F8E92), fontSize: 13),
              ),
            ),

                       // Display Android ID
            Text(
              _androidId != null ? 'Android ID: $_androidId' : 'Fetching Android ID...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Display Latitude
            Text(
              _latitude != null ? 'Latitude: $_latitude' : 'Fetching latitude...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Display Longitude
            Text(
              _longitude != null ? 'Longitude: $_longitude' : 'Fetching longitude...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
          ),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            setState(() {}); // Reload the page
          },
        ),
      ],
    ),
    drawer: CustomSidebar(),
    body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Breadcrumb(),
            SizedBox(height: 16.0),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
			ElevatedButton.icon(
			  onPressed: () async {
			    await _clockInOrOut();
			  },
			  icon: Icon(clockedIn ? Icons.logout : Icons.check),
			  label: Text(clockedIn ? 'Clock Out' : 'Clock In'),
			  style: ElevatedButton.styleFrom(
			    backgroundColor: Colors.white,
			    shape: RoundedRectangleBorder(
			      borderRadius: BorderRadius.circular(20.0),
			    ),
			  ),
			),

                    SizedBox(height: 16.0),
                    Text(
                      'Your clock-in history',
                      style: TextStyle(color: Colors.blue),
                    ),
                    SizedBox(height: 16.0),
                    _buildAttendanceTable(),
                  ],
                ),
              ),
            ),
           if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildAttendanceTable() {
    if (clockIns.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: Colors.grey),
          const SizedBox(width: 20),
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
            ...clockIns.map((clockIn) {
              return TableRow(
                children: [
                  _buildTableCell(clockIn['name']),
                  _buildTableCell(clockIn['date']),
                  _buildTableCell(clockIn['first_in']),
                  _buildTableCell(clockIn['last_out']),
                ],
              );
            }).toList(),
          ],
        ),
      ],
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
      child: Text(text),
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

