import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mission_provider.dart';

class MissionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(context);
    final missions = missionProvider.missions;

    return ListView.builder(
      itemCount: missions.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          title: Text(missions[index].title),
          value: false,
          onChanged: (bool? value) {
            missionProvider.removeMission(missions[index].id);
          },
        );
      },
    );
  }
}
