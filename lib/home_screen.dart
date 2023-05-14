import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_notifications/notification_services.dart';
import 'package:http/http.dart' as http;
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotificationServices notificationServices =NotificationServices();
  @override
  void initState() {

    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    // notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) {
      setState(() async{

        final setDateRef=FirebaseDatabase.instance.ref();
        setDateRef.child('token').set(value);
        setDateRef.child('state').set(1);
        // final setDateRef=FirebaseDatabase.instance.ref('token');
        // await setDateRef.set('pranay');
      });
      print("Device Token");


      print(value);
    }).onError((error, stackTrace){
      print(error.toString());
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Firebase Notifications"),
      ),
    body: Center(
      child: TextButton(onPressed: (){
        notificationServices.getDeviceToken().then((value)async {
          var data={
              'to' : value.toString(),
              'priority' : 'high',
              'notification':{
                'title' : 'Pranay',
                'body' : 'It Works!!'
              }
          };
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
            body: jsonEncode(data),
            headers:
              {
                'Content-Type':'application/json; charset=UTF-8',
                'Authorization' : 'key=AAAAwgb2AnY:APA91bFjvlpMDiRF8_OJXUDyAsFzFZPwpnx_ZC5vTGXai6WJOjVHjC1hFoafXLZYdKCm95yNWsZm1aNjK7hXUe6hHAKo5cY3Ga_JTmxkz60xGgWYMnlti4R7BDGnWwaNsfwBT4dW6JNd'
              }
          );


        });
      }, child: const Text("Send Notification")),
    )
    );
  }
}
