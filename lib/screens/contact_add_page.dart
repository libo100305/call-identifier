import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';
import '../theme/app_theme.dart';

/// 添加/编辑联系人页面
class ContactAddPage extends StatefulWidget {
  /// 构造函数
  const ContactAddPage({super.key});

  @override
  State<ContactAddPage> createState() => _ContactAddPageState();
}

class _ContactAddPageState extends State<ContactAddPage> {
  /// 表单控制器
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  /// 是否编辑模式
  bool _isEditing = false;
  
  /// 编辑的联系人
  Contact? _editingContact;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args.containsKey('contact')) {
        // 编辑模式
        _editingContact = args['contact'] as Contact;
        _isEditing = true;
        
        // 设置控制器初始值
        _nameController.text = _editingContact!.name;
        _phoneController.text = _editingContact!.phoneNumber;
        _companyController.text = _editingContact!.company ?? '';
        _positionController.text = _editingContact!.position ?? '';
        _emailController.text = _editingContact!.email ?? '';
        _addressController.text = _editingContact!.address ?? '';
      } else if (args.containsKey('phoneNumber')) {
        // 从扫描结果添加
        _phoneController.text = args['phoneNumber'] as String;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑联系人' : '添加联系人'),
        actions: [
          TextButton(
            onPressed: _saveContact,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 头像区域
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryLight,
                    child: Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text[0].toUpperCase()
                          : _phoneController.text.isNotEmpty
                              ? _phoneController.text[0]
                              : '?',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 姓名输入
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '姓名 *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入姓名';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // 电话输入
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '电话号码 *',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入电话号码';
                }
                
                // 验证电话号码格式
                final phoneRegex = RegExp(r'^1[3-9]\d{9}$|^0\d{2,3}-?\d{7,8}$');
                if (!phoneRegex.hasMatch(value)) {
                  return '请输入有效的电话号码';
                }
                
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // 公司输入
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: '公司',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 职位输入
            TextFormField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: '职位',
                prefixIcon: Icon(Icons.work),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 邮箱输入
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '邮箱',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return '请输入有效的邮箱地址';
                  }
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // 地址输入
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '地址',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 保存按钮
            ElevatedButton(
              onPressed: _saveContact,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.primaryColor,
              ),
              child: Text(
                _isEditing ? '更新联系人' : '添加联系人',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            if (_isEditing)
              const SizedBox(height: 12),
            
            if (_isEditing)
              OutlinedButton(
                onPressed: _deleteContact,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text(
                  '删除联系人',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 保存联系人
  void _saveContact() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final contact = Contact(
      id: _isEditing ? _editingContact!.id : null,
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      company: _companyController.text.trim(),
      position: _positionController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (_isEditing) {
      // 更新联系人
      context.read<ContactProvider>().updateContact(contact);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('联系人已更新')),
      );
    } else {
      // 添加联系人
      context.read<ContactProvider>().addContact(contact);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('联系人已添加')),
      );
    }

    // 返回上一页
    Navigator.pop(context);
  }

  /// 删除联系人
  void _deleteContact() async {
    if (!_isEditing || _editingContact?.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除联系人 "${_editingContact!.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<ContactProvider>().deleteContact(_editingContact!.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('联系人已删除')),
      );
      Navigator.pop(context); // 关闭编辑页面
    }
  }
}