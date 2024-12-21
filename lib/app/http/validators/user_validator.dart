import '../../../utils/validator.dart';

class UserValidator {
  static Map<String, String> validateUserCreate(Map<String, dynamic> data) {
    final errors = <String, String>{};

    // Field yang wajib diisi
    final requiredFields = ['name', 'username', 'email', 'password'];
    final missingFields = Validator.findMissingFields(data, requiredFields);
    if (missingFields.isNotEmpty) {
      errors['required'] =
          'Field berikut harus diisi: ${missingFields.join(", ")}';
      return errors; // Early return jika field wajib tidak lengkap
    }

    // Validasi username
    if (data['username'] != null &&
        !Validator.isValidUsername(data['username'])) {
      errors['username'] = 'Username tidak valid.';
    }

    // Validasi email
    if (data['email'] != null && !Validator.isValidEmail(data['email'])) {
      errors['email'] = 'Email tidak valid.';
    }

    // Validasi password
    if (data['password'] != null &&
        !Validator.isValidPassword(data['password'])) {
      errors['password'] =
          'Password harus minimal 6 karakter dan mengandung huruf besar, huruf kecil, angka, dan karakter spesial.';
    }

    return errors;
  }

  static Map<String, String> validateUserUpdate(Map<String, dynamic> data) {
    final errors = <String, String>{};

    if (data['email'] != null && !Validator.isValidEmail(data['email'])) {
      errors['email'] = 'Email tidak valid.';
    }

    if (data['password'] != null &&
        !Validator.isValidPassword(data['password'])) {
      errors['password'] = 'Password tidak valid.';
    }

    return errors;
  }
}
