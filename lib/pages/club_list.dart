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

class ClubListView extends StatefulWidget {
  const ClubListView({super.key});

  @override
  State<ClubListView> createState() => _ClubListViewState();
}

class _ClubListViewState extends State<ClubListView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //사설 버튼을 통한 endDrawer를 위해 필요

  void _showSnackBar(String text) {
    showSnackBar(context, text);
  }

  void _navigateToClubDetail(ClubEntity club) {
    context.push(
      RouterPath.clubDetailPage,
      extra: {
        'clubId': club.clubId,
        'role': club.role,
      },
    );
  }

  void _navigateToClubRegist() {
    context.push(RouterPath.clubRegist);
  }

  void _openDrawer() => _scaffoldKey.currentState?.openEndDrawer();

  Future<void> _initClubList() async {
    bool result = await context.read<ClubListRepo>().initClubList();
    if (result == false) {
      _showSnackBar("목록을 불러오지 못했습니다..");
    }
    return;
  }

  @override
  void initState() {
    super.initState();
    _initClubList();
  }

  @override
  Widget build(BuildContext context) {
    List<ClubEntity> clubs = context.watch<ClubListRepo>().clubs;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("나의 모임들"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _navigateToClubRegist(),
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
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              ClubEntity club = clubs[index];
              Image image = clubs[index].image != null
                  ? Image.network(
                      clubs[index].image!,
                      fit: BoxFit.cover,
                      height: parentWidth * 0.5,
                    )
                  : Image.asset(
                      'assets/images/test1.png',
                      fit: BoxFit.cover,
                      height: parentWidth * 0.5,
                    );

              return InkWell(
                onTap: () => _navigateToClubDetail(club),
                child: mainUnit(
                  child: Column(
                    children: [
                      image,
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            const Divider(thickness: 0.5),
                            Row(children: [
                              const VerticalDivider(),
                              Text(club.clubName),
                              const Spacer(),
                              Text(club.clubStatus),
                              const VerticalDivider(),
                            ]),
                            const SizedBox(height: 4),
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
