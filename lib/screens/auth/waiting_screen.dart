import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_routes.dart';

class WaitingScreen extends StatelessWidget {
  const WaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Если пользователь не авторизован, сразу перенаправляем на login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.login);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('nurse')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка загрузки данных. Пожалуйста, попробуйте снова.'),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            // Если документа нет, перенаправляем на login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed(AppRoutes.login);
            });
            return const SizedBox.shrink();
          }

          // Преобразуем данные в Map<String, dynamic>
          final Map<String, dynamic>? userData =
          snapshot.data!.data() as Map<String, dynamic>?;

          // Получаем статус
          final status = userData?['status'];

          if (status == 'approved') {
            // Если статус "approved", перенаправляем на home
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed(AppRoutes.home);
            });
          } else if (status == 'rejected') {
            // Если статус "rejected", перенаправляем на login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed(AppRoutes.login);
            });
          }

          // Пока статус "pending", остаемся на экране ожидания
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text(
                  'Ожидайте, пока администратор обработает вашу заявку...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}