/// 日期时间工具类
/// 提供日期格式化、计算等常用功能
class DateUtils {
  /// 私有构造函数，防止实例化
  DateUtils._();

  /// 格式化日期时间
  /// 
  /// 参数:
  ///   date: 要格式化的日期时间
  ///   format: 格式模式（默认：yyyy-MM-dd HH:mm:ss）
  /// 
  /// 返回:
  ///   格式化后的字符串
  static String format(DateTime date, {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    String pad(int n, int len) => n.toString().padLeft(len, '0');
    
    switch (format) {
      case 'yyyy-MM-dd':
        return '${date.year}-${pad(date.month, 2)}-${pad(date.day, 2)}';
      
      case 'HH:mm:ss':
        return '${pad(date.hour, 2)}:${pad(date.minute, 2)}:${pad(date.second, 2)}';
      
      case 'yyyy-MM-dd HH:mm':
        return '${date.year}-${pad(date.month, 2)}-${pad(date.day, 2)} ${pad(date.hour, 2)}:${pad(date.minute, 2)}';
      
      case 'yyyy-MM-dd HH:mm:ss':
        return '${date.year}-${pad(date.month, 2)}-${pad(date.day, 2)} ${pad(date.hour, 2)}:${pad(date.minute, 2)}:${pad(date.second, 2)}';
      
      case 'MM/dd':
        return '${pad(date.month, 2)}/${pad(date.day, 2)}';
      
      case 'yyyy/MM/dd':
        return '${date.year}/${pad(date.month, 2)}/${pad(date.day, 2)}';
      
      default:
        return '${date.year}-${pad(date.month, 2)}-${pad(date.day, 2)} ${pad(date.hour, 2)}:${pad(date.minute, 2)}:${pad(date.second, 2)}';
    }
  }

  /// 格式化相对时间
  /// 
  /// 参数:
  ///   date: 要格式化的日期时间
  /// 
  /// 返回:
  ///   相对时间字符串（如：刚刚、5 分钟前、1 小时前等）
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 1) {
      return '刚刚';
    } else if (diff.inMinutes < 1) {
      return '${diff.inSeconds}秒前';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}周前';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}个月前';
    } else {
      return '${(diff.inDays / 365).floor()}年前';
    }
  }

  /// 判断是否是今天
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 判断是否是昨天
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// 判断是否是本周
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfThisWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return date.isAfter(startOfThisWeek.subtract(const Duration(days: 1)));
  }

  /// 获取年龄
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  /// 计算两个日期之间的天数
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// 获取月份的天数
  static int getDaysInMonthCount(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0);
    return lastDay.day;
  }

  /// 获取指定月份的日期列表
  static List<DateTime> getDaysInMonth(int year, int month) {
    final days = <DateTime>[];
    final daysInMonth = getDaysInMonthCount(year, month);
    
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(year, month, i));
    }
    
    return days;
  }
}
