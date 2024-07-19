// lib/styles.dart
import 'package:flutter/material.dart';

// Define text styles
const TextStyle kTitleTextStyle = TextStyle(
  color: Colors.black,
  fontSize: 24.0,
  fontWeight: FontWeight.bold,
);

const TextStyle kSubtitleTextStyle = TextStyle(
  color: Colors.grey,
  fontSize: 16.0,
);

const TextStyle kBodyTextStyle = TextStyle(
  color: Colors.black87,
  fontSize: 14.0,
);

const TextStyle kButtonTextStyle = TextStyle(
  color: Colors.black,
  fontSize: 12.0,
);

// Define button styles

// Define container decorations
const BoxDecoration kDrawerHeaderDecoration = BoxDecoration(
  gradient: LinearGradient(
    colors: [Color(0xFF773697), Color(0xFF773697)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  ),
);

const BoxDecoration kCardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(8.0)),
  boxShadow: [
    BoxShadow(
      color: Colors.grey,
      blurRadius: 5.0,
      offset: Offset(0, 2),
    ),
  ],
);

const BoxDecoration kContainerDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(8.0)),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 5.0,
      offset: Offset(0, 2),
    ),
  ],
);

// ListTile style

// Input decoration
const InputDecoration kInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.black54),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Colors.grey, width: 1.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: Colors.blue, width: 1.0),
  ),
);

