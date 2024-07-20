import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../services/authService.dart';
import '../../widgets/buttonwidget.dart';
import '../../widgets/customtextfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  final _idNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

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
      _showSnackBar('Please fill all fields', Colors.red);
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final user =
          await _authService.login(idNumber: idNumber, password: password);

      if (user != null) {
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
            _showSnackBar('Unknown user role', Colors.red);
            setState(() {
              _loading = false;
            });
            return;
        }

        Navigator.pushReplacementNamed(context, routeName);
      }
    } catch (e) {
      _showSnackBar(e.toString(), Colors.red);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SvgPicture.asset(
                    'assets/heart.svg',
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Please enter your credentials'),
                const SizedBox(height: 18),
                CustomTextFormField(
                  labelText: 'ID Number',
                  enabled: true,
                  readOnly: false,
                  onChanged: (_) {},
                  textInputType: TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                  ],
                  textController: _idNumberController,
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
                ButtonsWidget(
                  name: 'Login',
                  onPressed: _login,
                  isLoading: _loading,
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
        ),
      ),
    );
  }
}
