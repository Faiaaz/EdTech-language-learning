import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/models/forum_comment.dart';
import 'package:ez_trainz/models/forum_post.dart';
import 'package:ez_trainz/services/forum_service.dart';

/// Single thread with comments.
class ForumPostDetailScreen extends StatefulWidget {
  const ForumPostDetailScreen({super.key, required this.initialPost});

  final ForumPost initialPost;

  @override
  State<ForumPostDetailScreen> createState() => _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState extends State<ForumPostDetailScreen> {
  late ForumPost _post;
  List<ForumComment> _comments = [];
  ForumComment? _replyTo;
  var _loading = true;
  var _loadingComments = false;
  var _sending = false;
  final _commentCtrl = TextEditingController();

  static const _bg = Color(0xFF4DA6E8);
  static const _accent = Color(0xFFFFE000);

  @override
  void initState() {
    super.initState();
    _post = widget.initialPost;
    _hydrate();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _hydrate() async {
    setState(() => _loading = true);
    try {
      final fresh = await ForumService.fetchPost(_post.id);
      _post = fresh.mergedWith(widget.initialPost);
    } catch (_) {
      // Keep list payload if single GET fails or is minimal.
    }
    await _loadComments();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadComments() async {
    setState(() => _loadingComments = true);
    try {
      _comments = await ForumService.fetchComments(_post.id);
    } on ForumException catch (e) {
      Get.snackbar('forum_error'.tr, e.message);
    } catch (e) {
      Get.snackbar('forum_error'.tr, e.toString());
    } finally {
      if (mounted) setState(() => _loadingComments = false);
    }
  }

  bool get _loggedIn =>
      AuthController.to.isLoggedIn && AuthController.to.forumBearerToken.isNotEmpty;

  bool _isAuthor(String authorId) {
    final c = AuthController.to.cognitoId;
    if (c == null || c.isEmpty) return false;
    return c == authorId;
  }

  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    final l = d.toLocal();
    return '${l.day}/${l.month}/${l.year} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  List<ForumComment> _flattenComments(List<ForumComment> list) {
    final out = <ForumComment>[];
    void visit(ForumComment c) {
      out.add(c);
      for (final r in c.replies) {
        visit(r);
      }
    }

    for (final c in list) {
      visit(c);
    }
    return out;
  }

  List<ForumComment> _commentTree(List<ForumComment> source) {
    final all = _flattenComments(source);
    final byId = <String, ForumComment>{for (final c in all) c.id: c};
    final children = <String, List<ForumComment>>{};
    final roots = <ForumComment>[];

    for (final c in all) {
      final parentId = c.parentCommentId;
      if (parentId == null || parentId.isEmpty || !byId.containsKey(parentId)) {
        roots.add(c);
      } else {
        children.putIfAbsent(parentId, () => []).add(c);
      }
    }

    ForumComment build(ForumComment c) {
      final kids = (children[c.id] ?? [])
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return ForumComment(
        id: c.id,
        postId: c.postId,
        authorId: c.authorId,
        parentCommentId: c.parentCommentId,
        authorName: c.authorName,
        content: c.content,
        createdAt: c.createdAt,
        updatedAt: c.updatedAt,
        replies: kids.map(build).toList(),
      );
    }

    roots.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return roots.map(build).toList();
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    if (!_loggedIn) {
      Get.snackbar('forum_login_required_title'.tr, 'forum_login_required_body'.tr);
      return;
    }
    setState(() => _sending = true);
    try {
      await ForumService.addComment(
        bearerToken: AuthController.to.forumBearerToken,
        postId: _post.id,
        content: text,
        authorId: AuthController.to.cognitoId,
        authorName: AuthController.to.userName,
        parentCommentId: _replyTo?.id,
      );
      _commentCtrl.clear();
      _replyTo = null;
      await _loadComments();
      if (mounted) FocusScope.of(context).unfocus();
    } on ForumException catch (e) {
      Get.snackbar('forum_error'.tr, e.message);
    } catch (e) {
      Get.snackbar('forum_error'.tr, e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _startReply(ForumComment c) {
    setState(() => _replyTo = c);
  }

  Future<void> _confirmDeletePost() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('forum_delete_post_title'.tr),
        content: Text('forum_delete_post_body'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('profile_cancel'.tr)),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('game_delete'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ForumService.deletePost(
        bearerToken: AuthController.to.forumBearerToken,
        id: _post.id,
      );
      Get.back(result: true);
    } on ForumException catch (e) {
      Get.snackbar('forum_error'.tr, e.message);
    }
  }

  Future<void> _editPost() async {
    final titleCtrl = TextEditingController(text: _post.title);
    final bodyCtrl = TextEditingController(text: _post.content);
    final saved = await Get.dialog<bool>(
      AlertDialog(
        title: Text('forum_edit_post'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: 'forum_title_label'.tr),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                maxLines: 5,
                decoration: InputDecoration(labelText: 'forum_body_label'.tr),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('profile_cancel'.tr)),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('forum_save'.tr),
          ),
        ],
      ),
    );
    if (saved != true) return;
    try {
      final updated = await ForumService.updatePost(
        bearerToken: AuthController.to.forumBearerToken,
        id: _post.id,
        title: titleCtrl.text.trim(),
        content: bodyCtrl.text.trim(),
      );
      setState(() => _post = updated.mergedWith(_post));
    } on ForumException catch (e) {
      Get.snackbar('forum_error'.tr, e.message);
    }
  }

  Future<void> _deleteComment(ForumComment c) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('forum_delete_comment_title'.tr),
        content: Text('forum_delete_comment_body'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('profile_cancel'.tr)),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('game_delete'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ForumService.deleteComment(
        bearerToken: AuthController.to.forumBearerToken,
        id: c.id,
      );
      await _loadComments();
    } on ForumException catch (e) {
      Get.snackbar('forum_error'.tr, e.message);
    }
  }

