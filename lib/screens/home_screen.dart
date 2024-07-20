import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../location_service.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

Future<void> _requestPermissions(BuildContext context) async {
  print('Checking location permissions...');
  var locationStatus = await Permission.location.status;

  if (locationStatus.isGranted) {
    print('Location permission already granted.');
    Navigator.pushNamed(context, '/login');
  } else if (locationStatus.isDenied) {
    print('Requesting location permission...');
    var newStatus = await Permission.location.request();
    if (newStatus.isGranted) {
      print('Location permission granted.');
      Navigator.pushNamed(context, '/login');
    } else {
      _showPermissionError(context);
    }
  } else if (locationStatus.isPermanentlyDenied) {
    print('Location permission permanently denied.');
    openAppSettings();
  }
}


  void _showPermissionError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location permission is required.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _getDeviceId() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String deviceId = androidInfo.id; 
      print('Device ID: $deviceId');
    } catch (e) {
      print('Error getting device info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFfdeb3d),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/jawabu_logo.jpeg',
                height: 40,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/board.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 240,
                child: CarouselWidget(),
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () async {
                  print('Get started button pressed.');
                  await _requestPermissions(context);
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF773697),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 24.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: const Text(
                  'Get started →',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
            ],
          ),
        ),
      ),
    );
  }
}

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({Key? key}) : super(key: key);

  @override
  _CarouselWidgetState createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentPage < 2) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            CarouselItem(
              title: 'Employee Management',
              subtitle: 'Efficiently manage your workforce with our comprehensive HRMS.',
            ),
            CarouselItem(
              title: 'Time Tracking',
              subtitle: 'Track attendance and time records effortlessly.',
            ),
            CarouselItem(
              title: 'Company Management',
              subtitle: 'Streamline operations with powerful administrative tools.',
            ),
          ],
        ),
        Positioned(
          bottom: 16.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => _buildDot(index)),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8.0,
      width: _currentPage == index ? 24.0 : 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFFfdeb3d) : Colors.grey[400],
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

class CarouselItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const CarouselItem({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

             

