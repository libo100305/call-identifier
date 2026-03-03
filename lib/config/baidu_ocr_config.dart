/// 百度 OCR API 配置
/// 
/// 请在百度 AI 开放平台申请 API Key：
/// https://ai.baidu.com/tech/ocr
/// 
/// 申请步骤：
/// 1. 登录百度账号
/// 2. 创建应用，获取 API Key 和 Secret Key
/// 3. 开通 "名片识别" 服务
class BaiduOcrConfig {
  /// 百度 API Key
  /// 在 https://ai.baidu.com/ 创建应用后获取
  static const String apiKey = 'YOUR_API_KEY_HERE';
  
  /// 百度 Secret Key
  /// 在 https://ai.baidu.com/ 创建应用后获取
  static const String secretKey = 'YOUR_SECRET_KEY_HERE';
  
  /// 名片识别 API 地址
  static const String ocrUrl = 'https://aip.baidubce.com/rest/2.0/ocr/v1/business_card';
  
  /// 获取 Token 的地址
  static const String tokenUrl = 'https://aip.baidubce.com/oauth/2.0/token';
  
  /// 检查是否已配置
  static bool get isConfigured => 
    apiKey != 'YOUR_API_KEY_HERE' && 
    secretKey != 'YOUR_SECRET_KEY_HERE';
}
