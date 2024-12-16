import 'dart:convert';
import 'dart:developer';

import 'package:band_front/cores/api.dart';
import 'package:band_front/cores/repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../cores/router.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  String selectedValue = "회원 변화";

  // Body 위젯을 결정하는 메소드
  Widget getBody(String selectedValue) {
    int clubId = context.read<ClubDetailRepo>().clubId!;
    switch (selectedValue) {
      case '회원 변화':
        return MemberStatistics(clubId: clubId);
      case '활동량':
        return ActivityStatistics(clubId: clubId);
      case '예산 변화':
        return BudgetStatistics(clubId: clubId);
      // case '회원 통계':
      //   return RankStatistics(clubId: clubId);
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
              items: ['회원 변화', '활동량', '예산 변화']
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

class MemberStatistics extends StatefulWidget {
  MemberStatistics({super.key, required this.clubId});
  int clubId;

  @override
  State<MemberStatistics> createState() => _MemberStatisticsState();
}

class _MemberStatisticsState extends State<MemberStatistics> {
  List<dynamic> dataList = [];
  DateTime? date;

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2000), // 선택 가능한 시작 날짜
      lastDate: DateTime(2100), // 선택 가능한 마지막 날짜
    );
    if (pickedDate != null && pickedDate != date) {
      setState(() {
        date = pickedDate;
      });
    }
  }

  Future<void> getData() async {
    var data = await StatisticsApi.getMemberStatistics(widget.clubId, date);
    log("== local data ==");
    log("$dataList");

    dataList = List.from(data['list'].reversed);
  }

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

        if (dataList.isEmpty) {
          return const Center(child: Text("조회된 데이터가 없습니다."));
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
                onPressed: () async => _selectDate(),
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
            const Text("month"),
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

class ActivityStatistics extends StatefulWidget {
  ActivityStatistics({super.key, required this.clubId});
  int clubId;

  @override
  State<ActivityStatistics> createState() => _ActivityStatisticsState();
}

class _ActivityStatisticsState extends State<ActivityStatistics> {
  List<dynamic> dataList = [];
  DateTime? date;

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2000), // 선택 가능한 시작 날짜
      lastDate: DateTime(2100), // 선택 가능한 마지막 날짜
    );
    if (pickedDate != null && pickedDate != date) {
      setState(() {
        date = pickedDate;
      });
    }
  }

  // getData()에서 바로 데이터를 반환하도록 수정
  Future<void> getData() async {
    var data = await StatisticsApi.getActivityStatistics(widget.clubId, date);
    dataList = List.from(data['list'].reversed);
  }

  @override
  Widget build(BuildContext context) {
    double parentWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: getData(), // List<dynamic> 타입으로 변경
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (dataList.isEmpty) {
          return const Center(child: Text("조회된 데이터가 없습니다."));
        }

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
                  onPressed: () async => await _selectDate(),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.green[300]),
                  ),
                  child: const Text("조회 날짜 선택"),
                ),
              ),
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
              const Text("month"),
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

class BudgetStatistics extends StatefulWidget {
  BudgetStatistics({super.key, required this.clubId});
  int clubId;

  @override
  State<BudgetStatistics> createState() => _BudgetStatisticsState();
}

