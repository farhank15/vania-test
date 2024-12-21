import 'package:bcrypt/bcrypt.dart';

class PasswordUtil {
  static const int saltRounds = 10;

  static String hashPassword(String password) {
    try {
      // Gunakan salt rounds yang tetap untuk konsistensi
      final salt = BCrypt.gensalt(logRounds: saltRounds);
      return BCrypt.hashpw(password, salt);
    } catch (e) {
      print('Error saat hashing password: $e');
      rethrow;
    }
  }

  static bool verifyPassword(String plainPassword, String hashedPassword) {
    try {
      // Tambahkan validasi input
      if (plainPassword.isEmpty || hashedPassword.isEmpty) {
        print('Password atau hash kosong');
        return false;
      }

      // Validasi format hash
      if (!hashedPassword.startsWith('\$2a\$') &&
          !hashedPassword.startsWith('\$2b\$')) {
        print('Format hash password tidak valid');
        return false;
      }

      // Verifikasi password
      final result = BCrypt.checkpw(plainPassword, hashedPassword);
      print('Hasil verifikasi detail:');
      print('Plain password: $plainPassword');
      print('Hashed password: $hashedPassword');
      print('Verification result: $result');

      return result;
    } catch (e) {
      print('Error saat verifikasi password: $e');
      return false;
    }
  }
}
