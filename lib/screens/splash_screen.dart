import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/app_routes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _checkUserStatus();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Загрузка...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Задержка на 2 секунды

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Если пользователь не авторизован, перенаправляем на Login
      _navigateTo(AppRoutes.login);
      return;
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('nurse')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        final Map<String, dynamic>? userData =
        docSnapshot.data() as Map<String, dynamic>?;
        final status = userData?['status'];

        if (status == 'approved') {
          // Статус "approved" -> Home
          _navigateTo(AppRoutes.home);
        } else if (status == 'pending') {
          // Статус "pending" -> WaitingScreen
          _navigateTo(AppRoutes.waiting);
        } else {
          // Все остальные статусы -> Login
          _navigateTo(AppRoutes.login);
        }
      } else {
        // Документ не найден -> Login
        _navigateTo(AppRoutes.login);
      }
    } catch (e) {
      // Ошибка -> Login
      _navigateTo(AppRoutes.login);
    }
  }

  void _navigateTo(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed(route);
    });
  }
}