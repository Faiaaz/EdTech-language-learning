import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/forum_controller.dart';

class ForumCreatePostScreen extends StatefulWidget {
  const ForumCreatePostScreen({super.key});

  @override
  State<ForumCreatePostScreen> createState() => _ForumCreatePostScreenState();
}

class _ForumCreatePostScreenState extends State<ForumCreatePostScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      Get.snackbar(
        'forum_create'.tr,
        'forum_create_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
      );
      return;
    }
    setState(() => _submitting = true);
    final ok =
        await ForumController.to.createPost(title: title, content: body);
    setState(() => _submitting = false);
    if (ok && mounted) {
      Get.back(result: true);
    } else if (mounted && ForumController.to.error.value.isNotEmpty) {
      Get.snackbar(
        'forum_error'.tr,
        ForumController.to.error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF4DA6E8);
    const accent = Color(0xFFFFE000);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text('forum_create'.tr,
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'forum_title_field'.tr,
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: accent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyCtrl,
              minLines: 6,
              maxLines: 14,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: 'forum_body_field'.tr,
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: accent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('forum_publish'.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
