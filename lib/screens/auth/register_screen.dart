import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../110n/app_localizations.dart';
import '../../utils/color_screen.dart';
import '../../utils/size_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Добавляем поле `registeredFromApp` в Firestore
      await FirebaseFirestore.instance
          .collection('nurse')
          .doc(userCredential.user!.uid)
          .set({
        'email': _emailController.text.trim(),
        'status': 'pending',
        'registeredFromApp': true, // Поле указывает, что пользователь зарегистрирован через это приложение
      });

      Navigator.pushReplacementNamed(context, '/waiting');
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Ошибка", "Не удалось зарегистрироваться. Проверьте данные.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Text(
                  AppLocalizations.of(context).translate('register'),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: ScreenColor.color2,
                  ),
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
                  text: AppLocalizations.of(context).translate('register'),
                  onPressed: _register,
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
                width: 100,
                height: 100,
              ),
            ),
          ),
      ]),
    );
  }
}

