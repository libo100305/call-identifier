import 'dart:io';
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
/// 负责名片图像的 OCR 识别和信息提取（使用国内 PaddleOCR 方案）
class OcrService {
  /// 从图像文件识别文本
  /// 使用 PaddleOCR 进行离线 OCR 识别
  Future<OcrResult> recognizeImage(String imagePath) async {
    try {
      // 检查文件是否存在
      if (!await File(imagePath).exists()) {
        return OcrResult(
          success: false,
          errorMessage: '图片文件不存在',
        );
      }

      // 由于 PaddleOCR 插件可能需要额外配置，
      // 这里先使用模拟数据演示功能
      // 实际使用时需要集成 PaddleOCR Flutter 插件
      
      // 模拟识别结果
      await Future.delayed(const Duration(seconds: 1));
      
      // 这里应该调用 PaddleOCR 进行实际识别
      // 暂时返回模拟数据
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
    } catch (e) {
      return OcrResult(
        success: false,
        errorMessage: '识别失败: $e',
      );
    }
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
    // PaddleOCR 不需要手动释放资源
  }
}
