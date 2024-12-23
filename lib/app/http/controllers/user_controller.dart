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
  final RateLimiter _rateLimiter = RateLimiter();

  String _getIpAddress(Request request) {
    final ipAddress = request.headers['X-Real-IP'];
    if (ipAddress != null && ipAddress.isNotEmpty) {
      return ipAddress;
    }

    final forwardedFor = request.headers['X-Forwarded-For'];
    if (forwardedFor != null && forwardedFor.isNotEmpty) {
      return forwardedFor.split(',').first.trim();
    }

    return "unknown";
  }

  Future<User?> _getUserByIdentifier(String identifier) async {
    if (Validator.isValidEmail(identifier)) {
      return await _service.getUserByEmail(identifier);
    } else {
      return await _service.getUserByUsername(identifier);
    }
  }

  Future<Response> index() async {
    try {
      final users = await _service.getAllUsers();
      return ResponseUtil.createSuccessResponse(
          'Data berhasil diambil', users.map((u) => u.toJson()).toList());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal mengambil data', e);
    }
  }

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

  Future<Response> store(Request request) async {
    try {
      final data = request.body;

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

      final responseData = newUser.toJson();
      responseData.remove('password');

      return ResponseUtil.createSuccessResponse(
          'Data pengguna berhasil dibuat', responseData, 201);
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal membuat data pengguna', e);
    }
  }

  Future<Response> login(Request request) async {
    try {
      final ipAddress = _getIpAddress(request);

      if (_rateLimiter.isLimitReached(ipAddress)) {
        return ResponseUtil.createErrorResponse(
            'Terlalu banyak percobaan login', 'Coba lagi nanti', 429);
      }

      final data = request.body;
      final identifier = data['identifier']?.trim();
      final password = data['password']?.trim();

      if (identifier == null ||
          password == null ||
          identifier.isEmpty ||
          password.isEmpty) {
        return ResponseUtil.createErrorResponse(
            'Data tidak lengkap', 'Identifier dan password wajib diisi', 400);
      }

      final user = await _getUserByIdentifier(identifier);
      if (user == null) {
        _rateLimiter.logFailedAttempt(ipAddress);
        return ResponseUtil.createErrorResponse(
            'Login gagal', 'Identifier atau password salah', 401);
      }

      final isPasswordValid =
          PasswordUtil.verifyPassword(password, user.password!);
      if (!isPasswordValid) {
        _rateLimiter.logFailedAttempt(ipAddress);
        return ResponseUtil.createErrorResponse(
            'Login gagal', 'Identifier atau password salah', 401);
      }

      // Generate tokens with required parameters
      final accessToken = JwtUtil.generateToken(
        userId: user.id!,
        name: user.name!,
        email: user.email!,
        expiresIn: const Duration(minutes: 15),
      );

      final refreshToken = JwtUtil.generateToken(
        userId: user.id!,
        name: user.name!,
        email: user.email!,
        isRefreshToken: true,
        expiresIn: const Duration(days: 7),
      );

      await _service.updateUserToken(user.id!, refreshToken);
      await _service.logLoginAttempt(user.id!, ipAddress, isSuccess: true);

      return ResponseUtil.createSuccessResponse('Login berhasil', {
        'access_token': accessToken,
        'refresh_token': refreshToken,
      });
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal login', e);
    }
  }

  Future<Response> refreshToken(Request request) async {
    try {
      final data = request.body;
      final refreshToken = data['refresh_token'];

      if (refreshToken == null || refreshToken.isEmpty) {
        return ResponseUtil.createErrorResponse(
            'Refresh token tidak valid', 'Token is required', 400);
      }

      final claims = JwtUtil.verifyRefreshToken(refreshToken);
      final userId = int.parse(claims.subject!);

      final user = await _service.getUserById(userId);
      if (user == null || user.token != refreshToken) {
        return ResponseUtil.createErrorResponse(
            'Refresh token tidak valid', 'Invalid token', 401);
      }

      final newAccessToken = JwtUtil.generateToken(
        userId: user.id!,
        name: user.name!,
        email: user.email!,
        expiresIn: const Duration(minutes: 15),
      );

      final newRefreshToken = JwtUtil.generateToken(
        userId: user.id!,
        name: user.name!,
        email: user.email!,
        isRefreshToken: true,
        expiresIn: const Duration(days: 7),
      );

      await _service.updateUserToken(user.id!, newRefreshToken);

      return ResponseUtil.createSuccessResponse('Token berhasil diperbarui', {
        'access_token': newAccessToken,
        'refresh_token': newRefreshToken,
      });
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal memperbarui token', e);
    }
  }

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

      final validationErrors = UserValidator.validateUserUpdate(data);
      if (validationErrors.isNotEmpty) {
        return ResponseUtil.createErrorResponse(
            'Validasi gagal', validationErrors, 400);
      }

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

      final responseData = updatedUser.toJson();
      responseData.remove('password');

      return ResponseUtil.createSuccessResponse(
          'Data pengguna berhasil diperbarui', responseData);
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal memperbarui data', e);
    }
  }

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
