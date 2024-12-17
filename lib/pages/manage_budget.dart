import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../cores/data_class.dart';
import '../cores/repository.dart';
import '../cores/widget_utils.dart';

class BudgetManageView extends StatefulWidget {
  const BudgetManageView({super.key});

  @override
  State<BudgetManageView> createState() => _BudgetManageViewState();
}

class _BudgetManageViewState extends State<BudgetManageView> {
  bool isLoaded = false;
  DateTime? _filteredDate;

  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<void> _writeBtnListener() async {
    final desCon = TextEditingController();
    final amountCon = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('지출 내역 작성'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCon,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '지출액'),
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
                int amount = int.tryParse(amountCon.text) ?? 0;
                if (amount == 0) {
                  context.pop();
                } else {
                  amount = -amount;
                  await context
                      .read<BudgetRepo>()
                      .writeExpense(amount, desCon.text)
                      .then((ret) {
                    if (ret == false) {
                      _showSnackBar("something went wrong..");
                      context.pop();
                    } else {
                      _showSnackBar("작성되었습니다.");
                      context.pop();
                    }
                  });
                }
              },
              child: const Text('등록'),
            ),
          ],
        );
      },
    );
  }

  // Future<bool> _writeBtnHandler(int amount, String description) async {
  //   await context
  //       .read<BudgetRepo>()
  //       .writeExpense(amount, description)
  //       .then((ret) {
  //     if (ret == false) return false;
  //     return true;
  //   });
  //   return true;
  // }

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
        await context.read<BudgetRepo>().reloadBudgetInfo(_filteredDate!);
    if (result == false) {
      _showSnackBar("기록을 불러오지 못했습니다..");
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _initBudgetManageView();
  }

  Future<void> _initBudgetManageView() async {
    int clubId = context.read<ClubDetailRepo>().clubId!;
    bool result = await context.read<BudgetRepo>().initBudgetInfo(clubId);
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
  Widget build(BuildContext context) {
    if (isLoaded == false || _filteredDate == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double parentWidth = MediaQuery.of(context).size.width;
    int amount = context.watch<BudgetRepo>().budget ?? 0;
    List<BudgetRecordEntity> record = context.watch<BudgetRepo>().record;

    return Scaffold(
      appBar: AppBar(
        title: const Text("예산 관리"),
        actions: [
          IconButton(
            onPressed: () async => await _writeBtnListener(),
            icon: const Icon(Icons.create),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
      ),
    );
  }
}
