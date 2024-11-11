import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chart_provider.dart';

class CircularChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chartProvider = Provider.of<ChartProvider>(context);
    final quantitiesInPercentage = chartProvider.getQuantitiesInPercentage();

    return Container(
      height: 200,
      width: 200,
      child: CustomPaint(
        painter: ChartPainter(quantitiesInPercentage),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final Map<String, double> quantitiesInPercentage;
  final List<Color> colors = [
    Colors.orange, // 첫 번째 카테고리 색상
    Colors.purple, // 두 번째 카테고리 색상
    Colors.cyan,   // 세 번째 카테고리 색상
    Colors.pink    // 네 번째 카테고리 색상
  ];

  ChartPainter(this.quantitiesInPercentage);

  @override
  void paint(Canvas canvas, Size size) {
    double startAngle = 0.0;
    int i = 0;

    // 데이터를 순회하며 각 섹션을 그리기
    quantitiesInPercentage.forEach((option, percentage) {
      // 각 데이터에 대응하는 색상을 선택
      final colorIndex = i % colors.length;
      final paint = Paint()
        ..color = colors[colorIndex] // 올바른 색상 설정
        ..style = PaintingStyle.fill;

      // 비율에 따라 각도 설정
      final sweepAngle = percentage * 2 * 3.1415;

      // 원형 차트 그리기
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2,
        ),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // 다음 섹션을 위한 시작 각도 업데이트
      startAngle += sweepAngle;
      i++;
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
