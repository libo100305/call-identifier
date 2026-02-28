/// 验证器工具类
/// 提供表单验证、数据校验等常用功能
class ValidatorUtils {
  /// 私有构造函数，防止实例化
  ValidatorUtils._();

  /// 验证邮箱格式
  /// 
  /// 参数:
  ///   email: 要验证的邮箱地址
  /// 
  /// 返回:
  ///   如果格式正确返回 null，否则返回错误信息
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return '邮箱不能为空';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(email)) {
      return '邮箱格式不正确';
    }
    
    return null;
  }

  /// 验证手机号码
  /// 
  /// 参数:
  ///   phone: 要验证的手机号码
  ///   required: 是否必填（默认：true）
  /// 
  /// 返回:
  ///   如果格式正确返回 null，否则返回错误信息
  static String? validatePhoneNumber(String? phone, {bool required = true}) {
    if (phone == null || phone.isEmpty) {
      if (required) {
        return '手机号码不能为空';
      }
      return null;
    }
    
    // 中国大陆手机号：11 位数字，以 1 开头
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    
    if (!phoneRegex.hasMatch(phone)) {
      return '手机号码格式不正确';
    }
    
    return null;
  }

  /// 验证固定电话号码
  static String? validateLandlinePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return null; // 固定电话可选
    }
    
    // 固定电话号码格式：区号 + 电话号码
    final phoneRegex = RegExp(r'^0\d{2,3}-?\d{7,8}$');
    
    if (!phoneRegex.hasMatch(phone)) {
      return '固定电话号码格式不正确';
    }
    
    return null;
  }

  /// 验证密码强度
  /// 
  /// 参数:
  ///   password: 要验证的密码
  ///   minLength: 最小长度（默认：6）
  ///   requireNumber: 是否要求包含数字（默认：false）
  ///   requireSpecial: 是否要求包含特殊字符（默认：false）
  /// 
  /// 返回:
  ///   如果符合要求返回 null，否则返回错误信息
  static String? validatePassword(
    String? password, {
    int minLength = 6,
    bool requireNumber = false,
    bool requireSpecial = false,
  }) {
    if (password == null || password.isEmpty) {
      return '密码不能为空';
    }
    
    if (password.length < minLength) {
      return '密码长度不能少于$minLength 位';
    }
    
    if (requireNumber && !RegExp(r'\d').hasMatch(password)) {
      return '密码必须包含数字';
    }
    
    if (requireSpecial && !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return '密码必须包含特殊字符';
    }
    
    return null;
  }

  /// 验证密码强度等级
  /// 
  /// 返回:
  ///   1: 弱
  ///   2: 中
  ///   3: 强
  static int getPasswordStrength(String password) {
    if (password.length < 6) {
      return 0; // 太弱
    }
    
    int score = 0;
    
    // 长度评分
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    
    // 字符类型评分
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    
    if (score <= 2) return 1; // 弱
    if (score <= 4) return 2; // 中
    return 3; // 强
  }

  /// 验证姓名
  static String? validateName(String? name, {String fieldName = '姓名'}) {
    if (name == null || name.isEmpty) {
      return '$fieldName不能为空';
    }
    
    if (name.length < 2) {
      return '$fieldName长度至少为 2 个字符';
    }
    
    if (name.length > 50) {
      return '$fieldName长度不能超过 50 个字符';
    }
    
    return null;
  }

  /// 验证身份证号（中国大陆）
  static String? validateIdCard(String? idCard) {
    if (idCard == null || idCard.isEmpty) {
      return null; // 身份证号可选
    }
    
    // 18 位身份证号验证
    final idCardRegex = RegExp(
      r'^[1-9]\d{5}(18|19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dXx]$',
    );
    
    if (!idCardRegex.hasMatch(idCard)) {
      return '身份证号格式不正确';
    }
    
    return null;
  }

  /// 验证 URL
  static String? validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }
    
    final urlRegex = RegExp(
      r'^https?://.+\..+$',
    );
    
    if (!urlRegex.hasMatch(url)) {
      return 'URL 格式不正确';
    }
    
    return null;
  }

  /// 验证数字范围
  static String? validateNumberRange(
    num? value, {
    num? min,
    num? max,
    String fieldName = '数值',
  }) {
    if (value == null) {
      return null;
    }
    
    if (min != null && value < min) {
      return '$fieldName不能小于$min';
    }
    
    if (max != null && value > max) {
      return '$fieldName不能大于$max';
    }
    
    return null;
  }

  /// 验证字符串长度
  static String? validateStringLength(
    String? value, {
    int? minLength,
    int? maxLength,
    String fieldName = '内容',
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    if (minLength != null && value.length < minLength) {
      return '$fieldName长度不能少于$minLength 个字符';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return '$fieldName长度不能超过$maxLength 个字符';
    }
    
    return null;
  }

  /// 验证必填字段
  static String? validateRequired(String? value, {String fieldName = '此字段'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能为空';
    }
    return null;
  }

  /// 验证自定义正则
  static String? validatePattern(
    String? value,
    RegExp pattern, {
    String errorMessage = '格式不正确',
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    if (!pattern.hasMatch(value)) {
      return errorMessage;
    }
    
    return null;
  }

  /// 组合验证器
  /// 同时验证多个规则
  static String? validateAll(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (var validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}
