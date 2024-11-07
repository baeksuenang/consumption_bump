import 'package:flutter/material.dart';
import '../models/mission.dart';

class MissionProvider with ChangeNotifier {
  List<Mission> missions = [];

  void addMission(Mission mission) {
    missions.add(mission);
    notifyListeners();
  }

  void removeMission(int id) {
    missions.removeWhere((mission) => mission.id == id);
    notifyListeners();
  }
}
