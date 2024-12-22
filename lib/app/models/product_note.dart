class ProductNote {
  int? id;
  int? prodId;
  String? noteDate;
  String? noteText;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  ProductNote({
    this.id,
    this.prodId,
    this.noteDate,
    this.noteText,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prod_id': prodId,
      'note_date': noteDate,
      'note_text': noteText,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // Convert JSON to ProductNote instance
  factory ProductNote.fromJson(Map<String, dynamic> json) {
    return ProductNote(
      id: json['id'],
      prodId: json['prod_id'],
      noteDate: json['note_date'] is DateTime
          ? (json['note_date'] as DateTime).toIso8601String().split('T')[0]
          : json['note_date']?.toString().split('T')[0],
      noteText: json['note_text'],
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

  static const String tableName = 'product_notes';
}
