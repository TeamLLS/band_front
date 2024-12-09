import 'dart:developer';

import 'package:band_front/cores/api.dart';
import 'package:flutter/material.dart';

class PersonalStatisticsView extends StatelessWidget {
  PersonalStatisticsView({
    super.key,
    required this.clubId,
    required this.memberId,
  });
  int clubId;
  int memberId;

  Future<void> getData() async {
    var data = await StatisticsApi.getParticipationRateStatistics(
        clubId, memberId, null);
    log("===== 1. participation =====");
    log("$data");

    data = await StatisticsApi.getPaymentRateStatistics(clubId, memberId, null);
    log("===== 2. PaymentRate =====");
    log("$data");

    data = await StatisticsApi.getScoreStatistics(clubId, memberId);
    log("===== 3. score =====");
    log("$data");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("개인 통계 자료")),
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            return Text("$clubId & $memberId");
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
/// lastAttendTime: 2024-12-06T00:44:23.760302Z, lastPayTime: 2024-12-05T13:37:43.760303Z