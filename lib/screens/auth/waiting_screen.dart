import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:medicall_work/utils/color_screen.dart';
import 'package:medicall_work/utils/size_screen.dart';
import '../../110n/app_localizations.dart';
import '../../app/app_routes.dart';

class WaitingScreen extends StatelessWidget {
  const WaitingScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, String>? ?? {};
    final email = arguments['email'] ?? '';
    final password = arguments['password'] ?? '';


    // Функция для повторной аутентификации
    Future<void> reauthenticateUser(String email, String password) async {
      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
          await user.reauthenticateWithCredential(credential);
          print("Пользователь успешно повторно аутентифицирован.");
        } else {
          print("Пользователь не авторизован.");
        }
      } catch (e) {
        print("Ошибка повторной аутентификации: $e");
      }
    }

// Удаление данных из Firestore
    Future<void> deleteCurrentUserDataFromFirestore() async {
      try {
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          String userId = currentUser.uid;

          // Удаление документа пользователя
          await FirebaseFirestore.instance.collection('nurse').doc(userId).delete();
          print("Данные пользователя успешно удалены из Firestore.");
        } else {
          print("Пользователь не авторизован.");
        }
      } catch (e) {
        print("Ошибка при удалении данных пользователя из Firestore: $e");
      }
    }

// Удаление пользователя из Authentication
    Future<void> deleteCurrentUserFromAuthentication() async {
      try {
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          await currentUser.delete();
          print("Пользователь успешно удалён из Authentication.");
        } else {
          print("Пользователь не авторизован.");
        }
      } catch (e) {
        print("Ошибка при удалении пользователя из Authentication: $e");
      }
    }

// Полное удаление пользователя
    Future<void> deleteCurrentUser(String email, String password) async {
      try {
        // Повторная аутентификация
        await reauthenticateUser(email, password);

        // Удаление данных из Firestore
        await deleteCurrentUserDataFromFirestore();

        // Удаление пользователя из Authentication
        await deleteCurrentUserFromAuthentication();

        print("Пользователь и его данные успешно удалены.");
      } catch (e) {
        print("Ошибка при полном удалении пользователя: $e");
      }
    }

    if (user == null) {
      // Если пользователь не авторизован, сразу перенаправляем на login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.login);
      });
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: ScreenSize(context).height * 0.30,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                ScreenColor.color6,
                ScreenColor.color6.withOpacity(0.2)
              ],begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: ScreenColor.color6.withOpacity(0.5),
                  blurRadius: 20,
                  offset: Offset(0, 10)
                )
              ]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context).translate('wait_title'), style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ScreenColor.white
                    ),),
                    IconButton(onPressed: ()=> deleteCurrentUser(email, password), icon: Icon(Icons.close, color: Colors.white,))
                  ],
                ),
                Text(AppLocalizations.of(context).translate('wait_subtitle'), style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: ScreenColor.white
                ),)
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('nurse')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: Lottie.asset('assets/lottie/loading.json'));
                }
            
                if (snapshot.hasError) {
                  return Center(
                    child: Text(AppLocalizations.of(context).translate('wait_error_data')),
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
                    Get.offAllNamed(AppRoutes.navBar);
                  });
                } else if (status == 'rejected') {
                  // Если статус "rejected", перенаправляем на login
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Get.offAllNamed(AppRoutes.login);
                  });
                }
            
                // Пока статус "pending", остаемся на экране ожидания
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/lottie/waiting.json',
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context).translate('please_wait'),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}