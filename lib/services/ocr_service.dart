import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/contact.dart';

/// OCR 识别服务结果类
/// 封装 OCR 识别的返回结果
class OcrResult {
  /// 是否识别成功
  final bool success;

  /// 识别到的联系人信息
  final Contact? contact;

  /// 错误信息（如果识别失败）
  final String? errorMessage;

  /// 原始识别文本
  final String? rawText;

  /// 置信度 (0-100)
  final double confidence;

  /// OCR 识别结果构造函数
  OcrResult({
    required this.success,
    this.contact,
    this.errorMessage,
    this.rawText,
    this.confidence = 0.0,
  });
}

/// OCR 识别服务类
/// 负责名片图像的 OCR 识别和信息提取
/// 
/// 支持多种 OCR 引擎：
/// 1. 百度 OCR API（推荐，国内稳定）
/// 2. 本地模拟识别（离线演示）
class OcrService {
  // 百度 OCR API 配置（需要申请）
  // 申请地址：https://ai.baidu.com/tech/ocr
  static const String _baiduApiKey = 'YOUR_API_KEY';
  static const String _baiduSecretKey = 'YOUR_SECRET_KEY';
  static const String _baiduOcrUrl = 'https://aip.baidubce.com/rest/2.0/ocr/v1/business_card';

  /// 从图像文件识别文本
  /// 
  /// [imagePath] - 图片文件路径
  /// [useOnlineOcr] - 是否使用在线 OCR（需要联网和 API Key）
  Future<OcrResult> recognizeImage(String imagePath, {bool useOnlineOcr = false}) async {
    try {
      // 检查文件是否存在
      if (!await File(imagePath).exists()) {
        return OcrResult(
          success: false,
          errorMessage: '图片文件不存在',
        );
      }

      if (useOnlineOcr) {
        // 使用百度在线 OCR
        return await _recognizeWithBaiduOcr(imagePath);
      } else {
        // 使用本地模拟识别（离线演示）
        return await _recognizeOffline(imagePath);
      }
    } catch (e) {
      return OcrResult(
        success: false,
        errorMessage: '识别失败: $e',
      );
    }
  }

  /// 使用百度 OCR API 进行识别
  Future<OcrResult> _recognizeWithBaiduOcr(String imagePath) async {
    try {
      // 检查 API Key 是否配置
      if (_baiduApiKey == 'YOUR_API_KEY') {
        return OcrResult(
          success: false,
          errorMessage: '请先配置百度 OCR API Key',
        );
      }

      // 读取图片文件并转为 Base64
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      // 获取 Access Token
      final tokenUrl = 'https://aip.baidubce.com/oauth/2.0/token'
          '?grant_type=client_credentials'
          '&client_id=$_baiduApiKey'
          '&client_secret=$_baiduSecretKey';

      final tokenResponse = await http.post(Uri.parse(tokenUrl));
      if (tokenResponse.statusCode != 200) {
        return OcrResult(
          success: false,
          errorMessage: '获取百度 OCR Token 失败',
        );
      }

      final tokenData = jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      // 调用名片识别 API
      final ocrUrl = '$_baiduOcrUrl?access_token=$accessToken';
      final ocrResponse = await http.post(
        Uri.parse(ocrUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'image': base64Image,
        },
      );

      if (ocrResponse.statusCode == 200) {
        final result = jsonDecode(ocrResponse.body);
        
        if (result['words_result'] != null) {
          final wordsResult = result['words_result'] as Map<String, dynamic>;
          
          // 提取名片信息
          final name = wordsResult['name']?['words'] ?? '';
          final title = wordsResult['title']?['words'] ?? '';
          final mobile = wordsResult['mobile']?['words'] ?? '';
          final tel = wordsResult['tel']?['words'] ?? '';
          final email = wordsResult['email']?['words'] ?? '';
          final company = wordsResult['company']?['words'] ?? '';
          final addr = wordsResult['addr']?['words'] ?? '';

          final contact = Contact(
            name: name.isNotEmpty ? name : '未知姓名',
            phone: mobile.isNotEmpty ? mobile : tel,
            email: email.isNotEmpty ? email : null,
            company: company.isNotEmpty ? company : null,
            position: title.isNotEmpty ? title : null,
            address: addr.isNotEmpty ? addr : null,
            note: '从名片识别导入（百度OCR）',
          );

          return OcrResult(
            success: true,
            contact: contact,
            rawText: result.toString(),
            confidence: 90.0,
          );
        }
      }

      return OcrResult(
        success: false,
        errorMessage: '百度 OCR 识别失败: ${ocrResponse.body}',
      );
    } catch (e) {
      return OcrResult(
        success: false,
        errorMessage: '百度 OCR 调用失败: $e',
      );
    }
  }

