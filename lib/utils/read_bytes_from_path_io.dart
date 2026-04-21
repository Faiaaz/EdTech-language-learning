import 'dart:io';

Future<List<int>> readBytesFromPathImpl(String path) async {
  return File(path).readAsBytes();
}

