import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:postgres/postgres.dart';

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
  @override
  String toString() => "DatabaseException: $message";
}

class Database {
  late final Connection _connection;
  static final Database _instance = Database._internal();
  bool _isConnected = false;

  Database._internal();

  factory Database() {
    return _instance;
  }

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      dotenv.load();

      final endpoint = Endpoint(
        host: dotenv.env['DB_HOST'] ?? 'localhost',
        database: dotenv.env['DB_NAME'] ?? 'vania_test',
        username: dotenv.env['DB_USER'] ?? 'postgres',
        password: dotenv.env['DB_PASS'] ?? 'postgres',
        port: int.parse(dotenv.env['DB_PORT'] ?? '5432'),
      );

      _connection = await Connection.open(endpoint);
      _isConnected = true;
      print('Database connected successfully!');
    } catch (e) {
      _isConnected = false;
      print('Database connection error: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    if (_isConnected) {
      await _connection.close();
      _isConnected = false;
      print('Database connection closed.');
    }
  }

  Future<List<Map<String, dynamic>>> query(String sql,
      [Map<String, dynamic>? parameters]) async {
    if (!_isConnected) {
      throw DatabaseException('Database not connected');
    }

    try {
      final result = await _connection.execute(
        Sql.named(sql),
        parameters: parameters,
      );
      return result.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print('Query error: $e');
      rethrow;
    }
  }
}
