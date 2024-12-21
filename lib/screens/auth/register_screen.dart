import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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
  final _formKey = GlobalKey<FormState>(); // GlobalKey for Form validation


  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _iinController = TextEditingController();
  final _nameController = TextEditingController();
  final _certificateNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _experienceController = TextEditingController();

  bool _isLoading = false;

  final phoneFormatter = MaskTextInputFormatter(
    mask: '+7 ### ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final iinFormatter = MaskTextInputFormatter(
    mask: '## ## ## ### ###',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final experienceFormatter = MaskTextInputFormatter(
    mask: '##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if the form is not valid
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('nurse')
          .doc(userCredential.user!.uid)
          .set({
        'email': _emailController.text.trim(),
        'iin': _iinController.text.trim(),
        'name': _nameController.text.trim(),
        'certificateNumber': _certificateNumberController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _cityController.text.trim(),
        'experience': _experienceController.text.trim(),
        'status': 'pending',
        'registeredFromApp': true,
      });

      Navigator.pushReplacementNamed(
        context,
        '/waiting',
        arguments: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        AppLocalizations.of(context).translate('error'),
        e.message ?? AppLocalizations.of(context).translate('error_info_screen'),
      );
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
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Form( // Wrap with Form
                key: _formKey,
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
                    Text(
                      AppLocalizations.of(context).translate('register_description'),
                      style: const TextStyle(
                        fontSize: 16,
                        color: ScreenColor.color2,
                      ),
                    ),
                    SizedBox(height: 30),
                    CustomTextField(
                      controller: _emailController,
                      label: AppLocalizations.of(context).translate('email'),
                      icon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)
                              .translate('field_cannot_be_empty');
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return AppLocalizations.of(context).translate('invalid_email');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _passwordController,
                      label: AppLocalizations.of(context).translate('password'),
                      icon: Icons.lock,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)
                              .translate('field_cannot_be_empty');
                        }
                        if (value.length < 6) {
                          return AppLocalizations.of(context)
                              .translate('password_too_short');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _iinController,
                      label: AppLocalizations.of(context).translate('iin'),
                      icon: Iconsax.fatrows,
                      type: TextInputType.number,
                      inputFormatters: [iinFormatter],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)
                              .translate('field_cannot_be_empty');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _nameController,
                      label: AppLocalizations.of(context).translate('name'),
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)
                              .translate('field_cannot_be_empty');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _certificateNumberController,
                      label: AppLocalizations.of(context)
                          .translate('number_sertificate'),
                      icon: Icons.book,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)
                              .translate('field_cannot_be_empty');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _phoneController,
                      label: AppLocalizations.of(context).translate('phone'),
                      icon: Icons.phone,
                      type: TextInputType.phone,
                      inputFormatters: [phoneFormatter],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)
                              .translate('field_cannot_be_empty');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _cityController,
                      suffixIcon: Icons.location_on_outlined,
                      label: AppLocalizations.of(context)
                          .translate('address'),
                      icon: Icons.location_city,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)
                              .translate('field_cannot_be_empty');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _experienceController,
                      label: AppLocalizations.of(context).translate('experience'),
                      icon: Icons.work,
                      type: TextInputType.number,
                      inputFormatters: [experienceFormatter],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)
                              .translate('field_cannot_be_empty');
                        }
                        return null;
                      },
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
          ),
          if (_isLoading)
            Positioned.fill(
              child: Center(
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  height: ScreenSize(context).height * 0.5
                ),
              ),
            ),
        ],
      ),
    );
  }
}