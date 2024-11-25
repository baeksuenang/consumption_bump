import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
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
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.pink,
    Colors.green
  ];

  ChartPainter(this.quantitiesInPercentage);

  @override
  void paint(Canvas canvas, Size size) {
    double startAngle = 0.0;
    int i = 0;
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // 데이터 순회하며 원형 차트와 텍스트를 그리기
    quantitiesInPercentage.forEach((option, percentage) {
      // 색상 설정
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      // 각도 계산
      final sweepAngle = percentage * 2 * pi;

      // 원형 차트 그리기
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // 중간 각도 계산
      final midAngle = startAngle + sweepAngle / 2;
      final offsetX = center.dx + (radius * 0.7) * cos(midAngle);
      final offsetY = center.dy + (radius * 0.7) * sin(midAngle);

      // 텍스트 설정 및 그리기
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$option\n${(percentage * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(); // 텍스트 레이아웃 설정
      textPainter.paint(
        canvas,
        Offset(
          offsetX - textPainter.width / 2,
          offsetY - textPainter.height / 2,
        ),
      );

      // 시작 각도 업데이트
      startAngle += sweepAngle;
      i++;
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
