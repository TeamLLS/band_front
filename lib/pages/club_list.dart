//dependencies
import 'dart:developer';

import 'package:band_front/cores/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

//pages
import '../cores/api.dart';
import '../cores/data_class.dart';
import '../cores/repository.dart';
import '../cores/router.dart';
import 'drawers.dart';

class ClubListViewModel {
  List<ClubEntity>? clubs;
  int pn = 0;

  Future<void> getClubList() async {
    var data = await ClubApi.getMyClubList(pn);
    var list = data['list'];
    log("$data");
    List<ClubEntity> receivedClubs = [];
    for (Map<String, dynamic> element in list) {
      ClubEntity temp = ClubEntity.fromMap(element);
      if (temp.clubStatus != "운영종료") {
        receivedClubs.add(temp);
      }
    }
    clubs = receivedClubs;
    //pn++;
    return;
  }
}

class ClubListView extends StatefulWidget {
  const ClubListView({super.key});

  @override
  State<ClubListView> createState() => _ClubListViewState();
}

class _ClubListViewState extends State<ClubListView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //사설 버튼을 통한 endDrawer를 위해 필요
  final ClubListViewModel _viewModel = ClubListViewModel();

  void _clubDetailBtnListener(ClubEntity club) async {
    dynamic result = await context.push(
      RouterPath.clubDetailPage,
      extra: {
        'clubId': club.clubId,
        'role': club.role,
      },
    );
    await _returnHandler(result);
    return;
  }

  Future<void> _clubRegistBtnListener() async {
    dynamic result = await context.push(RouterPath.clubRegist); //or await?
    if (result == false || result == null) {
      return;
    }
    await _loadData();
    return;
  }

  Future<void> _returnHandler(dynamic result) async {
    if (result == false || result == null) {
      return;
    }
    await _loadData();
    return;
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Scaffold _returnLoading() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Future<void> _loadData() async {
    await _viewModel.getClubList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.clubs == null) {
      return _returnLoading();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("나의 모임들"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _clubRegistBtnListener(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _openDrawer(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double parentWidth = constraints.maxWidth;

          return ListView.builder(
            itemCount: _viewModel.clubs!.length,
            itemBuilder: (context, index) {
              ClubEntity club = _viewModel.clubs![index];
              Image image = _viewModel.clubs![index].image != null
                  ? Image.network(
                      _viewModel.clubs![index].image!,
                      fit: BoxFit.cover,
                      height: parentWidth * 0.5,
                    )
                  : Image.asset(
                      'assets/images/test1.png',
                      fit: BoxFit.cover,
                      height: parentWidth * 0.5,
                    );

              return InkWell(
                onTap: () => _clubDetailBtnListener(club),
                child: mainUnit(
                  child: Column(
                    children: [
                      image,
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(children: [
                              const VerticalDivider(),
                              Text(club.clubName),
                              const Spacer(),
                              const Icon(Icons.people),
                              Text(club.clubStatus ?? "10"),
                              const VerticalDivider(),
                            ]),
                            const Divider(thickness: 0.5),
                            Row(children: [
                              const VerticalDivider(),
                              const Icon(Icons.contact_support),
                              const VerticalDivider(),
                              Text(testClubs[index].contactInfo ?? "없음"),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      endDrawer: const DrawerView(),
    );
  }
}
