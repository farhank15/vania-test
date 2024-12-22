import 'package:backend/utils/hash.dart';
import '../models/user.dart';
import '../../config/database.dart';

class UserService {
  final Database _db;
  static final UserService _instance = UserService._internal(Database());

  UserService._internal(this._db);

  factory UserService() {
    return _instance;
  }

  Future<void> checkConnection() async {
    if (!_db.isConnected) {
      await _db.connect();
    }
  }

  Future<List<User>> getAllUsers() async {
    await checkConnection();
    try {
      final results =
          await _db.query('SELECT * FROM users WHERE deleted_at IS NULL');
      return results.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data pengguna: ${e.toString()}');
    }
  }

  Future<void> logLoginAttempt(int? userId, String ipAddress,
      {required bool isSuccess}) async {
    print('Login attempt: UserID=$userId, IP=$ipAddress, Success=$isSuccess');
  }

  Future<User?> getUserById(int id) async {
    await checkConnection();
    try {
      final results = await _db.query(
        'SELECT * FROM users WHERE id = @id AND deleted_at IS NULL',
        {'id': id},
      );
      return results.isNotEmpty ? User.fromJson(results.first) : null;
    } catch (e) {
      throw Exception('Gagal mengambil data pengguna: ${e.toString()}');
    }
  }

  Future<User?> getUserByEmail(String email) async {
    await checkConnection();
    try {
      final results = await _db.query(
        'SELECT * FROM users WHERE email = @email AND deleted_at IS NULL',
        {'email': email},
      );
      return results.isNotEmpty ? User.fromJson(results.first) : null;
    } catch (e) {
      throw Exception('Gagal mengambil data pengguna: ${e.toString()}');
    }
  }

  Future<User?> getUserByUsername(String username) async {
    await checkConnection();
    try {
      final results = await _db.query(
        'SELECT * FROM users WHERE username = @username AND deleted_at IS NULL',
        {'username': username},
      );
      return results.isNotEmpty ? User.fromJson(results.first) : null;
    } catch (e) {
      throw Exception('Gagal mengambil data pengguna: ${e.toString()}');
    }
  }

  Future<User?> createUser(User user) async {
    await checkConnection();
    try {
      // Validasi untuk username
      if (user.username == null || user.username!.isEmpty) {
        throw Exception('Username wajib diisi');
      }

      // Validasi untuk email
      if (user.email == null || user.email!.isEmpty) {
        throw Exception('Email wajib diisi');
      }

      // Validasi untuk password
      if (user.password == null || user.password!.isEmpty) {
        throw Exception('Password wajib diisi');
      }

      // Check if email already exists
      final existingEmail = await getUserByEmail(user.email!);
      if (existingEmail != null) {
        throw Exception('Email sudah terdaftar');
      }

      // Check if username already exists
      final existingUsername = await getUserByUsername(user.username!);
      if (existingUsername != null) {
        throw Exception('Username sudah digunakan');
      }

      // Hash password HANYA SEKALI di sini
      final hashedPassword = PasswordUtil.hashPassword(user.password!);

      final result = await _db.query(
        '''
      INSERT INTO users (name, username, email, password) 
      VALUES (@name, @username, @email, @password) 
      RETURNING *
      ''',
        {
          'name': user.name,
          'username': user.username,
          'email': user.email,
          'password': hashedPassword,
        },
      );

      return result.isNotEmpty ? User.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal membuat data pengguna: ${e.toString()}');
    }
  }

  Future<User?> updateUser(int id, User user) async {
    await checkConnection();
    try {
      final updates = <String, dynamic>{};
      final setClauses = <String>[];

      if (user.name != null) {
        updates['name'] = user.name;
        setClauses.add('name = @name');
      }
      if (user.username != null) {
        final existingUsername = await getUserByUsername(user.username!);
        if (existingUsername != null && existingUsername.id != id) {
          throw Exception('Username sudah digunakan');
        }
        updates['username'] = user.username;
        setClauses.add('username = @username');
      }
      if (user.email != null) {
        final existingEmail = await getUserByEmail(user.email!);
        if (existingEmail != null && existingEmail.id != id) {
          throw Exception('Email sudah terdaftar');
        }
        updates['email'] = user.email;
        setClauses.add('email = @email');
      }
      if (user.password != null) {
        updates['password'] = PasswordUtil.hashPassword(user.password!);
        setClauses.add('password = @password');
      }

      if (setClauses.isEmpty) {
        throw Exception('Tidak ada data yang diupdate');
      }

      setClauses.add('updated_at = now()');
      updates['id'] = id;

      final result = await _db.query(
        '''
        UPDATE users 
        SET ${setClauses.join(', ')}
        WHERE id = @id AND deleted_at IS NULL
        RETURNING *
        ''',
        updates,
      );
      return result.isNotEmpty ? User.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal memperbarui data pengguna: ${e.toString()}');
    }
  }

  Future<User?> deleteUser(int id) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
        UPDATE users 
        SET deleted_at = now() 
        WHERE id = @id AND deleted_at IS NULL
        RETURNING *
        ''',
        {'id': id},
      );
      return result.isNotEmpty ? User.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal menghapus data pengguna: ${e.toString()}');
    }
  }
}
