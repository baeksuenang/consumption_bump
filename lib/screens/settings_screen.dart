import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  double? _homeLatitude;
  double? _homeLongitude;
  bool _isWithinHomeZone = false; // 현재 위치 상태를 저장

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadHomeLocation();
    _initializeWorkManager();
  }

  /// 알림 초기화
  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        if (payload != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          );
        }
      },
    );
  }

  /// 권한 요청
  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다.');
    }
  }

  /// 알림 전송
  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'home_channel',
      'Home Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      '알림',
      message,
      notificationDetails,
    );
  }

  /// 집 위치 저장
  Future<void> _saveHomeLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('homeLatitude', latitude);
    await prefs.setDouble('homeLongitude', longitude);
  }

  /// 집 위치 로드
  Future<void> _loadHomeLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _homeLatitude = prefs.getDouble('homeLatitude');
      _homeLongitude = prefs.getDouble('homeLongitude');
    });
  }

  /// 현재 위치를 집으로 설정
  Future<void> _setHomeLocation() async {
    await _requestLocationPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _homeLatitude = position.latitude;
      _homeLongitude = position.longitude;
    });
    await _saveHomeLocation(position.latitude, position.longitude);
    _startBackgroundLocationCheck(); // 백그라운드 작업 시작
  }

  /// WorkManager 초기화
  void _initializeWorkManager() {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  /// 백그라운드 작업 예약
  void _startBackgroundLocationCheck() {
    Workmanager().registerPeriodicTask(
      "1",
      "backgroundLocationCheck",
      frequency: const Duration(minutes: 15),
      inputData: {
        'homeLatitude': _homeLatitude.toString(),
        'homeLongitude': _homeLongitude.toString(),
      },
    );
  }

  /// 백그라운드 콜백
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
      flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // 저장된 집 위치
      double? homeLat = double.tryParse(inputData?['homeLatitude'] ?? '');
      double? homeLon = double.tryParse(inputData?['homeLongitude'] ?? '');

      if (homeLat != null && homeLon != null) {
        Position currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        double distance = Geolocator.distanceBetween(
          homeLat,
          homeLon,
          currentPosition.latitude,
          currentPosition.longitude,
        );

        // 일정 거리 이상 벗어났다가 다시 돌아온 경우 알림
        final prefs = await SharedPreferences.getInstance();
        bool wasWithinHomeZone = prefs.getBool('isWithinHomeZone') ?? false;

        if (distance < 10 && !wasWithinHomeZone) {
          // 집에 돌아옴
          prefs.setBool('isWithinHomeZone', true);
          const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'home_channel',
            'Home Notifications',
            importance: Importance.high,
            priority: Priority.high,
          );
          const NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

          await flutterLocalNotificationsPlugin.show(
            0,
            '알림',
            '집에 도착했습니다!',
            notificationDetails,
          );
        } else if (distance >= 10 && wasWithinHomeZone) {
          // 집에서 멀어짐
          prefs.setBool('isWithinHomeZone', false);
        }
      }

      return Future.value(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _homeLatitude == null
                  ? '집 위치가 설정되지 않았습니다.'
                  : '집 위치: $_homeLatitude, $_homeLongitude',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setHomeLocation,
              child: const Text('현재 위치를 집으로 설정'),
            ),
          ],
        ),
      ),
    );
  }
}
