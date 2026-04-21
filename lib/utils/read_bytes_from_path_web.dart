import 'package:http/http.dart' as http;

Future<List<int>> readBytesFromPathImpl(String path) async {
  final res = await http.get(Uri.parse(path));
  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception('Failed to read blob bytes (${res.statusCode}).');
  }
  return res.bodyBytes;
}

