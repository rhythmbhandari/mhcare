import 'package:flutter/material.dart';
import 'addPatientScreen.dart';
import 'patientListScreen.dart';
import 'profileScreen.dart';

/// Main screen for the app for staff users including doctors and receptionists.
class SharedHomeScreen extends StatefulWidget {
  const SharedHomeScreen({super.key});

  @override
  SharedHomeScreenState createState() => SharedHomeScreenState();
}

class SharedHomeScreenState extends State<SharedHomeScreen> {
  int _currentIndex = 0;

  // List of screens to be displayed for each tab.
  final List<Widget> _screens = [
    const PatientListScreen(),
    AddPatientScreen(),
    const UserInfoScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Displays the currently selected screen.
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
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
        currentIndex: _currentIndex,
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