class _BudgetStatisticsState extends State<BudgetStatistics> {
  List<dynamic> dataList = [];
  DateTime? date;

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2000), // 선택 가능한 시작 날짜
      lastDate: DateTime(2100), // 선택 가능한 마지막 날짜
    );
    if (pickedDate != null && pickedDate != date) {
      setState(() {
        date = pickedDate;
      });
    }
  }

  ///{clubId: 1, year: 2024, month: 11, trend: 10000, income: 60000, expense: -50000},
  ///{clubId: 1, year: 2024, month: 10, trend: -30000, income: 190000, expense: -220000},
  ///{clubId: 1, year: 2024, month: 9, trend: 10000, income: 50000, expense: -40000},
  ///{clubId: 1, year: 2024, month: 7, trend: -30000, income: 120000, expense: -150000},
  ///{clubId: 1, year: 2024, month: 6, trend: -10000, income: 100000, expense: -110000}

  Future<void> getData() async {
    var data = await StatisticsApi.getBudgetStatistics(widget.clubId, date);
    dataList = List.from(data['list'].reversed);
  }

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

        if (dataList.isEmpty) {
          return const Center(child: Text("조회된 데이터가 없습니다."));
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
                  entry['income']!,
                  -entry['expense']!,
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
                onPressed: () async => await _selectDate(),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.green[300]),
                ),
                child: const Text("조회 날짜 선택"),
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    "총 예산 변화 추이",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text("단위 : 만 원", style: TextStyle(fontSize: 12)),
              ],
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 32, 0),
              height: parentWidth * 0.8,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
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
                        getTitlesWidget: (value, meta) {
                          return Text("${(value / 10000).toInt()}");
                        },
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    "수입 / 지출 변화",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text("단위 : 만 원", style: TextStyle(fontSize: 12)),
              ],
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
                        getTitlesWidget: (value, meta) {
                          return Text("${(value / 10000).toInt()}");
                        },
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
                          toY: data['income']!.toDouble(),
                          color: Colors.blue,
                          width: 5,
                        ),
                        BarChartRodData(
                          toY: -data['expense']!.toDouble(),
                          color: Colors.red,
                          width: 5,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const Text("month"),
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
                  child: Text("수입"),
                ),
                Container(
                  width: 20,
                  height: 20,
                  color: Colors.red,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Text("지출"),
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

// class RankStatistics extends StatelessWidget {
//   RankStatistics({super.key, required this.clubId});
//   int clubId;
//   List<dynamic> members = [];

//   Icon _getRoleIcon(String role) {
//     switch (role) {
//       case '회장':
//         return const Icon(Icons.stars, color: Colors.yellow);
//       case '관리자':
//         return const Icon(Icons.build, color: Colors.blue);
//       case '일반':
//         return const Icon(Icons.person, color: Colors.green);
//       default:
//         return const Icon(Icons.help, color: Colors.red);
//     }
//   }

//   ///{clubId: 1, memberId: 2, username: Dummy_userB, memberName: 임윤빈, role: 회장, point: 19},
//   ///{clubId: 1, memberId: 3, username: Dummy_userC, memberName: 권미르, role: 일반, point: 15},
//   ///{clubId: 1, memberId: 4, username: Dummy_userD, memberName: 최은, role: 일반, point: 11},
//   ///{clubId: 1, memberId: 1, username: Dummy_userA, memberName: 허연준, role: 관리자, point: 6},
//   ///{clubId: 1, memberId: 5, username: Dummy_userF, memberName: 하도준, role: 일반, point: 2}

//   Future<void> getData() async {
//     var data = await StatisticsApi.getRankStatistics(clubId);
//     members = data['list'];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: getData(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // 데이터 로딩 중일 때 로딩 스피너 표시
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             // 에러가 발생한 경우 에러 메시지 표시
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (members.isEmpty) {
//             return const Center(child: Text("조회된 데이터가 없습니다."));
//           }

//           return Column(
//             children: [
//               const Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Text(
//                   "회원 순위 및 개인 통계 조회",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
//                   itemCount: members.length,
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 8),
//                       child: Card(
//                         elevation: 5.0, // 그림자 효과
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(40.0),
//                         ),
//                         child: ListTile(
//                           leading: _getRoleIcon(members[index]['role']),
//                           title: Text(members[index]['role']),
//                           subtitle: Text(
//                               '${members[index]['memberName']}  |  ${members[index]['username']}'),
//                           trailing: Text(members[index]['point'].toString()),
//                           onTap: () {
//                             context.push(
//                               RouterPath.personalStatistics,
//                               extra: {
//                                 'clubId': members[index]['clubId'],
//                                 'memberId': members[index]['memberId'],
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         });
//   }
// }
