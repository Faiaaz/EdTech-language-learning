import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/models/roster_api_models.dart';
import 'package:ez_trainz/services/roster_service.dart';

class RosterController extends GetxController {
  static RosterController get to => Get.find();

  final isLoading = false.obs;
  final error = ''.obs;

  final rosterSummaries = <RosterSummary>[].obs;
  final meetingSlots = <InstructorMeetingSlot>[].obs;
  final myMeetingSlots = <InstructorMeetingSlot>[].obs;

  String get _token => AuthController.to.accessToken;

  static List<Map<String, dynamic>> _asMapList(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Future<void> loadRosters() async {
    final token = _token;
    if (token.isEmpty) {
      error.value = 'Login required.';
      return;
    }
    isLoading.value = true;
    error.value = '';
    try {
      final data = await RosterService.listRosters(bearerToken: token);
      final rows = _asMapList(data);
      rosterSummaries.value =
          rows.map(RosterSummary.fromJson).where((r) => r.id.isNotEmpty).toList();
    } on RosterException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createRoster(Map<String, dynamic> payload) async {
    final token = _token;
    if (token.isEmpty) {
      error.value = 'Login required.';
      return;
    }
    isLoading.value = true;
    error.value = '';
    try {
      await RosterService.createRoster(bearerToken: token, payload: payload);
      await loadRosters();
    } on RosterException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRoster(String id) async {
    final token = _token;
    if (token.isEmpty) {
      error.value = 'Login required.';
      return;
    }
    isLoading.value = true;
    error.value = '';
    try {
      await RosterService.deleteRoster(bearerToken: token, id: id);
      await loadRosters();
    } on RosterException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadInstructorRoster() async {
    final token = _token;
    if (token.isEmpty) {
      error.value = 'Login required.';
      return;
    }
    isLoading.value = true;
    error.value = '';
    try {
      final data = await RosterService.listInstructorRoster(bearerToken: token);
      final rows = data is List
          ? data
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : _asMapList(data);
      meetingSlots.value = rows
          .map(InstructorMeetingSlot.fromJson)
          .where((s) => s.id.isNotEmpty)
          .toList();
    } on RosterException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMyInstructorSlots() async {
    final token = _token;
    if (token.isEmpty) {
      error.value = 'Login required.';
      return;
    }
    isLoading.value = true;
    error.value = '';
    try {
      final data = await RosterService.listMyInstructorSlots(bearerToken: token);
      final rows = data is List
          ? data
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : _asMapList(data);
      myMeetingSlots.value = rows
          .map(InstructorMeetingSlot.fromJson)
          .where((s) => s.id.isNotEmpty)
          .toList();
    } on RosterException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinSlot(String id) async {
    final token = _token;
    if (token.isEmpty) {
      error.value = 'Login required.';
      return;
    }
    isLoading.value = true;
    error.value = '';
    try {
      await RosterService.joinMeetingSlot(bearerToken: token, id: id);
      await loadInstructorRoster();
    } on RosterException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> leaveSlot(String id) async {
    final token = _token;
    if (token.isEmpty) {
      error.value = 'Login required.';
      return;
    }
    isLoading.value = true;
    error.value = '';
    try {
      await RosterService.leaveMeetingSlot(bearerToken: token, id: id);
      await loadInstructorRoster();
    } on RosterException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
