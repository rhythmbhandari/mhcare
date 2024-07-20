import 'package:david/services/authService.dart';
import 'package:flutter/material.dart';
import '../../widgets/buttonwidget.dart';
import '../../widgets/customtextfield.dart';

/// A screen for registering a new staff.
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'Doctor'; // Default selected role
  bool _loading = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Handles user registration

  Future<void> _register() async {
    setState(() {
      _loading = true;
    });

    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();

    if (password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill all fields'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      // Attempt to register the user

      final response = await _authService.register(
        name: name,
        password: password,
        role: _selectedRole,
      );
      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: Colors.green,
        ));
        await _authService.login(idNumber: response, password: password);
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, '/shared_home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Registration failed'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(''),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Register',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 18),
                const Text(
                  'Please enter your details',
                ),
                const SizedBox(height: 18),
                CustomTextFormField(
                  labelText: 'Name',
                  enabled: true,
                  readOnly: false,
                  onChanged: (_) {},
                  textInputType: TextInputType.text,
                  inputFormatters: const [],
                  textController: _nameController,
                ),
                const SizedBox(height: 18),
                CustomTextFormField(
                  labelText: 'Password',
                  errorBool: false,
                  readOnly: false,
                  obscureText: true,
                  onChanged: (_) {},
                  textInputType: TextInputType.text,
                  inputFormatters: [],
                  textController: _passwordController,
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.only(left: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue!;
                      });
                    },
                    underline: const SizedBox(),
                    isExpanded: true,
                    items: <String>['Doctor', 'Receptionist']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.black87),
                        ),
                      );
                    }).toList(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.black87),
                    dropdownColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                ButtonsWidget(
                  name: 'Register',
                  onPressed: _register,
                  isLoading: _loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
