import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../providers/chart_provider.dart';
import '../widgets/checklist_popup.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chartProvider = Provider.of<ChartProvider>(context);
    final colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.purple];
    int colorIndex = 0;

    final chartData = chartProvider.getQuantitiesInPercentage().entries.map((entry) {
      final color = charts.ColorUtil.fromDartColor(colors[colorIndex % colors.length]);
      colorIndex++;
      return PieChartData(
        label: entry.key,
        value: entry.value,
        color: color,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Color(0xFF798645),
      ),
      backgroundColor: Color(0xFFFEFAE0),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pie chart
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  child: charts.PieChart(
                    [
                      charts.Series<PieChartData, String>(
                        id: 'Chart',
                        data: chartData,
                        domainFn: (PieChartData data, _) => data.label,
                        measureFn: (PieChartData data, _) => data.value,
                        colorFn: (PieChartData data, _) => data.color,
                        labelAccessorFn: (PieChartData row, _) =>
                        '${row.label}: ${(row.value * 100).toStringAsFixed(1)}%',
                      )
                    ],
                    animate: true,
                    defaultRenderer: charts.ArcRendererConfig<String>(
                      arcRendererDecorators: [
                        charts.ArcLabelDecorator(
                          labelPosition: charts.ArcLabelPosition.inside,
                          outsideLabelStyleSpec: charts.TextStyleSpec(
                            fontSize: 12,
                            color: charts.MaterialPalette.black,
                          ),
                        ),
                      ],
                    ),
                    selectionModels: [
                      charts.SelectionModelConfig(
                        type: charts.SelectionModelType.info,
                        changedListener: (charts.SelectionModel<String> model) {
                          if (model.hasDatumSelection) {
                            final selectedData = model.selectedDatum[0].datum;
                            showMissionTypeDialog(context, selectedData.label);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Box 1: 해결한 미션 수 표시
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '해결한 미션 수: ${chartProvider.completedDailyMissionsCount + chartProvider.completedWeeklyMissionsCount}',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => ChecklistPopup(),
          );
        },
        backgroundColor: Color(0xFF798645),
        child: Icon(Icons.add), // 플러스 아이콘 추가
      ),

    );
  }
  void showMissionTypeDialog(BuildContext context, String missionName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$missionName 미션 종류 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('주간 미션'),
                onTap: () {
                  Navigator.of(context).pop();
                  showWeeklyMissionDialog(context, missionName); // 주간 미션 팝업
                },
              ),
              ListTile(
                title: Text('일간 미션'),
                onTap: () {
                  Navigator.of(context).pop();
                  showDailyMissionDialog(context , missionName); // 일간 미션 팝업
                },
              ),
            ],
          ),
        );
      },
    );
  }


  void showDailyMissionDialog(BuildContext context, String missionName) {
    List<String> missions;
    if (missionName == '식사') {
      missions = ['하루동안 물 750ml 마시기', '식사 후 남은 음식을 활용한 레시피 찾아보기', '도시락 싸기', '자주 남는 음식 분석하고, 리스트 만들기'];
    } else if (missionName == '교통') {
      missions = ['지하철이나 버스를 이용하여 출퇴근하기', '출퇴근 거리의 일부를 걷거나 자전거로 이동하기', '교통비 지출 내역 기록하기', '택시 대신 버스나 지하철 노선 검색하기', '교통 패스 구독하기'];
    } else if (missionName == '취미') {
      missions = ['다른 사람에게 취미에 관한 정보 공유하거나 이야기 나누기', '필요한 취미 지출 미리 계획하기', '취미 활동 중 무료 체험할 수 있는 다른 활동 찾아보기'];
    } else if (missionName == '기타') {
      missions = ['간식을 한 번 덜 먹고 물이나 차로 대체하기', '오늘 간식 지출 금액 기록하기', '상점에서 간식을 사지 않고 집에서 가져오기', '리필제품 구매후, 리필 채워넣기', '배고픔과 갈증을 구분하고, 갈증 해소를 먼저 시도하기', '포인트 적립하기', '현금영수증 신청하기'];
    } else {
      missions = ['입지 않은 옷 조합을 이용해 새로운 스타일 만들어보기', '필요한 물품 체크리스트 만들기', '구매할 물품 중고 플랫폼에 있는지 확인하기'];
    }

    // 커스텀 미션을 추가할 임시 변수
    TextEditingController customMissionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('$missionName 미션 선택'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. 사용자가 커스텀 미션을 추가할 수 있는 입력 필드와 추가 버튼
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: customMissionController,
                            decoration: InputDecoration(
                              hintText: '새로운 미션 입력',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            String newMission = customMissionController.text.trim();
                            if (newMission.isNotEmpty) {
                              setState(() {
                                missions.add(newMission);
                              });
                              customMissionController.clear(); // 입력 필드 초기화
                            }
                          },
                          child: Text('추가'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // 2. 미션 목록 출력
                    ...missions.map((mission) {
                      return ListTile(
                        title: Text(mission),
                        onTap: () {
                          Provider.of<ChartProvider>(context, listen: false).addDailyMission(mission);
                          Navigator.of(context).pop();
                        },
                      );
                    }).toList(),
                  ],
                ),
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
      },
    );
  }


  void showWeeklyMissionDialog(BuildContext context, String missionName) {
    List<String> missions;
    if (missionName == '식사') {
      missions = ['이번 한 주 매일 아침 만들어먹기', '올바른 수면 습관을 통해 규칙적인 식사 하기','일주일간 금주 도전하기'];
    } else if (missionName == '교통') {
      missions = ['한시간 이내 거리는 무조건 공용자전거 이용하기','늦잠 자지 않고 제때 버스타기'];
    } else if (missionName == '취미') {
      missions = ['일주일간 인터넷 구매 없이 살아보기','일주일간 현금으로만 구매하기'];
    } else if (missionName == '기타') {
      missions = ['하루 동안 다회용품만 사용하기','소비 후 5분내에 기록하기'];
    } else {
      missions = ['이번 주는 원래 있던 옷으로 조합 만들기', '사고 싶은 옷이 있다면  인터넷과 오프라인 매장의 가격을 비교해보고 저렴하게 구입하기','물기 닦을 때 수건 재사용하기'];
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
                  Provider.of<ChartProvider>(context, listen: false).addWeeklyMission(mission);
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
