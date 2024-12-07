import 'dart:convert';
import 'dart:developer';

import 'package:band_front/cores/api.dart';
import 'package:band_front/cores/repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  String selectedValue = "활동";

  // Body 위젯을 결정하는 메소드
  Widget getBody(String selectedValue) {
    int clubId = context.read<ClubDetailRepo>().clubId!;
    switch (selectedValue) {
      case '회원':
        return MemberStatistics(clubId: clubId);
      case '활동':
        return ActivityStatistics(clubId: clubId);
      case '예산':
        return BudgetStatistics(clubId: clubId);
      case '참가율':
        return ParticipationStatistics(clubId: clubId);
      case '납부율':
        return PaymentStatistics(clubId: clubId);
      default:
        return const Center(child: Text("Unknown"));
    }
  }

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
              items: ['회원', '활동', '예산', '참가율', '납부율']
                  .map(
                    (str) => DropdownMenuItem<String>(
                      value: str,
                      child: Text(str),
                    ),
                  )
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue!;
                });
              },
            ),
          ),
        ],
      ),
      body: getBody(selectedValue),
    );
  }
}

class MemberStatistics extends StatelessWidget {
  MemberStatistics({super.key, required this.clubId});
  int clubId;
  List<dynamic> dataList = [];

  // data : _Map<String, dynamic> {list : [ {~~~}, {~~} ](dynamic)}
  // data['list'] : List<dynamic> [ {~~~}, {~~} ]
  // data['list'][0] : Map<String, dynamic> {~~~}

  Future<void> getData() async {
    var data = await StatisticsApi.getMemberStatistics(clubId, null);
    log("== local data ==");
    log("$dataList");

    dataList = data['list'];
  }

  ///year: 2024, ~ 2023
  ///month: 11,
  ///trend: 0, -> 증감 후 회원 변화 수
  ///memberRegisterCount: 6,
  ///memberLeftCount: 5,
  ///memberBanCount: 1
  ///}

  @override
  Widget build(BuildContext context) {
    double parentWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 데이터 로딩 중일 때 로딩 스피너 표시
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // 에러가 발생한 경우 에러 메시지 표시
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        double maxY = dataList
            .map((entry) => entry['trend'] as int)
            .reduce((a, b) => a.abs() > b.abs() ? a : b)
            .abs()
            .toDouble();
        int interval = ((maxY / 5).ceil()); // 간격을 정수로 계산 (5등분)
        int upperBound = interval * 5; // 최대값을 간격에 맞춰 정수로 설정

        double barmaxY = dataList
            .map((entry) => [
                  entry['memberRegisterCount']!,
                  entry['memberLeftCount']!,
                  entry['memberBanCount']!
                ])
            .expand((e) => e) // 모든 값들을 평탄화하여 한 리스트로 만듦
            .reduce((a, b) => a > b ? a : b)
            .toDouble();
        int barInterval = ((barmaxY / 5).ceil()); // 간격을 정수로 계산 (5등분)
        int barUpperBound = barInterval * 5; // 최대값을 간격에 맞춰 정수로 설정

        return SingleChildScrollView(
          child: Column(children: [
            Container(
              width: parentWidth,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.green[300]),
                ),
                child: const Text("조회 날짜 선택"),
              ),
            ),
            const Text(
              "회원 수 증감 추이",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 32, 0),
              height: parentWidth * 0.8,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 1, // y축 간격을 1로 설정
                    verticalInterval: 1, // x축 간격을 1로 설정
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      if (value == 0) {
                        // y=0 위치에 진한 구분선
                        return const FlLine(
                          color: Colors.black,
                          strokeWidth: 2,
                        );
                      } else {
                        return const FlLine(
                          color: Colors.grey,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      }
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval.toDouble(),
                        reservedSize: 40,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          int month = dataList[value.toInt()]['month'];
                          return Text("$month");
                        },
                      ),
                    ),
                  ),
                  minY: -upperBound.toDouble(),
                  maxY: upperBound.toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dataList.asMap().entries.map((entry) {
                        int index = entry.key; // 인덱스를 x값으로 설정
                        var data = entry.value; // entry.value는 Map 형태입니다

                        double xValue = index.toDouble(); // 인덱스를 x값으로 설정
                        return FlSpot(
                            xValue, data['trend']!.toDouble()); // trend 값은 y값
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            const Text("month"),
            const SizedBox(height: 32),
            const Text(
              "각 항목 별 회원 수 변화",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: parentWidth * 0.8,
              padding: const EdgeInsets.fromLTRB(16, 8, 32, 0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: barInterval.toDouble(),
                        reservedSize: 40,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          int month = dataList[value.toInt()]['month'];
                          return Text("$month");
                        },
                      ),
                    ),
                  ),
                  maxY: barUpperBound.toDouble(), // maxY에 설정할 값을 구함
                  barGroups: dataList.asMap().entries.map((entry) {
                    int index = entry.key; // 인덱스를 x값으로 설정
                    var data = entry.value; // entry.value는 Map 형태입니다

                    // 각 항목에 대해 BarChartRodData 생성
                    return BarChartGroupData(
                      x: index, // x축 값 (index)
                      barRods: [
                        BarChartRodData(
                          toY: data['memberRegisterCount']!.toDouble(),
                          color: Colors.blue,
                          width: 5,
                        ),
                        BarChartRodData(
                          toY: data['memberLeftCount']!.toDouble(),
                          color: Colors.red,
                          width: 5,
                        ),
                        BarChartRodData(
                          toY: data['memberBanCount']!.toDouble(),
                          color: Colors.green,
                          width: 5,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  color: Colors.blue,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Text("가입 인원"),
                ),
                Container(
                  width: 20,
                  height: 20,
                  color: Colors.red,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Text("탈퇴 인원"),
                ),
                Container(
                  width: 20,
                  height: 20,
                  color: Colors.green,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Text("추방 인원"),
                ),
              ],
            ),
            const SizedBox(height: 64),
          ]),
        );
      },
    );
  }
}

