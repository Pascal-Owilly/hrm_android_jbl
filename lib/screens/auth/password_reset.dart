import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Reset',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamSubscription _sub;


  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  void _initDeepLinkListener() {
     _sub = getLinksStream().listen((String? link) {
      if (link != null) {
        _handleDeepLink(link);
      }
    }, onError: (err) {
      print('Failed to get deep link: $err');
    });
  }

void _handleDeepLink(String? link) {
  if (link != null) {
    final uri = Uri.parse(link);
    if (uri.scheme == 'myapp' && uri.host == 'reset_password') {
      final uidb64 = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
      final token = uri.pathSegments.length > 2 ? uri.pathSegments[2] : '';

      // Navigate to the password reset screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordResetScreen(uidb64: uidb64, token: token),
        ),
      );
    } else {
      print('Invalid or unsupported deep link: $link');
    }
  } else {
    print('Null deep link received');
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Reset'),
      ),
      body: const Center(
        child: Text('Home Screen'),
      ),
    );
  }
}

class PasswordResetScreen extends StatelessWidget {
  final String uidb64;
  final String token;

  const PasswordResetScreen({super.key, required this.uidb64, required this.token});

  @override
  Widget build(BuildContext context) {
    // Implement your password reset form here
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Center(
        child: Text('UID: $uidb64, Token: $token'),
      ),
    );
  }
}
