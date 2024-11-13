import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chart_provider.dart';

class CharacterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final completedMissionsCount =
        Provider.of<ChartProvider>(context).completedMissionsCount;

    return Scaffold(
      appBar: AppBar(
        title: Text('캐릭터 화면'),
        backgroundColor: Color(0xFF798645),
      ),
      backgroundColor: Color(0xFFFEFAE0),
      body: Center(
        child: Text(
          '$completedMissionsCount',
          style: TextStyle(fontSize: 100, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
