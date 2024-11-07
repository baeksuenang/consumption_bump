import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chart_provider.dart';
class MissionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Color(0xFF798645), // AppBar color changed to #798645
      ),
      backgroundColor: Color(0xFFFEFAE0),
      body: Consumer<ChartProvider>(
        builder: (context, chartProvider, child) {
          final missions = chartProvider.missions;

          return ListView.builder(
            itemCount: missions.length,
            itemBuilder: (context, index) {
              final missionName = missions[index];

              return ListTile(
                title: Text(missionName),
                trailing: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    // 체크한 미션을 목록에서 제거
                    chartProvider.removeMission(missionName);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
