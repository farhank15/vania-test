class Vendor {
  static const String tableName = 'vendors';

  int? id;
  String? vendName;
  String? vendAddress;
  String? vendKota;
  String? vendState;
  String? vendZip;
  String? vendCountry;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  Vendor({
    this.id,
    this.vendName,
    this.vendAddress,
    this.vendKota,
    this.vendState,
    this.vendZip,
    this.vendCountry,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  // Convert Vendor to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'vend_name': vendName,
        'vend_address': vendAddress,
        'vend_kota': vendKota,
        'vend_state': vendState,
        'vend_zip': vendZip,
        'vend_country': vendCountry,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  // Create Vendor from JSON
  static Vendor fromJson(Map<String, dynamic> json) => Vendor(
        id: json['id'],
        vendName: json['vend_name'],
        vendAddress: json['vend_address'],
        vendKota: json['vend_kota'],
        vendState: json['vend_state'],
        vendZip: json['vend_zip'],
        vendCountry: json['vend_country'],
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
