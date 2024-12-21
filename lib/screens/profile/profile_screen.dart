import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import '../../utils/color_screen.dart';
import '../../utils/size_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  late User _currentUser;
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _cachedUserData;

  @override
  void initState() {
    super.initState();
    _getCurrentUserData();
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      print("Пользователь успешно вышел из системы");
    } catch (e) {
      print("Ошибка при выходе: $e");
    }
  }

  Future<void> _getCurrentUserData() async {
    if (_cachedUserData != null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      _currentUser = FirebaseAuth.instance.currentUser!;

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('nurse')
          .doc(_currentUser.uid)
          .get();

      if (snapshot.exists) {
        _cachedUserData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "User data not found";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
        child: Lottie.asset(
          'assets/lottie/loading.json',
          width: 150,
          height: 150,
        ),
      )
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : Column(
        children: [
          Container(
            width: double.infinity,
            height: ScreenSize(context).height * 0.30,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ScreenColor.color6,
                  ScreenColor.color6.withOpacity(0.2)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: ScreenColor.color6.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: _cachedUserData!['photoUrl'] != null
                          ? NetworkImage(_cachedUserData!['photoUrl'])
                          : null,
                      child: _cachedUserData!['photoUrl'] == null
                          ? const Icon(Icons.person,
                          size: 50, color: ScreenColor.color6)
                          : null,
                    ),
                    IconButton(
                        onPressed: ()async{
                          await signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        icon: const Icon(Iconsax.logout,
                            color: Colors.white))
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cachedUserData!['name'] ?? "Unknown User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      _cachedUserData!['email'] ?? "Unknown User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                _buildInfoCard(
                    icon: Iconsax.location,
                    title: "Адрес",
                    value: _cachedUserData!['address'] ?? "Not Available"),
                _buildInfoCard(
                    icon: Icons.apartment,
                    title: "Город",
                    value: _cachedUserData!['city']?.toString() ?? "Not Available"),
                _buildInfoCard(
                    icon: Iconsax.clock,
                    title: "Опыт",
                    value: "${_cachedUserData!['experience'] ?? "Not Available"} лет"),
                _buildInfoCard(
                    icon: Iconsax.call,
                    title: "Телефон",
                    value: _cachedUserData!['phone'] ?? "Not Available"),
                _buildInfoCard(
                    icon: Icons.password,
                    title: "ИИН",
                    value: _cachedUserData!['iin'] ?? "Not Available"),
                _buildInfoCard(
                    icon: Icons.format_align_center,
                    title: "Номер Сертификата",
                    value: _cachedUserData!['certificateNumber'] ?? "Not Available"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String value}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [ScreenColor.background, Colors.white70],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: ScreenColor.color6),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(color: Colors.grey[700])),
      ),
    );
  }
}
