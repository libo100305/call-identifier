/// 识别状态枚举
/// 用于标识来电识别记录的状态
enum IdentificationStatus {
  /// 匹配成功 - 在联系人数据库中找到对应联系人
  matched,
  
  /// 未匹配 - 未在联系人数据库中找到对应联系人
  unmatched,
  
  /// 待处理 - 识别完成但尚未处理
  pending;

  /// 获取状态的中文显示文本
  String get displayName {
    switch (this) {
      case IdentificationStatus.matched:
        return '已匹配';
      case IdentificationStatus.unmatched:
        return '未匹配';
      case IdentificationStatus.pending:
        return '待处理';
    }
  }

  /// 获取状态对应的颜色
  /// 用于 UI 显示中的状态标识
  String get colorCode {
    switch (this) {
      case IdentificationStatus.matched:
        return '#4CAF50'; // 绿色
      case IdentificationStatus.unmatched:
        return '#FF9800'; // 橙色
      case IdentificationStatus.pending:
        return '#9E9E9E'; // 灰色
    }
  }
}
