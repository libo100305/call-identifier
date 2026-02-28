import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_widget.dart';
import '../widgets/loading_widget.dart';

/// 联系人列表页面
class ContactsPage extends StatefulWidget {
  /// 构造函数
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  /// 搜索控制器
  final TextEditingController _searchController = TextEditingController();
  
  /// 是否正在搜索
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '搜索联系人...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text('联系人'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Consumer<ContactProvider>(
        builder: (context, contactProvider, child) {
          if (contactProvider.isLoading) {
            return const LoadingWidget();
          }

          List<Contact> contacts = contactProvider.contacts;
          
          // 如果在搜索，过滤结果
          if (_isSearching && _searchController.text.isNotEmpty) {
            final query = _searchController.text.toLowerCase();
            contacts = contacts.where((contact) {
              return contact.name.toLowerCase().contains(query) ||
                  contact.phoneNumber.contains(query) ||
                  (contact.company != null && 
                   contact.company!.toLowerCase().contains(query));
            }).toList();
          }

          if (contacts.isEmpty) {
            return EmptyWidget(
              icon: Icons.contacts_outlined,
              title: _isSearching ? '未找到联系人' : '暂无联系人',
              subtitle: _isSearching 
                  ? '尝试其他关键词' 
                  : '点击右上角导入联系人',
            );
          }

          return RefreshIndicator(
            onRefresh: () => contactProvider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return _buildContactTile(context, contact);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/contact-add');
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  /// 构建联系人列表项
  Widget _buildContactTile(BuildContext context, Contact contact) {
    return Dismissible(
      key: Key(contact.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除联系人"${contact.name}"吗？'),
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
      },
      onDismissed: (direction) {
        context.read<ContactProvider>().deleteContact(contact.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除 ${contact.name}'),
            action: SnackBarAction(
              label: '撤销',
              onPressed: () {
                context.read<ContactProvider>().addContact(contact);
              },
            ),
          ),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryLight,
          child: Text(
            contact.name.isNotEmpty ? contact.name[0] : '?',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        title: Text(
          contact.name.isNotEmpty ? contact.name : '未知',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(contact.phoneNumber),
            if (contact.company != null && contact.company!.isNotEmpty)
              Text(
                contact.company!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('编辑'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('删除'),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.pushNamed(
                context,
                '/contact-add',
                arguments: {'contact': contact},
              );
            } else if (value == 'delete') {
              context.read<ContactProvider>().deleteContact(contact.id!);
            }
          },
        ),
        onTap: () {
          _showContactDetail(context, contact);
        },
      ),
    );
  }

  /// 显示联系人详情
  void _showContactDetail(BuildContext context, Contact contact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部
              Center(
                child: Text(
                  contact.name.isNotEmpty ? contact.name : '未知',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 姓名
              Center(
                child: Text(
                  contact.name.isNotEmpty ? contact.name : '未知',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              // 详细信息
              _buildDetailItem(
                icon: Icons.phone,
                label: '电话号码',
                value: contact.phoneNumber,
              ),
              if (contact.company != null && contact.company!.isNotEmpty)
                _buildDetailItem(
                  icon: Icons.business,
                  label: '公司',
                  value: contact.company!,
                ),
              if (contact.position != null && contact.position!.isNotEmpty)
                _buildDetailItem(
                  icon: Icons.work,
                  label: '职位',
                  value: contact.position!,
                ),
              if (contact.email != null && contact.email!.isNotEmpty)
                _buildDetailItem(
                  icon: Icons.email,
                  label: '邮箱',
                  value: contact.email!,
                ),
              if (contact.address != null && contact.address!.isNotEmpty)
                _buildDetailItem(
                  icon: Icons.location_on,
                  label: '地址',
                  value: contact.address!,
                ),
              
              const SizedBox(height: 24),
              
              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/contact-add',
                        arguments: {'contact': contact},
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('编辑'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<ContactProvider>().deleteContact(contact.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已删除联系人')),
                      );
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('删除'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建详情项
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 显示更多选项
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.import_contacts, color: AppTheme.primaryColor),
              title: const Text('导入联系人'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/camera-scan');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: AppTheme.primaryColor),
              title: const Text('导出联系人'),
              onTap: () {
                // TODO: 实现导出功能
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
