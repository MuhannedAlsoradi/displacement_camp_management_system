import 'package:displacement_camp_management_system/screen/camps_management_Screen.dart';
import 'package:displacement_camp_management_system/screen/login_screen.dart';
import 'package:displacement_camp_management_system/screen/screens.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Screens());
  }
}
