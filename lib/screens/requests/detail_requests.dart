import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../110n/app_localizations.dart';
import '../../utils/color_screen.dart';
import '../../utils/size_screen.dart';

class DetailScreen extends StatefulWidget {
  final String userId;
  final String requestId;
  final Map<String, dynamic> request;

  const DetailScreen({
    Key? key,
    required this.userId,
    required this.requestId,
    required this.request,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isLoading = false;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchRequestStream();
  }

  Stream<DocumentSnapshot> fetchRequestStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('requests')
        .doc(widget.requestId)
        .snapshots();
  }

  Stream<DocumentSnapshot> fetchUserStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .snapshots();
  }

  Future<void> clearSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
    await prefs.remove('currentRequestId');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: ScreenSize(context).height * 0.30,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ScreenColor.color6,
                      ScreenColor.color6.withOpacity(0.2),
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
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Details',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).translate('wait_subtitle'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Information
                      StreamBuilder<DocumentSnapshot>(
                        stream: fetchUserStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }

                          if (!snapshot.hasData || snapshot.data == null) {
                            return const Center(child: Text('No user data available'));
                          }

                          final userData = snapshot.data!.data() as Map<String, dynamic>;

                          return _buildSectionCard(
                            title: 'User Information',
                            content: Column(
                              children: [
                                _buildInfoTile('Name', userData['name'] ?? 'No name provided'),
                                _buildInfoTile('Phone', userData['phone'] ?? 'No phone provided'),
                                _buildInfoTile('Address', userData['address'] ?? 'No address provided'),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Request Information
                      StreamBuilder<DocumentSnapshot>(
                        stream: fetchRequestStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }

                          if (!snapshot.hasData || snapshot.data == null) {
                            return const Center(child: Text('No request data available'));
                          }

                          final requestData = snapshot.data!.data() as Map<String, dynamic>;

                          return _buildSectionCard(
                            title: 'Request Information',
                            content: Column(
                              children: [
                                _buildInfoTile('Service', requestData['service'] ?? 'No service provided'),
                                _buildInfoTile('Date', requestData['date'] ?? 'No date provided'),
                                _buildInfoTile('Time', requestData['time'] ?? 'No time provided'),
                              ],
                            ),
                          );
                        },
                      ),


                      // Button
                      SizedBox(height: 20),
                      StreamBuilder<DocumentSnapshot>(
                        stream: fetchRequestStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }

                          if (!snapshot.hasData || snapshot.data == null) {
                            return const Center(child: Text('No request data available'));
                          }

                          final requestData = snapshot.data!.data() as Map<String, dynamic>;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Cancel Button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(widget.userId)
                                        .collection('requests')
                                        .doc(widget.requestId)
                                        .update({
                                      'status': 'rejected',
                                      'acceptedBy': {
                                        'id': '',
                                        'name': '',
                                        'phone': '',
                                      },
                                    });

                                    await clearSavedState();
                                    Get.snackbar('Canceled', 'The request has been canceled.');
                                    Navigator.pushReplacementNamed(context, '/navbar');
                                  } catch (e) {
                                    Get.snackbar('Error', 'An error occurred: $e');
                                  }
                                },
                                icon: const Icon(Icons.cancel, color: Colors.white),
                                label: const Text(
                                  'Cancel',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 10,
                                ),
                              ),

                              // Complete Button
                              ElevatedButton.icon(
                                onPressed: requestData['status'] == 'completed'
                                    ? () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(widget.userId)
                                        .collection('requests')
                                        .doc(widget.requestId)
                                        .update({'status': 'finished'});

                                    await clearSavedState();
                                    Get.snackbar('Completed', 'The request has been marked as completed.');
                                    Navigator.pushReplacementNamed(context, '/navbar');
                                  } catch (e) {
                                    Get.snackbar('Error', 'An error occurred: $e');
                                  }
                                }
                                    : null, // Disabled if status is not 'completed'
                                icon: const Icon(Icons.check, color: Colors.white),
                                label: const Text(
                                  'Complete',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: requestData['status'] == 'completed'
                                      ? Colors.green
                                      : Colors.grey, // Change color based on status
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 10,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if(isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: Center(
                child: Lottie.asset("assets/lottie/loading.json"),
              ),
            )
        ]),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            ScreenColor.background,
            ScreenColor.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ScreenColor.color6,
              ),
            ),
            const Divider(color: Colors.grey, thickness: 1),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$title:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ScreenColor.color2,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
