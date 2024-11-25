import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/mission_screen.dart';
import 'screens/input_screen.dart';
import 'screens/character_screen.dart'; // Import Character screen
import 'screens/settings_screen.dart';  // Import Settings screen
import 'providers/chart_provider.dart';

void main() {
  runApp(

    ChangeNotifierProvider(
      create: (context) => ChartProvider(),
      child: MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CharacterScreen(),
    InputScreen(),
    MissionScreen(),// Add Character screen
    SettingsScreen(),   // Add Settings screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '캐릭터',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.input),
            label: '입력',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '미션',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF798645),
        unselectedItemColor: Color(0xFF798645).withOpacity(0.6),
      ),
    );
  }
}



