import 'read_bytes_from_path_stub.dart'
    if (dart.library.html) 'read_bytes_from_path_web.dart'
    if (dart.library.io) 'read_bytes_from_path_io.dart';

/// Reads bytes from a platform-specific path.
///
/// - On mobile/desktop: [path] is a filesystem path.
/// - On web: [path] can be a blob URL returned by a recorder implementation.
Future<List<int>> readBytesFromPath(String path) => readBytesFromPathImpl(path);

