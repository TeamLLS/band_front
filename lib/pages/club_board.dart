import 'dart:developer';

import 'package:band_front/cores/data_class.dart';
import 'package:band_front/cores/repository.dart';
import 'package:band_front/cores/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../cores/widget_utils.dart';

class ClubBoardView extends StatefulWidget {
  const ClubBoardView({super.key});

  @override
  State<ClubBoardView> createState() => _ClubBoardViewState();
}

class _ClubBoardViewState extends State<ClubBoardView> {
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _initClubNotificationView();
  }

  Future<void> _initClubNotificationView() async {
    int clubId = context.read<ClubDetailRepo>().clubId!;
    bool ret = await context.read<BoardRepo>().initPostList(clubId);

    setState(() => isLoaded = ret);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoaded == false) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    List<BoardPostEntity> list = context.watch<BoardRepo>().postList;
    double parentWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("공지사항"),
        actions: [
          IconButton(
            onPressed: () => context.push(RouterPath.boardRegist),
            icon: const Icon(Icons.create),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            BoardPostEntity postEntity = list[index];
            Image postEntityImage = postEntity.image == null ||
                    postEntity.image ==
                        "https://d310q11a7rdsb8.cloudfront.net/null"
                ? Image.asset(
                    "assets/images/empty.png",
                    height: parentWidth * 0.6,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    postEntity.image!,
                    height: parentWidth * 0.6,
                    fit: BoxFit.cover,
                  );

            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              child: InkWell(
                child: desUnit(
                  child: LayoutBuilder(builder: (context, constraints) {
                    final double desWidth = constraints.maxWidth;

                    return Stack(
                      children: [
                        Center(child: postEntityImage),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          width: desWidth,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                top: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(postEntity.title),
                                  const Divider(thickness: 0.5),
                                  Row(
                                    children: [
                                      const Icon(Icons.account_circle),
                                      const VerticalDivider(),
                                      Text(postEntity.memberName),
                                      const VerticalDivider(),
                                      Text(postEntity.createdBy),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today),
                                      const VerticalDivider(),
                                      Text(
                                        formatToYMDHM(postEntity.createdAt),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                onTap: () {
                  context.push(
                    RouterPath.postDetail,
                    extra: {'postId': postEntity.id},
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
