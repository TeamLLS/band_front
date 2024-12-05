import 'package:flutter/material.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  String selectedValue = "회원";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("모임 활동 통계"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DropdownButton<String>(
              value: selectedValue,
              hint: Text(selectedValue),
              items: ['회원', '활동', '예산', '참가율', '납부율'].map(
                (str) {
                  return DropdownMenuItem<String>(
                    value: str,
                    child: Text(str),
                  );
                },
              ).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue!;
                });
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(selectedValue),
      ),
    );
  }
}
