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
import 'dart:math';

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
  static const String _clockedInKey = 'clockedIn';
  DateTime selectedDate = DateTime.now();
  String keyword = '';
  double? latitude;
  double? longitude;
  bool clockedIn = false;
  List<dynamic> clockIns = [];  // Ensure this is defined
  String? userId;
  String _deviceID = 'Loading...';  // Device ID variable
  String? _androidId;

  @override
  void initState() {
    super.initState();
    _loadClockedInState();
    fetchUserData();
    fetchClockIns();
    getOrCreateUUID().then((id) {
      _androidId = id; 
    });
    _getDeviceID();  // Initialize device ID
  }

  Future<void> _getDeviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      _deviceID = androidInfo.id;  // Use device ID
    });
  }

  Future<bool> isSdk30OrHigher() async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    return build.version.sdkInt >= 30;
  }

  Future<String> getOrCreateUUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString('uuid');

    if (uuid == null) {
      uuid = _generateUUID();
      await prefs.setString('uuid', uuid);
    }
    return uuid;
  }

  String _generateUUID() {
    return base64Url.encode(List<int>.generate(16, (index) => Random().nextInt(256)));
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
      });
    }
  }

  Future<void> _clockInOrOut() async {
    setState(() {
      _isLoading = true;
    });
    final clockUrl = Uri.parse('${BASE_URL}/api/admin_clock-in/');
    final token = await getToken();

    final clockData = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'device_id': _deviceID,  // Include device ID
      'imei': _androidId,
    };

    try {
      if (clockedIn) {
        // Clock Out
        clockData['last_out'] = DateFormat('HH:mm:ss').format(DateTime.now());

        final response = await http.post(
          clockUrl,
          body: jsonEncode(clockData),
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
        clockData['first_in'] = DateFormat('HH:mm:ss').format(DateTime.now());

        final response = await http.post(
          clockUrl,
          body: jsonEncode(clockData),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            clockedIn = true;
            _isLoading = false;
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
    final errorMessage = errorResponse['error'] ?? 'Failed to process request. Please try again.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );

    setState(() {
      _isLoading = false;
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
        final errorMessage = errorResponse['error'] ?? 'Failed to load clock-ins.';

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
          content: Text('You have no internet connection.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);

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
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
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
                      Text(
                        'Device ID: $_deviceID',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _clockInOrOut();
                        },
                        icon: Icon(clockedIn ? Icons.logout : Icons.check),
                        label: Text(clockedIn ? 'Clock Out' : 'Clock In'),
                      ),
                      SizedBox(height: 16.0),
                      if (_isLoading)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: LinearProgressIndicator(),
                        ),
                      SizedBox(height: 16.0),
                      Text(
                        'Clock-In Records:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
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

  Widget _buildAttendanceTable() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (clockIns.isEmpty) {
      return Center(child: Text('No clock-ins found.'));
    }

    return Table(
      border: TableBorder.all(),
      columnWidths: {
        0: FixedColumnWidth(80.0),
        1: FixedColumnWidth(100.0),
        2: FixedColumnWidth(100.0),
        3: FixedColumnWidth(150.0),
      },
      children: [
        TableRow(
          children: [
            _buildTableHeaderCell('Date'),
            _buildTableHeaderCell('First In'),
            _buildTableHeaderCell('Last Out'),
            _buildTableHeaderCell('Location'),
          ],
        ),
        ...clockIns.map<TableRow>((entry) {
          return TableRow(
            children: [
              _buildTableCell(entry['date'] ?? ''),
              _buildTableCell(entry['first_in'] ?? ''),
              _buildTableCell(entry['last_out'] ?? ''),
              _buildTableCell(
                entry['latitude'] != null && entry['longitude'] != null
                    ? '(${entry['latitude']}, ${entry['longitude']})'
                    : 'Location unavailable',
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text),
      ),
    );
  }
}

class Breadcrumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Home > ',
          style: TextStyle(color: Colors.blue),
        ),
        Text(
          'Attendance',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