  /// 离线识别（模拟数据，用于演示）
  Future<OcrResult> _recognizeOffline(String imagePath) async {
    // 模拟识别延迟
    await Future.delayed(const Duration(seconds: 1));

    // 模拟识别结果
    final mockText = '''
张三
经理
电话：13800138000
邮箱：zhangsan@example.com
公司：科技有限公司
地址：北京市朝阳区xxx路xxx号
''';

    // 解析识别结果
    final contact = _parseContactInfo(mockText);

    return OcrResult(
      success: true,
      contact: contact,
      rawText: mockText,
      confidence: 85.0,
    );
  }

  /// 从识别的文本中解析联系人信息
  Contact _parseContactInfo(String text) {
    String name = '';
    String phone = '';
    String email = '';
    String company = '';
    String position = '';
    String address = '';

    // 按行分割文本
    final lines = text.split('\n');

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      // 提取姓名（通常是第一行或包含"姓名"）
      if (name.isEmpty && !trimmedLine.contains(RegExp(r'[电话邮箱公司地址]'))) {
        if (trimmedLine.length <= 4) {
          name = trimmedLine;
        }
      }

      // 提取职位（包含经理、主管、工程师等关键词）
      if (position.isEmpty && 
          RegExp(r'(经理|主管|工程师|总监|助理|专员|销售|技术)').hasMatch(trimmedLine)) {
        position = trimmedLine;
      }

      // 提取电话号码
      if (phone.isEmpty) {
        final phoneMatch = RegExp(r'(电话|手机|Tel|Phone)[:：]?\s*(\d{11}|\d{3,4}-\d{7,8})')
            .firstMatch(trimmedLine);
        if (phoneMatch != null) {
          phone = phoneMatch.group(2) ?? '';
        } else {
          // 直接匹配11位手机号
          final mobileMatch = RegExp(r'(1\d{10})').firstMatch(trimmedLine);
          if (mobileMatch != null) {
            phone = mobileMatch.group(1) ?? '';
          }
        }
      }

      // 提取邮箱
      if (email.isEmpty) {
        final emailMatch = RegExp(r'[\w.-]+@[\w.-]+\.\w+').firstMatch(trimmedLine);
        if (emailMatch != null) {
          email = emailMatch.group(0) ?? '';
        }
      }

      // 提取公司
      if (company.isEmpty && 
          (trimmedLine.contains('公司') || trimmedLine.contains('企业') || 
           trimmedLine.contains('集团') || trimmedLine.contains('科技'))) {
        company = trimmedLine.replaceAll(RegExp(r'(公司|企业|集团|科技)[:：]?\s*'), '');
      }

      // 提取地址
      if (address.isEmpty && 
          (trimmedLine.contains('地址') || trimmedLine.contains('Addr'))) {
        address = trimmedLine.replaceAll(RegExp(r'(地址|Addr)[:：]?\s*'), '');
      }
    }

    // 如果没有提取到姓名，使用第一行非空文本
    if (name.isEmpty && lines.isNotEmpty) {
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && trimmed.length <= 6) {
          name = trimmed;
          break;
        }
      }
    }

    return Contact(
      name: name.isNotEmpty ? name : '未知姓名',
      phone: phone.isNotEmpty ? phone : '',
      email: email.isNotEmpty ? email : null,
      company: company.isNotEmpty ? company : null,
      position: position.isNotEmpty ? position : null,
      address: address.isNotEmpty ? address : null,
      note: '从名片识别导入',
    );
  }

  /// 释放资源
  void dispose() {
    // 不需要手动释放资源
  }
}
