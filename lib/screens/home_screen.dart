import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../providers/chart_provider.dart';
import '../widgets/checklist_popup.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chartProvider = Provider.of<ChartProvider>(context);
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple
    ];
    int colorIndex = 0;

    final chartData = chartProvider
        .getQuantitiesInPercentage()
        .entries
        .map((entry) {
      final color = charts.ColorUtil.fromDartColor(
          colors[colorIndex % colors.length]);
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
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.8,
                  height: MediaQuery
                      .of(context)
                      .size
                      .width * 0.8,
                  child: charts.PieChart(
                    [
                      charts.Series<PieChartData, String>(
                        id: 'Chart',
                        data: chartData,
                        domainFn: (PieChartData data, _) => data.label,
                        measureFn: (PieChartData data, _) => data.value,
                        colorFn: (PieChartData data, _) => data.color,
                        labelAccessorFn: (PieChartData row, _) =>
                        '${row.label}: ${(row.value * 100).toStringAsFixed(
                            1)}%',
                      ),
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
                      // 차트 항목을 선택할 때 주간/일간 미션 팝업을 띄우는 부분
                      charts.SelectionModelConfig(
                        type: charts.SelectionModelType.info,
                        changedListener: (charts.SelectionModel<String> model) {
                          if (model.hasDatumSelection) {
                            final selectedData = model.selectedDatum[0].datum;
                            showMissionTypeDialog(context, selectedData.label);  // 카테고리별 주간/일간 미션 선택 팝업 호출
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
                          '해결한 미션 수: ${chartProvider.completedMissionsCount}',
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
      // 추가된 FloatingActionButton
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF798645),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => ChecklistPopup(),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, // 오른쪽 아래에 위치 설정
    );
  }


  void showDailyMissionDialog(BuildContext context, String missionName, bool isWeekly) {
    final chartProvider = Provider.of<ChartProvider>(context, listen: false);
    final List<String> availableMissions = isWeekly
        ? [
      '일주일동안 배달음식 안 먹기',
      '일주일동안 집에서 요리한 식사를 SNS나 메모장에 기록하기',
      '옷장을 정리하여 필요한 옷과 불필요한 옷을 구분해보기',
      '일주일간 7만보 달성하기',
      '매일, 텀블러 들고다니기',
      '필요한 물품 체크리스트 작성',
      '소모품 자리 정리해두기'
    ]
        : [
      '다른 사람에게 취미에 관한 정보 공유하거나 이야기 나누기',
      '필요한 취미 지출 미리 계획하기',
      '취미 활동 중 무료 체험할 수 있는 다른 활동 찾아보기'
    ];

    // 현재 선택된 미션을 로컬 상태로 유지
    final selectedMissions = Set<String>.from(chartProvider.dailyMissions);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('$missionName ${isWeekly ? '주간' : '일간'} 미션 설정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: availableMissions.map((mission) {
                  return CheckboxListTile(
                    title: Text(mission),
                    value: selectedMissions.contains(mission),
                    onChanged: (bool? isSelected) {
                      setState(() {
                        if (isSelected == true) {
                          selectedMissions.add(mission);
                        } else {
                          selectedMissions.remove(mission);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    chartProvider.dailyMissions.clear();
                    chartProvider.dailyMissions.addAll(selectedMissions);
                    chartProvider.notifyListeners(); // 변경 사항을 반영
                    Navigator.of(context).pop();
                  },
                  child: Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showMissionPopup(BuildContext context, String missionName) {
    List<String> missions;
    if (missionName == '취미') {
      missions = [
        '다른 사람에게 취미에 관한 정보 공유하거나 이야기 나누기',
        '필요한 취미 지출 미리 계획하기',
        '취미 활동 중 무료 체험할 수 있는 다른 활동 찾아보기',
      ];
    } else if (missionName == '기타') {
      missions = [
        '간식을 한 번 덜 먹고 물이나 차로 대체하기',
        '오늘 간식 지출 금액 기록하기',
        '상점에서 간식을 사지 않고 집에서 가져오기',
        '리필제품 구매후, 리필 채워넣기',
        '배고픔과 갈증을 구분하고, 갈증 해소를 먼저 시도하기',
        '포인트 적립하기',
        '현금영수증 신청하기',
      ];
    } else {
      missions = [
        '입지 않은 옷 조합을 이용해 새로운 스타일 만들어보기',
        '필요한 물품 체크리스트 만들기',
        '구매할 물품 중고 플랫폼에 있는지 확인하기',
      ];
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
                  // 선택된 미션을 ChartProvider에 추가
                  Provider.of<ChartProvider>(context, listen: false).addDailyMission(mission);
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
                  showDailyMissionDialog(context, missionName, false); // 일간 미션 팝업
                },
              ),
            ],
          ),
        );
      },
    );
  }
  void showWeeklyMissionDialog(BuildContext context, String missionName) {
    final chartProvider = Provider.of<ChartProvider>(context, listen: false);
    final List<String> availableMissions = chartProvider.weeklyMissionsByCategory[missionName] ?? [];

    // 팝업을 열 때마다 체크리스트를 초기화
    final selectedMissions = <String>{}; // 항상 비어 있는 상태에서 시작

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('$missionName 주간 미션 설정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: availableMissions.map((mission) {
                  return CheckboxListTile(
                    title: Text(mission),
                    value: selectedMissions.contains(mission),
                    onChanged: (bool? isSelected) {
                      setState(() {
                        if (isSelected == true) {
                          selectedMissions.add(mission);
                        } else {
                          selectedMissions.remove(mission);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    // 주간 미션을 선택한 카테고리와 연결하여 저장
                    chartProvider.setWeeklyMissionsForCategory(missionName, selectedMissions);
                    Navigator.of(context).pop();
                  },
                  child: Text('저장'),
                ),
              ],
            );
          },
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
