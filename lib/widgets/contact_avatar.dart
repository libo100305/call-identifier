import 'package:flutter/material.dart';

/// 联系人头像组件
/// 用于显示联系人头像，支持字母头像和圆形头像
class ContactAvatar extends StatelessWidget {
  /// 联系人姓名
  final String? name;

  /// 头像图片 URL
  final String? imageUrl;

  /// 头像大小
  final double radius;

  /// 背景颜色
  final Color? backgroundColor;

  /// 文字颜色
  final Color? textColor;

  /// 是否显示边框
  final bool showBorder;

  /// 边框颜色
  final Color? borderColor;

  /// 边框宽度
  final double borderWidth;

  /// 联系人头像构造函数
  const ContactAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.radius = 24.0,
    this.backgroundColor,
    this.textColor,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    // 计算首字母
    final String initial = _getInitial(name);
    
    // 生成背景颜色
    final Color bgColor = backgroundColor ?? _generateColor(name);
    
    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // 使用网络图片
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: bgColor,
        child: const CircularProgressIndicator(),
      );
    } else {
      // 使用字母头像
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: Text(
          initial,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: radius * 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // 添加边框
    if (showBorder) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? Colors.white,
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }

    return avatar;
  }

  /// 获取姓名的首字母
  String _getInitial(String? name) {
    if (name == null || name.isEmpty) {
      return '?';
    }

    // 去除前后空格
    final trimmedName = name.trim();
    
    if (trimmedName.isEmpty) {
      return '?';
    }

    // 如果是中文，返回第一个字
    if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(trimmedName[0])) {
      return trimmedName[0];
    }

    // 如果是英文，返回首字母大写
    return trimmedName[0].toUpperCase();
  }

  /// 根据姓名生成稳定的背景颜色
  Color _generateColor(String? name) {
    // 预定义的颜色列表
    final colors = [
      const Color(0xFFE57373), // 红色
      const Color(0xFFBA68C8), // 紫色
      const Color(0xFF64B5F6), // 蓝色
      const Color(0xFF4DB6AC), // 青色
      const Color(0xFF81C784), // 绿色
      const Color(0xFFFFD54F), // 黄色
      const Color(0xFFFFB74D), // 橙色
      const Color(0xFFA1887F), // 棕色
      const Color(0xFF90A4AE), // 蓝灰色
      const Color(0xFFF06292), // 粉红色
    ];

    if (name == null || name.isEmpty) {
      return colors[0];
    }

    // 根据姓名的哈希值选择颜色
    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }

  /// 创建大尺寸头像
  static ContactAvatar large({
    String? name,
    String? imageUrl,
    double radius = 40.0,
  }) {
    return ContactAvatar(
      name: name,
      imageUrl: imageUrl,
      radius: radius,
    );
  }

  /// 创建中等尺寸头像
  static ContactAvatar medium({
    String? name,
    String? imageUrl,
    double radius = 24.0,
  }) {
    return ContactAvatar(
      name: name,
      imageUrl: imageUrl,
      radius: radius,
    );
  }

  /// 创建小尺寸头像
  static ContactAvatar small({
    String? name,
    String? imageUrl,
    double radius = 16.0,
  }) {
    return ContactAvatar(
      name: name,
      imageUrl: imageUrl,
      radius: radius,
    );
  }

  /// 创建带边框的头像
  static ContactAvatar withBorder({
    String? name,
    String? imageUrl,
    double radius = 24.0,
    Color borderColor = Colors.white,
    double borderWidth = 2.0,
  }) {
    return ContactAvatar(
      name: name,
      imageUrl: imageUrl,
      radius: radius,
      showBorder: true,
      borderColor: borderColor,
      borderWidth: borderWidth,
    );
  }
}

/// 联系人头像列表组件
class ContactAvatarList extends StatelessWidget {
  /// 联系人姓名列表
  final List<String> names;

  /// 头像大小
  final double radius;

  /// 头像之间的重叠量
  final double overlap;

  /// 最大显示数量
  final int maxCount;

  /// 联系人头像列表构造函数
  const ContactAvatarList({
    super.key,
    required this.names,
    this.radius = 20.0,
    this.overlap = 10.0,
    this.maxCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    final displayNames = names.length > maxCount
        ? names.sublist(0, maxCount)
        : names;
    
    final hasMore = names.length > maxCount;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...displayNames.asMap().entries.map((entry) {
          final index = entry.key;
          final name = entry.value;
          
          return Transform.translate(
            offset: Offset(-overlap * index, 0),
            child: ContactAvatar(
              name: name,
              radius: radius,
              showBorder: true,
            ),
          );
        }),
        
        if (hasMore) ...[
          Transform.translate(
            offset: Offset(-overlap * displayNames.length, 0),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: Colors.grey[300],
              child: Text(
                '+${names.length - maxCount}',
                style: TextStyle(
                  fontSize: radius * 0.6,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
