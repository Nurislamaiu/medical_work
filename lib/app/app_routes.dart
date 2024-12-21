import 'package:flutter/material.dart';
import 'package:medicall_work/nav_bar.dart';
import 'package:medicall_work/screens/auth/register_screen.dart';
import 'package:medicall_work/screens/auth/waiting_screen.dart';

import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String waiting = '/waiting';
  static const String navBar = '/navbar';
  static const String home = '/home';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> getRoutes(){
    return {
      splash: (context) => SplashScreen(),
      login: (context) => LoginScreen(),
      register: (context) => RegisterScreen(),
      waiting: (context) => WaitingScreen(),
      navBar: (context) => NavBarScreen(),
      home: (context) => HomeScreen(),
      profile: (context) => ProfileScreen(),
    };
  }
}