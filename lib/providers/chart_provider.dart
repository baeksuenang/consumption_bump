import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChartProvider with ChangeNotifier {
  List<String> completedMissions = [];
  // 선택된 수량과 누적 수량
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

  // 미션 리스트
  List<String> dailyMissions = []; // 일간 미션
  List<String> weeklyMissions = []; // 주간 미션
  int completedDailyMissionsCount = 0; // 완료된 일간 미션 수
  int completedWeeklyMissionsCount = 0; // 완료된 주간 미션 수

  // 생성자에서 데이터 로드
  ChartProvider() {
    _loadData();
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

  // 일간 미션 추가/삭제
  void addDailyMission(String mission) {
    if (!dailyMissions.contains(mission)) {
      dailyMissions.add(mission);
      _saveData(); // 저장
      notifyListeners();
    }
  }

  void removeDailyMission(String mission) {
    dailyMissions.remove(mission);
    completedDailyMissionsCount++; // 일간 미션 완료 수 증가
    completedMissions.add(mission);
    _saveData(); // 저장
    notifyListeners();
  }

  // 주간 미션 추가/삭제
  void addWeeklyMission(String mission) {
    if (!weeklyMissions.contains(mission)) {
      weeklyMissions.add(mission);
      weeklyMissionsProgress[mission] = 0; // 진행도 초기화
      _saveData();
      notifyListeners();
    }
  }

  void removeWeeklyMission(String mission) {
    weeklyMissions.remove(mission);
    weeklyMissionsProgress.remove(mission);
    completedMissions.add(mission);
    _saveData();
    notifyListeners();
  }

  // 데이터 저장
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // 수량 저장
    accumulatedQuantities.forEach((key, value) {
      prefs.setInt('accumulated_$key', value);
    });

    // 완료된 미션 수 저장
    prefs.setInt('completedDailyMissionsCount', completedDailyMissionsCount);
    prefs.setInt('completedWeeklyMissionsCount', completedWeeklyMissionsCount);

    prefs.setStringList('completedMissions', completedMissions);

    // 미션 리스트 저장
    prefs.setStringList('dailyMissions', dailyMissions);
    prefs.setStringList(
      'weeklyMissionsProgress',
      weeklyMissions.map((mission) => '${mission}:${weeklyMissionsProgress[mission]}').toList(),
    );

    prefs.setStringList('weeklyMissions', weeklyMissions);

  }

  // 데이터 로드
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // 수량 로드
    accumulatedQuantities.forEach((key, _) {
      accumulatedQuantities[key] = prefs.getInt('accumulated_$key') ?? 0;
    });

    // 완료된 미션 수 로드
    completedDailyMissionsCount = prefs.getInt('completedDailyMissionsCount') ?? 0;
    completedWeeklyMissionsCount = prefs.getInt('completedWeeklyMissionsCount') ?? 0;

    completedMissions = prefs.getStringList('completedMissions') ?? [];


    // 미션 리스트 로드
    dailyMissions = prefs.getStringList('dailyMissions') ?? [];

    weeklyMissions = prefs.getStringList('weeklyMissions') ?? [];
    final progressList = prefs.getStringList('weeklyMissionsProgress') ?? [];

    // 진행 상태 로드
    weeklyMissionsProgress = {
      for (var progress in progressList)
        progress.split(':')[0]: int.parse(progress.split(':')[1])
    };

    notifyListeners();
  }

  Map<String, int> weeklyMissionsProgress = {}; // 미션별 진행 상태
  void updateWeeklyMissionProgress(String mission, int progress) {
    if (weeklyMissionsProgress.containsKey(mission)) {
      weeklyMissionsProgress[mission] = progress;
      _saveData();
      notifyListeners(); // 상태 변경 후 UI 업데이트
    }
  }
}