  Future<void> _editComment(ForumComment c) async {
    final ctrl = TextEditingController(text: c.content);
    final saved = await Get.dialog<bool>(
      AlertDialog(
        title: Text('forum_edit_comment'.tr),
        content: TextField(controller: ctrl, maxLines: 4),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('profile_cancel'.tr)),
          TextButton(onPressed: () => Get.back(result: true), child: Text('forum_save'.tr)),
        ],
      ),
    );
    if (saved != true) return;
    try {
      await ForumService.updateComment(
        bearerToken: AuthController.to.forumBearerToken,
        id: c.id,
        content: ctrl.text.trim(),
      );
      await _loadComments();
    } on ForumException catch (e) {
      Get.snackbar('forum_error'.tr, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEditPost = _loggedIn && _isAuthor(_post.authorId);
    final authorName = _post.author?.name ?? 'forum_anonymous'.tr;
    final tree = _commentTree(_comments);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'forum_thread'.tr,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          if (canEditPost)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (v) {
                if (v == 'edit') _editPost();
                if (v == 'delete') _confirmDeletePost();
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text('forum_edit_post'.tr)),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('game_delete'.tr, style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: _accent,
                    onRefresh: () async {
                      await _hydrate();
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _post.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _post.content,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.45,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Icon(Icons.person_outline_rounded,
                                      size: 18, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(
                                    authorName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatDate(_post.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'forum_comments'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_loadingComments)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: CircularProgressIndicator(color: _accent),
                            ),
                          )
                        else if (_comments.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'forum_no_comments'.tr,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          )
                        else
                          ...tree.map((c) => _buildCommentTile(c, depth: 0)),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    8,
                    12,
                    8 + MediaQuery.paddingOf(context).bottom,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_replyTo != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'forum_replying_to'
                                            .trParams({'name': _replyTo!.authorName}),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() => _replyTo = null),
                                      child: const Icon(Icons.close, size: 16),
                                    ),
                                  ],
                                ),
                              ),
                            TextField(
                              controller: _commentCtrl,
                              minLines: 1,
                              maxLines: 4,
                              enabled: _loggedIn,
                              decoration: InputDecoration(
                                hintText: _loggedIn
                                    ? (_replyTo == null
                                        ? 'forum_comment_hint'.tr
                                        : 'forum_reply_hint'.tr)
                                    : 'forum_login_to_comment'.tr,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: (!_loggedIn || _sending) ? null : _sendComment,
                        style: IconButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: const Color(0xFF1A1A2E),
                        ),
                        icon: _sending
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCommentTile(ForumComment c, {required int depth}) {
    final mine = _loggedIn && _isAuthor(c.authorId);
    final leftPad = 12.0 * depth.clamp(0, 4);
    return Padding(
      padding: EdgeInsets.only(left: leftPad, bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.authorName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.content,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              _formatDate(c.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _loggedIn ? () => _startReply(c) : null,
                              child: Text(
                                'forum_reply'.tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _bg,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (mine)
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      onSelected: (v) {
                        if (v == 'edit') _editComment(c);
                        if (v == 'delete') _deleteComment(c);
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('forum_edit_comment'.tr),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'game_delete'.tr,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (c.replies.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...c.replies.map((r) => _buildCommentTile(r, depth: depth + 1)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
