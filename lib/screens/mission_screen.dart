import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chart_provider.dart';

class MissionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('미션 관리'),
        backgroundColor: Color(0xFF798645),
      ),
      backgroundColor: Color(0xFFFEFAE0),
      body: Consumer<ChartProvider>(
        builder: (context, chartProvider, child) {
          final dailyMissions = chartProvider.dailyMissions;
          final weeklyMissions = chartProvider.weeklyMissions;
          final weeklyMissionsProgress = chartProvider.weeklyMissionsProgress;
          final completedWeeklyMissions = chartProvider.completedMissions;

          return ListView(
            children: [
              _buildSectionContainer(
                title: '일간 미션',
                child: _buildMissionSection(
                  missions: dailyMissions,
                  chartProvider: chartProvider,
                  isDaily: true,
                ),
              ),
              _buildSectionContainer(
                title: '주간 미션',
                child: _buildMissionSection(
                  missions: weeklyMissions,
                  chartProvider: chartProvider,
                  progressMap: weeklyMissionsProgress,
                ),
              ),
              _buildSectionContainer(
                title: '완료된 미션',
                child: _buildCompletedMissions(completedWeeklyMissions),
              ),
            ],
          );
        },
      ),
    );
  }

  // 섹션 전체를 감싸는 둥근 상자
  Widget _buildSectionContainer({required String title, required Widget child}) {
    return Card(
      margin: EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18, // 텍스트 크기 줄임
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  // 미션 섹션 생성
  Widget _buildMissionSection({
    required List<String> missions,
    required ChartProvider chartProvider,
    Map<String, int>? progressMap,
    bool isDaily = false,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final missionName = missions[index];
        final progress = progressMap?[missionName] ?? 0;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: isDaily
                ? ListTile(
              dense: true, // 카드 크기 줄이기
              title: Text(
                missionName,
                style: TextStyle(fontSize: 14), // 텍스트 크기 줄이기
              ),
              trailing: IconButton(
                icon: Icon(Icons.check, size: 20), // 아이콘 크기 줄이기
                onPressed: () {
                  chartProvider.removeDailyMission(missionName);
                },
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        missionName,
                        style: TextStyle(
                          fontSize: 14, // 텍스트 크기 줄이기
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (progress < 7) {
                          chartProvider.updateWeeklyMissionProgress(
                            missionName,
                            progress + 1,
                          );
                        }
                        if (progress + 1 >= 7) {
                          Future.delayed(Duration(milliseconds: 300), () {
                            chartProvider.removeWeeklyMission(missionName);
                          });
                        }
                      },
                      child: Text(
                        progress + 1 >= 7 ? '완료하기' : '진행하기',
                        style: TextStyle(fontSize: 16, color: Color(0xFF798645)),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: Size(10, 10), // 버튼 최소 크기 설정
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress / 7,
                  backgroundColor: Colors.grey[300],
                  color: Colors.green,
                ),
                SizedBox(height: 4),
                Text(
                  '진행도: $progress / 7',
                  style: TextStyle(fontSize: 16), // 텍스트 크기 줄이기
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // 완료된 미션 섹션 생성
  Widget _buildCompletedMissions(List<String> completedMissions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: completedMissions.length,
      itemBuilder: (context, index) {
        final missionName = completedMissions[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            dense: true, // 크기 줄이기
            title: Text(
              missionName,
              style: TextStyle(
                fontSize: 14, // 텍스트 크기 줄이기
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }
}
