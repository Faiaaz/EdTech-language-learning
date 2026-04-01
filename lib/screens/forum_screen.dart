import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/controllers/forum_controller.dart';
import 'package:ez_trainz/models/forum_post.dart';
import 'package:ez_trainz/screens/forum_compose_screen.dart';
import 'package:ez_trainz/screens/forum_post_detail_screen.dart';

/// Community tab — forum threads from API.
class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  static const _bg = Color(0xFF4DA6E8);
  static const _accent = Color(0xFFFFE000);

  static String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    final l = d.toLocal();
    return '${l.day}/${l.month}/${l.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ForumController>();

    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (!AuthController.to.isLoggedIn ||
              AuthController.to.accessToken.isEmpty) {
            Get.snackbar(
              'forum_login_required_title'.tr,
              'forum_login_required_body'.tr,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.white,
              colorText: const Color(0xFF1A1A2E),
            );
            return;
          }
          Get.to(() => const ForumComposeScreen())?.then((created) {
            if (created == true) ctrl.loadThreads();
          });
        },
        backgroundColor: _accent,
        foregroundColor: const Color(0xFF1A1A2E),
        icon: const Icon(Icons.edit_rounded),
        label: Text(
          'forum_new_thread'.tr,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.forum_rounded, color: _accent, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'nav_community'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: ctrl.loadThreads,
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'forum_subtitle'.tr,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value && ctrl.threads.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: _accent),
                  );
                }
                if (ctrl.errorMessage.value.isNotEmpty &&
                    ctrl.threads.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ctrl.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: ctrl.loadThreads,
                            child: Text(
                              'retry'.tr,
                              style: const TextStyle(color: _accent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (ctrl.threads.isEmpty) {
                  return Center(
                    child: Text(
                      'forum_no_threads'.tr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  color: _accent,
                  onRefresh: ctrl.loadThreads,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: ctrl.threads.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final post = ctrl.threads[i];
                      return _ThreadTile(
                        post: post,
                        dateLabel: _formatDate(post.createdAt),
                        onTap: () {
                          Get.to(
                            () => ForumPostDetailScreen(initialPost: post),
                          )?.then((_) => ctrl.loadThreads());
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

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({
    required this.post,
    required this.dateLabel,
    required this.onTap,
  });

  final ForumPost post;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final authorName = post.author?.name ?? 'forum_anonymous'.tr;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline_rounded,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      authorName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (dateLabel.isNotEmpty)
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${post.commentCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
