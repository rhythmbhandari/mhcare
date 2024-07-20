import 'package:david/screens/patient/heartRate.dart';
import 'package:flutter/material.dart';

import 'diagnosisScreen.dart';
import 'messagesScreen.dart';
import 'profileScreen.dart';

/// Main screen for the app for patient users.
class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  PatientHomeScreenState createState() => PatientHomeScreenState();
}

class PatientHomeScreenState extends State<PatientHomeScreen> {
  // Index to track the selected tab in the BottomNavigationBar

  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DiagnosisScreen(),
    const MessagesScreen(),
    const HeartRateScreen(),
    const PersonalInformationScreen(),
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
        currentIndex: _selectedIndex, // Highlight the currently selected tab
        selectedItemColor: Colors.blueGrey[800],
        unselectedItemColor: Colors.blueGrey[400],
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
