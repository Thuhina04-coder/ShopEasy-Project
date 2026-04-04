import 'dart:io' show Platform;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// SQLite on Windows / Linux / macOS uses the FFI implementation.
Future<void> initSqliteForDesktop() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
