//dependencies
import 'dart:developer';

import 'package:band_front/cores/widgetutils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

//pages
import '../cores/api.dart';
import '../cores/dataclass.dart';
import '../cores/repositories.dart';
import '../cores/router.dart';
import 'drawers.dart';

class ClubListViewModel {
  List<ClubEntity>? clubs;
  int pn = 0;

  Future<void> getClubList() async {
    var data = await ClubApi.getMyClubList(pn);
    var list = data['list'];
    List<ClubEntity> receivedClubs = [];
    for (Map<String, dynamic> element in list) {
      receivedClubs.add(ClubEntity.fromMap(element));
    }
    clubs = receivedClubs;
    pn++;
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

  Future<void> initClubListView() async {
    await _viewModel.getClubList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initClubListView();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.clubs == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("나의 모임들"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.go(RouterPath.clubRegist),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
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
                onTap: () {
                  context.go(
                    RouterPath.clubDetailPage,
                    extra: {'clubId': club.clubId},
                  );
                },
                child: mainUnit(
                  child: Column(
                    children: [
                      image,
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(children: [
                          Row(children: [
                            const VerticalDivider(),
                            Text(club.clubName),
                            const Spacer(),
                            const Icon(Icons.people),
                            Text("10"),
                            const VerticalDivider(),
                          ]),
                          const Divider(thickness: 0.5),
                          Row(children: [
                            const VerticalDivider(),
                            const Icon(Icons.contact_support),
                            const VerticalDivider(),
                            Text(testClubs[index].contactInfo ?? "없음"),
                          ]),
                        ]),
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
