import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/contact_provider.dart';
import 'providers/record_provider.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'screens/contacts_page.dart';
import 'screens/records_page.dart';

/// 应用主入口函数
void main() async {
  // 确保 Flutter 绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库（可选，延迟加载也可以）
  // await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

/// 应用根组件
/// 负责配置 Provider、路由和主题
class MyApp extends StatelessWidget {
  /// 构造函数
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 MultiProvider 管理多个 Provider
    return MultiProvider(
      providers: [
        // 联系人 Provider
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        
        // 识别记录 Provider
        ChangeNotifierProvider(create: (_) => RecordProvider()),
        
        // 可以在这里添加更多的 Provider
        // ChangeNotifierProvider(create: (_) => SettingsProvider()),
        // ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        // 应用标题
        title: '来电识别',
        
        // 应用描述（用于辅助功能）
        debugShowCheckedModeBanner: false,
        
        // 主题配置
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // 跟随系统主题
        
        // 路由配置
        routes: AppRoutes.getRoutes(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
        
        // 未知路由处理
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('错误'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '页面不存在：${settings.name}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.contactList,
                          (route) => false,
                        );
                      },
                      child: const Text('返回首页'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        
        // 本地化配置（可选）
        // localizationsDelegates: [
        //   GlobalMaterialLocalizations.delegate,
        //   GlobalWidgetsLocalizations.delegate,
        //   GlobalCupertinoLocalizations.delegate,
        // ],
        // supportedLocales: [
        //   Locale('zh', 'CN'), // 简体中文
        //   Locale('en', 'US'), // 英语
        // ],
        
        // 首页
        home: const HomePage(),
      ),
    );
  }
}

/// 首页组件
/// 应用的主页面，包含底部导航栏
class HomePage extends StatefulWidget {
  /// 构造函数
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 当前选中的索引
  int _selectedIndex = 0;

  /// 页面控制器
  final List<Widget> _pages = [
    const HomeContent(),
    const ContactsPage(),
    const RecordsPage(),
    const PlaceholderPage(title: '设置'),
  ];

  /// 底部导航栏项
  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: '首页',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.contacts_outlined),
      activeIcon: Icon(Icons.contacts),
      label: '联系人',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.phone_in_talk_outlined),
      activeIcon: Icon(Icons.phone_in_talk),
      label: '识别记录',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      label: '设置',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// 构建浮动操作按钮
  Widget _buildFloatingActionButton() {
    // 根据不同页面显示不同的 FAB
    switch (_selectedIndex) {
      case 0: // 首页
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.ocrScan);
          },
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('扫描'),
          backgroundColor: AppTheme.primaryColor,
        );
      
      case 1: // 联系人
        return FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.contactAdd);
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.person_add),
        );
      
      default:
        return const SizedBox.shrink();
    }
  }

  /// 显示快捷操作对话框
  void _showQuickActions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('快捷操作'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryColor),
              title: const Text('扫描名片'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 打开 OCR 扫描
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: AppTheme.primaryColor),
              title: const Text('手动添加'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 打开添加联系人表单
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open, color: AppTheme.primaryColor),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 打开相册选择图片
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 显示添加联系人选项
  void _showAddContactOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
              title: const Text('手动输入'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 打开手动输入表单
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryColor),
              title: const Text('扫描名片'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 打开 OCR 扫描
              },
            ),
            ListTile(
              leading: const Icon(Icons.contacts, color: AppTheme.primaryColor),
              title: const Text('导入联系人'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 打开导入功能
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// 首页内容组件
class HomeContent extends StatelessWidget {
  /// 构造函数
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('来电识别'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 打开搜索页面
              // Navigator.pushNamed(context, AppRoutes.search);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // 刷新数据
          await context.read<ContactProvider>().refresh();
          await context.read<RecordProvider>().refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 统计卡片
              _buildStatsCard(context),
              
              const SizedBox(height: 24),
              
              // 最近识别记录
              Text(
                '最近识别',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              
              const SizedBox(height: 12),
              
              _buildRecentRecords(context),
              
              const SizedBox(height: 24),
              
              // 快捷操作
              Text(
                '快捷操作',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              
              const SizedBox(height: 12),
              
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatsCard(BuildContext context) {
    return Consumer<RecordProvider>(
      builder: (context, recordProvider, child) {
        return Card(
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.analytics,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '识别统计',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      '总识别',
                      '${recordProvider.recordsCount}',
                      Icons.phone,
                    ),
                    _buildStatItem(
                      context,
                      '已匹配',
                      '${recordProvider.matchedCount}',
                      Icons.check_circle,
                    ),
                    _buildStatItem(
                      context,
                      '未匹配',
                      '${recordProvider.unmatchedCount}',
                      Icons.help,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建统计项
  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  /// 构建最近识别记录
  Widget _buildRecentRecords(BuildContext context) {
    return Consumer<RecordProvider>(
      builder: (context, recordProvider, child) {
        if (recordProvider.records.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '暂无识别记录',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recordProvider.records.length > 5 
                ? 5 
                : recordProvider.records.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final record = recordProvider.records[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.getStatusColor(record.status).withOpacity(0.1),
                  child: Icon(
                    AppTheme.getStatusIcon(record.status),
                    color: AppTheme.getStatusColor(record.status),
                  ),
                ),
                title: Text(
                  record.contactName ?? record.phoneNumber,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  record.contactName != null ? record.phoneNumber : '未知号码',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Text(
                  _formatTime(record.identifiedAt),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  // TODO: 跳转到记录详情页
                  // Navigator.pushNamed(
                  //   context,
                  //   AppRoutes.recordDetail,
                  //   arguments: {'recordId': record.id},
                  // );
                },
              );
            },
          ),
        );
      },
    );
  }

  /// 构建快捷操作
  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionItem(
              context,
              '扫描名片',
              Icons.qr_code_scanner,
              () {
                // TODO: 打开 OCR 扫描
              },
            ),
            _buildQuickActionItem(
              context,
              '添加联系人',
              Icons.person_add,
              () {
                // TODO: 打开添加联系人
              },
            ),
            _buildQuickActionItem(
              context,
              '搜索',
              Icons.search,
              () {
                // TODO: 打开搜索
              },
            ),
            _buildQuickActionItem(
              context,
              '设置',
              Icons.settings,
              () {
                // TODO: 打开设置
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建快捷操作项
  Widget _buildQuickActionItem(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化时间显示
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${time.month}/${time.day}';
    }
  }
}

/// 占位页面组件
/// 用于尚未实现的页面
class PlaceholderPage extends StatelessWidget {
  /// 页面标题
  final String title;

  /// 构造函数
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '$title（开发中）',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '页面正在开发中，敬请期待...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
