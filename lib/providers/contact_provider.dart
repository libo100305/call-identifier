import 'package:flutter/foundation.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';

/// 联系人状态枚举
enum ContactLoadStatus {
  /// 初始状态
  initial,

  /// 加载中
  loading,

  /// 加载成功
  success,

  /// 加载失败
  error,
}

/// 联系人状态提供者类
/// 使用 ChangeNotifier 实现状态管理
class ContactProvider extends ChangeNotifier {
  /// 联系人服务实例
  final ContactService _contactService = ContactService();

  /// 联系人列表
  List<Contact> _contacts = [];

  /// 当前加载状态
  ContactLoadStatus _status = ContactLoadStatus.initial;

  /// 当前页码
  int _currentPage = 1;

  /// 每页数量
  final int _pageSize = 50;

  /// 是否有更多数据
  bool _hasMore = true;

  /// 搜索关键字
  String _searchQuery = '';

  /// 错误信息
  String? _errorMessage;

  /// 获取联系人列表
  List<Contact> get contacts => _contacts;

  /// 获取加载状态
  ContactLoadStatus get status => _status;

  /// 获取是否正在加载
  bool get isLoading => _status == ContactLoadStatus.loading;

  /// 获取是否加载成功
  bool get isSuccess => _status == ContactLoadStatus.success;

  /// 获取是否加载失败
  bool get isError => _status == ContactLoadStatus.error;

  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  /// 获取联系人总数
  int get contactsCount => _contacts.length;

  /// 获取当前页码
  int get currentPage => _currentPage;

  /// 获取是否有更多数据
  bool get hasMore => _hasMore;

  /// 获取搜索关键字
  String get searchQuery => _searchQuery;

  /// 构造函数
  ContactProvider() {
    // 初始化时加载联系人列表
    loadContacts();
  }

  /// 加载联系人列表
  /// 
  /// 参数:
  ///   refresh: 是否刷新列表（重置分页）
  Future<void> loadContacts({bool refresh = false}) async {
    try {
      _status = ContactLoadStatus.loading;
      _errorMessage = null;
      notifyListeners();

      if (refresh) {
        _currentPage = 1;
        _contacts = [];
        _hasMore = true;
      }

      final newContacts = await _contactService.getAllContacts(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (refresh) {
        _contacts = newContacts;
      } else {
        _contacts.addAll(newContacts);
      }

      _currentPage++;
      _hasMore = newContacts.length == _pageSize;
      _status = ContactLoadStatus.success;
      
      notifyListeners();
    } catch (e) {
      _status = ContactLoadStatus.error;
      _errorMessage = '加载联系人失败：$e';
      notifyListeners();
    }
  }

  /// 搜索联系人
  /// 
  /// 参数:
  ///   query: 搜索关键字
  Future<void> searchContacts(String query) async {
    try {
      _searchQuery = query;
      _status = ContactLoadStatus.loading;
      _errorMessage = null;
      notifyListeners();

      if (query.isEmpty) {
        // 关键字为空，加载所有联系人
        await loadContacts(refresh: true);
        return;
      }

      final result = await _contactService.searchContacts(query);
      
      if (result.success && result.contacts != null) {
        _contacts = result.contacts!;
        _status = ContactLoadStatus.success;
      } else {
        _status = ContactLoadStatus.error;
        _errorMessage = result.errorMessage;
      }
      
      notifyListeners();
    } catch (e) {
      _status = ContactLoadStatus.error;
      _errorMessage = '搜索联系人失败：$e';
      notifyListeners();
    }
  }

  /// 添加联系人
  /// 
  /// 参数:
  ///   contact: 要添加的联系人对象
  Future<bool> addContact(Contact contact) async {
    try {
      final result = await _contactService.addContact(contact);
      
      if (result.success && result.contact != null) {
        // 添加到列表顶部
        _contacts.insert(0, result.contact!);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '添加联系人失败：$e';
      notifyListeners();
      return false;
    }
  }

  /// 更新联系人
  /// 
  /// 参数:
  ///   contact: 更新后的联系人对象
  Future<bool> updateContact(Contact contact) async {
    try {
      final result = await _contactService.updateContact(contact);
      
      if (result.success && result.contact != null) {
        // 更新列表中的联系人
        final index = _contacts.indexWhere((c) => c.id == contact.id);
        if (index != -1) {
          _contacts[index] = result.contact!;
          notifyListeners();
        }
        return true;
      } else {
        _errorMessage = result.errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '更新联系人失败：$e';
      notifyListeners();
      return false;
    }
  }

  /// 删除联系人
  /// 
  /// 参数:
  ///   id: 要删除的联系人 ID
  Future<bool> deleteContact(int id) async {
    try {
      final result = await _contactService.deleteContact(id);
      
      if (result.success) {
        // 从列表中移除
        _contacts.removeWhere((c) => c.id == id);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '删除联系人失败：$e';
      notifyListeners();
      return false;
    }
  }

  /// 根据 ID 获取联系人
  /// 
  /// 参数:
  ///   id: 联系人 ID
  Contact? getContactById(int id) {
    try {
      return _contacts.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 刷新联系人列表
  Future<void> refresh() async {
    await loadContacts(refresh: true);
  }

  /// 加载更多联系人
  Future<void> loadMore() async {
    if (_hasMore && !isLoading) {
      await loadContacts();
    }
  }

  /// 清空错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 清空搜索
  void clearSearch() {
    _searchQuery = '';
    loadContacts(refresh: true);
  }
}
