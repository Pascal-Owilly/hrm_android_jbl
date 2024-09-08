import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// API Endpoints
final postClockUrl = Uri.parse('${BASE_URL}/api/admin_clock-in/');
final fetchClockIns = Uri.parse('${BASE_URL}/api/admin_clock-in/');

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool clockedIn = false;
  bool otpSent = false;
  double? latitude;
  double? longitude;
  String? otp;
  TextEditingController otpController = TextEditingController();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Fetch location
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  // Clock In/Out request
  Future<void> _clockInOut() async {
    final response = await http.post(
      postClockUrl,
      body: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        if (otpSent) 'otp': otpController.text,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['otp_sent'] != null) {
        setState(() {
          otpSent = true;
          clockedIn = !clockedIn;
        });
        _showMessage('OTP sent, please enter it to verify.');
      } else if (data['error'] != null) {
        setState(() {
          errorMessage = data['error'];
        });
        _showMessage(data['error'], isError: true);
      }
    } else {
      _showMessage('Error: Failed to clock in/out.', isError: true);
    }
  }

  // Show message
  void _showMessage(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Clock In/Out',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            if (otpSent)
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _clockInOut,
              child: clockedIn
                  ? Text('Clock Out')
                  : Text('Clock In'),
              style: ElevatedButton.styleFrom(
                primary: clockedIn ? Colors.red : Colors.green,
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 20),
            Divider(),
            Text(
              'Your clock-in history',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            // The history section could be implemented here
            // You can fetch the history using fetchClockIns API call
          ],
        ),
      ),
    );
  }
}
