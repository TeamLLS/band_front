import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../cores/api.dart';
import '../cores/data_class.dart';
import '../cores/repository.dart';
import '../cores/router.dart';
import '../cores/widget_utils.dart';

class PaymentManageView extends StatefulWidget {
  const PaymentManageView({super.key});

  @override
  State<PaymentManageView> createState() => _PaymentManageViewState();
}

class _PaymentManageViewState extends State<PaymentManageView> {
  bool isLoaded = false;
  DateTime? deadline;

  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    deadline = DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> writeBtnListener() async {
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
              ElevatedButton(
                onPressed: () async => await _pickDateTime(),
                child: const Text("마감일 지정"),
              ),
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
                  return;
                }

                await writeBtnHandler(amount, name, description);
              },
              child: const Text('등록'),
            ),
          ],
        );
      },
    );
  }

  Future<void> writeBtnHandler(
    int amount,
    String name,
    String description,
  ) async {
    if (deadline == null) {
      _showSnackBar("마감일을 지정해 주세요");
      return;
    }

    await context
        .read<PaymentListRepo>()
        .registPayment(amount, name, description, deadline!)
        .then((ret) {
      if (ret == false) {
        _showSnackBar("something went wrong...");
        return;
      }
      _showSnackBar("장부가 등록되었습니다.");
      context.pop();
    });
  }

  @override
  void initState() {
    super.initState();
    _initPaymentManageView();
  }

  Future<void> _initPaymentManageView() async {
    int clubId = context.read<ClubDetailRepo>().clubId!;
    bool result =
        await context.read<PaymentListRepo>().initPaymentListInfo(clubId);
    if (result == false) {
      _showSnackBar("장부 목록 불러오기 실패..");
      return;
    }

    // TODO: 디버깅용. 끝나면 지울 것
    // dynamic ret = await BudgetApi.getMyPayments(clubId);
    // log("$ret");

    setState(() => isLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoaded == false) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    List<PaymentEntity> payments = context.watch<PaymentListRepo>().paments;

    return Scaffold(
      appBar: AppBar(
        title: const Text("납부 내역 관리"),
        actions: [
          IconButton(
            onPressed: () async => await writeBtnListener(),
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
            String deadline =
                payment.deadline == null ? "" : formatToYMD(payment.deadline!);

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
                  padding: const EdgeInsets.all(20),
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
                            "회비  :  ${payment.amount}",
                          ),
                          Text(
                            "마감일  :  $deadline",
                          ),
                        ],
                      ),
                      Text(
                        payment.status,
                        style: TextStyle(fontSize: 18, color: stateColor),
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
  //// 넣을 기능 (expanded tile 활용)
  // 장부 취소
  // 장부 만료

  // 납부 대상 등록 - 전체,선택, 특정 회원 제외
  // 선택 등록 빼고 특정 제외 회원으로만 구현하자
  // 회원 납부 상황 변경 - 납부, 미납, 연체 납부

  // 회원 expansion에 버튼 뭐 구현할까
  // 1. 미납 - 납부 - 연체 납부
  // 2. 특정 회원 제외 - 납부 대상 포함

  bool _isLoaded = false;

  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<void> closeBtnListener() async {
    bool ret = await context.read<PaymentDetailRepo>().cancelPayment();
    if (ret == false) {
      _showSnackBar("something went wrong...");
      return;
    }

    await closeBtnHandler();
  }

  Future<void> closeBtnHandler() async {
    await context.read<PaymentListRepo>().reloadPaymentListInfo().then((ret) {
      if (ret == false) {
        _showSnackBar("something went wrong...");
        return;
      }
      _showSnackBar("취소되었습니다.");
      context.pop();
    });
  }

  Future<void> expireBtnListener() async {
    bool ret = await context.read<PaymentDetailRepo>().expirePayment();
    if (ret == false) {
      _showSnackBar("something went wrong...");
      return;
    }

    await expireBtnHandler();
  }

  Future<void> expireBtnHandler() async {
    await context.read<PaymentListRepo>().reloadPaymentListInfo().then((ret) {
      if (ret == false) {
        _showSnackBar("something went wrong...");
        return;
      }
      _showSnackBar("만료 처리되었습니다.");
      context.pop();
    });
  }

  Future<void> paidBtnListener(int memberId) async {
    bool ret = await context.read<PaymentDetailRepo>().setPaid(memberId);
    if (ret == false) {
      _showSnackBar("something went wrong...");
      return;
    }
    _showSnackBar("납부 처리되었습니다");
    return;
  }

  Future<void> unpaidBtnListener(int memberId) async {
    bool ret = await context.read<PaymentDetailRepo>().setUnPaid(memberId);
    if (ret == false) {
      _showSnackBar("something went wrong...");
      return;
    }
    _showSnackBar("미납 처리되었습니다.");
    return;
  }

  Future<void> latePaidBtnListener(int memberId) async {
    bool ret = await context.read<PaymentDetailRepo>().setLatePaid(memberId);
    if (ret == false) {
      _showSnackBar("something went wrong...");
      return;
    }
    _showSnackBar("납부 처리되었습니다.");
    return;
  }

  Future<void> excludeBtnListener(int memberId) async {
    bool ret = await context.read<PaymentDetailRepo>().excludeMember(memberId);
    if (ret == false) {
      _showSnackBar("something went wrong...");
      return;
    }
    _showSnackBar("납부 대상에서 제외되었습니다.");
    return;
  }

  @override
  void initState() {
    super.initState();
    _initPaymentDetailManageView();
  }

  Future<void> _initPaymentDetailManageView() async {
    int clubId = context.read<ClubDetailRepo>().clubId!;
    int paymentId = widget.paymentId;

    bool ret = await context
        .read<PaymentDetailRepo>()
        .initPaymentDetail(clubId, paymentId);
    if (ret == false) {
      _showSnackBar("장부 정보를 불러오지 못했습니다..");
      return;
    }

    setState(() => _isLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded == false) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double parentWidth = MediaQuery.of(context).size.width;

    Payment payment = context.read<PaymentDetailRepo>().payment!;
    String startDate = formatToYMDHM(payment.createdAt);
    String deadline =
        payment.deadline == null ? "" : formatToYMDHM(payment.deadline!);

    return Scaffold(
      appBar: AppBar(
        title: const Text("장부 상세 정보"),
        actions: [
          IconButton(
            onPressed: () async {
              await closeBtnListener();
            },
            icon: const Icon(Icons.close),
          ),
          IconButton(
            onPressed: () async {
              await expireBtnListener();
            },
            icon: const Icon(Icons.task_alt),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            children: [
              Table(
                border: TableBorder.all(color: Colors.grey, width: 1),
                columnWidths: const {
                  0: FractionColumnWidth(0.3),
                  1: FractionColumnWidth(0.7),
                },
                children: [
                  TableRow(children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("장부명"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(payment.name),
                    ),
                  ]),
                  TableRow(children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("회비"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${payment.amount}'),
                    ),
                  ]),
                  TableRow(children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('담당자'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(payment.createdBy),
                    ),
                  ]),
                  TableRow(children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('상태'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(payment.status),
                    ),
                  ]),
                  TableRow(children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('생성 일자'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(startDate),
                    ),
                  ]),
                  TableRow(children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('마감 일자'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(deadline),
                    ),
                  ]),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: desUnit(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: desTextUnit(
                      maxLine: 3,
                      description: payment.description,
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
                  )),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount:
                    context.watch<PaymentDetailRepo>().paymentTargets.length,
                itemBuilder: (context, index) {
                  PaymentTargetEntity target =
                      context.watch<PaymentDetailRepo>().paymentTargets[index];

                  Color statusColor;
                  if (target.status == "납부") {
                    statusColor = Colors.blue;
                  } else if (target.status == "미납") {
                    statusColor = Colors.red;
                  } else if (target.status == "연체 납부") {
                    statusColor = Colors.orange;
                  } else {
                    statusColor = Colors.grey;
                  }

                  ElevatedButton btn1;
                  if (payment.status == "모금중") {
                    if (target.status == "미납") {
                      btn1 = ElevatedButton(
                        onPressed: () async {
                          await paidBtnListener(target.memberId);
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Colors.green,
                          ),
                        ),
                        child: const Text("납부됨"),
                      );
                    } else {
                      //납부, 연체납부, 제외(제외는 안뜸 목록에)의 경우
                      btn1 = ElevatedButton(
                        onPressed: () async {
                          await unpaidBtnListener(target.memberId);
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.red),
                        ),
                        child: const Text("미납"),
                      );
                    }
                  } else if (payment.status == "모금종료") {
                    if (target.status == "미납") {
                      btn1 = ElevatedButton(
                        onPressed: () async {
                          await latePaidBtnListener(target.memberId);
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.orange),
                        ),
                        child: const Text("연체 납부"),
                      );
                    } else {
                      btn1 = ElevatedButton(
                        onPressed: () async {
                          await unpaidBtnListener(target.memberId);
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.red),
                        ),
                        child: const Text("미납"),
                      );
                    }
                  } else {
                    btn1 = ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.black),
                      ),
                      child: const Text("exception"),
                    );
                  }

                  ElevatedButton btn2;
                  if (target.status == "제외") {
                    btn2 = ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.green),
                      ),
                      child: const Text("포함"),
                    );
                  } else {
                    btn2 = ElevatedButton(
                      onPressed: () async =>
                          await excludeBtnListener(target.memberId),
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.grey[400]),
                      ),
                      child: const Text("제외"),
                    );
                  }

                  if (payment.status == "취소됨") {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.remove),
                        title: Text(target.memberName),
                        subtitle: Text(target.username),
                        trailing: Text(
                          target.status,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        shape: Border.all(color: Colors.transparent),
                        title: Text(target.memberName),
                        subtitle: Text(target.username),
                        trailing: Text(
                          target.status,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [btn1, btn2],
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
