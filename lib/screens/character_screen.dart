import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chart_provider.dart';

class CharacterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final completedMissionsCount =
        Provider.of<ChartProvider>(context).completedDailyMissionsCount
      + Provider.of<ChartProvider>(context).completedWeeklyMissionsCount;

    // 이미지 파일 이름을 결정하는 함수
    String getImageForMissionCount(int count) {
      // 미션 수를 2로 나눈 후 올림하여 1부터 6까지 범위의 이미지 선택
      int imageIndex = (count / 2).ceil();
      if (imageIndex > 6) imageIndex = 6; // 최대 이미지 제한
      return 'assets/images/${imageIndex}c.png';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('캐릭터 화면'),
        backgroundColor: Color(0xFF798645),
      ),
      backgroundColor: Color(0xFFFEFAE0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지 위젯
            Image.asset(
              getImageForMissionCount(completedMissionsCount),
              width: 400,
              height: 400,
            ),
            SizedBox(height: 20),
            // 미션 수 텍스트
            Text(
              '해결한 미션 수: $completedMissionsCount',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
