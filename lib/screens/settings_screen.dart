import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay? _selectedTime;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadSavedTime(); // 저장된 시간 불러오기
  }

  // 알림 초기화
  void _initializeNotifications() async {
    tz.initializeTimeZones(); // 타임존 초기화
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 저장된 알람 시간 불러오기
  Future<void> _loadSavedTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('alarm_hour');
    final minute = prefs.getInt('alarm_minute');

    if (hour != null && minute != null) {
      setState(() {
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      });
      _scheduleNotification(_selectedTime!); // 저장된 시간으로 알림 예약
    }
  }

  // 알람 시간 저장
  Future<void> _saveTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('alarm_hour', time.hour);
    await prefs.setInt('alarm_minute', time.minute);
  }

  // 알림 예약
  void _scheduleNotification(TimeOfDay time) async {
    final now = DateTime.now();
    final scheduleTime = tz.TZDateTime.from(
      DateTime(now.year, now.month, now.day, time.hour, time.minute),
      tz.local,
    );

    if (scheduleTime.isBefore(now)) {
      scheduleTime.add(Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminder',
      channelDescription: 'Sends daily reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '미션 알림',
      '설정된 시간에 푸쉬 알람을 받습니다.',
      scheduleTime,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 시간 선택
  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });

      _saveTime(pickedTime); // 선택한 시간 저장
      _scheduleNotification(pickedTime); // 알림 예약
    }
  }

  // **튜토리얼 시작 함수**
  void _startTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TutorialScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
        backgroundColor: Color(0xFF798645),
      ),
      backgroundColor: Color(0xFFFEFAE0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '푸쉬 알람 시간 설정',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTime != null
                      ? '설정된 시간: ${_selectedTime!.format(context)}'
                      : '시간이 설정되지 않았습니다.',
                  style: TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: _pickTime,
                  child: Text('시간 설정'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF798645),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _startTutorial,
                child: Text('튜토리얼 시작'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF798645),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int currentIndex = 0;

  final List<String> tutorialImages = List.generate(
    10,
        (index) => 'assets/images/tutorial_${index + 1}.png',
  );

  void _nextImage() {
    setState(() {
      if (currentIndex < tutorialImages.length - 1) {
        currentIndex++;
      } else {
        Navigator.pop(context); // 마지막 이미지에 도달하면 튜토리얼 종료
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _nextImage,
        child: Center(
          child: Image.asset(
            tutorialImages[currentIndex],
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
