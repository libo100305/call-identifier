import 'package:flutter/material.dart';
// import '../screens/camera_scan_page.dart'; // 暂时禁用以解决 jlink 兼容性问题
import '../screens/contacts_page.dart';
import '../screens/records_page.dart';
import '../screens/contact_add_page.dart';

/// 首页组件（用于路由）
typedef HomePage = Scaffold;

/// 应用路由配置类
/// 管理应用的所有路由路径和页面导航
class AppRoutes {
  /// 私有构造函数，防止实例化
  AppRoutes._();

  // ==================== 路由路径常量 ====================

  /// 联系人列表页
  static const String contactList = '/contacts';

  /// 联系人详情页
  static const String contactDetail = '/contacts/detail';

  /// 联系人编辑页
  static const String contactEdit = '/contacts/edit';

  /// 联系人添加页
  static const String contactAdd = '/contacts/add';

  /// 识别记录列表页
  static const String recordList = '/records';

  /// 识别记录详情页
  static const String recordDetail = '/records/detail';

  /// OCR 识别页
  static const String ocrScan = '/ocr/scan';

  /// 来电识别页
  static const String incomingCall = '/call/incoming';

  /// 搜索页
  static const String search = '/search';

  /// 设置页
  static const String settings = '/settings';

  /// 关于页
  static const String about = '/about';

  // ==================== 路由生成器 ====================

  /// 获取应用所有路由配置
  /// 
  /// 返回:
  ///   Map<String, WidgetBuilder> 路由映射表
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      contactList: (context) => const ContactsPage(),
      contactAdd: (context) => const ContactAddPage(),
      recordList: (context) => const RecordsPage(),
      // ocrScan: (context) => const CameraScanPage(), // 暂时禁用
      ocrScan: (context) => _placeholderPage(context, 'OCR 识别（开发中）'),
      contactEdit: (context) => const ContactAddPage(),
      recordDetail: (context) => _placeholderPage(context, '记录详情'),
      incomingCall: (context) => _placeholderPage(context, '来电识别'),
      search: (context) => _placeholderPage(context, '搜索'),
      settings: (context) => _placeholderPage(context, '设置'),
      about: (context) => _placeholderPage(context, '关于'),
    };
  }

  /// 生成路由处理器
  /// 处理未定义的路由和带参数的路由
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // 联系人详情页（带参数）
      case contactDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => _placeholderPage(
            context,
            '联系人详情 - ${args?['contactId'] ?? '未知'}',
          ),
          settings: settings,
        );

      // 识别记录详情页（带参数）
      case recordDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => _placeholderPage(
            context,
            '记录详情 - ${args?['recordId'] ?? '未知'}',
          ),
          settings: settings,
        );

      // 未知路由
      default:
        return MaterialPageRoute(
          builder: (context) => _unknownRoutePage(context, settings.name),
          settings: settings,
        );
    }
  }

  // ==================== 导航辅助方法 ====================

  /// 导航到指定路由
  /// 
  /// 参数:
  ///   context: BuildContext
  ///   routeName: 路由名称
  ///   arguments: 路由参数（可选）
  static void navigateTo(BuildContext context, String routeName, {dynamic arguments}) {
    Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// 导航到指定路由并替换当前路由
  static void navigateAndReplace(BuildContext context, String routeName, {dynamic arguments}) {
    Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// 导航到指定路由并清除之前的路由
  static void navigateAndClearStack(BuildContext context, String routeName, {dynamic arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// 返回上一页
  static void goBack(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result);
  }

  // ==================== 占位页面 ====================

  /// 占位页面
  /// 用于尚未实现的页面
  static Widget _placeholderPage(BuildContext context, String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '$title（开发中）',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '页面正在开发中，敬请期待...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 未知路由页面
  static Widget _unknownRoutePage(BuildContext context, String? routeName) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              '页面未找到',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '路由：${routeName ?? '未知'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 路由参数辅助类
/// 用于传递类型安全的路由参数
class RouteArguments {
  /// 联系人 ID
  final int? contactId;

  /// 识别记录 ID
  final int? recordId;

  /// 电话号码
  final String? phoneNumber;

  /// 其他参数
  final Map<String, dynamic>? extra;

  /// 路由参数构造函数
  RouteArguments({
    this.contactId,
    this.recordId,
    this.phoneNumber,
    this.extra,
  });

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      if (contactId != null) 'contactId': contactId,
      if (recordId != null) 'recordId': recordId,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (extra != null) 'extra': extra,
    };
  }

  /// 从 Map 创建
  factory RouteArguments.fromMap(Map<String, dynamic> map) {
    return RouteArguments(
      contactId: map['contactId'] as int?,
      recordId: map['recordId'] as int?,
      phoneNumber: map['phoneNumber'] as String?,
      extra: map['extra'] as Map<String, dynamic>?,
    );
  }
}
