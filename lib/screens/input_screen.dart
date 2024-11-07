import 'package:flutter/material.dart';
import '../widgets/checklist_popup.dart';

class InputScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF798645), // 상단 바 색상 설정
      ),
      backgroundColor: Color(0xFFFEFAE0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // 좌우 여백 추가
          child: SizedBox(
            width: double.infinity, // 화면 가로를 거의 다 차지하도록 설정
            height: 60, // 버튼 높이를 적절히 설정
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ChecklistPopup(),
                );
              },
              child: Text(
                '오늘 소비 입력하기',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
