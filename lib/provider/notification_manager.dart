
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class NotificationManager{
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin ;

  BehaviorSubject<ReceivedNotification> get didReceiveLocalNotificationSubject => BehaviorSubject<ReceivedNotification>();

  InitializationSettings initSetting;
  NotificationManager.init(){
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if(Platform.isIOS){
      requestIOSPermission();
    }
    initializePlatform();
  }

   requestIOSPermission() {
     flutterLocalNotificationsPlugin
         .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
         .requestPermissions(
             alert: true,
             sound: true,
             badge: true
         );
  }

   initializePlatform() async{
     var initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
     var initSettingsIOS = IOSInitializationSettings(
       requestSoundPermission: true,
       requestAlertPermission: true,
       requestBadgePermission: true,
       onDidReceiveLocalNotification: (id,title,body,payload) async{
         ReceivedNotification receivedNotification = ReceivedNotification(id: id, title: title, body: body, payload: payload);
         didReceiveLocalNotificationSubject.add(receivedNotification);
       }
     );
     initSetting = InitializationSettings(android: initSettingsAndroid,iOS: initSettingsIOS);
   }
  setOnNotificationReceived(Function onNotificationReceived){
    didReceiveLocalNotificationSubject.listen((notification) {
      onNotificationReceived(notification);
    });
  }
  setOnNotificationClicked(Function onNotificationClicked) async{
      await flutterLocalNotificationsPlugin.initialize(initSetting,
        onSelectNotification: (String payload) async{
          onNotificationClicked(payload);
        }
      );
  }
  showNotification() async {
    var androidChannel = AndroidNotificationDetails(
        'CHANNEL_ID', 'CHANNEL_NAME',
        priority: Priority.high,
        importance: Importance.max,
        playSound: true
    );
    var iOSChannel = IOSNotificationDetails();
    var platformChannel=  NotificationDetails(iOS: iOSChannel,android: androidChannel);


    await flutterLocalNotificationsPlugin.show(
        0, 'Flutter devs', 'Flutter Local Notification Demo', platformChannel,
        payload: 'Welcome to the Local Notification demo');

  }

  _downloadAndSaveFile(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(Uri.parse(url).replace(queryParameters:null));
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
  showNotificationWithAttachment(String _id,String title,String message,String image,String icon,String payload) async {

    int id = int.parse(_id);


    var iOSPlatformSpecifics = IOSNotificationDetails();

    var notificationPannelText = BigTextStyleInformation('');
    var notificationPannel ;
    var largeIcon =  null;
    if(icon != null && icon != "null"){
      var attachmentIconPath = await _downloadAndSaveFile(icon, id.toString()+'icon_attachment_img.jpg');
      largeIcon =  FilePathAndroidBitmap(attachmentIconPath);
    }
    if(image != null && image != "null"){

      var attachmentPicturePath = await _downloadAndSaveFile(image, id.toString()+'attachment_img.jpg');

      notificationPannel = BigPictureStyleInformation(
        FilePathAndroidBitmap(attachmentPicturePath),
        largeIcon :largeIcon,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: message,
        htmlFormatSummaryText: true,
      );

      iOSPlatformSpecifics = IOSNotificationDetails(
        attachments: [IOSNotificationAttachment(attachmentPicturePath)],
      );
    }



    var androidChannelSpecifics = AndroidNotificationDetails(
      id.toString(),
      "Link_channel",
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: (image != null && image != "null")? notificationPannel:notificationPannelText,
      largeIcon: largeIcon,
      setAsGroupSummary: true,
      visibility: NotificationVisibility.public
    );

    var notificationDetails = NotificationDetails(android:androidChannelSpecifics, iOS: iOSPlatformSpecifics);
    await flutterLocalNotificationsPlugin.show(
        id,
        title,
        message,
        notificationDetails,
        payload:payload
    );
  }

}


NotificationManager notificationManager = NotificationManager.init();
class ReceivedNotification{
  final int id ;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({@required this.id, @required this.title,@required this.body,@required this.payload});
}