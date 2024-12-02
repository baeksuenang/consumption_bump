import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double? _homeLatitude;
  double? _homeLongitude;
  String _currentStatus = '위치를 확인하려면 버튼을 누르세요.';
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

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

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
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

  /// 집 위치 저장
  Future<void> _saveHomeLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('homeLatitude', latitude);
    await prefs.setDouble('homeLongitude', longitude);
    setState(() {
      _homeLatitude = latitude;
      _homeLongitude = longitude;
    });
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
    await _saveHomeLocation(position.latitude, position.longitude);
    setState(() {
      _currentStatus = '집 위치가 설정되었습니다.';
    });
  }

  /// WorkManager 초기화
  void _initializeWorkManager() {
    Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: false, // 릴리스 환경에서는 항상 false
    );
  }

  /// WorkManager에 작업 등록
  void _startPeriodicLocationCheck() {
    if (_homeLatitude != null && _homeLongitude != null) {
      Workmanager().registerPeriodicTask(
        'checkLocationTask',
        'backgroundLocationCheck',
        frequency: const Duration(minutes: 15), // 최소 15분 간격
        inputData: {
          'homeLatitude': _homeLatitude.toString(),
          'homeLongitude': _homeLongitude.toString(),
        },
      );
      setState(() {
        _currentStatus = '주기적인 위치 확인 작업이 시작되었습니다.';
      });
    } else {
      setState(() {
        _currentStatus = '먼저 집 위치를 설정하세요.';
      });
    }
  }

  /// WorkManager 콜백
  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      // 알림 초기화
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

        if (distance < 10) {
          // 집에 도착했음을 알림
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
            '소비를 입력하세요!',
            notificationDetails,
          );
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
              _currentStatus,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setHomeLocation,
              child: const Text('현재 위치를 집으로 설정'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startPeriodicLocationCheck,
              child: const Text('주기적 위치 확인 시작'),
            ),
          ],
        ),
      ),
    );
  }
}
