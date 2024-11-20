// dependencies
import 'package:band_front/cores/data_class.dart';
import 'package:band_front/cores/widget_utils.dart';
import 'package:flutter/material.dart';
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
          child: desUnit(
            child: SizedBox(
              height: parentWidth * 0.3,
              child: Center(
                child: Text(
                  "$amount  ₩",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
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
        PaymentEntity pament = payments[index];

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey, width: 1.5),
            // boxShadow: const [
            //   BoxShadow(
            //     color: Colors.black,
            //     blurRadius: 1,
            //     offset: Offset(2, 2),
            //   )
            // ],
          ),
          child: ListTile(
            title: Text(pament.name),
            trailing: Text(pament.status),
            subtitle: Text("${formatToYMD(pament.createdAt.toString())} ~"),
            onTap: () {},
          ),
        );
      },
    );
  }
}

class PaymentDetailView extends StatefulWidget {
  const PaymentDetailView({super.key});

  @override
  State<PaymentDetailView> createState() => _PaymentDetailViewState();
}

class _PaymentDetailViewState extends State<PaymentDetailView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
