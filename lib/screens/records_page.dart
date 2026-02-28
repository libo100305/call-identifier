import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/identification_record.dart';
import '../providers/record_provider.dart';
import '../widgets/empty_widget.dart';

/// 历史记录页面
class RecordsPage extends StatefulWidget {
  /// 构造函数
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  /// 搜索控制器
  final TextEditingController _searchController = TextEditingController();
  
  /// 是否正在搜索
  bool _isSearching = false;
  
  /// 筛选类型
  String _filterType = 'all'; // all, matched, unmatched

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
                  hintText: '搜索记录...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text('识别记录'),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterType = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('全部记录'),
              ),
              const PopupMenuItem(
                value: 'matched',
                child: Text('已匹配'),
              ),
              const PopupMenuItem(
                value: 'unmatched',
                child: Text('未匹配'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<RecordProvider>(
        builder: (context, recordProvider, child) {
          if (recordProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<IdentificationRecord> records = recordProvider.records;
          
          // 应用筛选
          if (_filterType == 'matched') {
            records = records.where((r) => r.contactName != null).toList();
          } else if (_filterType == 'unmatched') {
            records = records.where((r) => r.contactName == null).toList();
          }
          
          // 应用搜索
          if (_isSearching && _searchController.text.isNotEmpty) {
            final query = _searchController.text.toLowerCase();
            records = records.where((record) {
              return record.phoneNumber.contains(query) ||
                  (record.contactName != null && 
                   record.contactName!.toLowerCase().contains(query));
            }).toList();
          }

          if (records.isEmpty) {
            return EmptyWidget(
              icon: Icons.history,
              title: '暂无记录',
              subtitle: '识别记录将显示在这里',
            );
          }

          return RefreshIndicator(
            onRefresh: () => recordProvider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return _buildRecordTile(context, record);
              },
            ),
          );
        },
      ),
    );
  }

  /// 构建记录列表项
  Widget _buildRecordTile(BuildContext context, IdentificationRecord record) {
    bool isMatched = record.contactName != null;
    
    return Dismissible(
      key: Key(record.id.toString()),
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
            content: const Text('确定要删除这条识别记录吗？'),
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
        context.read<RecordProvider>().deleteRecord(record.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已删除记录')),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isMatched 
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          child: Icon(
            isMatched ? Icons.person : Icons.phone_in_talk,
            color: isMatched 
                ? Colors.green
                : Colors.orange,
          ),
        ),
        title: Text(
          isMatched ? (record.contactName ?? '未知') : '未知号码',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(record.phoneNumber),
            const SizedBox(height: 2),
            Text(
              _formatDateTime(record.identifiedAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: isMatched
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.help_outline, color: Colors.orange),
        onTap: () {
          _showRecordDetail(context, record);
        },
      ),
    );
  }

  /// 显示记录详情
  void _showRecordDetail(BuildContext context, IdentificationRecord record) {
    bool isMatched = record.contactName != null;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isMatched 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  child: Icon(
                    isMatched ? Icons.person : Icons.phone_in_talk,
                    color: isMatched 
                        ? Colors.green
                        : Colors.orange,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMatched ? (record.contactName ?? '未知') : '未知号码',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.phoneNumber,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Divider(height: 32),
            
            _buildInfoRow(
              '识别时间',
              _formatDateTime(record.identifiedAt),
            ),
            
            if (isMatched)
              _buildInfoRow(
                '状态',
                '已匹配',
                valueColor: Colors.green,
              )
            else
              _buildInfoRow(
                '状态',
                '未匹配',
                valueColor: Colors.orange,
              ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!isMatched)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/contact-add',
                          arguments: {'phoneNumber': record.phoneNumber},
                        );
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('添加为联系人'),
                    ),
                  ),
                if (!isMatched) const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<RecordProvider>().deleteRecord(record.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已删除记录')),
                      );
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('删除记录'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    }
  }
}
