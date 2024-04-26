
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async{
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
        print("User granted permission");
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print("User granted permission provisional");
    }else{
      print("User denied permission");
    }
  }


  void initLocalNotifications(BuildContext context,RemoteMessage message)async{
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSetting = InitializationSettings(
      android: androidInitializationSettings
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse: (payload)async{
       // handleMessages(context,message);
      }
    );
  }
  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message) {
      print(message.notification!.title.toString());
      print(message.notification!.body.toString());
      initLocalNotifications(context, message);
      showNotification(message);

    });
  }

  Future<void> showNotification(RemoteMessage message)async{
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(10000).toString(),
        'High Importance Notification',
      importance: Importance.max
    );
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: 'Description of it',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker'
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails
    );
    Future.delayed(Duration.zero,(){
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }
  Future<String> getDeviceToken() async{
      String? token = await messaging.getToken();
      return token!;
  }
  void isTokenRefresh()async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print("refresh");
    });
  }
}