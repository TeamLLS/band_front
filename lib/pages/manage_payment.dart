import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../cores/data_class.dart';
import '../cores/repository.dart';
import '../cores/router.dart';
import '../cores/widget_utils.dart';

/*
  장부 생성
  장부 취소
  장부 만료

  납부 대상 등록
  납부 대상 제외

  회원 납부, 미납, 연체 납부

  expanded tile
 */

class PaymentManageView extends StatefulWidget {
  const PaymentManageView({super.key});

  @override
  State<PaymentManageView> createState() => _PaymentManageViewState();
}

class _PaymentManageViewState extends State<PaymentManageView> {
  bool isLoaded = false;

  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<void> _writeBtnHandler() async {
    final desCon = TextEditingController();
    final amountCon = TextEditingController();
    final nameCon = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('회비 장부 등록하기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCon,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '회비'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCon,
                decoration: const InputDecoration(hintText: '장부명'),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 3,
                controller: desCon,
                decoration: const InputDecoration(hintText: '비고'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                String description = desCon.text;
                String name = nameCon.text;
                int amount = int.tryParse(amountCon.text) ?? 0;
                if (amount == 0) {
                  context.pop();
                } else {
                  log("start");
                  await context
                      .read<PaymentInfo>()
                      .registPayment(
                        amount,
                        name,
                        description,
                      )
                      .then((_) => context.pop());
                }
              },
              child: const Text('등록'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initPaymentManageView() async {
    int clubId = context.read<ClubDetail>().clubId!;
    bool result = await context.read<PaymentInfo>().initPaymentInfo(clubId);
    if (result == false) {
      _showSnackBar("장부 목록 불러오기 실패..");
      return;
    }

    setState(() => isLoaded = true);
  }

  @override
  void initState() {
    super.initState();
    _initPaymentManageView();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoaded == false) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    List<PaymentEntity> payments = context.watch<PaymentInfo>().paments;

    return Scaffold(
      appBar: AppBar(
        title: const Text("납부 내역 관리"),
        actions: [
          IconButton(
            onPressed: () async => await _writeBtnHandler(),
            icon: const Icon(Icons.create),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: ListView.builder(
          itemCount: payments.length,
          itemBuilder: (context, index) {
            PaymentEntity payment = payments[index];

            Color stateColor;
            if (payment.status == "모금중") {
              stateColor = Colors.green;
            } else if (payment.status == "모금종료") {
              stateColor = Colors.red;
            } else {
              stateColor = Colors.grey;
            }

            return InkWell(
              onTap: () {
                context.push(
                  RouterPath.paymentDetailManage,
                  extra: {"paymentId": payment.id},
                );
              },
              child: desUnit(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.name,
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                              "${formatToYMD(payment.createdAt.toString())} ~"),
                        ],
                      ),
                      Text(
                        payment.status,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: stateColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PaymentDetailManageView extends StatefulWidget {
  PaymentDetailManageView({super.key, required this.paymentId});
  int paymentId;

  @override
  State<PaymentDetailManageView> createState() =>
      _PaymentDetailManageViewState();
}

class _PaymentDetailManageViewState extends State<PaymentDetailManageView> {
  bool _isLoaded = false;

  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<void> _initPaymentDetailManageView() async {
    int clubId = context.read<ClubDetail>().clubId!;
    int paymentId = widget.paymentId;

    bool ret = await context
        .read<PaymentDetail>()
        .initPaymentDetail(clubId, paymentId);
    if (ret == false) {
      _showSnackBar("장부 정보를 불러오지 못했습니다..");
      return;
    }

    setState(() => _isLoaded = true);
  }

  @override
  void initState() {
    super.initState();
    _initPaymentDetailManageView();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded == false) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Payment payment = context.read<PaymentDetail>().payment!;
    double parentWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text("납부 정보")),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: budgetUnit(amount: payment.amount, parentWidth: parentWidth),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: desUnit(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Spacer(flex: 1),
                      Text("담당자 : ${payment.name}"),
                      const Spacer(flex: 8),
                      Text(payment.status),
                      const Spacer(flex: 1),
                    ]),
                    const Divider(indent: 8, endIndent: 8, color: Colors.grey),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Text(payment.description),
                    ),
                    const Divider(indent: 8, endIndent: 8, color: Colors.grey),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Text(
                        "${formatToYMD(payment.createdAt.toString())} ~ ${payment.closedAt ?? ""}",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("납부자 목록"),
                Divider(),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: context.watch<PaymentDetail>().paymentTargets.length,
              itemBuilder: (context, index) {
                PaymentTargetEntity target =
                    context.watch<PaymentDetail>().paymentTargets[index];

                return desUnit(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(children: [
                      const Spacer(flex: 1),
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              target.memberName,
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(target.username),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          target.status,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: target.status != "납부"
                                ? Colors.red
                                : Colors.blue,
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                    ]),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
