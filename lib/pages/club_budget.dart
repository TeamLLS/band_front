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
      initialDate: _filteredDate,
      firstDate: DateTime(2000).toUtc(),
      lastDate: DateTime(2100).toUtc(),
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
        await context.read<BudgetRepo>().reloadBudgetInfo(_filteredDate!);
    if (result == false) {
      _showSnackBar("기록을 불러오지 못했습니다..");
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _initBudgetView();
  }

  Future<void> _initBudgetView() async {
    int clubId = context.read<ClubDetailRepo>().clubId!;
    bool result = await context.read<BudgetRepo>().initBudgetInfo(clubId);
    if (result == false) {
      _showSnackBar("예산 불러오기 실패..");
      return;
    }

    setState(() {
      isLoaded = true;
      _filteredDate = DateTime.now().toUtc();
    });
  }

  void _showSnackBar(String text) => showSnackBar(context, text);

  @override
  Widget build(BuildContext context) {
    if (isLoaded == false || _filteredDate == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double parentWidth = MediaQuery.of(context).size.width;
    int amount = context.watch<BudgetRepo>().budget ?? 0;
    List<BudgetRecordEntity> record = context.watch<BudgetRepo>().record;

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
                  Text("~ ${formatToYMD(_filteredDate!)}"),
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
                      Text(formatStringToYMDHM(entity.time)),
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
    int clubId = context.read<ClubDetailRepo>().clubId!;
    bool result =
        await context.read<PaymentListRepo>().initPaymentListInfo(clubId);
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

    List<PaymentEntity> payments = context.watch<PaymentListRepo>().paments;

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
        String deadline =
            payment.deadline == null ? "" : formatToYMD(payment.deadline!);

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
  void initState() {
    super.initState();
    _initPaymentDetailView();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded == false) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Payment payment = context.read<PaymentDetailRepo>().payment!;
    double parentWidth = MediaQuery.of(context).size.width;
    String startDate = formatToYMD(payment.createdAt);
    String deadline =
        payment.deadline == null ? "" : formatToYMDHM(payment.deadline!);
    Widget endDate = payment.closedAt == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text("${formatToYMD(payment.closedAt!)}에 모금 종료됨"),
          );

    //status 추가 : 입금액이 회비에 못미치면 ex) 진행 중
    // 현재 납부액 -> 고려 중
    // 총액
    // 미납 인원 (진행중 까지) -> 추가 예정
    // 납부 인원
    // 제외 인원

    return Scaffold(
      appBar: AppBar(title: Text(payment.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(children: [
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
              padding: EdgeInsets.all(8),
              child: Column(children: [
                Text("납부자 목록"),
                Divider(),
              ]),
            ),
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
                String paidAt =
                    target.paidAt == null ? "" : formatToYMD(target.paidAt!);

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
                                    "입금 날짜  :  $paidAt",
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
          ]),
        ),
      ),
    );
  }
}
