import '../../../utils/validator.dart';

class CustomersValidator {
  static Map<String, String> validateCreate(Map<String, dynamic> data) {
    final errors = <String, String>{};

    // Cek field yang wajib diisi
    final requiredFields = [
      'cust_name',
      'cust_address',
      'cust_city',
      'cust_state',
      'cust_zip',
      'cust_country',
      'cust_telp',
    ];

    final missingFields = Validator.findMissingFields(data, requiredFields);
    if (missingFields.isNotEmpty) {
      errors['required'] =
          'Field berikut harus diisi: ${missingFields.join(", ")}';
      return errors;
    }

    // Validasi kode pos
    if (!Validator.isValidPostalCode(data['cust_zip'] ?? '')) {
      errors['cust_zip'] = 'Kode pos harus berupa angka 5 digit.';
    }

    // Validasi nomor telepon
    if (!Validator.isValidPhone(data['cust_telp'] ?? '')) {
      errors['cust_telp'] = 'Nomor telepon tidak valid.';
    }

    return errors;
  }

  // Validasi untuk pembaruan data customer
  static Map<String, String> validateUpdate(Map<String, dynamic> data) {
    final errors = <String, String>{};

    if (data['cust_zip'] != null &&
        !Validator.isValidPostalCode(data['cust_zip'])) {
      errors['cust_zip'] = 'Kode pos harus berupa angka 5 digit.';
    }

    if (data['cust_telp'] != null &&
        !Validator.isValidPhone(data['cust_telp'])) {
      errors['cust_telp'] = 'Nomor telepon tidak valid.';
    }

    return errors;
  }
}
