class Order {
  static const String tableName = 'orders';

  int? id;
  String? orderDate;
  int? custId;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  Order({
    this.id,
    this.orderDate,
    this.custId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_date': orderDate,
        'cust_id': custId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  static Order fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        orderDate: json['order_date'] is DateTime
            ? (json['order_date'] as DateTime).toIso8601String().split('T')[0]
            : json['order_date']?.toString(),
        custId: json['cust_id'],
        createdAt: json['created_at'] is String
            ? DateTime.parse(json['created_at'])
            : json['created_at'],
        updatedAt: json['updated_at'] is String
            ? DateTime.parse(json['updated_at'])
            : json['updated_at'],
        deletedAt: json['deleted_at'] is String
            ? DateTime.parse(json['deleted_at'])
            : json['deleted_at'],
      );
}
