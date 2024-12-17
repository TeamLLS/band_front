import 'dart:developer';

import 'package:band_front/cores/data_class.dart';
import 'package:band_front/cores/repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../cores/widget_utils.dart';

class PostDetailView extends StatefulWidget {
  PostDetailView({super.key, required this.postId});
  int postId;

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  bool isLoaded = false;
  final TextEditingController _commentCon = TextEditingController();

  void _showReplyInputDialog(String writer, int commentId) {
    TextEditingController replyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("$writer에게 답글"),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: replyController,
                        decoration: const InputDecoration(
                          labelText: "답글 입력",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        String reply = replyController.text;
                        if (reply == "") return;
                        log("replyed to $commentId");
                        await replyBtnListener(reply, commentId);
                      },
                      label: const Icon(Icons.send),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> replyBtnListener(String content, int commentId) async {
    await context
        .read<BoardPostDetailRepo>()
        .writeComment(commentId, content)
        .then((ret) {
      if (ret == false) {
        _showSnackBar("등록 실패..");
        return;
      }
      _showSnackBar("댓글이 등록되었습니다.");
      context.pop();
    });
  }

  Future<void> commentBtnListener(String content) async {
    await context
        .read<BoardPostDetailRepo>()
        .writeComment(null, content)
        .then((ret) {
      if (ret == false) {
        _showSnackBar("등록 실패..");
        return;
      }
      _showSnackBar("댓글이 등록되었습니다.");
      return;
    });
  }

  Future<void> deleteBtnListener() async {
    bool ret = await context.read<BoardPostDetailRepo>().deletePost();
    if (ret == false) {
      _showSnackBar("something went wrong...");
      return;
    }
    await deleteBtnHandler();
  }

  Future<void> deleteBtnHandler() async {
    await context.read<BoardRepo>().reloadPostList().then((ret) {
      if (ret == false) {
        _showSnackBar("something went wrong...");
        return;
      }
      _showSnackBar("게시글이 삭제되었습니다.");
      context.pop();
    });
  }

  @override
  void initState() {
    super.initState();
    _initPostDetailView();
  }

  Future<void> _initPostDetailView() async {
    int clubId = context.read<ClubDetailRepo>().clubId!;
    int postId = widget.postId;
    bool ret = await context
        .read<BoardPostDetailRepo>()
        .initPostDetail(clubId, postId);
    setState(() => isLoaded = ret);
  }

  void _showSnackBar(String text) => showSnackBar(context, text);

  @override
  Widget build(BuildContext context) {
    if (isLoaded == false) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double parentWidth = MediaQuery.of(context).size.width;
    BoardPost postDetail = context.watch<BoardPostDetailRepo>().postDetail!;
    Image image = postDetail.image == null ||
            postDetail.image == "https://d310q11a7rdsb8.cloudfront.net/null"
        ? Image.asset(
            'assets/images/empty.png',
            fit: BoxFit.cover,
            height: parentWidth * 0.7,
            width: parentWidth,
          )
        : Image.network(
            postDetail.image!,
            fit: BoxFit.cover,
            height: parentWidth * 0.7,
            width: parentWidth,
          );
    String writer = postDetail.createdBy;
    String me = context.watch<MyRepo>().username!;
    List<BoardComment> comments = context.watch<BoardPostDetailRepo>().comments;

    return Scaffold(
      appBar: AppBar(
        title: const Text("게시글"),
        actions: [
          writer != me
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () async => await deleteBtnListener(),
                  icon: const Icon(Icons.delete),
                ),
          writer != me
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          image,
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
            child: Column(children: [
              desUnit(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    Text(postDetail.title),
                    const Divider(thickness: 0.5),
                    Row(
                      children: [
                        const Icon(Icons.account_circle),
                        const VerticalDivider(),
                        Text(postDetail.memberName),
                        const VerticalDivider(),
                        Text(postDetail.createdBy),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const VerticalDivider(),
                        Text(
                          formatToYMDHM(postDetail.createdAt),
                        ),
                      ],
                    ),
                    const Divider(thickness: 0.5),
                    desTextUnit(
                      maxLine: 5,
                      description: postDetail.content,
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              const Text("댓글"),
              const Divider(color: Colors.black, thickness: 1),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  BoardComment comment = comments[index];

                  return Column(
                    children: [
                      // 기본 댓글
                      InkWell(
                        onTap: () {
                          _showReplyInputDialog(comment.memberName, comment.id);
                        },
                        onLongPress: () {},
                        child: desUnit(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment.memberName),
                                const Divider(),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 4, 0, 4),
                                  child: Text(comment.content),
                                ),
                                Text(
                                  formatToMDHM(comment.createdAt),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // 답글 리스트
                      if (comment.comments.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0), // 들여쓰기
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: comment.comments.length,
                            itemBuilder: (context, replyIndex) {
                              final reply = comment.comments[replyIndex];

                              return InkWell(
                                child: desUnit(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(reply.memberName),
                                        const Divider(),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 4, 0, 4),
                                          child: Text(reply.content),
                                        ),
                                        Text(
                                          formatToMDHM(reply.createdAt),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
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
                    ],
                  );
                },
              ),
            ]),
          ),
          const SizedBox(height: 128),
        ]),
      ),
      bottomSheet: BottomSheet(
        onClosing: () {},
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCon,
                    decoration: const InputDecoration(
                      labelText: "답글 입력",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    String comment = _commentCon.text;
                    if (comment == "") return;
                    await commentBtnListener(comment);
                  },
                  label: const Icon(Icons.send),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
