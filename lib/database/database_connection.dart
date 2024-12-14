// lib/database/database_connection.dart
import 'package:mysql1/mysql1.dart';
import 'package:dotenv/dotenv.dart'; // Import dotenv

Future<MySqlConnection> connectToDatabase() async {
  var env = DotEnv()..load();

  var settings = ConnectionSettings(
    host: env['DB_HOST'] ?? 'localhost',
    port: int.parse(env['DB_PORT'] ?? '3306'),
    user: env['DB_USERNAME'] ?? 'root',
    password: env['DB_PASSWORD'] ?? 'password',
    db: env['DB_DATABASE'] ?? 'vania',
  );

  var conn = await MySqlConnection.connect(settings);
  print('Koneksi berhasil!');
  return conn;
}
