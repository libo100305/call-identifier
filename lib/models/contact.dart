/// 联系人数据模型
/// 用于表示从名片识别提取的联系人信息
class Contact {
  /// 联系人唯一标识
  final int? id;

  /// 姓名
  final String name;

  /// 电话号码
  final String phoneNumber;

  /// 公司名称
  final String? company;

  /// 职位
  final String? position;

  /// 电子邮件
  final String? email;

  /// 地址
  final String? address;

  /// 备注信息
  final String? note;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 联系人构造函数
  Contact({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.company,
    this.position,
    this.email,
    this.address,
    this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 从 Map 创建联系人对象（用于从数据库读取）
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String,
      company: map['company'] as String?,
      position: map['position'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// 将联系人转换为 Map（用于存入数据库）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'company': company,
      'position': position,
      'email': email,
      'address': address,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 复制并更新联系人信息
  Contact copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? company,
    String? position,
    String? email,
    String? address,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      company: company ?? this.company,
      position: position ?? this.position,
      email: email ?? this.email,
      address: address ?? this.address,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 重写 toString 方法便于调试
  @override
  String toString() {
    return 'Contact(id: $id, name: $name, phoneNumber: $phoneNumber, company: $company, position: $position)';
  }

  /// 重写 equality 运算符
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact &&
        other.id == id &&
        other.name == name &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ phoneNumber.hashCode;
  }
}
