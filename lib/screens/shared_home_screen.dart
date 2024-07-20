import 'package:flutter/material.dart';

import 'staff/addDiagnosisScreen.dart';
import 'staff/addPatientScreen.dart';
import 'staff/patientListScreen.dart';
import 'staff/profileScreen.dart';

class SharedHomeScreen extends StatefulWidget {
  @override
  _SharedHomeScreenState createState() => _SharedHomeScreenState();
}

class _SharedHomeScreenState extends State<SharedHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    PatientListScreen(),
    AddPatientScreen(),
    UserInfoScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.teal,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Patient List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Patient',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'User Info',
          ),
        ],
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        unselectedItemColor: Colors.grey.shade400,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
