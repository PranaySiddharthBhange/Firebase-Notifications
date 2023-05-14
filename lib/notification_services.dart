import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_notifications/message_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class NotificationServices{

  FirebaseMessaging messaging=FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin();

  void requestNotificationPermission()async{

    NotificationSettings settings =await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if(settings.authorizationStatus==AuthorizationStatus.authorized){
      print("User Granted Permission");
    }
    else if(settings.authorizationStatus==AuthorizationStatus.provisional)
      {
        print("User Granted PROVISIONAL PERMISSION");
      }
    else{
      print("User denied permission");
    }
  }
  Future<String>getDeviceToken()async{

    String? token =await messaging.getToken();

    return token!;
  }
  void isTokenRefresh()async{
   messaging.onTokenRefresh.listen((event) {
     event.toString();
     print("Refresh");
   });
  }
  void initLocalNotifications(BuildContext context,RemoteMessage message)async {
    var androidInitializationSettings =const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings=InitializationSettings(
      android: androidInitializationSettings
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload){
        handleMessage(context, message);
      }
    );
  }
  Future<void>showNotification(RemoteMessage message)async{
    AndroidNotificationChannel channel=AndroidNotificationChannel(Random.secure().nextInt(100000).toString(), 'High Importance Notifications',
    importance: Importance.max);
    AndroidNotificationDetails androidNotificationDetails =AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
        icon: "@mipmap/ic_launcher",
        channelDescription: 'Your Message Discription',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker'
    );
    NotificationDetails notificationDetails=NotificationDetails(
      android: androidNotificationDetails
    );
    Future.delayed(Duration.zero,
        () {
          _flutterLocalNotificationsPlugin.show(
              0,
              message.notification!.title.toString(),
              message.notification!.body.toString(),
              notificationDetails);
        },);
  }

  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message) {

      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        print(message.data.toString());
        print(message.data['type']);
        print(message.data['id']);
      }
      initLocalNotifications(context,message);
      showNotification(message);

    });

  }
  Future<void> setupInteractMessage(BuildContext context)async {
    RemoteMessage? initialMessage=await FirebaseMessaging.instance.getInitialMessage();
    //terminated
    if(initialMessage!=null){
      handleMessage(context, initialMessage);
    }

    //background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context,RemoteMessage message){
    if(message.data['type'=='msj']=='msj'){
      Navigator.push(context, MaterialPageRoute(builder:  (context) => MessageScreen(),));
    }

  }


}
// enI9tRutSoWPybXjQoa2Xf:APA91bHRt5RmXoaDAGIwMAbZZS4Y18y8mbT87zBvxjlWyRMGrV52R-3kaC-rDCP5iBDxPX138PTeZDynuMTftMx9pb9Q9go3mb6ngVraKDOUKEMTaiZ2_okTgcMNLhFyABSz7y1tgPYd