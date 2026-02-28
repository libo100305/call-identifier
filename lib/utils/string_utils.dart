/// 字符串工具类
/// 提供字符串处理、格式化等常用功能
class StringUtils {
  /// 私有构造函数，防止实例化
  StringUtils._();

  /// 判断字符串是否为空
  /// 
  /// 参数:
  ///   str: 要检查的字符串
  /// 
  /// 返回:
  ///   如果字符串为 null 或空字符串则返回 true
  static bool isEmpty(String? str) {
    return str == null || str.isEmpty;
  }

  /// 判断字符串是否不为空
  static bool isNotEmpty(String? str) {
    return !isEmpty(str);
  }

  /// 判断字符串是否为 null 或空白
  static bool isNullOrBlank(String? str) {
    if (str == null) return true;
    return str.trim().isEmpty;
  }

  /// 格式化电话号码
  /// 将电话号码格式化为更易读的格式
  /// 
  /// 参数:
  ///   phone: 电话号码
  /// 
  /// 返回:
  ///   格式化后的电话号码
  static String formatPhoneNumber(String phone) {
    // 去除空格和特殊字符
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

  /// 隐藏手机号码中间数字
  /// 
  /// 参数:
  ///   phone: 手机号码
  ///   maskChar: 掩码字符（默认：*）
  /// 
  /// 返回:
  ///   隐藏后的手机号码
  static String maskPhoneNumber(String phone, {String maskChar = '*'}) {
    if (phone.length < 7) {
      return phone;
    }
    
    // 保留前 3 位和后 4 位
    final prefix = phone.substring(0, 3);
    final suffix = phone.substring(phone.length - 4);
    final maskLength = phone.length - 7;
    
    return '$prefix${maskChar * maskLength}$suffix';
  }

  /// 隐藏邮箱用户名部分
  /// 
  /// 参数:
  ///   email: 邮箱地址
  ///   maskChar: 掩码字符（默认：*）
  /// 
  /// 返回:
  ///   隐藏后的邮箱地址
  static String maskEmail(String email, {String maskChar = '*'}) {
    final atIndex = email.indexOf('@');
    if (atIndex <= 0) {
      return email;
    }
    
    final username = email.substring(0, atIndex);
    final domain = email.substring(atIndex);
    
    if (username.length <= 2) {
      return '${maskChar * username.length}$domain';
    }
    
    // 保留前 2 位和最后 1 位
    final prefix = username.substring(0, 2);
    final suffix = username.substring(username.length - 1);
    final maskLength = username.length - 3;
    
    return '$prefix${maskChar * maskLength}$suffix$domain';
  }

  /// 截断字符串
  /// 如果字符串超过指定长度，则截断并添加省略号
  /// 
  /// 参数:
  ///   str: 要截断的字符串
  ///   maxLength: 最大长度
  ///   suffix: 省略号（默认：...）
  /// 
  /// 返回:
  ///   截断后的字符串
  static String truncate(String str, int maxLength, {String suffix = '...'}) {
    if (str.length <= maxLength) {
      return str;
    }
    
    if (maxLength <= suffix.length) {
      return suffix.substring(0, maxLength);
    }
    
    return '${str.substring(0, maxLength - suffix.length)}$suffix';
  }

  /// 移除 HTML 标签
  /// 
  /// 参数:
  ///   html: HTML 字符串
  /// 
  /// 返回:
  ///   纯文本
  static String removeHtmlTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// 首字母大写
  static String capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  /// 每个单词首字母大写
  static String capitalizeWords(String str) {
    return str.split(' ').map(capitalize).join(' ');
  }

  /// 转换为驼峰命名
  static String toCamelCase(String str) {
    final words = str.split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return '';
    
    return words[0].toLowerCase() +
        words.skip(1).map(capitalize).join('');
  }

  /// 转换为短横线命名
  static String toKebabCase(String str) {
    return str
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'([a-z])([A-Z])'), '\$1-\$2')
        .toLowerCase();
  }

  /// 转换为下划线命名
  static String toSnakeCase(String str) {
    return str
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'([a-z])([A-Z])'), '\$1_\$2')
        .toLowerCase();
  }

  /// 重复字符串
  static String repeat(String str, int count) {
    return List.filled(count, str).join();
  }

  /// 提取数字
  static String extractDigits(String str) {
    return str.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// 提取字母
  static String extractLetters(String str) {
    return str.replaceAll(RegExp(r'[^a-zA-Z]'), '');
  }

  /// 反转字符串
  static String reverse(String str) {
    return str.split('').reversed.join('');
  }

  /// 判断字符串是否只包含数字
  static bool isNumeric(String str) {
    return str.isNotEmpty && RegExp(r'^\d+$').hasMatch(str);
  }

  /// 判断字符串是否只包含字母
  static bool isAlphabetic(String str) {
    return str.isNotEmpty && RegExp(r'^[a-zA-Z]+$').hasMatch(str);
  }

  /// 判断字符串是否是邮箱格式
  static bool isEmail(String str) {
    return str.isNotEmpty &&
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(str);
  }

  /// 判断字符串是否是手机号格式
  static bool isPhoneNumber(String str) {
    return str.isNotEmpty && RegExp(r'^1[3-9]\d{9}$').hasMatch(str);
  }

  /// 判断字符串是否是 URL 格式
  static bool isUrl(String str) {
    return str.isNotEmpty &&
        RegExp(r'^https?://.+$').hasMatch(str);
  }
}
