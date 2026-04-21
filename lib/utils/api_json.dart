/// Small helpers for loosely-typed API Gateway JSON (string vs int ids, etc.).
class ApiJson {
  ApiJson._();

  static String? str(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }

  static String strOr(dynamic v, [String fallback = '']) =>
      str(v) ?? fallback;

  static int? intVal(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString());
  }

  static double? doubleVal(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static List<Map<String, dynamic>> mapList(dynamic v) {
    if (v is! List) return const [];
    return v
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Map<String, dynamic>? map(dynamic v) {
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }
}
