/// 识别记录数据模型
/// 用于记录每次来电识别的历史记录
class IdentificationRecord {
  /// 记录唯一标识
  final int? id;

  /// 来电号码
  final String phoneNumber;

  /// 识别到的联系人 ID（如果没有匹配到则为 null）
  final int? contactId;

  /// 识别到的联系人姓名
  final String? contactName;

  /// 识别来源 (OCR: 名片识别，MANUAL: 手动添加，IMPORT: 导入)
  final String source;

  /// 识别状态 (MATCHED: 匹配成功，UNMATCHED: 未匹配，PENDING: 待处理)
  final String status;

  /// 识别置信度 (0-100)
  final double? confidence;

  /// 识别时的截图路径（如果有）
  final String? screenshotPath;

  /// 备注信息
  final String? note;

  /// 识别时间
  final DateTime identifiedAt;

  /// 创建时间
  final DateTime createdAt;

  /// 识别记录构造函数
  IdentificationRecord({
    this.id,
    required this.phoneNumber,
    this.contactId,
    this.contactName,
    required this.source,
    required this.status,
    this.confidence,
    this.screenshotPath,
    this.note,
    DateTime? identifiedAt,
    DateTime? createdAt,
  })  : identifiedAt = identifiedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  /// 从 Map 创建识别记录对象（用于从数据库读取）
  factory IdentificationRecord.fromMap(Map<String, dynamic> map) {
    return IdentificationRecord(
      id: map['id'] as int?,
      phoneNumber: map['phone_number'] as String,
      contactId: map['contact_id'] as int?,
      contactName: map['contact_name'] as String?,
      source: map['source'] as String,
      status: map['status'] as String,
      confidence: map['confidence'] as double?,
      screenshotPath: map['screenshot_path'] as String?,
      note: map['note'] as String?,
      identifiedAt: DateTime.parse(map['identified_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// 将识别记录转换为 Map（用于存入数据库）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'contact_id': contactId,
      'contact_name': contactName,
      'source': source,
      'status': status,
      'confidence': confidence,
      'screenshot_path': screenshotPath,
      'note': note,
      'identified_at': identifiedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 复制并更新识别记录
  IdentificationRecord copyWith({
    int? id,
    String? phoneNumber,
    int? contactId,
    String? contactName,
    String? source,
    String? status,
    double? confidence,
    String? screenshotPath,
    String? note,
    DateTime? identifiedAt,
    DateTime? createdAt,
  }) {
    return IdentificationRecord(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contactId: contactId ?? this.contactId,
      contactName: contactName ?? this.contactName,
      source: source ?? this.source,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      screenshotPath: screenshotPath ?? this.screenshotPath,
      note: note ?? this.note,
      identifiedAt: identifiedAt ?? this.identifiedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 判断是否匹配成功
  bool get isMatched => status == 'MATCHED';

  /// 重写 toString 方法便于调试
  @override
  String toString() {
    return 'IdentificationRecord(id: $id, phoneNumber: $phoneNumber, contactName: $contactName, status: $status)';
  }

  /// 重写 equality 运算符
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IdentificationRecord &&
        other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.identifiedAt == identifiedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ phoneNumber.hashCode ^ identifiedAt.hashCode;
  }
}
