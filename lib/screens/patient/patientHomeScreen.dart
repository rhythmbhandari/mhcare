import 'package:david/screens/patient/heartRate.dart';
import 'package:flutter/material.dart';

import 'diagnosisScreen.dart';
import 'messagesScreen.dart';
import 'profileScreen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  _PatientHomeScreenState createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DiagnosisScreen(),
    MessagesScreen(), // Placeholder
    HeartRateScreen(),
    PersonalInformationScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Diagnosis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Heart Rate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Personal Info',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueGrey[800], // Updated color
        unselectedItemColor: Colors.blueGrey[400], // Updated color
        showUnselectedLabels: false,
        backgroundColor: Colors.white, // Updated color for background
        elevation: 8, // Slight elevation for shadow effect
        type: BottomNavigationBarType
            .fixed, // Fixed type for consistent icon size
        onTap: _onItemTapped,
      ),
    );
  }
}
