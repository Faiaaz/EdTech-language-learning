import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/forum_controller.dart';
import 'package:ez_trainz/models/forum_post.dart';
import 'package:ez_trainz/screens/forum_create_post_screen.dart';
import 'package:ez_trainz/screens/forum_post_detail_screen.dart';

/// Community tab — forum posts and threads.
class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  static const _bgColor = Color(0xFF4DA6E8);
  static const _accentColor = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    final ctrl = ForumController.to;

    return Scaffold(
      backgroundColor: _bgColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Get.to<bool>(() => const ForumCreatePostScreen());
          if (ok == true) await ctrl.loadFeed();
        },
        backgroundColor: _accentColor,
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.edit_rounded),
        label: Text('forum_new_post'.tr),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  const Icon(Icons.forum_rounded,
                      color: _accentColor, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'forum_title'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Obx(() {
                return Row(
                  children: [
                    _ModeChip(
                      label: 'forum_all_posts'.tr,
                      selected: ctrl.listMode.value == ForumListMode.all,
                      onTap: () => ctrl.setMode(ForumListMode.all),
                    ),
                    const SizedBox(width: 10),
                    _ModeChip(
                      label: 'forum_threads'.tr,
                      selected: ctrl.listMode.value == ForumListMode.threads,
                      onTap: () => ctrl.setMode(ForumListMode.threads),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value && ctrl.posts.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: _accentColor),
                  );
                }
                if (ctrl.error.value.isNotEmpty && ctrl.posts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 48),
                          const SizedBox(height: 12),
                          Text(
                            ctrl.error.value,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: ctrl.loadFeed,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _accentColor),
                            child: Text('retry'.tr,
                                style: const TextStyle(color: Colors.black87)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (ctrl.posts.isEmpty) {
                  return Center(
                    child: Text(
                      'forum_empty'.tr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  color: _accentColor,
                  onRefresh: ctrl.loadFeed,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 88),
                    itemCount: ctrl.posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final p = ctrl.posts[i];
                      return _PostTile(
                        post: p,
                        onTap: () {
                          if (p.id.isEmpty) return;
                          Get.to(() => ForumPostDetailScreen(post: p));
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _accentColor = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? _accentColor.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: selected ? Border.all(color: _accentColor, width: 1.5) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _accentColor : Colors.white,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post, required this.onTap});
  final ForumPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = post.content.length > 120
        ? '${post.content.substring(0, 120)}…'
        : post.content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title.isNotEmpty ? post.title : 'forum_untitled'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                preview,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    post.authorName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (post.commentCount != null) ...[
                    const SizedBox(width: 10),
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 14, color: Colors.white.withValues(alpha: 0.45)),
                    const SizedBox(width: 4),
                    Text(
                      '${post.commentCount}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
