class Order {
  static const String tableName = 'orders';

  int? id;
  DateTime? orderDate;
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

  // Convert Order to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'order_date': orderDate?.toIso8601String(),
        'cust_id': custId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  // Create Order from JSON
  static Order fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        orderDate: json['order_date'] != null && json['order_date'] is String
            ? DateTime.parse(json['order_date'])
            : (json['order_date'] is DateTime ? json['order_date'] : null),
        custId: json['cust_id'],
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
