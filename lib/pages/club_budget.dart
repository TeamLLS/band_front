// dependencies
import 'package:band_front/cores/data_class.dart';
import 'package:band_front/cores/router.dart';
import 'package:band_front/cores/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// local dependencies
import '../cores/repository.dart';

class BudgetCtrlView extends StatefulWidget {
  const BudgetCtrlView({super.key});

  @override
  State<BudgetCtrlView> createState() => _BudgetCtrlViewState();
}

class _BudgetCtrlViewState extends State<BudgetCtrlView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('모임 회계 장부'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '예산'), Tab(text: '장부')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [BudgetView(), PaymentView()],
      ),
    );
  }
}

class BudgetView extends StatefulWidget {
  const BudgetView({super.key});

  @override
  State<BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends State<BudgetView> {
  bool isLoaded = false;
  DateTime? _filteredDate;

  Future<void> _filterBtnListener() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _filteredDate) {
      setState(() {
        _filteredDate = picked;
        _filterBtnHandler();
      });
    }
  }

  Future<void> _filterBtnHandler() async {
    bool result =
        await context.read<BudgetInfo>().reloadBudgetInfo(_filteredDate!);
    if (result == false) {
      _showSnackBar("기록을 불러오지 못했습니다..");
      return;
    }
  }

  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<void> _initBudgetView() async {
    int clubId = context.read<ClubDetail>().clubId!;
    bool result = await context.read<BudgetInfo>().initBudgetInfo(clubId);
    if (result == false) {
      _showSnackBar("예산 불러오기 실패..");
      return;
    }

    setState(() {
      isLoaded = true;
      _filteredDate = DateTime.now();
    });
  }

  @override
  void initState() {
    super.initState();
    _initBudgetView();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoaded == false || _filteredDate == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double parentWidth = MediaQuery.of(context).size.width;
    int amount = context.watch<BudgetInfo>().budget ?? 0;
    List<BudgetRecordEntity> record = context.watch<BudgetInfo>().record;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: budgetUnit(amount: amount, parentWidth: parentWidth),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: menuBarUnit(
            width: parentWidth,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("~ ${formatToYMD(_filteredDate.toString())}"),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () async => await _filterBtnListener(),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: record.length,
            itemBuilder: (context, index) {
              var entity = record[index];
              Color? color;
              if (entity.amount == 0) {
                color = Colors.black;
              } else if (entity.amount > 0) {
                color = Colors.blue;
              } else if (entity.amount < 0) {
                color = Colors.red;
              } else {
                color = null;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entity.time),
                      Text(entity.username),
                    ],
                  ),
                  Text(
                    entity.description,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Row(children: [
                    const Spacer(),
                    Text(
                      "${entity.amount}",
                      style: TextStyle(fontSize: 18, color: color),
                    ),
                    const VerticalDivider(),
                    Text(
                      "after",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ]),
                  const Divider(color: Colors.grey),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }
}

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  bool isLoaded = false;

  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<void> _initPaymentView() async {
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
    _initPaymentView();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoaded == false) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    List<PaymentEntity> payments = context.watch<PaymentInfo>().paments;

    return ListView.builder(
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

        // id x
        // name o
        // amount
        // status o
        // deadline o

        return InkWell(
          onTap: () {
            context.push(
              RouterPath.paymentDetail,
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
                        "마감일  :  ${formatToYMD(payment.deadline.toString())}",
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
    );
  }
}

class PaymentDetailView extends StatefulWidget {
  PaymentDetailView({super.key, required this.paymentId});
  int paymentId;

  @override
  State<PaymentDetailView> createState() => _PaymentDetailViewState();
}

class _PaymentDetailViewState extends State<PaymentDetailView> {
  bool _isLoaded = false;

  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<void> _initPaymentDetailView() async {
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
    _initPaymentDetailView();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded == false) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Payment payment = context.read<PaymentDetail>().payment!;
    double parentWidth = MediaQuery.of(context).size.width;
    String startDate = formatToYMD(payment.createdAt.toString());
    String deadline = formatToYMDHM(payment.deadline.toString());
    Widget endDate = payment.closedAt == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text("${formatToYMD(payment.closedAt.toString())}에 모금 종료됨"),
          );

    //status 추가 : 입금액이 회비에 못미치면 ex) 진행 중
    // 현재 납부액 -> 고려 중
    // 총액
    // 미납 인원 (진행중 까지) -> 추가 예정
    // 납부 인원
    // 제외 인원

    return Scaffold(
      appBar: AppBar(title: Text(payment.name)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(children: [
          desUnit(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text("회비  :  ${payment.amount}"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text("담당자  :  ${payment.createdBy}"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text("상태  :  현재 ${payment.status}"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text("모금 기간  :  $startDate  ~  $deadline"),
                  ),
                  endDate,
                  const Divider(color: Colors.grey),
                  Text(payment.description),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Column(children: [
              Text("납부자 목록"),
              Divider(),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: context.watch<PaymentDetail>().paymentTargets.length,
              itemBuilder: (context, index) {
                PaymentTargetEntity target =
                    context.watch<PaymentDetail>().paymentTargets[index];
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

                return desUnit(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              target.memberName,
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(target.username),
                            target.paidAt == null
                                ? const SizedBox.shrink()
                                : Text(
                                    "입금 날짜  :  ${formatToYMD(target.paidAt.toString())}",
                                  ),
                          ],
                        ),
                        Text(
                          target.status,
                          style: TextStyle(fontSize: 18, color: statusColor),
                        ),
                      ],
                    ),
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
