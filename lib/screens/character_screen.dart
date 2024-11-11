import 'package:flutter/material.dart';

class CharacterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('캐릭터'),
      ),
      body: Center(
        child: Text('캐릭터 화면입니다.'),
      ),
    );
  }
}
