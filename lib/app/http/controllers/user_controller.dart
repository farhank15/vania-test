import 'package:backend/utils/hash.dart';
import 'package:backend/utils/validator.dart';
import 'package:vania/vania.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';
import '../../../utils/response.dart';
import '../../../utils/jwt.dart';
import '../validators/user_validator.dart';

class RateLimiter {
  final Map<String, int> _attempts = {};
  final int maxAttempts;
  final Duration duration;

  RateLimiter(
      {this.maxAttempts = 5, this.duration = const Duration(minutes: 5)});

  bool isLimitReached(String ipAddress) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_attempts.containsKey(ipAddress)) {
      final lastAttempt = _attempts[ipAddress]!;
      if (now - lastAttempt < duration.inMilliseconds) {
        return true;
      }
    }
    _attempts[ipAddress] = now;
    return false;
  }

  void logFailedAttempt(String ipAddress) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _attempts[ipAddress] = now;
  }
}

class UserController extends Controller {
  final UserService _service = UserService();

  // Middleware to enforce rate limiting
  final RateLimiter _rateLimiter = RateLimiter();

  // Helper to get IP address
  String _getIpAddress(Request request) {
    return request.headers['X-Forwarded-For']?.split(',').first ?? 'unknown';
  }

  Future<User?> _getUserByIdentifier(String identifier) async {
    if (Validator.isValidEmail(identifier)) {
      return await _service.getUserByEmail(identifier);
    } else {
      return await _service.getUserByUsername(identifier);
    }
  }

  // GET /users - Get all users
  Future<Response> index() async {
    try {
      final users = await _service.getAllUsers();
      return ResponseUtil.createSuccessResponse(
          'Data berhasil diambil', users.map((u) => u.toJson()).toList());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal mengambil data', e);
    }
  }

  // GET /users/:id - Get user by ID
  Future<Response> show(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak valid', 'ID is required', 400);
      }

      final userId = int.tryParse(id.toString());
      if (userId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final user = await _service.getUserById(userId);
      if (user == null) {
        return ResponseUtil.createErrorResponse(
            'Data tidak ditemukan', 'User not found', 404);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil ditemukan', user.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal mengambil data', e);
    }
  }

  // POST /users - Create new user
  Future<Response> store(Request request) async {
    try {
      final data = request.body;

      // Validasi input
      final validationErrors = UserValidator.validateUserCreate(data);
      if (validationErrors.isNotEmpty) {
        return ResponseUtil.createErrorResponse(
            'Validasi gagal', validationErrors, 400);
      }

      final user = User(
        name: data['name'],
        username: data['username'],
        email: data['email'],
        password: data['password'],
      );

      final newUser = await _service.createUser(user);
      if (newUser == null) {
        return ResponseUtil.createErrorResponse('Gagal membuat data pengguna',
            'Terjadi kesalahan saat menyimpan data', 500);
      }

      // Hapus password dari response
      final responseData = newUser.toJson();
      responseData.remove('password');

      return ResponseUtil.createSuccessResponse(
          'Data pengguna berhasil dibuat', responseData, 201);
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal membuat data pengguna', e);
    }
  }

  // POST /users/login - User login
  Future<Response> login(Request request) async {
    try {
      final ipAddress = _getIpAddress(request);

      // Rate limiting
      if (_rateLimiter.isLimitReached(ipAddress)) {
        return ResponseUtil.createErrorResponse(
            'Terlalu banyak percobaan login', 'Coba lagi nanti', 429);
      }

      final data = request.body;

      if (!Validator.validateRequiredFields(data, ['identifier', 'password'])) {
        return ResponseUtil.createErrorResponse(
            'Data tidak lengkap', 'Identifier dan password wajib diisi', 400);
      }

      final identifier = data['identifier'];
      final password = data['password'];

      final user = await _getUserByIdentifier(identifier);
      if (user == null) {
        _rateLimiter.logFailedAttempt(ipAddress);
        return ResponseUtil.createErrorResponse(
            'Login gagal', 'Identifier atau password salah', 401);
      }

      // Verif password
      final isPasswordValid =
          PasswordUtil.verifyPassword(password, user.password!);

      if (!isPasswordValid) {
        _rateLimiter.logFailedAttempt(ipAddress);
        return ResponseUtil.createErrorResponse(
            'Login gagal', 'Identifier atau password salah', 401);
      }

      // Log successful login
      await _service.logLoginAttempt(user.id, ipAddress, isSuccess: true);

      // Generate token JWT dan refresh token
      final accessToken = JwtUtil.generateToken(
        user.id!,
        expiresIn: const Duration(minutes: 15),
      );

      final refreshToken = JwtUtil.generateToken(
        user.id!,
        expiresIn: const Duration(days: 7),
        isRefreshToken: true,
      );

      return ResponseUtil.createSuccessResponse('Login berhasil', {
        'access_token': accessToken,
        'refresh_token': refreshToken,
      });
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal login', e);
    }
  }

  // PUT /users/:id - Update user by ID
  Future<Response> update(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak ditemukan', 'ID is required', 400);
      }

      final userId = int.tryParse(id.toString());
      if (userId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final data = request.body;

      // Validate update data
      final validationErrors = UserValidator.validateUserUpdate(data);
      if (validationErrors.isNotEmpty) {
        return ResponseUtil.createErrorResponse(
            'Validasi gagal', validationErrors, 400);
      }

      // Optional: Hash password if provided
      if (data.containsKey('password') && data['password'] != null) {
        data['password'] = PasswordUtil.hashPassword(data['password']);
      }

      final user = User(
        id: userId,
        name: data['name'],
        email: data['email'],
        password: data['password'],
      );

      final updatedUser = await _service.updateUser(userId, user);
      if (updatedUser == null) {
        return ResponseUtil.createErrorResponse(
            'Gagal memperbarui data pengguna', 'Update failed', 400);
      }

      // Remove password from response
      final responseData = updatedUser.toJson();
      responseData.remove('password');

      return ResponseUtil.createSuccessResponse(
          'Data pengguna berhasil diperbarui', responseData);
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal memperbarui data', e);
    }
  }

  // DELETE /users/:id - Delete user by ID
  Future<Response> destroy(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak ditemukan', 'ID is required', 400);
      }

      final userId = int.tryParse(id.toString());
      if (userId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final deletedUser = await _service.deleteUser(userId);
      if (deletedUser == null) {
        return ResponseUtil.createErrorResponse(
            'Gagal menghapus data pengguna', 'Deletion failed', 400);
      }

      return ResponseUtil.createSuccessResponse(
          'Data pengguna berhasil dihapus', deletedUser.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal menghapus data', e);
    }
  }
}
