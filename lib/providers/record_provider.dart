import 'package:flutter/foundation.dart';
import '../models/identification_record.dart';
import '../services/identification_service.dart';

/// 识别记录状态枚举
enum RecordLoadStatus {
  /// 初始状态
  initial,

  /// 加载中
  loading,

  /// 加载成功
  success,

  /// 加载失败
  error,
}

/// 识别记录筛选条件
enum RecordFilter {
  /// 全部记录
  all,

  /// 已匹配
  matched,

  /// 未匹配
  unmatched,

  /// 待处理
  pending,
}

/// 识别记录状态提供者类
/// 使用 ChangeNotifier 实现状态管理
class RecordProvider extends ChangeNotifier {
  /// 识别服务实例
  final IdentificationService _identificationService = IdentificationService();

  /// 识别记录列表
  List<IdentificationRecord> _records = [];

  /// 当前加载状态
  RecordLoadStatus _status = RecordLoadStatus.initial;

  /// 当前筛选条件
  RecordFilter _currentFilter = RecordFilter.all;

  /// 当前页码
  int _currentPage = 1;

  /// 每页数量
  final int _pageSize = 50;

  /// 是否有更多数据
  bool _hasMore = true;

  /// 错误信息
  String? _errorMessage;

  /// 统计信息
  Map<String, int> _stats = {};

  /// 获取识别记录列表
  List<IdentificationRecord> get records => _records;

  /// 获取加载状态
  RecordLoadStatus get status => _status;

  /// 获取是否正在加载
  bool get isLoading => _status == RecordLoadStatus.loading;

  /// 获取是否加载成功
  bool get isSuccess => _status == RecordLoadStatus.success;

  /// 获取是否加载失败
  bool get isError => _status == RecordLoadStatus.error;

  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  /// 获取记录总数
  int get recordsCount => _records.length;

  /// 获取当前筛选条件
  RecordFilter get currentFilter => _currentFilter;

  /// 获取统计信息
  Map<String, int> get stats => _stats;

  /// 获取未匹配记录数量
  int get unmatchedCount => _stats['unmatched'] ?? 0;

  /// 获取已匹配记录数量
  int get matchedCount => _stats['matched'] ?? 0;

  /// 构造函数
  RecordProvider() {
    // 初始化时加载统计信息和最近记录
    loadStats();
    loadRecords();
  }

  /// 加载识别记录
  /// 
  /// 参数:
  ///   refresh: 是否刷新列表（重置分页）
  ///   filter: 筛选条件
  Future<void> loadRecords({
    bool refresh = false,
    RecordFilter? filter,
  }) async {
    try {
      _status = RecordLoadStatus.loading;
      _errorMessage = null;
      notifyListeners();

      if (refresh) {
        _currentPage = 1;
        _records = [];
        _hasMore = true;
      }

      if (filter != null) {
        _currentFilter = filter;
      }

      String? statusFilter;
      if (_currentFilter == RecordFilter.matched) {
        statusFilter = 'MATCHED';
      } else if (_currentFilter == RecordFilter.unmatched) {
        statusFilter = 'UNMATCHED';
      } else if (_currentFilter == RecordFilter.pending) {
        statusFilter = 'PENDING';
      }

      final result = await _identificationService.getRecentRecords(
        limit: _pageSize * _currentPage,
      );

      if (result.success && result.data != null) {
        final allRecords = result.data['records'] as List<IdentificationRecord>;
        
        // 应用筛选
        List<IdentificationRecord> filteredRecords = allRecords;
        if (statusFilter != null) {
          filteredRecords = allRecords
              .where((r) => r.status == statusFilter)
              .toList();
        }

        if (refresh) {
          _records = filteredRecords;
        } else {
          _records.addAll(filteredRecords);
        }

        _currentPage++;
        _hasMore = filteredRecords.length >= _pageSize;
        _status = RecordLoadStatus.success;
      } else {
        _status = RecordLoadStatus.error;
        _errorMessage = result.errorMessage;
      }

      notifyListeners();
    } catch (e) {
      _status = RecordLoadStatus.error;
      _errorMessage = '加载识别记录失败：$e';
      notifyListeners();
    }
  }

  /// 加载统计信息
  Future<void> loadStats() async {
    try {
      final result = await _identificationService.getIdentificationStats();
      
      if (result.success && result.data != null) {
        _stats = result.data['stats'] as Map<String, int>;
        notifyListeners();
      }
    } catch (e) {
      print('加载统计信息失败：$e');
    }
  }

  /// 识别电话号码
  /// 
  /// 参数:
  ///   phoneNumber: 电话号码
  ///   source: 识别来源
  Future<bool> identifyPhone({
    required String phoneNumber,
    required String source,
  }) async {
    try {
      final result = await _identificationService.identifyPhoneNumber(
        phoneNumber: phoneNumber,
        source: source,
      );

      if (result.success && result.record != null) {
        // 添加到列表顶部
        _records.insert(0, result.record!);
        
        // 更新统计信息
        await loadStats();
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '识别失败：$e';
      notifyListeners();
      return false;
    }
  }

  /// 手动匹配记录到联系人
  /// 
  /// 参数:
  ///   recordId: 识别记录 ID
  ///   contactId: 联系人 ID
  Future<bool> matchRecord({
    required int recordId,
    required int contactId,
  }) async {
    try {
      final result = await _identificationService.matchRecordToContact(
        recordId: recordId,
        contactId: contactId,
      );

      if (result.success && result.record != null) {
        // 更新列表中的记录
        final index = _records.indexWhere((r) => r.id == recordId);
        if (index != -1) {
          _records[index] = result.record!;
          
          // 更新统计信息
          await loadStats();
          
          notifyListeners();
        }
        return true;
      } else {
        _errorMessage = result.errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '匹配失败：$e';
      notifyListeners();
      return false;
    }
  }

  /// 删除识别记录
  /// 
  /// 参数:
  ///   id: 要删除的记录 ID
  Future<bool> deleteRecord(int id) async {
    try {
      final result = await _identificationService.deleteRecord(id);
      
      if (result.success) {
        // 从列表中移除
        _records.removeWhere((r) => r.id == id);
        
        // 更新统计信息
        await loadStats();
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '删除记录失败：$e';
      notifyListeners();
      return false;
    }
  }

  /// 根据 ID 获取识别记录
  /// 
  /// 参数:
  ///   id: 记录 ID
  IdentificationRecord? getRecordById(int id) {
    try {
      return _records.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 刷新记录列表
  Future<void> refresh() async {
    await loadRecords(refresh: true);
    await loadStats();
  }

  /// 加载更多记录
  Future<void> loadMore() async {
    if (_hasMore && !isLoading) {
      await loadRecords();
    }
  }

  /// 设置筛选条件
  void setFilter(RecordFilter filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
      loadRecords(refresh: true);
    }
  }

  /// 清空错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 获取筛选条件的显示文本
  String getFilterLabel(RecordFilter filter) {
    switch (filter) {
      case RecordFilter.all:
        return '全部';
      case RecordFilter.matched:
        return '已匹配';
      case RecordFilter.unmatched:
        return '未匹配';
      case RecordFilter.pending:
        return '待处理';
    }
  }
}
