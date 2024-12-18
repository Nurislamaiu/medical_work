import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../110n/app_localizations.dart';
import '../../utils/color_screen.dart';
import '../../utils/size_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/nav-bar');
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Ошибка", "Неизвестная ошибка");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: ScreenColor.white,
        body: Stack(children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/logo.png',
                      height: ScreenSize(context).width * 0.4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate('title1'),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: ScreenColor.color2,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).translate('your_detail'),
                        style:
                        TextStyle(fontSize: 16, color: ScreenColor.color2),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  CustomTextField(
                    controller: _emailController,
                    label: AppLocalizations.of(context).translate('email'),
                    icon: Icons.email,
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    label: AppLocalizations.of(context).translate('password'),
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  SizedBox(height: 30),
                  CustomButton(
                    text: AppLocalizations.of(context).translate('login'),
                    onPressed: _login,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        ///
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('no_account'),
                        style: TextStyle(color: ScreenColor.color2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Center(
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  // Add the path to your Lottie file
                  width: 100,
                  height: 100,
                ),
              ),
            ),
        ]),
      ),
    );
  }
}