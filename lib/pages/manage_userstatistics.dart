import 'dart:developer';

import 'package:band_front/cores/api.dart';
import 'package:band_front/cores/repository.dart';
import 'package:band_front/cores/widget_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../cores/router.dart';

class UserStatisticsView extends StatefulWidget {
  const UserStatisticsView({super.key});

  @override
  State<UserStatisticsView> createState() => _UserStatisticsViewState();
}

class _UserStatisticsViewState extends State<UserStatisticsView> {
  List<dynamic> members = [];
  String selectedValue = "전체"; //상위 회원, 하위 회원
  bool isLoaded = false;
  late int clubId;

  Icon _getRoleIcon(String role) {
    switch (role) {
      case '회장':
        return const Icon(Icons.stars, color: Colors.yellow);
      case '관리자':
        return const Icon(Icons.build, color: Colors.blue);
      case '일반':
        return const Icon(Icons.person, color: Colors.green);
      default:
        return const Icon(Icons.help, color: Colors.red);
    }
  }

  Future<void> getData() async {
    dynamic data;
    if (selectedValue == "전체") {
      data = await StatisticsApi.getRankStatistics(clubId, null);
    } else if (selectedValue == "상위 회원") {
      data = await StatisticsApi.getRankStatistics(clubId, 1);
    } else {
      data = await StatisticsApi.getRankStatistics(clubId, 2);
    }

    setState(() {
      members = data['list'];
    });
  }

  @override
  void initState() {
    super.initState();
    _initUserStaticsView();
  }

