class OrderItem {
  int? id;
  int? orderId;
  int? prodId;
  int? quantity;
  int? size;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  OrderItem({
    this.id,
    this.orderId,
    this.prodId,
    this.quantity,
    this.size,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  // Convert JSON to OrderItem instance
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      prodId: json['prod_id'],
      quantity: json['quantity'],
      size: json['size'],
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

  // Convert OrderItem instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'prod_id': prodId,
      'quantity': quantity,
      'size': size,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
