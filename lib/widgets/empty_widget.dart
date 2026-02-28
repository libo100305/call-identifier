import 'package:flutter/material.dart';

/// 空状态组件
/// 用于显示数据为空的提示界面
class EmptyWidget extends StatelessWidget {
  /// 标题文字
  final String? title;

  /// 副标题文字
  final String? subtitle;

  /// 图标
  final IconData? icon;

  /// 自定义图片路径（可选）
  final String? imagePath;

  /// 操作按钮文字
  final String? actionText;

  /// 操作按钮点击回调
  final VoidCallback? onAction;

  /// 是否显示操作按钮
  final bool showAction;

  /// 空状态组件构造函数
  const EmptyWidget({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.imagePath,
    this.actionText,
    this.onAction,
    this.showAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标或图片
            if (imagePath != null) ...[
              Image.asset(
                imagePath!,
                width: 120,
                height: 120,
              ),
            ] else ...[
              Icon(
                icon ?? Icons.inbox_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // 标题
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // 副标题
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // 操作按钮
            if (showAction && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 创建空列表状态的快捷方法
  static EmptyWidget list({String? title, String? subtitle}) {
    return EmptyWidget(
      title: title ?? '暂无数据',
      subtitle: subtitle,
      icon: Icons.list_alt_outlined,
    );
  }

  /// 创建空搜索结果状态的快捷方法
  static EmptyWidget search({String? query}) {
    return EmptyWidget(
      title: '未找到相关结果',
      subtitle: query != null ? '未找到与"$query"相关的内容' : null,
      icon: Icons.search_off,
    );
  }

  /// 创建空网络状态的快捷方法
  static EmptyWidget network({VoidCallback? onRetry}) {
    return EmptyWidget(
      title: '网络异常',
      subtitle: '请检查网络连接后重试',
      icon: Icons.cloud_off_outlined,
      actionText: '重试',
      showAction: true,
      onAction: onRetry,
    );
  }

  /// 创建空权限状态的快捷方法
  static EmptyWidget permission({
    String? title,
    String? subtitle,
    VoidCallback? onGrant,
  }) {
    return EmptyWidget(
      title: title ?? '无权限',
      subtitle: subtitle ?? '请在设置中授予相应权限',
      icon: Icons.lock_outline,
      actionText: '去设置',
      showAction: true,
      onAction: onGrant,
    );
  }
}
