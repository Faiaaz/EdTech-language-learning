import 'package:get/get.dart';

import 'package:ez_trainz/models/forum_post.dart';
import 'package:ez_trainz/services/forum_service.dart';

class ForumController extends GetxController {
  static ForumController get to => Get.find();

  final threads = <ForumPost>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> loadThreads() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      threads.value = await ForumService.fetchThreads();
    } on ForumException catch (e) {
      errorMessage.value = e.message;
      threads.clear();
    } catch (e) {
      errorMessage.value = e.toString();
      threads.clear();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadThreads();
  }
}
