import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Position? _homePosition;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _setHomeLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _homePosition = position;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('집 위치가 설정되었습니다.')),
    );
  }

  Future<void> _checkLocation() async {
    if (_homePosition == null) return;
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    double distance = Geolocator.distanceBetween(
      _homePosition!.latitude,
      _homePosition!.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    if (distance < 100) {
      _showNotification();
    }
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails('home_channel', 'Home Notifications',
        importance: Importance.high, priority: Priority.high);
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      '알림',
      '집에 도착했습니다!',
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _homePosition == null
                  ? '집 위치가 설정되지 않았습니다.'
                  : '집 위치: ${_homePosition!.latitude}, ${_homePosition!.longitude}',
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setHomeLocation,
              child: Text('현재 위치를 집으로 설정'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkLocation,
              child: Text('현재 위치 확인'),
            ),
          ],
        ),
      ),
    );
  }
}
