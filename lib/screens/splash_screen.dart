import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicall_work/screens/requests/detail_requests.dart';
import 'package:medicall_work/utils/size_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Image.asset(
              'assets/images/logo.png',
              height: ScreenSize(context).height * 0.3,
              fit: BoxFit.cover,
            ),
            Spacer(),
            Text(
              'Med Call',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: ScreenSize(context).height * 0.1),
          ],
        ),
      ),
    );
  }

  void _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 1));

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Если пользователь не авторизован, перенаправляем на Login
      _navigateTo(AppRoutes.login);
      return;
    }

    try {
      // Проверяем, сохранено ли состояние для DetailScreen
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('currentUserId');
      final savedRequestId = prefs.getString('currentRequestId');

      if (savedUserId != null && savedRequestId != null) {
        // Если данные найдены, проверяем их наличие в Firestore
        final requestDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(savedUserId)
            .collection('requests')
            .doc(savedRequestId)
            .get();

        if (requestDoc.exists) {
          final requestData = requestDoc.data();
          if (requestData != null) {
            Get.offAll(() => DetailScreen(
              userId: savedUserId,
              requestId: savedRequestId,
              request: requestData,
            ));
            return;
          }
        }
      }

      // Если сохраненные данные не найдены, продолжаем обычную проверку
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
          _navigateTo(AppRoutes.navBar);
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
    Get.offAllNamed(route);
  }
}