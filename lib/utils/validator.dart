class Validator {
  // Field validation
  static bool isRequired(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    return true;
  }

  // String patterns
  static final _patterns = {
    'email': r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    'phone': r'^\+?[0-9-]{7,15}$',
    'postalCode': r'^\d{5}$',
    'username': r'^[a-zA-Z0-9_-]{3,20}$',
    'password':
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$',
  };

  // Basic validations
  static bool isValidEmail(String? email) {
    if (email == null) return false;
    return RegExp(_patterns['email'] ?? '').hasMatch(email.trim());
  }

  static bool isValidPhone(String? phone) {
    if (phone == null) return false;
    return RegExp(_patterns['phone'] ?? '').hasMatch(phone.trim());
  }

  static bool isValidPostalCode(String? code) {
    if (code == null) return false;
    return RegExp(_patterns['postalCode'] ?? '').hasMatch(code.trim());
  }

  static bool isValidUsername(String? username) {
    if (username == null) return false;
    return RegExp(_patterns['username'] ?? '').hasMatch(username.trim());
  }

  static bool isValidPassword(String? password) {
    if (password == null) return false;
    return RegExp(_patterns['password'] ?? '').hasMatch(password);
  }

  // Helper methods
  static List<String> findMissingFields(
      Map<String, dynamic> data, List<String> requiredFields) {
    return requiredFields.where((field) => !isRequired(data[field])).toList();
  }

  static bool validateRequiredFields(
      Map<String, dynamic> data, List<String> requiredFields) {
    return findMissingFields(data, requiredFields).isEmpty;
  }
}
