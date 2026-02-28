import '../models/contact.dart';
import '../models/identification_record.dart';
import '../database/database_helper.dart';
import 'contact_service.dart';

/// 身份匹配服务结果类
class IdentificationServiceResult {
  /// 操作是否成功
  final bool success;

  /// 识别记录
  final IdentificationRecord? record;

  /// 匹配到的联系人
  final Contact? matchedContact;

  /// 匹配到的联系人列表（可能有多个）
  final List<Contact>? matchedContacts;

  /// 错误信息
  final String? errorMessage;

  /// 附加数据
  final dynamic data;

  /// 身份匹配服务结果构造函数
  IdentificationServiceResult({
    required this.success,
    this.record,
    this.matchedContact,
    this.matchedContacts,
    this.errorMessage,
    this.data,
  });

  /// 创建成功结果
  factory IdentificationServiceResult.success({
    IdentificationRecord? record,
    Contact? matchedContact,
    List<Contact>? matchedContacts,
    dynamic data,
  }) {
    return IdentificationServiceResult(
      success: true,
      record: record,
      matchedContact: matchedContact,
      matchedContacts: matchedContacts,
      data: data,
    );
  }

  /// 创建失败结果
  factory IdentificationServiceResult.failure(String errorMessage) {
    return IdentificationServiceResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// 身份匹配服务类
/// 负责来电号码与联系人数据库的匹配识别
class IdentificationService {
  /// 数据库帮助类实例
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// 联系人服务实例
  final ContactService _contactService = ContactService();

  /// 识别并匹配来电号码
  /// 
  /// 参数:
  ///   phoneNumber: 来电号码
  ///   source: 识别来源 (OCR, MANUAL, IMPORT 等)
  ///   screenshotPath: 截图路径（可选）
  /// 
  /// 返回:
  ///   IdentificationServiceResult 包含匹配结果
  Future<IdentificationServiceResult> identifyPhoneNumber({
    required String phoneNumber,
    required String source,
    String? screenshotPath,
  }) async {
    try {
      // 格式化电话号码
      final formattedPhone = _formatPhoneNumber(phoneNumber);

      // 搜索匹配的联系人
      final matchedContacts = await _dbHelper.getContactsByPhone(formattedPhone);

      IdentificationRecord record;
      Contact? matchedContact;

      if (matchedContacts.isNotEmpty) {
        // 匹配成功
        matchedContact = matchedContacts.first;
        
        record = IdentificationRecord(
          phoneNumber: formattedPhone,
          contactId: matchedContact.id,
          contactName: matchedContact.name,
          source: source,
          status: 'MATCHED',
          confidence: 100.0,
          screenshotPath: screenshotPath,
        );
      } else {
        // 未匹配
        record = IdentificationRecord(
          phoneNumber: formattedPhone,
          contactId: null,
          contactName: null,
          source: source,
          status: 'UNMATCHED',
          confidence: 0.0,
          screenshotPath: screenshotPath,
        );
      }

      // 保存识别记录
      await _dbHelper.insertIdentificationRecord(record);

      return IdentificationServiceResult.success(
        record: record,
        matchedContact: matchedContact,
      );
    } catch (e) {
      return IdentificationServiceResult.failure('识别失败：$e');
    }
  }

  /// 识别来电者（简化版本，直接返回联系人）
  /// 
  /// 参数:
  ///   phoneNumber: 电话号码
  /// 
  /// 返回:
  ///   匹配到的联系人，如果没有则返回 null
  Future<Contact?> identifyCaller(String phoneNumber) async {
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      final matchedContacts = await _dbHelper.getContactsByPhone(formattedPhone);
      
      if (matchedContacts.isNotEmpty) {
        return matchedContacts.first;
      }
      return null;
    } catch (e) {
      print('识别来电者失败：$e');
      return null;
    }
  }

  /// 手动匹配识别记录到联系人
  /// 
  /// 参数:
  ///   recordId: 识别记录 ID
  ///   contactId: 联系人 ID
  /// 
  /// 返回:
  ///   IdentificationServiceResult 包含更新后的记录
  Future<IdentificationServiceResult> matchRecordToContact({
    required int recordId,
    required int contactId,
  }) async {
    try {
      // 获取识别记录
      final record = await _dbHelper.getIdentificationRecordById(recordId);
      if (record == null) {
        return IdentificationServiceResult.failure('识别记录不存在');
      }

      // 获取联系人
      final contact = await _dbHelper.getContactById(contactId);
      if (contact == null) {
        return IdentificationServiceResult.failure('联系人不存在');
      }

      // 更新识别记录
      final updatedRecord = record.copyWith(
        contactId: contactId,
        contactName: contact.name,
        status: 'MATCHED',
        confidence: 100.0,
      );

      await _dbHelper.updateIdentificationRecord(updatedRecord);

      return IdentificationServiceResult.success(
        record: updatedRecord,
        matchedContact: contact,
      );
    } catch (e) {
      return IdentificationServiceResult.failure('匹配操作失败：$e');
    }
  }

  /// 从 OCR 识别结果创建联系人并记录
  /// 
  /// 参数:
  ///   contact: OCR 识别的联系人
  ///   source: 识别来源
  /// 
  /// 返回:
  ///   IdentificationServiceResult 包含创建结果
  Future<IdentificationServiceResult> createContactFromOcr({
    required Contact contact,
    required String source,
  }) async {
    try {
      // 添加联系人
      final addResult = await _contactService.addContact(contact);
      
      if (!addResult.success) {
        return IdentificationServiceResult.failure(addResult.errorMessage!);
      }

      final newContact = addResult.contact!;

      // 创建识别记录
      final record = IdentificationRecord(
        phoneNumber: newContact.phoneNumber,
        contactId: newContact.id,
        contactName: newContact.name,
        source: source,
        status: 'MATCHED',
        confidence: 90.0, // OCR 识别的置信度
      );

      final recordId = await _dbHelper.insertIdentificationRecord(record);
      final newRecord = record.copyWith(id: recordId);

      return IdentificationServiceResult.success(
        record: newRecord,
        matchedContact: newContact,
      );
    } catch (e) {
      return IdentificationServiceResult.failure('创建联系人失败：$e');
    }
  }

  /// 获取未匹配的识别记录
  /// 
  /// 返回:
  ///   IdentificationServiceResult 包含未匹配记录列表
  Future<IdentificationServiceResult> getUnmatchedRecords() async {
    try {
      final records = await _dbHelper.getUnmatchedRecords();
      return IdentificationServiceResult.success(
        data: {'records': records, 'count': records.length},
      );
    } catch (e) {
      return IdentificationServiceResult.failure('获取未匹配记录失败：$e');
    }
  }

  /// 获取最近的识别记录
  /// 
  /// 参数:
  ///   limit: 返回数量限制
  /// 
  /// 返回:
  ///   IdentificationServiceResult 包含记录列表
  Future<IdentificationServiceResult> getRecentRecords({int limit = 20}) async {
    try {
      final records = await _dbHelper.getRecentRecords(limit: limit);
      return IdentificationServiceResult.success(
        data: {'records': records, 'count': records.length},
      );
    } catch (e) {
      return IdentificationServiceResult.failure('获取识别记录失败：$e');
    }
  }

  /// 获取识别统计信息
  /// 
  /// 返回:
  ///   IdentificationServiceResult 包含统计数据
  Future<IdentificationServiceResult> getIdentificationStats() async {
    try {
      final stats = await _dbHelper.getRecordStatusStats();
      final totalCount = stats.values.fold(0, (sum, count) => sum + count);
      
      return IdentificationServiceResult.success(
        data: {
          'total': totalCount,
          'matched': stats['MATCHED'] ?? 0,
          'unmatched': stats['UNMATCHED'] ?? 0,
          'pending': stats['PENDING'] ?? 0,
          'stats': stats,
        },
      );
    } catch (e) {
      return IdentificationServiceResult.failure('获取统计信息失败：$e');
    }
  }

  /// 删除识别记录
  /// 
  /// 参数:
  ///   recordId: 识别记录 ID
  /// 
  /// 返回:
  ///   IdentificationServiceResult 包含操作结果
  Future<IdentificationServiceResult> deleteRecord(int recordId) async {
    try {
      await _dbHelper.deleteIdentificationRecord(recordId);
      return IdentificationServiceResult.success(
        data: {'deletedId': recordId},
      );
    } catch (e) {
      return IdentificationServiceResult.failure('删除记录失败：$e');
    }
  }

  /// 批量清理过期识别记录
  /// 
  /// 参数:
  ///   daysAgo: 清理多少天前的记录
  /// 
  /// 返回:
  ///   IdentificationServiceResult 包含操作结果
  Future<IdentificationServiceResult> cleanupOldRecords({int daysAgo = 90}) async {
    try {
      // TODO: 实现批量删除逻辑
      // 由于 SQLite 限制，需要通过原始 SQL 执行
      final cutoffDate = DateTime.now().subtract(Duration(days: daysAgo));
      
      // 这里仅返回成功结果，实际删除逻辑需要根据具体需求实现
      return IdentificationServiceResult.success(
        data: {
          'cutoffDate': cutoffDate.toIso8601String(),
          'message': '清理 $daysAgo 天前的记录功能待实现',
        },
      );
    } catch (e) {
      return IdentificationServiceResult.failure('清理记录失败：$e');
    }
  }

  /// 格式化电话号码
  /// 去除空格、横杠等特殊字符
  String _formatPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-]'), '');
  }

  /// 电话号码模糊匹配
  /// 支持不同格式的电话号码匹配（如带区号和不带区号）
  bool isPhoneMatch(String phone1, String phone2) {
    // 提取纯数字
    final digits1 = phone1.replaceAll(RegExp(r'[^\d]'), '');
    final digits2 = phone2.replaceAll(RegExp(r'[^\d]'), '');

    // 完全匹配
    if (digits1 == digits2) {
      return true;
    }

    // 手机号匹配（11 位）
    if (digits1.length == 11 && digits2.length == 11) {
      return digits1 == digits2;
    }

    // 固定电话匹配（考虑区号）
    if (digits1.length >= 10 && digits2.length >= 10) {
      // 去掉区号后匹配
      final local1 = digits1.length > 10 ? digits1.substring(digits1.length - 8) : digits1;
      final local2 = digits2.length > 10 ? digits2.substring(digits2.length - 8) : digits2;
      return local1 == local2;
    }

    return false;
  }
}
