import '../models/contact.dart';
import '../database/database_helper.dart';

/// 联系人管理服务结果类
class ContactServiceResult {
  /// 操作是否成功
  final bool success;

  /// 联系人数据（如果操作成功）
  final Contact? contact;

  /// 联系人列表（如果操作成功）
  final List<Contact>? contacts;

  /// 错误信息（如果操作失败）
  final String? errorMessage;

  /// 附加数据
  final dynamic data;

  /// 联系人服务结果构造函数
  ContactServiceResult({
    required this.success,
    this.contact,
    this.contacts,
    this.errorMessage,
    this.data,
  });

  /// 创建成功结果
  factory ContactServiceResult.success({
    Contact? contact,
    List<Contact>? contacts,
    dynamic data,
  }) {
    return ContactServiceResult(
      success: true,
      contact: contact,
      contacts: contacts,
      data: data,
    );
  }

  /// 创建失败结果
  factory ContactServiceResult.failure(String errorMessage) {
    return ContactServiceResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// 联系人管理服务类
/// 负责联系人的增删改查等业务逻辑
class ContactService {
  /// 数据库帮助类实例
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// 添加联系人
  /// 
  /// 参数:
  ///   contact: 要添加的联系人对象
  /// 
  /// 返回:
  ///   ContactServiceResult 包含操作结果
  Future<ContactServiceResult> addContact(Contact contact) async {
    try {
      // 验证必填字段
      if (contact.name.isEmpty || contact.phoneNumber.isEmpty) {
        return ContactServiceResult.failure('姓名和电话号码为必填项');
      }

      // 验证电话号码格式
      if (!_isValidPhoneNumber(contact.phoneNumber)) {
        return ContactServiceResult.failure('电话号码格式不正确');
      }

      // 检查是否已存在相同电话号码的联系人
      final existingContacts = await _dbHelper.getContactsByPhone(contact.phoneNumber);
      if (existingContacts.isNotEmpty) {
        return ContactServiceResult.failure('该电话号码的联系人已存在');
      }

      // 插入数据库
      final id = await _dbHelper.insertContact(contact);
      final newContact = contact.copyWith(id: id);

      return ContactServiceResult.success(contact: newContact);
    } catch (e) {
      return ContactServiceResult.failure('添加联系人失败：$e');
    }
  }

  /// 批量添加联系人
  /// 
  /// 参数:
  ///   contacts: 联系人列表
  /// 
  /// 返回:
  ///   ContactServiceResult 包含操作结果和统计信息
  Future<ContactServiceResult> addContactsBatch(List<Contact> contacts) async {
    try {
      if (contacts.isEmpty) {
        return ContactServiceResult.failure('联系人列表不能为空');
      }

      int successCount = 0;
      int skipCount = 0;
      final addedContacts = <Contact>[];

      for (var contact in contacts) {
        // 验证必填字段
        if (contact.name.isEmpty || contact.phoneNumber.isEmpty) {
          skipCount++;
          continue;
        }

        // 检查是否已存在
        final existingContacts = await _dbHelper.getContactsByPhone(contact.phoneNumber);
        if (existingContacts.isNotEmpty) {
          skipCount++;
          continue;
        }

        // 插入数据库
        final id = await _dbHelper.insertContact(contact);
        addedContacts.add(contact.copyWith(id: id));
        successCount++;
      }

      return ContactServiceResult.success(
        contacts: addedContacts,
        data: {
          'total': contacts.length,
          'success': successCount,
          'skipped': skipCount,
        },
      );
    } catch (e) {
      return ContactServiceResult.failure('批量添加联系人失败：$e');
    }
  }

  /// 更新联系人信息
  /// 
  /// 参数:
  ///   contact: 要更新的联系人对象（必须包含 id）
  /// 
  /// 返回:
  ///   ContactServiceResult 包含操作结果
  Future<ContactServiceResult> updateContact(Contact contact) async {
    try {
      if (contact.id == null) {
        return ContactServiceResult.failure('联系人 ID 不能为空');
      }

      // 验证必填字段
      if (contact.name.isEmpty || contact.phoneNumber.isEmpty) {
        return ContactServiceResult.failure('姓名和电话号码为必填项');
      }

      // 验证电话号码格式
      if (!_isValidPhoneNumber(contact.phoneNumber)) {
        return ContactServiceResult.failure('电话号码格式不正确');
      }

      // 更新数据库
      await _dbHelper.updateContact(contact);
      final updatedContact = contact.copyWith(updatedAt: DateTime.now());

      return ContactServiceResult.success(contact: updatedContact);
    } catch (e) {
      return ContactServiceResult.failure('更新联系人失败：$e');
    }
  }

  /// 删除联系人
  /// 
  /// 参数:
  ///   id: 联系人 ID
  /// 
  /// 返回:
  ///   ContactServiceResult 包含操作结果
  Future<ContactServiceResult> deleteContact(int id) async {
    try {
      // 检查联系人是否存在
      final contact = await _dbHelper.getContactById(id);
      if (contact == null) {
        return ContactServiceResult.failure('联系人不存在');
      }

      // 删除数据库记录
      await _dbHelper.deleteContact(id);

      return ContactServiceResult.success(data: {'deletedId': id});
    } catch (e) {
      return ContactServiceResult.failure('删除联系人失败：$e');
    }
  }

  /// 根据 ID 获取联系人
  /// 
  /// 参数:
  ///   id: 联系人 ID
  /// 
  /// 返回:
  ///   ContactServiceResult 包含联系人数据
  Future<ContactServiceResult> getContactById(int id) async {
    try {
      final contact = await _dbHelper.getContactById(id);
      
      if (contact == null) {
        return ContactServiceResult.failure('联系人不存在');
      }

      return ContactServiceResult.success(contact: contact);
    } catch (e) {
      return ContactServiceResult.failure('获取联系人失败：$e');
    }
  }

  /// 根据电话号码搜索联系人
  /// 
  /// 参数:
  ///   phoneNumber: 电话号码（支持模糊匹配）
  /// 
  /// 返回:
  ///   ContactServiceResult 包含联系人列表
  Future<ContactServiceResult> searchByPhone(String phoneNumber) async {
    try {
      if (phoneNumber.isEmpty) {
        return ContactServiceResult.failure('电话号码不能为空');
      }

      final contacts = await _dbHelper.getContactsByPhone(phoneNumber);
      return ContactServiceResult.success(contacts: contacts);
    } catch (e) {
      return ContactServiceResult.failure('搜索联系人失败：$e');
    }
  }

  /// 搜索联系人
  /// 
  /// 参数:
  ///   query: 搜索关键字
  /// 
  /// 返回:
  ///   ContactServiceResult 包含联系人列表
  Future<ContactServiceResult> searchContacts(String query) async {
    try {
      if (query.isEmpty) {
        // 如果关键字为空，返回所有联系人
        final contacts = await getAllContacts();
        return ContactServiceResult.success(contacts: contacts);
      }

      final contacts = await _dbHelper.searchContacts(query);
      return ContactServiceResult.success(contacts: contacts);
    } catch (e) {
      return ContactServiceResult.failure('搜索联系人失败：$e');
    }
  }

  /// 获取所有联系人（分页）
  /// 
  /// 参数:
  ///   page: 页码（从 1 开始）
  ///   pageSize: 每页数量
  /// 
  /// 返回:
  ///   ContactServiceResult 包含联系人列表
  Future<List<Contact>> getAllContacts({
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      return await _dbHelper.getAllContacts(
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      print('获取联系人列表失败：$e');
      return [];
    }
  }

  /// 获取联系人总数
  Future<int> getContactsCount() async {
    try {
      return await _dbHelper.getContactsCount();
    } catch (e) {
      print('获取联系人总数失败：$e');
      return 0;
    }
  }

  /// 验证电话号码格式
  /// 支持中国大陆手机号和固定电话号码
  bool _isValidPhoneNumber(String phone) {
    // 去除空格和特殊字符
    final cleanedPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    
    // 中国大陆手机号：11 位数字，以 1 开头
    final mobileRegex = RegExp(r'^1[3-9]\d{9}$');
    
    // 固定电话号码：区号 + 电话号码
    final landlineRegex = RegExp(r'^0\d{2,3}\d{7,8}$');
    
    // 400 电话
    final tollFreeRegex = RegExp(r'^400\d{7}$');
    
    return mobileRegex.hasMatch(cleanedPhone) ||
        landlineRegex.hasMatch(cleanedPhone) ||
        tollFreeRegex.hasMatch(cleanedPhone);
  }

  /// 格式化电话号码
  /// 将电话号码格式化为更易读的格式
  String formatPhoneNumber(String phone) {
    final cleanedPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    
    // 手机号格式：138 0013 8000
    if (cleanedPhone.length == 11 && cleanedPhone.startsWith('1')) {
      return '${cleanedPhone.substring(0, 3)} ${cleanedPhone.substring(3, 7)} ${cleanedPhone.substring(7)}';
    }
    
    // 400 电话格式：400-xxx-xxxx
    if (cleanedPhone.length == 10 && cleanedPhone.startsWith('400')) {
      return '${cleanedPhone.substring(0, 3)}-${cleanedPhone.substring(3, 6)}-${cleanedPhone.substring(6)}';
    }
    
    // 固定电话格式：010-12345678
    if (cleanedPhone.startsWith('0') && cleanedPhone.length >= 11) {
      final areaCodeLength = cleanedPhone.length == 11 ? 3 : 4;
      return '${cleanedPhone.substring(0, areaCodeLength)}-${cleanedPhone.substring(areaCodeLength)}';
    }
    
    return phone;
  }
}
