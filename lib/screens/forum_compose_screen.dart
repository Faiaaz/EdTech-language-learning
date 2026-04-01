import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/services/forum_service.dart';

/// Create a new forum thread (POST /forum/posts).
class ForumComposeScreen extends StatefulWidget {
  const ForumComposeScreen({super.key});

  @override
  State<ForumComposeScreen> createState() => _ForumComposeScreenState();
}

class _ForumComposeScreenState extends State<ForumComposeScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _submitting = false;

  static const _bg = Color(0xFF4DA6E8);
  static const _accent = Color(0xFFFFE000);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final token = AuthController.to.forumBearerToken;
    if (token.isEmpty) {
      Get.snackbar('forum_login_required_title'.tr, 'forum_login_required_body'.tr);
      return;
    }
    setState(() => _submitting = true);
    try {
      await ForumService.createPost(
        bearerToken: token,
        title: _titleCtrl.text.trim(),
        content: _bodyCtrl.text.trim(),
      );
      if (mounted) Get.back(result: true);
    } on ForumException catch (e) {
      Get.snackbar('forum_error'.tr, e.message);
    } catch (e) {
      Get.snackbar('forum_error'.tr, e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'forum_new_thread'.tr,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _accent,
                    ),
                  )
                : Text(
                    'forum_post'.tr,
                    style: const TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(color: Color(0xFF1A1A2E)),
                decoration: InputDecoration(
                  labelText: 'forum_title_label'.tr,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'forum_title_required'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyCtrl,
                minLines: 8,
                maxLines: 16,
                style: const TextStyle(color: Color(0xFF1A1A2E)),
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'forum_body_label'.tr,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'forum_body_required'.tr;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
