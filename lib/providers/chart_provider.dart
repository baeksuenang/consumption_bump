import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChartProvider with ChangeNotifier {
  Map<String, int> weeklyMissionProgress = {};
  Map<String, int> _weeklyMissionProgress = {};

  // 완료된 주간 미션
  Map<String, List<String>> _completedWeeklyMissions = {};

  // 완료된 미션 횟수
  int completedMissionsCount = 0;


  // 주간 미션 진행 업데이트
  void updateWeeklyMissionProgress(String missionName) {
    if (weeklyMissionProgress.containsKey(missionName)) {
      weeklyMissionProgress[missionName] = (weeklyMissionProgress[missionName]! + 1).clamp(0, 7);

      // 진행도가 7(100%)이면 완료 처리
      if (weeklyMissionProgress[missionName] == 7) {
        completeWeeklyMission(missionName);
      }
      notifyListeners();
    }
  }

  // 주간 미션 완료 처리
  void completeWeeklyMission(String missionName) {
    if (weeklyMissionProgress.containsKey(missionName)) {
      // 해당 미션의 카테고리 가져오기
      final category = weeklyMissionCategories[missionName] ?? '미분류';

      // 완료된 미션 리스트에 추가
      _completedWeeklyMissions.putIfAbsent(category, () => []).add(missionName);

      // 진행 상태 및 카테고리에서 제거
      weeklyMissionProgress.remove(missionName);
      weeklyMissionCategories.remove(missionName);

      // 완료된 미션 수 증가
      completedMissionsCount++;

      notifyListeners();
    }
  }


  // 주간 미션 초기화 (테스트용)
  void resetWeeklyMission(String category) {
    if (weeklyMissionProgress.containsKey(category)) {
      weeklyMissionProgress[category] = 0;
      notifyListeners();
    }
  }
  // 선택된 임시 수량 및 누적 수량
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


  // 미션 관련 변수
  List<String> _dailyMissions = [];
  List<String> _completedDailyMissions = [];

  Map<String, Set<String>> _selectedWeeklyMissions = {};

  Map<String, List<String>> _weeklyMissionsByCategory = {
    '취미': ['다른 사람에게 취미에 관한 정보 공유하기', '필요한 취미 지출 계획 세우기'],
    '기타': ['간식 한 번 덜 먹기', '오늘 간식 지출 기록하기'],
    '기타2': ['입지 않은 옷 조합해 새로운 스타일 만들기', '필요한 물품 체크리스트 작성']
  };

  // Getter
  List<String> get dailyMissions => _dailyMissions;
  List<String> get completedDailyMissions => _completedDailyMissions;
  Map<String, Set<String>> get selectedWeeklyMissions => _selectedWeeklyMissions;
  Map<String, List<String>> get completedWeeklyMissions => _completedWeeklyMissions;
  Map<String, List<String>> get weeklyMissionsByCategory => _weeklyMissionsByCategory;


  ChartProvider() {
    _loadData(); // 초기 데이터 로드
  }

  // 선택된 수량 업데이트
  void updateTemporaryQuantity(String option, int quantity) {
    selectedQuantities[option] = quantity;
    notifyListeners();
  }

  // 누적 수량에 적용
  void applyQuantities() {
    selectedQuantities.forEach((option, quantity) {
      accumulatedQuantities[option] = (accumulatedQuantities[option] ?? 0) + quantity;
    });
    resetTemporaryQuantities();
    _saveData();
    notifyListeners();
  }

  // 임시 수량 초기화
  void resetTemporaryQuantities() {
    selectedQuantities.updateAll((key, value) => 0);
  }

  // 전체 수량 계산
  double getTotalQuantity() {
    return accumulatedQuantities.values.fold(0, (sum, quantity) => sum + quantity);
  }

  // 비율 계산
  Map<String, double> getQuantitiesInPercentage() {
    double total = getTotalQuantity();
    if (total == 0) {
      return accumulatedQuantities.map((key, _) => MapEntry(key, 0.0));
    }
    return accumulatedQuantities.map((key, quantity) => MapEntry(key, quantity / total));
  }

  // 일간 미션 추가/제거
  void addDailyMission(String mission) {
    if (!_dailyMissions.contains(mission)) {
      _dailyMissions.add(mission);
      _saveData();
      notifyListeners();
    }
  }

  void removeDailyMission(String mission) {
    _dailyMissions.remove(mission);
    _saveData();
    notifyListeners();
  }

  // 일간 미션 완료 처리
  void completeDailyMission(String mission) {
    if (_dailyMissions.remove(mission)) {
      _completedDailyMissions.add(mission);
      completedMissionsCount++;
      _saveData();
      notifyListeners();
    }
  }
  Map<String, String> weeklyMissionCategories = {};
  // 주간 미션 추가/제거
  void addWeeklyMission(String category, String missionName) {
    if (!weeklyMissionProgress.containsKey(missionName)) {
      weeklyMissionProgress[missionName] = 0; // 초기 진행도 설정
      weeklyMissionCategories[missionName] = category; // 카테고리 저장
      notifyListeners();
    }
  }

  void removeWeeklyMission(String category, String mission) {
    _selectedWeeklyMissions[category]?.remove(mission);
    if (_selectedWeeklyMissions[category]?.isEmpty ?? false) {
      _selectedWeeklyMissions.remove(category);
    }
    _saveData();
    notifyListeners();
  }

  // 주간 미션 완료 처리
  void completeAllWeeklyMission(String category) {
    if (_weeklyMissionProgress.containsKey(category)) {
      _completedWeeklyMissions.putIfAbsent(category, () => []).add("완료");
      _weeklyMissionProgress.remove(category);
      completedMissionsCount++;
      notifyListeners();
    }
  }
  void setWeeklyMissionsForCategory(String category, Set<String> missions) {
    // 카테고리에 해당하는 미션 세트 저장
    _selectedWeeklyMissions[category] = missions;

    // 각 미션을 개별적으로 추가
    for (var mission in missions) {
      addWeeklyMission(category, mission);
    }

    notifyListeners();
  }

  // 카테고리별 주간 미션 설정 초기화
  void resetWeeklyMissionsForCategory(String category) {
    _selectedWeeklyMissions[category] = {};
    notifyListeners();
  }

  // 데이터 저장
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // 누적 수량 저장
    accumulatedQuantities.forEach((key, value) {
      prefs.setInt('accumulated_$key', value);
    });
    prefs.setInt('completedMissionsCount', completedMissionsCount);

    // 미션 저장
    prefs.setStringList('dailyMissions', _dailyMissions);
    prefs.setStringList('completedDailyMissions', _completedDailyMissions);

    prefs.setStringList(
      'selectedWeeklyMissions',
      _selectedWeeklyMissions.entries
          .map((entry) => '${entry.key}:${entry.value.join(",")}')
          .toList(),
    );

    prefs.setStringList(
      'completedWeeklyMissions',
      _completedWeeklyMissions.entries
          .map((entry) => '${entry.key}:${entry.value.join(",")}')
          .toList(),
    );
  }

  // 데이터 로드
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // 누적 수량 불러오기
    accumulatedQuantities.forEach((key, _) {
      accumulatedQuantities[key] = prefs.getInt('accumulated_$key') ?? 0;
    });
    completedMissionsCount = prefs.getInt('completedMissionsCount') ?? 0;

    // 미션 불러오기
    _dailyMissions = prefs.getStringList('dailyMissions') ?? [];
    _completedDailyMissions = prefs.getStringList('completedDailyMissions') ?? [];

    final selectedWeeklyList = prefs.getStringList('selectedWeeklyMissions') ?? [];
    _selectedWeeklyMissions = {
      for (var item in selectedWeeklyList)
        item.split(":")[0]: item.split(":")[1].split(",").toSet()
    };

    final completedWeeklyList = prefs.getStringList('completedWeeklyMissions') ?? [];
    _completedWeeklyMissions = {
      for (var item in completedWeeklyList)
        item.split(":")[0]: item.split(":")[1].split(",").toList()
    };

    notifyListeners();
  }

}
