import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/forum_controller.dart';
import 'package:ez_trainz/models/forum_comment.dart';
import 'package:ez_trainz/models/forum_post.dart';

class ForumPostDetailScreen extends StatefulWidget {
  const ForumPostDetailScreen({super.key, required this.post});
  final ForumPost post;

  @override
  State<ForumPostDetailScreen> createState() => _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState extends State<ForumPostDetailScreen> {
  final _commentCtrl = TextEditingController();
  ForumPost? _post;
  bool _loadingPost = false;

  static const _bgColor = Color(0xFF4DA6E8);
  static const _accentColor = Color(0xFFFFE000);

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    final id = widget.post.id;
    if (id.isEmpty) return;
    ForumController.to.comments.clear();
    ForumController.to.loadComments(id);
    _loadingPost = true;
    setState(() {});
    final fresh = await ForumController.to.loadPost(id);
    if (fresh != null && mounted) {
      setState(() => _post = fresh);
    }
    _loadingPost = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    ForumController.to.comments.clear();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final id = _post?.id ?? widget.post.id;
    if (id.isEmpty) return;
    final text = _commentCtrl.text;
    final ok = await ForumController.to.addComment(id, text);
    if (ok) _commentCtrl.clear();
    if (!ok && ForumController.to.error.value.isNotEmpty && mounted) {
      Get.snackbar(
        'forum_error'.tr,
        ForumController.to.error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
      );
    }
  }

  Future<void> _confirmDeletePost() async {
    final id = _post?.id ?? widget.post.id;
    if (id.isEmpty) return;
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('forum_delete_post'.tr),
        content: Text('forum_delete_post_body'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('forum_cancel'.tr)),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text('forum_delete'.tr),
          ),
        ],
      ),
    );
    if (ok == true) {
      final deleted = await ForumController.to.deletePost(id);
      if (deleted && mounted) Get.back();
    }
  }

  String _fmt(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final p = _post ?? widget.post;
    final ctrl = ForumController.to;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text('forum_post'.tr,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          if (ctrl.isMyPost(p))
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _confirmDeletePost,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: _accentColor,
              onRefresh: _bootstrap,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  if (_loadingPost)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(color: _accentColor),
                      ),
                    ),
                  Text(
                    p.title.isNotEmpty ? p.title : 'forum_untitled'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${p.authorName} · ${_fmt(p.createdAt)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    p.content,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'forum_comments'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (ctrl.error.value.isNotEmpty && ctrl.comments.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          ctrl.error.value,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      );
                    }
                    if (ctrl.comments.isEmpty) {
                      return Text(
                        'forum_no_comments'.tr,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 14,
                        ),
                      );
                    }
                    return Column(
                      children: ctrl.comments
                          .map((c) => _CommentCard(
                                comment: c,
                                onDelete: ctrl.isMyComment(c)
                                    ? () => _deleteComment(c)
                                    : null,
                              ))
                          .toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              10 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    minLines: 1,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'forum_comment_hint'.tr,
                      hintStyle:
                          TextStyle(color: Colors.white.withValues(alpha: 0.45)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Obx(() {
                  final busy = ctrl.isPostingComment.value;
                  return IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.black87,
                    ),
                    onPressed: busy ? null : _sendComment,
                    icon: busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black87,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteComment(ForumComment c) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('forum_delete_comment'.tr),
        content: Text('forum_delete_comment_body'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('forum_cancel'.tr)),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text('forum_delete'.tr),
          ),
        ],
      ),
    );
    if (ok == true) await ForumController.to.deleteComment(c.id);
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment, this.onDelete});
  final ForumComment comment;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  comment.authorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: Icon(Icons.close_rounded,
                      size: 18, color: Colors.white.withValues(alpha: 0.5)),
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment.content,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
