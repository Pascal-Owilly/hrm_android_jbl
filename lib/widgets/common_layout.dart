import 'package:flutter/material.dart';

class CommonLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget drawer; // Add a drawer parameter
  final TextStyle? titleStyle; // Add titleStyle parameter

  const CommonLayout({super.key, 
    required this.child,
    required this.title,
    required this.drawer,
    this.titleStyle, // Make titleStyle optional
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: titleStyle, // Apply titleStyle to the AppBar's title
        ),
      ),
      drawer: drawer, // Use the passed drawer widget
      body: child,
      backgroundColor: const Color(0xFFFDEB3D),
    );
  }
}

