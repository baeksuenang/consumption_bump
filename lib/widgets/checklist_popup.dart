import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chart_provider.dart';

class ChecklistPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chartProvider = Provider.of<ChartProvider>(context);
    final selectedQuantities = chartProvider.selectedQuantities;

    return AlertDialog(
      title: Text("Select Options"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: selectedQuantities.keys.map((option) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(option),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      int newValue = selectedQuantities[option]! - 1;
                      if (newValue >= 0) {
                        chartProvider.updateTemporaryQuantity(option, newValue);
                      }
                    },
                  ),
                  Text('${selectedQuantities[option]}'), // 현재 입력 중인 수량 표시
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      int newValue = selectedQuantities[option]! + 1;
                      chartProvider.updateTemporaryQuantity(option, newValue);
                    },
                  ),
                ],
              ),
            ],
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            chartProvider.applyQuantities(); // 선택한 수량을 누적하고 초기화
            Navigator.pop(context);
          },
          child: Text("Apply"),
        ),
      ],
    );
  }
}
