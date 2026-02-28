import 'package:flutter/material.dart';

/// 错误状态组件
/// 用于显示错误信息的界面
class ErrorWidget extends StatelessWidget {
  /// 错误信息
  final String? message;

  /// 错误详情
  final String? details;

  /// 图标
  final IconData? icon;

  /// 重试按钮文字
  final String? retryText;

  /// 重试回调
  final VoidCallback? onRetry;

  /// 是否显示重试按钮
  final bool showRetry;

  /// 错误状态组件构造函数
  const ErrorWidget({
    super.key,
    this.message,
    this.details,
    this.icon,
    this.retryText,
    this.onRetry,
    this.showRetry = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 错误图标
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            
            const SizedBox(height: 24),
            
            // 错误标题
            Text(
              message ?? '出错了',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.red[600],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 错误详情
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // 重试按钮
            if (showRetry) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? '重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 创建网络错误状态的快捷方法
  static ErrorWidget network({VoidCallback? onRetry}) {
    return ErrorWidget(
      message: '网络连接失败',
      details: '请检查网络设置后重试',
      icon: Icons.cloud_off_outlined,
      retryText: '重新加载',
      showRetry: true,
      onRetry: onRetry,
    );
  }

  /// 创建加载错误状态的快捷方法
  static ErrorWidget load({String? message, VoidCallback? onRetry}) {
    return ErrorWidget(
      message: message ?? '加载失败',
      icon: Icons.folder_off_outlined,
      retryText: '重新加载',
      showRetry: true,
      onRetry: onRetry,
    );
  }

  /// 创建服务器错误状态的快捷方法
  static ErrorWidget server({VoidCallback? onRetry}) {
    return ErrorWidget(
      message: '服务器错误',
      details: '请稍后再试',
      icon: Icons.dns_outlined,
      retryText: '重试',
      showRetry: true,
      onRetry: onRetry,
    );
  }

  /// 创建权限错误状态的快捷方法
  static ErrorWidget permission({
    String? message,
    VoidCallback? onGrant,
  }) {
    return ErrorWidget(
      message: message ?? '权限被拒绝',
      details: '请在设置中授予相应权限',
      icon: Icons.lock_outline,
      retryText: '去设置',
      showRetry: true,
      onRetry: onGrant,
    );
  }
}

/// 带错误边界的构建器
/// 自动捕获构建过程中的错误
class ErrorBoundary extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 错误时显示的组件
  final Widget? errorWidget;

  /// 错误回调
  final void Function(Object error, StackTrace stack)? onError;

  /// 错误边界构造函数
  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorWidget,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.onError != null) {
        widget.onError!(_error!, _stackTrace!);
      }
      
      return widget.errorWidget ?? ErrorWidget(
        message: '渲染失败',
        details: _error.toString(),
        onRetry: () {
          setState(() {
            _error = null;
            _stackTrace = null;
          });
        },
      );
    }
    
    return widget.child;
  }

  /// 处理错误
  void handleError(Object error, StackTrace stack) {
    if (mounted) {
      setState(() {
        _error = error;
        _stackTrace = stack;
      });
    }
  }
}
