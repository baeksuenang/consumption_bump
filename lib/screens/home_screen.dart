import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../providers/chart_provider.dart';
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chartProvider = Provider.of<ChartProvider>(context);
    final chartData = chartProvider.getQuantitiesInPercentage().entries.map((entry) {
      return PieChartData(
        label: entry.key,
        value: entry.value,
        color: charts.ColorUtil.fromDartColor(Colors.blue), // 원하는 색상 적용
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Color(0xFF798645), // AppBar color changed to #798645
      ),
      backgroundColor: Color(0xFFFEFAE0),
      body: SingleChildScrollView( // Wrap the entire body in a SingleChildScrollView
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pie chart
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.width * 0.9,
                  child: charts.PieChart(
                    [
                      charts.Series<PieChartData, String>(
                        id: 'Chart',
                        data: chartData,
                        domainFn: (PieChartData data, _) => data.label,
                        measureFn: (PieChartData data, _) => data.value,
                        colorFn: (PieChartData data, _) => data.color,
                        labelAccessorFn: (PieChartData row, _) => '${row.label}: ${row.value}',
                      )
                    ],
                    animate: true,
                    defaultInteractions: true,
                    selectionModels: [
                      charts.SelectionModelConfig(
                        type: charts.SelectionModelType.info,
                        changedListener: (charts.SelectionModel<String> model) {
                          if (model.hasDatumSelection) {
                            final selectedData = model.selectedDatum[0].datum;
                            showMissionPopup(context, selectedData.label);  // 팝업 호출
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16), // Space between the chart and the boxes
                // Box 1
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Box 1',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 16), // Space between the two boxes
                // Box 2
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Box 2',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 미션 추가 팝업을 표시하는 함수
  void showMissionPopup(BuildContext context, String missionName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('미션 추가'),
          content: Text('$missionName을(를) 미션에 추가하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // 추가 로직 호출
                Provider.of<ChartProvider>(context, listen: false)
                    .addMission(missionName);
                Navigator.of(context).pop();
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }
}

class PieChartData {
  final String label;
  final double value;
  final charts.Color color;

  PieChartData({required this.label, required this.value, required this.color});
}
