import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../utils/color_screen.dart';
import '../../utils/size_screen.dart';
import '../../110n/app_localizations.dart';
import '../requests/detail_requests.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkSavedState();
  }

  Future<void> _checkSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('currentUserId');
    final savedRequestId = prefs.getString('currentRequestId');

    if (savedUserId != null && savedRequestId != null) {
      // Переход на DetailScreen, если есть сохраненное состояние
      final requestDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(savedUserId)
          .collection('requests')
          .doc(savedRequestId)
          .get();

      if (requestDoc.exists) {
        final requestData = requestDoc.data();
        if (requestData != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                userId: savedUserId,
                requestId: savedRequestId,
                request: requestData,
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _acceptRequest(BuildContext context, String userId,
      String requestId, Map<String, dynamic> request) async {
    try {
      // Получаем текущего пользователя
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Получаем данные текущего пользователя из Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('nurse')
          .doc(currentUser.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData == null) {
        throw Exception('User data not found');
      }

      // Извлекаем необходимые данные
      final String userName = userData['name'] ?? 'Unknown';
      final String userPhone = userData['phone'] ?? 'Unknown';

      // Обновляем заявку с данными текущего пользователя
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('requests')
          .doc(requestId)
          .update({
        'status': 'accepted',
        'acceptedBy': {
          'id': currentUser.uid,
          'name': userName,
          'phone': userPhone,
        },
      });

      // Сохраняем состояние
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserId', userId);
      await prefs.setString('currentRequestId', requestId);

      // Переход на экран деталей
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(
            userId: userId,
            requestId: requestId,
            request: request,
          ),
        ),
      );
    } catch (e) {
      print('Error updating request status: $e');
    }
  }

  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  final DateFormat customDateFormat = DateFormat('dd.MM.yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Container
          Container(
            width: double.infinity,
            height: ScreenSize(context).height * 0.30,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ScreenColor.color6,
                  ScreenColor.color6.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
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
                  offset: Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Добро пожаловать',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ScreenColor.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Пожалуйста, выберите удобную для вас заявку',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ScreenColor.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Calendar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TableCalendar(
              focusedDay: _selectedDate,
              firstDay: DateTime.now(),
              lastDay: DateTime.utc(2100, 12, 31),
              calendarFormat: _calendarFormat,
              headerVisible: false,
              availableCalendarFormats: const {
                CalendarFormat.week: 'Week',
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: ScreenColor.color6,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // StreamBuilder для заявок
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final userDocs = snapshot.data!.docs;

                return userDocs.isEmpty
                    ? Center(
                        child: Lottie.asset(
                          'assets/lottie/job.json',
                          // Укажите путь к вашему файлу анимации
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ListView.builder(
                        itemCount: userDocs.length,
                        itemBuilder: (context, userIndex) {
                          final userDoc = userDocs[userIndex];
                          final userId = userDoc.id;
                          final userData =
                              userDoc.data() as Map<String, dynamic>;
                          final userAddress =
                              userData['address'] ?? 'No address provided';
                          final userName =
                              userData['name'] ?? 'No name provided';

                          return StreamBuilder<QuerySnapshot>(
                            stream: userDoc.reference
                                .collection('requests')
                                .snapshots(),
                            builder: (context, requestSnapshot) {
                              if (requestSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (!requestSnapshot.hasData ||
                                  requestSnapshot.data!.docs.isEmpty) {
                                return Container();
                              }

                              final requests = requestSnapshot.data!.docs
                                  .map((requestDoc) {
                                    final requestData = requestDoc.data()
                                        as Map<String, dynamic>;

                                    if (requestData.containsKey('date') &&
                                        requestData['status'] != 'accepted') {
                                      try {
                                        final date = customDateFormat
                                            .parse(requestData['date']);
                                        if (date.year == _selectedDate.year &&
                                            date.month == _selectedDate.month &&
                                            date.day == _selectedDate.day) {
                                          return {
                                            'user': userId,
                                            'address': userAddress,
                                            'name': userName,
                                            'requestId': requestDoc.id,
                                            'request': requestData,
                                            'date': date,
                                          };
                                        }
                                      } catch (e) {
                                        print(
                                            'Error parsing date: ${requestData['date']}');
                                      }
                                    }
                                    return null;
                                  })
                                  .where((request) => request != null)
                                  .toList();

                              if (requests.isEmpty) {
                                return Center(
                                  child: Column(
                                    children: [
                                      Lottie.asset(
                                        'assets/lottie/job.json',
                                        height:
                                            ScreenSize(context).height * 0.4,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'No requests available.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Column(
                                children: requests.map((request) {
                                  return Container(
                                    margin: EdgeInsets.all(12),
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
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: Colors.white,
                                                child: Icon(
                                                  Icons.people,
                                                  color: ScreenColor.color6,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text('${request!['name']}',
                                                  style:
                                                      TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                          SizedBox(width: 20),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${request!['request']['service']}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Time: ${request['request']['time']}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Address: ${request['address']}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                SizedBox(height: 12),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        _acceptRequest(
                                                          context,
                                                          request['user'],
                                                          request['requestId'],
                                                          request['request'],
                                                        );
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 12,
                                                                vertical: 8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.green,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Text(
                                                          'Принять',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          );
                        },
                      );
              },
            ),
          )
        ],
      ),
    );
  }
}
