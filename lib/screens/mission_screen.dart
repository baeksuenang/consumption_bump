import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chart_provider.dart';

class MissionScreen extends StatefulWidget {
  @override
  _MissionScreenState createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  bool isCompletedMissionsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final chartProvider = Provider.of<ChartProvider>(context);
    final weeklyMissionProgress = chartProvider.weeklyMissionProgress;
    final dailyMissions = chartProvider.dailyMissions;
    final completedDailyMissions = chartProvider.completedDailyMissions;
    final completedWeeklyMissions = chartProvider.completedWeeklyMissions;

    return Scaffold(
      appBar: AppBar(
        title: Text('미션 설정'),
        backgroundColor: Color(0xFF798645),
      ),
      backgroundColor: Color(0xFFFEFAE0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 주간 미션 섹션
            _buildMissionsSection(
              context,
              title: '주간 미션',
              content: _buildWeeklyMissions(chartProvider, weeklyMissionProgress),
            ),
            SizedBox(height: 20),
            // 일간 미션 섹션
            _buildMissionsSection(
              context,
              title: '일간 미션',
              content: _buildDailyMissions(chartProvider, dailyMissions),
            ),
            SizedBox(height: 20),
            // 완료된 미션 섹션
            _buildExpandableMissionsSection(
              context,
              title: '완료된 미션',
              completedDailyMissions: completedDailyMissions,
              completedWeeklyMissions: completedWeeklyMissions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionsSection(BuildContext context, {required String title, required Widget content}) {
    return Container(
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  Widget _buildWeeklyMissions(ChartProvider chartProvider, Map<String, int> weeklyMissionProgress) {
    return weeklyMissionProgress.isNotEmpty
        ? Column(
      children: weeklyMissionProgress.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.all(16.0),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // 프로그레스 바
              LinearProgressIndicator(
                value: entry.value / 7,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
              ),
              SizedBox(height: 10),
              // 진행 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '진행 상황: ${entry.value} / 7',
                    style: TextStyle(fontSize: 16),
                  ),
                  ElevatedButton(
                    onPressed: entry.value < 7
                        ? () {
                      chartProvider.updateWeeklyMissionProgress(entry.key);
                    }
                        : null, // 진행 완료 시 버튼 비활성화
                    child: Text(entry.value < 7 ? '진행하기' : '완료됨'),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    )
        : Text('주간 미션이 없습니다.', style: TextStyle(color: Colors.grey));
  }

  Widget _buildDailyMissions(ChartProvider chartProvider, List<String> missions) {
    return missions.isNotEmpty
        ? Column(
      children: missions.map((mission) {
        return Row(
          children: [
            Checkbox(
              value: false,
              onChanged: (bool? value) {
                if (value == true) {
                  chartProvider.completeDailyMission(mission);
                }
              },
            ),
            Expanded(
              child: Text(
                mission,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      }).toList(),
    )
        : Text('일간 미션이 없습니다.', style: TextStyle(color: Colors.grey));
  }

  Widget _buildExpandableMissionsSection(
      BuildContext context, {
        required String title,
        required List<String> completedDailyMissions,
        required Map<String, List<String>> completedWeeklyMissions,
      }) {
    return Container(
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
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: isCompletedMissionsExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            isCompletedMissionsExpanded = expanded;
          });
        },
        children: [
          ...completedDailyMissions.map((mission) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '일간: $mission',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }).toList(),
          ...completedWeeklyMissions.entries.expand((entry) {
            return entry.value.map((mission) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '주간(${entry.key}): $mission',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            });
          }).toList(),
        ],
      ),
    );
  }
}
