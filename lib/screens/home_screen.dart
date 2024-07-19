import 'dart:async'; // For Timer
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFfdeb3d), // Set AppBar background color
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/jawabu_logo.jpeg', // Replace with your logo asset
                height: 40, // Adjust size as needed
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
              // Carousel
              SizedBox(
                height: 240, // Adjust height as needed
                child: CarouselWidget(),
              ),
              const SizedBox(height: 30.0), // Adjust space between carousel and button
              // Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login'); // Navigate to login screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF773697), // Button color
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
                    color: Colors.white, // Text color
                  ),
                ),
              ),
              const SizedBox(height: 50.0), // Space below button
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

class CarouselItem extends StatefulWidget {
  final String title;
  final String subtitle;

  const CarouselItem({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  _CarouselItemState createState() => _CarouselItemState();
}

class _CarouselItemState extends State<CarouselItem> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startFadeAnimation();
  }

  void _startFadeAnimation() {
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      setState(() {
        _opacity = _opacity == 1.0 ? 0.0 : 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Text color
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.white, // Text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}

