import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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
/// 负责名片图像的 OCR 识别和信息提取（使用 Google ML Kit）
class OcrService {
  /// 文本识别器实例
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// 从图像文件识别文本
  /// 使用 Google ML Kit 进行离线 OCR 识别
  Future<OcrResult> recognizeImage(String imagePath) async {
    try {
      // 检查文件是否存在
      if (!await File(imagePath).exists()) {
        return OcrResult(
          success: false,
          errorMessage: '图片文件不存在',
        );
      }

      // 创建输入图像
      final inputImage = InputImage.fromFilePath(imagePath);

      // 执行文本识别
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // 提取所有文本
      String fullText = recognizedText.text;
      
      if (fullText.isEmpty) {
        return OcrResult(
          success: false,
          errorMessage: '未识别到文本',
          rawText: '',
        );
      }

      // 解析文本提取联系人信息
      Contact contact = parseOcrText(fullText);
      
      // 计算置信度
      double confidence = _calculateConfidence(recognizedText);

      return OcrResult(
        success: true,
        contact: contact,
        rawText: fullText,
        confidence: confidence,
      );
    } catch (e) {
      print('OCR 识别失败：$e');
      return OcrResult(
        success: false,
        errorMessage: '识别过程出错：$e',
      );
    }
  }

  /// 从图像中提取电话号码
  /// 专门用于识别座机来电显示界面的电话号码
  Future<String?> extractPhoneNumber(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // 提取所有文本块
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          // 尝试从每一行提取电话号码
          String? phone = _extractPhoneFromLine(line.text);
          if (phone != null && phone.isNotEmpty) {
            return phone;
          }
        }
      }

      return null;
    } catch (e) {
      print('提取电话号码失败：$e');
      return null;
    }
  }

  /// 从文本行中提取电话号码
  String? _extractPhoneFromLine(String text) {
    // 移除空格和特殊字符
    String cleaned = text.replaceAll(RegExp(r'[\s\-]'), '');
    
    // 匹配固定电话号码格式（区号 + 号码）
    final landlineRegex = RegExp(r'(0\d{2,3})?(\d{7,8})');
    final match = landlineRegex.firstMatch(cleaned);
    
    if (match != null) {
      String areaCode = match.group(1) ?? '';
      String phoneNumber = match.group(2) ?? '';
      
      // 组合成标准格式
      if (areaCode.isNotEmpty) {
        return '$areaCode-$phoneNumber';
      }
      return phoneNumber;
    }
    
    return null;
  }

  /// 计算整体置信度
  double _calculateConfidence(RecognizedText recognizedText) {
    if (recognizedText.blocks.isEmpty) {
      return 0.0;
    }

    double totalConfidence = 0.0;
    int totalElements = 0;

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        totalConfidence += line.confidence ?? 0.0;
        totalElements++;
      }
    }

    return totalElements > 0 ? (totalConfidence / totalElements * 100) : 0.0;
  }

  /// 解析 OCR 识别的原始文本
  /// 将非结构化的文本转换为结构化的联系人信息
  Contact parseOcrText(String rawText) {
    String? name;
    String? phoneNumber;
    String? company;
    String? position;
    String? email;
    String? address;

    final lines = rawText.split('\n');
    
    for (var line in lines) {
      line = line.trim();
      
      // 姓名匹配
      if (line.contains('姓名') || line.contains('名：')) {
        name = _extractValue(line, ['姓名', '名']);
      }
      
      // 电话匹配
      if (line.contains('电话') || line.contains('手机') || line.contains('Tel')) {
        phoneNumber = _extractValue(line, ['电话', '手机', 'Tel', 'Mobile']);
      }
      
      // 公司匹配
      if (line.contains('公司') || line.contains('单位') || line.contains('Comp')) {
        company = _extractValue(line, ['公司', '单位', 'Comp', 'Company']);
      }
      
      // 职位匹配
      if (line.contains('职位') || line.contains('职务') || line.contains('Pos')) {
        position = _extractValue(line, ['职位', '职务', 'Pos', 'Position']);
      }
      
      // 邮箱匹配
      if (line.contains('邮箱') || line.contains('邮件') || line.contains('@')) {
        email = _extractValue(line, ['邮箱', '邮件', 'Email', 'E-mail']);
        // 如果没有匹配到关键字，尝试直接提取邮箱格式
        if (email == null || email.isEmpty) {
          final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
          final match = emailRegex.firstMatch(line);
          if (match != null) {
            email = match.group(0);
          }
        }
      }
      
      // 地址匹配
      if (line.contains('地址') || line.contains('Addr')) {
        address = _extractValue(line, ['地址', 'Addr', 'Address']);
      }
    }

    // 如果姓名和电话都为空，尝试从第一行提取
    if ((name == null || name.isEmpty) && lines.isNotEmpty) {
      name = lines.first.trim();
    }

    return Contact(
      name: name ?? '未知',
      phoneNumber: phoneNumber ?? '',
      company: company,
      position: position,
      email: email,
      address: address,
    );
  }

  /// 辅助方法：从键值对文本中提取值
  String? _extractValue(String line, List<String> keys) {
    for (var key in keys) {
      final index = line.indexOf(key);
      if (index != -1) {
        var valueStartIndex = index + key.length;
        
        // 跳过冒号、空格等分隔符
        while (valueStartIndex < line.length &&
            (line[valueStartIndex] == ':' ||
                line[valueStartIndex] == '：' ||
                line[valueStartIndex] == ' ')) {
          valueStartIndex++;
        }
        
        if (valueStartIndex < line.length) {
          return line.substring(valueStartIndex).trim();
        }
      }
    }
    return null;
  }

  /// 释放资源
  void dispose() {
    _textRecognizer.close();
  }
}
