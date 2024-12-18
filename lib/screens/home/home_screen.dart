import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  Future<void> _signOut() async {
  await FirebaseAuth.instance.signOut(); // Выход из системы
  Navigator.pushReplacementNamed(context, '/login'); // Перенаправление на экран входа
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: _signOut, icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: Center(child: Text('xfcgfvhbjn'),),
    );
  }
}
