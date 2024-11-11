import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../providers/chart_provider.dart';
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chartProvider = Provider.of<ChartProvider>(context);
    final colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow]; // 각 항목에 사용할 색상 배열
    int colorIndex = 0; // 색상 인덱스 초기화

    final chartData = chartProvider.getQuantitiesInPercentage().entries.map((entry) {
      final color = charts.ColorUtil.fromDartColor(colors[colorIndex % colors.length]); // 순환 색상 적용
      colorIndex++; // 다음 색상으로 넘어가기
      return PieChartData(
        label: entry.key,
        value: entry.value,
        color: color,
      );
    }).toList();

    // 나머지 코드 그대로 유지


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
    // 미션 리스트 정의 (예시)
    List<String> missions;
    if (missionName == '식사') {
      missions = ['식사미션 1', '식사미션 2', '식사미션 3'];
    } else if (missionName == '의류') {
      missions = ['의류미션 1', '의류미션 2'];
    } else if (missionName == '취미') {
      missions = ['취미미션 1', '취미미션 2'];
    } else {
      missions = ['교통미션 1', '교통미션 2', '교통미션 3'];
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$missionName 미션 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: missions.map((mission) {
              return ListTile(
                title: Text(mission),
                onTap: () {
                  // 미션 추가 로직 호출
                  Provider.of<ChartProvider>(context, listen: false).addMission(mission);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('닫기'),
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