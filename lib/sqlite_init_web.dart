import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Chrome / web: SQLite via WASM + IndexedDB (experimental).
Future<void> initSqliteForDesktop() async {
  databaseFactory = databaseFactoryFfiWeb;
}
