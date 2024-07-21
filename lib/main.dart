import 'package:flutter/material.dart';
import 'screens/authentication/loginScreen.dart';
import 'screens/patient/heartRateHistoryScreen.dart';
import 'screens/patient/patientHomeScreen.dart';
import 'screens/authentication/registerStaffScreen.dart';
import 'screens/staff/shared_home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Ensures that widget binding is initialized before running the application.
  WidgetsFlutterBinding.ensureInitialized();

  // Initializing our Postgres SQL with the db url and key.
  await Supabase.initialize(
      url: 'https://ggbfkcefnyvtuebpdshe.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdnYmZrY2Vmbnl2dHVlYnBkc2hlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE0NDIxNjcsImV4cCI6MjAzNzAxODE2N30.Pr-CLGgbVxIuxzGO0JCwFD3hH707zAv0KQMVK_3Xcso');

  // Runs the app
  runApp(const MHCareApp());
}

class MHCareApp extends StatelessWidget {
  const MHCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MH-Care',
      debugShowCheckedModeBanner: false, // Removes the debug banner
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.teal,
        buttonTheme: const ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      initialRoute: '/', // Default route is LoginScreen
      routes: {
        '/': (context) => const LoginScreen(),
        '/shared_home': (context) => const SharedHomeScreen(),
        '/register': (context) => const RegistrationPage(),
        '/patient_home': (context) => const PatientHomeScreen(),
        '/measurement_history': (context) => const HeartMeasurementsScreen(),
      },
    );
  }
}
