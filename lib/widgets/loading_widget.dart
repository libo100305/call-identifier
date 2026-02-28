import 'package:flutter/material.dart';

/// 加载指示器组件
/// 用于显示加载状态的动画
class LoadingWidget extends StatelessWidget {
  /// 加载提示文字
  final String? message;

  /// 加载图标大小
  final double size;

  /// 图标颜色
  final Color? color;

  /// 是否显示消息
  final bool showMessage;

  /// 加载指示器构造函数
  const LoadingWidget({
    super.key,
    this.message,
    this.size = 40.0,
    this.color,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: 16),
            Text(
              message ?? '加载中...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 全屏加载组件
class FullScreenLoading extends StatelessWidget {
  /// 加载提示文字
  final String? message;

  /// 全屏加载构造函数
  const FullScreenLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.9),
      child: LoadingWidget(
        message: message,
        size: 50,
      ),
    );
  }
}

/// 按钮加载状态包装器
class LoadingButton extends StatelessWidget {
  /// 按钮文字
  final String text;

  /// 是否正在加载
  final bool isLoading;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 按钮类型
  final ButtonType buttonType;

  /// 是否占满全宽
  final bool fullWidth;

  /// 按钮加载状态构造函数
  const LoadingButton({
    super.key,
    required this.text,
    this.isLoading = false,
    this.onPressed,
    this.buttonType = ButtonType.elevated,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;
    
    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                buttonType == ButtonType.text
                    ? Theme.of(context).primaryColor
                    : Colors.white,
              ),
            ),
          )
        : Text(text);

    switch (buttonType) {
      case ButtonType.elevated:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: fullWidth ? const Size(double.infinity, 48) : null,
          ),
          child: child,
        );
        break;
      
      case ButtonType.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: fullWidth ? const Size(double.infinity, 48) : null,
          ),
          child: child,
        );
        break;
      
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
        break;
    }

    return button;
  }
}

/// 按钮类型枚举
enum ButtonType {
  /// 填充按钮
  elevated,

  /// 边框按钮
  outlined,

  /// 文字按钮
  text,
}
