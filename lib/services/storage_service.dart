import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StorageService {
  static final StorageService instance = StorageService._init();
  static Database? _database;

  StorageService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'minerasys.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE apontador_registros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        placa TEXT NOT NULL,
        metros_cubicos REAL NOT NULL,
        valor_calculado REAL NOT NULL,
        latitude REAL,
        longitude REAL,
        foto TEXT,
        sincronizado INTEGER DEFAULT 0,
        data_registro TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE operador_registros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        placa TEXT NOT NULL,
        metros_cubicos REAL NOT NULL,
        valor_calculado REAL NOT NULL,
        latitude REAL,
        longitude REAL,
        foto TEXT,
        sincronizado INTEGER DEFAULT 0,
        data_registro TEXT NOT NULL
      )
    ''');
  }

  Future<int> salvarApontador({
    required String placa,
    required double metrosCubicos,
    required double valorCalculado,
    double? latitude,
    double? longitude,
    String? foto,
  }) async {
    final db = await database;
    return await db.insert('apontador_registros', {
      'placa': placa,
      'metros_cubicos': metrosCubicos,
      'valor_calculado': valorCalculado,
      'latitude': latitude,
      'longitude': longitude,
      'foto': foto,
      'sincronizado': 0,
      'data_registro': DateTime.now().toIso8601String(),
    });
  }

  Future<int> salvarOperador({
    required String placa,
    required double metrosCubicos,
    required double valorCalculado,
    double? latitude,
    double? longitude,
    String? foto,
  }) async {
    final db = await database;
    return await db.insert('operador_registros', {
      'placa': placa,
      'metros_cubicos': metrosCubicos,
      'valor_calculado': valorCalculado,
      'latitude': latitude,
      'longitude': longitude,
      'foto': foto,
      'sincronizado': 0,
      'data_registro': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getRegistrosNaoSincronizadosApontador() async {
    final db = await database;
    return await db.query(
      'apontador_registros',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
  }

  Future<List<Map<String, dynamic>>> getRegistrosNaoSincronizadosOperador() async {
    final db = await database;
    return await db.query(
      'operador_registros',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
  }

  Future<void> marcarComoSincronizadoApontador(int id) async {
    final db = await database;
    await db.update(
      'apontador_registros',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> marcarComoSincronizadoOperador(int id) async {
    final db = await database;
    await db.update(
      'operador_registros',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}