// [log] {list: [
//{clubId: 1, year: 2024, month: 11, trend: 2, actCloseCount: 2, actCancelCount: 1},
//{clubId: 1, year: 2024, month: 10, trend: 4, actCloseCount: 4, actCancelCount: 0},
//{clubId: 1, year: 2024, month: 9, trend: 1, actCloseCount: 1, actCancelCount: 1},
//{clubId: 1, year: 2024, month: 7, trend: 3, actCloseCount: 3, actCancelCount: 0},
//{clubId: 1, year: 2024, month: 6, trend: 2, actCloseCount: 2, actCancelCount: 0},
// {clubId: 1, year: 2024, month: 5, trend: 2, actCloseCount: 2, actCancelCount: 1},
//{clubId: 1, year: 2024, month: 3, trend: 1, actCloseCount: 1, actCancelCount: 3},
//{clubId: 1, year: 2023, month: 12, trend: 4, actCloseCount: 4, actCancelCount: 0},
//{clubId: 1, year: 2023, month: 11, trend: 3, actCloseCount: 3, actCancelCount: 1}]}

class ActivityStatistics extends StatelessWidget {
  ActivityStatistics({super.key, required this.clubId});
  int clubId;
  List<dynamic> dataList = [];

  // getData()에서 바로 데이터를 반환하도록 수정
  Future<List<dynamic>> getData() async {
    var data = await StatisticsApi.getActivityStatistics(clubId, null);
    return data['list']; // null인 경우 빈 리스트 반환
  }

  @override
  Widget build(BuildContext context) {
    double parentWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<List<dynamic>>(
      future: getData(), // List<dynamic> 타입으로 변경
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        dataList = snapshot.data!; // snapshot.data를 사용

        log("== local data ==");
        log("$dataList");

        double maxY = dataList
            .map((entry) => [
                  entry['actCloseCount'],
                  entry['actCancelCount'],
                ])
            .expand((e) => e)
            .reduce((a, b) => a > b ? a : b)
            .toDouble();

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: parentWidth,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.green[300]),
                  ),
                  child: const Text("조회 날짜 선택"),
                ),
              ),
              // const Text(
              //   "활동 증감 추이",
              //   style: TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // // Line chart
              // Container(
              //   padding: const EdgeInsets.fromLTRB(16, 0, 32, 0),
              //   height: parentWidth * 0.8,
              //   child: LineChart(
              //     LineChartData(
              //       gridData: FlGridData(
              //         show: true,
              //         horizontalInterval: 1,
              //         verticalInterval: 1,
              //         drawHorizontalLine: true,
              //       ),
              //       titlesData: FlTitlesData(
              //         leftTitles: const AxisTitles(
              //           sideTitles: SideTitles(
              //             showTitles: true,
              //             interval: 1,
              //           ),
              //         ),
              //         rightTitles: const AxisTitles(
              //           sideTitles: SideTitles(showTitles: false),
              //         ),
              //         topTitles: const AxisTitles(
              //           sideTitles: SideTitles(showTitles: false),
              //         ),
              //         bottomTitles: AxisTitles(
              //           sideTitles: SideTitles(
              //             showTitles: true,
              //             interval: 1,
              //             getTitlesWidget: (value, meta) {
              //               int month = dataList[value.toInt()]['month'];
              //               return Text("$month");
              //             },
              //           ),
              //         ),
              //       ),
              //       minY: 0,
              //       maxY: maxY + 2, // maxY 값 사용
              //       lineBarsData: [
              //         LineChartBarData(
              //           spots: dataList.asMap().entries.map((entry) {
              //             int index = entry.key;
              //             var data = entry.value;
              //             double xValue = index.toDouble();
              //             return FlSpot(xValue, data['trend'].toDouble());
              //           }).toList(),
              //           isCurved: true,
              //           color: Colors.blue,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 32),
              const Text(
                "활동 완료 / 취소 추이",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Bar chart
              Container(
                height: parentWidth * 0.8,
                padding: const EdgeInsets.fromLTRB(16, 8, 32, 0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY + maxY % 100, // maxY 값 사용
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            int month = dataList[value.toInt()]['month'];
                            return Text("$month");
                          },
                        ),
                      ),
                    ),
                    barGroups: dataList.asMap().entries.map((entry) {
                      int index = entry.key;
                      var data = entry.value;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data['actCloseCount'].toDouble(),
                            color: Colors.blue,
                            width: 5,
                          ),
                          BarChartRodData(
                            toY: data['actCancelCount'].toDouble(),
                            color: Colors.red,
                            width: 5,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Legend (color meaning text)
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    color: Colors.blue,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Text("수행된 활동"),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    color: Colors.red,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Text("취소된 활동"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class BudgetStatistics extends StatelessWidget {
  BudgetStatistics({super.key, required this.clubId});
  int clubId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("$clubId"),
    );
  }
}

class ParticipationStatistics extends StatelessWidget {
  ParticipationStatistics({super.key, required this.clubId});
  int clubId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("$clubId"),
    );
  }
}

class PaymentStatistics extends StatelessWidget {
  PaymentStatistics({super.key, required this.clubId});
  int clubId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("$clubId"),
    );
  }
}
