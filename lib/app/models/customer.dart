class Customer {
  static const String tableName = 'customers';

  int? id;
  String? custName;
  String? custAddress;
  String? custCity;
  String? custState;
  String? custZip;
  String? custCountry;
  String? custTelp;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  Customer({
    this.id,
    this.custName,
    this.custAddress,
    this.custCity,
    this.custState,
    this.custZip,
    this.custCountry,
    this.custTelp,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'cust_name': custName,
        'cust_address': custAddress,
        'cust_city': custCity,
        'cust_state': custState,
        'cust_zip': custZip,
        'cust_country': custCountry,
        'cust_telp': custTelp,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String()
      };

  static Customer fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'],
        custName: json['cust_name'],
        custAddress: json['cust_address'],
        custCity: json['cust_city'],
        custState: json['cust_state'],
        custZip: json['cust_zip'],
        custCountry: json['cust_country'],
        custTelp: json['cust_telp'],
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
