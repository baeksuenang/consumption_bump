import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChartProvider with ChangeNotifier {
  Map<String, int> selectedQuantities = {
    "취미": 0,
    "식사": 0,
    "의류": 0,
    "교통": 0,
    "기타": 0
  };

  Map<String, int> accumulatedQuantities = {
    "취미": 0,
    "식사": 0,
    "의류": 0,
    "교통": 0,
    "기타": 0
  };

  List<String> missions = [];
  int completedMissionsCount = 0; // 완료된 미션 횟수 추가

  ChartProvider() {
    _loadData(); // 생성자에서 데이터 로드
  }

  // 선택된 수량 업데이트
  void updateTemporaryQuantity(String option, int quantity) {
    selectedQuantities[option] = quantity;
    notifyListeners();
  }

  // 수량 적용 및 저장
  void applyQuantities() {
    selectedQuantities.forEach((option, quantity) {
      accumulatedQuantities[option] =
          (accumulatedQuantities[option] ?? 0) + quantity;
    });
    resetTemporaryQuantities();
    _saveData(); // 저장
    notifyListeners();
  }

  void resetTemporaryQuantities() {
    selectedQuantities.updateAll((key, value) => 0);
  }

  double getTotalQuantity() {
    return accumulatedQuantities.values.fold(0, (sum, quantity) => sum + quantity);
  }

  Map<String, double> getQuantitiesInPercentage() {
    double total = getTotalQuantity();
    if (total == 0) {
      return accumulatedQuantities.map((option, _) => MapEntry(option, 0.0));
    }
    return accumulatedQuantities.map((option, quantity) => MapEntry(option, quantity / total));
  }

  void addMission(String missionName) {
    if (!missions.contains(missionName)) {
      missions.add(missionName);
      _saveData(); // 저장
      notifyListeners();
    }
  }

  void removeMission(String missionName) {
    missions.remove(missionName);
    completedMissionsCount++; // 미션 완료 횟수 증가
    _saveData(); // 저장
    notifyListeners();
  }

  // 일일 미션 관련 메서드
  final List<String> _dailyMissions = [];

  List<String> get dailyMissions => _dailyMissions;

  void addDailyMission(String mission) {
    if (!_dailyMissions.contains(mission)) {
      _dailyMissions.add(mission);
      _saveData(); // 저장
      notifyListeners();
    }
  }

  void removeDailyMission(String mission) {
    _dailyMissions.remove(mission);
    _saveData(); // 저장
    notifyListeners();
  }

  // 데이터 저장
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    accumulatedQuantities.forEach((key, value) {
      prefs.setInt('accumulated_$key', value);
    });
    prefs.setInt('completedMissionsCount', completedMissionsCount);
    prefs.setStringList('missions', missions);
    prefs.setStringList('dailyMissions', _dailyMissions);
  }

  // 데이터 로드
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    accumulatedQuantities.forEach((key, _) {
      accumulatedQuantities[key] = prefs.getInt('accumulated_$key') ?? 0;
    });
    completedMissionsCount = prefs.getInt('completedMissionsCount') ?? 0;
    missions = prefs.getStringList('missions') ?? [];
    _dailyMissions.addAll(prefs.getStringList('dailyMissions') ?? []);
    notifyListeners();
  }
}
