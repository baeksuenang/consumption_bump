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
  final colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];

  ChartPainter(this.quantitiesInPercentage);

  @override
  void paint(Canvas canvas, Size size) {
    double startAngle = 0.0;
    int i = 0;
    quantitiesInPercentage.forEach((option, percentage) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      final sweepAngle = percentage * 2 * 3.1415; // 비율에 따라 각도 설정
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
      i++;
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
