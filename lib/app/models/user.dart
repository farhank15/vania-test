class User {
  static const String tableName = 'users';

  int? id;
  String? name;
  String? username;
  String? email;
  String? password;
  String? token;
  DateTime? lastLoginAt;
  String? lastLoginIp;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  User({
    this.id,
    this.name,
    this.username,
    this.email,
    this.password,
    this.token,
    this.lastLoginAt,
    this.lastLoginIp,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  // Convert User to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'token': token,
        'last_login_at': lastLoginAt?.toIso8601String(),
        'last_login_ip': lastLoginIp,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  // Create User from JSON
  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        username: json['username'],
        email: json['email'],
        password: json['password'],
        token: json['token'],
        lastLoginAt:
            json['last_login_at'] != null && json['last_login_at'] is String
                ? DateTime.parse(json['last_login_at'])
                : (json['last_login_at'] is DateTime
                    ? json['last_login_at']
                    : null),
        lastLoginIp: json['last_login_ip'],
        createdAt: json['created_at'] != null && json['created_at'] is String
            ? DateTime.parse(json['created_at'])
            : (json['created_at'] is DateTime ? json['created_at'] : null),
        updatedAt: json['updated_at'] != null && json['updated_at'] is String
            ? DateTime.parse(json['updated_at'])
            : (json['updated_at'] is DateTime ? json['updated_at'] : null),
        deletedAt: json['deleted_at'] != null && json['deleted_at'] is String
            ? DateTime.parse(json['deleted_at'])
            : (json['deleted_at'] is DateTime ? json['deleted_at'] : null),
      );
}
