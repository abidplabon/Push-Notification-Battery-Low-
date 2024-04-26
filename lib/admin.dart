import 'dart:convert';

import 'package:battery_low/fetch.dart';
import 'package:battery_low/notification_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  NotificationServices notificationServices = NotificationServices();
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  List<String> _userIds = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.getDeviceToken().then((value) {
      print("Device Token");
      print(value);
    });
    _fetchUserIds();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin"),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: Icon(
              Icons.logout,
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: bodyController,
              decoration: InputDecoration(
                labelText: 'Body',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sendNotification();
              },
              child: Text("Send Notification"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchUserIds() async {
    final userIds = await _firestoreHelper.fetchNonAdminUserIds();
    setState(() {
      _userIds = userIds;
    });
    // Print user IDs to the terminal
    _userIds.forEach((userId) {
      print('User ID: $userId');
    });
  }
  Future<void> sendNotification() async {
    String title = titleController.text;
    String body = bodyController.text;

    if (title.isEmpty || body.isEmpty) {
      // Show an error message if title or body is empty
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Title and Body cannot be empty."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }
    for(String userId in _userIds){
        await _sendNotificationToUser(userId,title,body);
      }
    }


  Future<void> _sendNotificationToUser(String userId, String title, String body) async {
    try {
      var data = {
        'to': userId, // Using the user ID directly as the 'to' field
        'priority': 'high',
        'notification': {
          'title': title,
          'body': body,
        }
      };
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=AAAALfALdTs:APA91bFF-1vvKpvcV9zqM7Mc80c9cRgqCt_SQrIeGBPNryV1qXldnsHGciCSQyaTrdtTgZ8zfHqyYJto3XM3Wz7OL_1DDzJac-tng7SMaZADyfj8piFd3XhXG2gTHty2UZk7jzEDCXcd'
        },
      );
      print('Notification sent to user ID: $userId');
    } catch (e) {
      print('Error sending notification to user ID $userId: $e');
    }
  }
  }

  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
}