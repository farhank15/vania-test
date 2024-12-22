class Product {
  static const String tableName = 'products';

  int? id;
  int? vendId;
  String? prodName;
  int? prodPrice;
  String? prodDesc;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  Product({
    this.id,
    this.vendId,
    this.prodName,
    this.prodPrice,
    this.prodDesc,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  // Convert Product to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'vend_id': vendId,
        'prod_name': prodName,
        'prod_price': prodPrice,
        'prod_desc': prodDesc,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  // Create Product from JSON
  static Product fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        vendId: json['vend_id'],
        prodName: json['prod_name'],
        prodPrice: json['prod_price'],
        prodDesc: json['prod_desc'],
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
