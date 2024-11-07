import 'package:flutter/material.dart';

class ChartProvider with ChangeNotifier {
  Map<String, int> selectedQuantities = {
    "취미": 0,
    "식사": 0,
    "의류": 0,
    "교통": 0,
  };

  Map<String, int> accumulatedQuantities = {
    "취미": 0,
    "식사": 0,
    "의류": 0,
    "교통": 0,
  };
  List<String> missions = [];

  void updateTemporaryQuantity(String option, int quantity) {
    selectedQuantities[option] = quantity;
    notifyListeners();
  }

  void applyQuantities() {
    selectedQuantities.forEach((option, quantity) {
      accumulatedQuantities[option] = (accumulatedQuantities[option] ?? 0) + quantity;
    });
    resetTemporaryQuantities();
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
    if (total == 0) return accumulatedQuantities.map((option, _) => MapEntry(option, 0.0));
    return accumulatedQuantities.map((option, quantity) => MapEntry(option, quantity / total));
  }
  void addMission(String missionName) {
    if (!missions.contains(missionName)) {
      missions.add(missionName);
      notifyListeners();
    }
  }

  void removeMission(String missionName) {
    missions.remove(missionName);
    notifyListeners();
  }

}