  Future<void> _initUserStaticsView() async {
    clubId = context.read<ClubDetailRepo>().clubId!;
    await getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원 관리 정보"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DropdownButton<String>(
              value: selectedValue,
              items: ['전체', '상위 회원', '하위 회원']
                  .map(
                    (str) => DropdownMenuItem<String>(
                      value: str,
                      child: Text(str),
                    ),
                  )
                  .toList(),
              onChanged: (String? newValue) async {
                selectedValue = newValue!;
                await getData();
                setState(() {});
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              itemCount: members.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    elevation: 5.0, // 그림자 효과
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: ListTile(
                      leading: _getRoleIcon(members[index]['role']),
                      title: Text(members[index]['role']),
                      subtitle: Text(
                          '${members[index]['memberName']}  |  ${members[index]['username']}'),
                      trailing: Text(members[index]['point'].toString()),
                      onTap: () {
                        context.push(
                          RouterPath.personalStatistics,
                          extra: {
                            'clubId': members[index]['clubId'],
                            'memberId': members[index]['memberId'],
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalStatisticsView extends StatelessWidget {
  PersonalStatisticsView({
    super.key,
    required this.clubId,
    required this.memberId,
  });
  int clubId;
  int memberId;
  List<dynamic> participationList = [];
  int attendCount = 0;
  int notAttendCount = 0;
  int lateAttendCount = 0;
  int lateNotAttendCount = 0;
  List<dynamic> paymentList = [];
  int payCount = 0;
  int unPayCount = 0;
  int latePayCount = 0;

  Future<void> _setPaymentData() async {
    var data =
        await StatisticsApi.getPaymentRateStatistics(clubId, memberId, null);
    paymentList = data['list'];
    log("===== 2. PaymentRate =====");
    log("$paymentList");

    for (var item in paymentList) {
      payCount += item['payCount'] as int;
      unPayCount += item['unPayCount'] as int;
      latePayCount += item['latePayCount'] as int;
    }
  }

  Future<void> _setParticipationData() async {
    var data = await StatisticsApi.getParticipationRateStatistics(
        clubId, memberId, null);
    participationList = data['list'];

    for (var item in participationList) {
      attendCount += item['attendCount'] as int;
      notAttendCount += item['notAttendCount'] as int;
      lateAttendCount += item['lateAttendCount'] as int;
      lateNotAttendCount += item['lateNotAttendCount'] as int;
    }
  }

  Future<Map<String, dynamic>> _setScore() async {
    return await StatisticsApi.getScoreStatistics(clubId, memberId);
  }

  Future<Map<String, dynamic>> getData() async {
    await _setParticipationData();
    await _setPaymentData();
    return await _setScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("개인별 통계 조회")),
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.data == null) {
              // 데이터 로딩 중일 때 로딩 스피너 표시
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // 에러가 발생한 경우 에러 메시지 표시
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            double parentWidth = MediaQuery.of(context).size.width;

            double barmaxY = paymentList
                .map((entry) => [
                      entry['payAmount']!,
                      entry['unPayAmount']!,
                      entry['latePayAmount']!,
                    ])
                .expand((e) => e) // 모든 값들을 평탄화하여 한 리스트로 만듦
                .reduce((a, b) => a > b ? a : b)
                .toDouble();
            int barInterval = ((barmaxY / 5).ceil()); // 간격을 정수로 계산 (5등분)
            int barUpperBound = barInterval * 5; // 최대값을 간격에 맞춰 정수로 설정
            Map<String, dynamic> data = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(3),
                      },
                      border: TableBorder.all(color: Colors.grey),
                      children: [
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('점수'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(data['point'].toString()),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('참여율'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: data['attendRate'],
                                    minHeight: 10,
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                    '${(data['attendRate'] * 100).toStringAsFixed(1)}%'),
                              ],
                            ),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('납부율'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: data['payRate'],
                                    minHeight: 10,
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                    '${(data['payRate'] * 100).toStringAsFixed(1)}%'),
                              ],
                            ),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('총 납부액'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('₩ ${data['payAmount']}'),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('총 미납액'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('₩ ${data['unPaidTotal']}'),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('마지막 활동 참여일'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                formatStringToYMDHM(data['lastAttendTime'])),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('마지막 회비 납부일'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                Text(formatStringToYMDHM(data['lastPayTime'])),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  const Text(
                    "활동 참여율",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  AspectRatio(
                    aspectRatio: 1.7,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: attendCount.toDouble(),
                            title: attendCount.toString(),
                            color: Colors.blue,
                            // titleStyle: const TextStyle(
                            //   fontSize: 18,
                            //   fontWeight: FontWeight.bold,
                            //   color: Colors.white,
                            // ),
                          ),
                          PieChartSectionData(
                            value: notAttendCount.toDouble(),
                            title: notAttendCount.toString(),
                            color: Colors.grey,
                          ),
                          PieChartSectionData(
                            value: lateAttendCount.toDouble(),
                            title: lateAttendCount.toString(),
                            color: Colors.green,
                          ),
                          PieChartSectionData(
                            value: lateNotAttendCount.toDouble(),
                            title: lateNotAttendCount.toString(),
                            color: Colors.red,
                          ),
                        ],
                        centerSpaceRadius: parentWidth * 0.15,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        color: Colors.blue,
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Text("참여"),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        color: Colors.grey,
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Text("불참"),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        color: Colors.green,
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Text("추가 참가"),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        color: Colors.red,
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Text("추가 불참"),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: Text(
                      "회비 납부율",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 1.7,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: payCount.toDouble(),
                            title: payCount.toString(),
                            color: Colors.blue,
                          ),
                          PieChartSectionData(
                            value: unPayCount.toDouble(),
                            title: unPayCount.toString(),
                            color: Colors.red,
                          ),
                          PieChartSectionData(
                            value: latePayCount.toDouble(),
                            title: latePayCount.toString(),
                            color: Colors.orange,
                          ),
                        ],
                        centerSpaceRadius: parentWidth * 0.15,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
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
                        child: Text("납부"),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        color: Colors.red,
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Text("미납"),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        color: Colors.orange,
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Text("연체 납부"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 64),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(
                          "납부액 통계",
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
                                int month = paymentList[value.toInt()]['month'];
                                return Text("$month");
                              },
                            ),
                          ),
                        ),
                        maxY: barUpperBound.toDouble(), // maxY에 설정할 값을 구함
                        barGroups: paymentList.asMap().entries.map((entry) {
                          int index = entry.key; // 인덱스를 x값으로 설정
                          var data = entry.value; // entry.value는 Map 형태입니다

                          // 각 항목에 대해 BarChartRodData 생성
                          return BarChartGroupData(
                            x: index, // x축 값 (index)
                            barRods: [
                              BarChartRodData(
                                toY: data['payAmount']!.toDouble(),
                                color: Colors.blue,
                                width: 5,
                              ),
                              BarChartRodData(
                                toY: data['latePayAmount']!.toDouble(),
                                color: Colors.orange,
                                width: 5,
                              ),
                              BarChartRodData(
                                toY: data['unPayAmount']!.toDouble(),
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
                  SizedBox(height: 100),
                ],
              ),
            );
          }),
    );
  }
}


/// 1. 참가율 변화
/// {clubId: 1, memberId: 2, year: 2024, month: 11, 
///   trend: 0.5, attendCount: 0, notAttendCount: 1, lateAttendCount: 1, lateNotAttendCount: 0}, 
/// 
/// {clubId: 1, memberId: 2, year: 2024, month: 10, trend: 0.75, attendCount: 2, notAttendCount: 1, lateAttendCount: 1, lateNotAttendCount: 0}, 
/// {clubId: 1, memberId: 2, year: 2024, month: 9, trend: 0.0, attendCount: 0, notAttendCount: 0, lateAttendCount: 0, lateNotAttendCount: 1}, 
/// {clubId: 1, memberId: 2, year: 2024, month: 7, trend: 0.6666666666666666, attendCount: 2, notAttendCount: 1, lateAttendCount: 0, lateNotAttendCount: 0}, 
/// {clubId: 1, memberId: 2, year: 2024, month: 6, trend: 1.0, attendCount: 1, notAttendCount: 0, lateAttendCount: 1, lateNotAttendCount: 0}
/// 
/// 
/// 2. 납부율 변화
/// {year: 2024, month: 11, trend: 1.0, payCount: 1, unPayCount: 0, latePayCount: 0, 
///   payAmount: 7000, unPayAmount: 0, latePayAmount: 0}, 
/// 
/// {year: 2024, month: 10, trend: 0.75, payCount: 3, unPayCount: 1, latePayCount: 0, payAmount: 15000, unPayAmount: 4000, latePayAmount: 0}, 
/// {year: 2024, month: 9, trend: 0.0, payCount: 0, unPayCount: 1, latePayCount: 0, payAmount: 0, unPayAmount: 6000, latePayAmount: 0}, 
/// {year: 2024, month: 7, trend: 1.0, payCount: 2, unPayCount: 0, latePayCount: 1, payAmount: 9000, unPayAmount: 0, latePayAmount: 4000}, 
/// {year: 2024, month: 6, trend: 1.0, payCount: 2, unPayCount: 0, latePayCount: 0, payAmount: 10000, unPayAmount: 0, latePayAmount: 0}, 
/// {year: 2024, month: 5, trend: 1.0, payCount: 1, unPayCount: 0, latePayCount: 0, payAmount: 4000, unPayAmount: 0, latePayAmount: 0}, 
/// {year: 2024, month: 3, trend: 1.0, payCount: 1, unPayCount: 0, latePayCount: 0, payAmount: 5000, unPayAmount: 0, latePayAmount: 0}, 
/// {year: 2023, month: 12, trend: 1.0, payCount: 3, unPayCount: 0, latePayCount: 0, payAmount: 18000, unPayAmount: 0, latePayAmount: 5000}, 
/// {year: 2023, month: 11, trend: 1.0, payCount: 3, unPayCount: 0, latePayCount: 0, payAmount: 15000, unPayAmount: 0, latePayAmount: 0}
/// 
/// 3. 회원 개인 점수
/// clubId: 1, memberId: 2, 
/// point: 19, 
/// attendRate: 0.631578947368421, 
/// payRate: 0.875, 
/// payAmount: 77000, 
/// unPaidTotal: 10000, 
/// lastAttendTime: 2024-12-06T00:44:23.760302Z, 
/// lastPayTime: 2024-12-05T13:37:43.760303Z