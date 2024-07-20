import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

import '../../models/user.dart';
import '../../services/databaseService.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  final _idNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _idNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
    });

    final idNumber = _idNumberController.text.trim();
    final password = _passwordController.text.trim();

    if (password.isEmpty || idNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id_number', idNumber)
          .maybeSingle();

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User does not exist'),
          backgroundColor: Colors.red,
        ));
        setState(() {
          _loading = false;
        });
        return;
      }

      final user = UserModel.fromJson(response);

      final storedPasswordHash = user.passwordHash;

      log("Here");
      log(response.toString());
      if (BCrypt.checkpw(password, storedPasswordHash)) {
        SharedPreferenceService().saveUser(user);

        String routeName;

        switch (user.role) {
          case 'receptionist':
          case 'doctor':
            routeName = '/shared_home';
            break;
          case 'patient':
            routeName = '/patient_home';
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Unknown user role'),
              backgroundColor: Colors.red,
            ));
            setState(() {
              _loading = false;
            });
            return;
        }

        Navigator.pushReplacementNamed(context, routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Invalid password'),
          backgroundColor: Colors.red,
        ));
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login failed: ${e.message}'),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An unexpected error occurred'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _idNumberController,
                    decoration: const InputDecoration(label: Text('Id Number')),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(label: Text('Password')),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Register as Staff'),
                  ),
                ],
              ),
            ),
    );
  }
}
