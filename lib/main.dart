import 'package:flutter/material.dart';
import 'screens/loginScreen.dart';
import 'screens/patientHomeScreen.dart';
import 'screens/registerStaffScreen.dart';
import 'screens/shared_home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://ggbfkcefnyvtuebpdshe.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdnYmZrY2Vmbnl2dHVlYnBkc2hlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE0NDIxNjcsImV4cCI6MjAzNzAxODE2N30.Pr-CLGgbVxIuxzGO0JCwFD3hH707zAv0KQMVK_3Xcso');
  runApp(MHCareApp());
}

class MHCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MH-Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      routes: {
        '/shared_home': (context) => SharedHomeScreen(),
        '/register': (context) => RegistrationPage(),
        '/patient_home': (context) => PatientHomeScreen(),
      },
    );
  }
}
