import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/models/forum_comment.dart';
import 'package:ez_trainz/models/forum_post.dart';
import 'package:ez_trainz/services/forum_service.dart';

enum ForumListMode { all, threads }

class ForumController extends GetxController {
  static ForumController get to => Get.find();

  final posts = <ForumPost>[].obs;
  final comments = <ForumComment>[].obs;
  final listMode = ForumListMode.all.obs;
  final isLoading = false.obs;
  final isPostingComment = false.obs;
  final error = ''.obs;

  String? get _token =>
      AuthController.to.accessToken.isEmpty
          ? null
          : AuthController.to.accessToken;

  @override
  void onInit() {
    super.onInit();
    loadFeed();
  }

  Future<void> loadFeed() async {
    isLoading.value = true;
    error.value = '';
    try {
      if (listMode.value == ForumListMode.threads) {
        posts.value = await ForumService.getThreads(accessToken: _token);
      } else {
        posts.value = await ForumService.getAllPosts(accessToken: _token);
      }
    } on ForumException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setMode(ForumListMode mode) {
    if (listMode.value == mode) return;
    listMode.value = mode;
    loadFeed();
  }

  Future<ForumPost?> loadPost(String id) async {
    error.value = '';
    try {
      return await ForumService.getPost(id, accessToken: _token);
    } on ForumException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    }
    return null;
  }

  Future<void> loadComments(String postId) async {
    error.value = '';
    try {
      comments.value =
          await ForumService.getComments(postId, accessToken: _token);
    } on ForumException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<bool> createPost({required String title, required String content}) async {
    error.value = '';
    try {
      final auth = AuthController.to;
      final p = await ForumService.createPost(
        title: title.trim(),
        content: content.trim(),
        authorName: auth.userName.isNotEmpty ? auth.userName : 'User',
        authorId: auth.cognitoId,
        accessToken: _token,
      );
      posts.insert(0, p);
      return true;
    } on ForumException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    }
    return false;
  }

  Future<bool> addComment(String postId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    isPostingComment.value = true;
    error.value = '';
    try {
      final auth = AuthController.to;
      final c = await ForumService.addComment(
        postId: postId,
        content: trimmed,
        authorName: auth.userName.isNotEmpty ? auth.userName : 'User',
        authorId: auth.cognitoId,
        accessToken: _token,
      );
      comments.add(c);
      return true;
    } on ForumException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isPostingComment.value = false;
    }
    return false;
  }

  Future<bool> deletePost(String id) async {
    try {
      await ForumService.deletePost(id, accessToken: _token);
      posts.removeWhere((p) => p.id == id);
      return true;
    } on ForumException catch (e) {
      error.value = e.message;
    }
    return false;
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      await ForumService.deleteComment(commentId, accessToken: _token);
      comments.removeWhere((c) => c.id == commentId);
      return true;
    } on ForumException catch (e) {
      error.value = e.message;
    }
    return false;
  }

  bool isMyPost(ForumPost p) {
    final id = AuthController.to.cognitoId;
    if (id == null || id.isEmpty) return false;
    return p.authorId == id;
  }

  bool isMyComment(ForumComment c) {
    final id = AuthController.to.cognitoId;
    if (id == null || id.isEmpty) return false;
    return c.authorId == id;
  }
}
