import 'package:ez_trainz/utils/api_json.dart';

class RosterSummary {
  RosterSummary({required this.id, required this.name, this.raw});

  final String id;
  final String name;
  final Map<String, dynamic>? raw;

  factory RosterSummary.fromJson(Map<String, dynamic> json) {
    return RosterSummary(
      id: ApiJson.str(json['id']) ?? ApiJson.str(json['rosterId']) ?? '',
      name: ApiJson.str(json['name']) ??
          ApiJson.str(json['title']) ??
          'Roster',
      raw: json,
    );
  }
}

class InstructorMeetingSlot {
  InstructorMeetingSlot({
    required this.id,
    this.postId,
    required this.date,
    required this.timeSlot,
    this.raw,
  });

  final String id;
  final String? postId;
  final String date;
  final String timeSlot;
  final Map<String, dynamic>? raw;

  factory InstructorMeetingSlot.fromJson(Map<String, dynamic> json) {
    return InstructorMeetingSlot(
      id: ApiJson.str(json['id']) ?? '',
      postId: ApiJson.str(json['postId']),
      date: ApiJson.str(json['date']) ?? '',
      timeSlot: ApiJson.str(json['timeSlot']) ?? ApiJson.str(json['slot']) ?? '',
      raw: json,
    );
  }
}
