import 'package:admin_panel/core/widgets/add_user_form.dart';
import 'package:admin_panel/core/widgets/settings_form.dart';
import 'package:admin_panel/core/widgets/stat_card.dart';
import 'package:admin_panel/core/widgets/weather_widget.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showAllActivities = false;
  int _selectedTimePeriod = 0; // 0=Week, 1=Month, 2=Year
  final List<bool> _selectedFilters = [
    true,
    false,
    true,
  ]; // New, Completed, Pending

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Badge(
              label: const Text('3'),
              child: const Icon(Icons.notifications),
            ),
            onPressed: () => _showNotifications(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Приветствие с быстрыми действиями
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hello, Admin!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Today is ${DateTime.now().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.amber),
                  color: Colors.green,
                  onPressed: () => _refreshData(),
                  tooltip: 'Refresh Data',
                ),
                IconButton(
                  icon: Text('Settings', style: TextStyle(color: Colors.amber)),
                  color: Colors.green,
                  onPressed: () => _openSettings(context),
                  tooltip: 'Settings',
                ),
              ],
            ),
            const SizedBox(height: 24),
            YandexWeatherWidget(),
            const SizedBox(height: 24),
            // Фильтры и период времени
            Row(
              children: [
                // Фильтры
                FilterChip(
                  label: const Text('New'),
                  selected: _selectedFilters[0],
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedFilters[0] = selected;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Completed'),
                  selected: _selectedFilters[1],
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedFilters[1] = selected;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pending'),
                  selected: _selectedFilters[2],
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedFilters[2] = selected;
                    });
                  },
                ),
                const Spacer(),
                // Период времени
                ToggleButtons(
                  isSelected: [
                    _selectedTimePeriod == 0,
                    _selectedTimePeriod == 1,
                    _selectedTimePeriod == 2,
                  ],
                  onPressed: (int index) {
                    setState(() {
                      _selectedTimePeriod = index;
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Week'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Month'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Year'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Карточки статистики
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildClickableStatCard(
                  title: 'Total Users',
                  value: '1,234',
                  icon: Icons.people,
                  color: Colors.blue,
                  onTap: () => _navigateToUsers(context),
                ),
                _buildClickableStatCard(
                  title: 'Revenue',
                  value: '\$12,345',
                  icon: Icons.attach_money,
                  color: Colors.green,
                  onTap: () => _showRevenueDetails(context),
                ),
                _buildClickableStatCard(
                  title: 'Active Projects',
                  value: '24',
                  icon: Icons.work,
                  color: Colors.orange,
                  onTap: () => _navigateToProjects(context),
                ),
                _buildClickableStatCard(
                  title: 'Tasks',
                  value: '56',
                  icon: Icons.task,
                  color: Colors.purple,
                  onTap: () => _navigateToTasks(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Интерактивный график
            _buildInteractiveChart(),
            const SizedBox(height: 24),

            // Активности с раскрывающимся списком
            _buildActivitiesSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewItem(context),
        tooltip: 'Add New',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddUserForm() {
    print(1);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddUserForm(
          onSubmit: (userData) {
            // Обработка данных пользователя
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User ${userData['name']} added')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildClickableStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: StatCard(title: title, value: value, icon: icon, color: color),
    );
  }

  Widget _buildInteractiveChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interactive Analytics',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              tooltipBehavior: TooltipBehavior(enable: true),
              onDataLabelTapped: (DataLabelTapDetails details) {
                _showChartPointDetails(details.text);
              },
              series: [
                ColumnSeries<ChartData, String>(
                  dataSource: [
                    ChartData('Jan', 35),
                    ChartData('Feb', 28),
                    ChartData('Mar', 34),
                    ChartData('Apr', 32),
                    ChartData('May', 40),
                  ],
                  xValueMapper: (ChartData data, _) => data.month,
                  yValueMapper: (ChartData data, _) => data.value,
                  color: Colors.blue[400],
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  selectionBehavior: SelectionBehavior(
                    enable: true,
                    selectedColor: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection() {
    final activities = [
      {'title': 'New user registered', 'time': '2h ago', 'type': 'new'},
      {
        'title': 'Project "Dashboard UI" completed',
        'time': '5h ago',
        'type': 'completed',
      },
      {
        'title': 'System update v2.3.1 installed',
        'time': '1d ago',
        'type': 'completed',
      },
      {
        'title': 'Payment received from Client A',
        'time': '2d ago',
        'type': 'new',
      },
      {
        'title': 'New task assigned to Team B',
        'time': '3d ago',
        'type': 'pending',
      },
      {
        'title': 'Database backup completed',
        'time': '4d ago',
        'type': 'completed',
      },
      {
        'title': 'New feature request added',
        'time': '5d ago',
        'type': 'pending',
      },
    ];

    final filteredActivities = activities.where((activity) {
      if (activity['type'] == 'new') return _selectedFilters[0];
      if (activity['type'] == 'completed') return _selectedFilters[1];
      if (activity['type'] == 'pending') return _selectedFilters[2];
      return false;
    }).toList();

    final displayedActivities = _showAllActivities
        ? filteredActivities
        : filteredActivities.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Recent Activities',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAllActivities = !_showAllActivities;
                  });
                },
                child: Text(_showAllActivities ? 'Show Less' : 'Show All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (displayedActivities.isEmpty)
            const Center(child: Text('No activities found'))
          else
            ...displayedActivities.map((activity) {
              return InkWell(
                onTap: () => _showActivityDetails(activity['title'] as String),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getActivityColor(
                            activity['type'] as String,
                          ).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getActivityIcon(activity['type'] as String),
                          size: 20,
                          color: _getActivityColor(activity['type'] as String),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activity['title'] as String),
                            const SizedBox(height: 4),
                            Text(
                              activity['time'] as String,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'new':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'new':
        return Icons.fiber_new;
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.notifications;
    }
  }

  // Методы обработки действий
  void _refreshData() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Refreshing data...')));
  }

  void _navigateToUsers(BuildContext context) {
    // Навигация к списку пользователей
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Users'),
        content: const Text('Would you like to view all users?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Здесь была бы навигация к экрану пользователей
            },
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  void _showRevenueDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Revenue Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('\$12,345 total revenue'),
            const SizedBox(height: 8),
            const Text('+12% from last month'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetails(String title) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Selected: $title')));
  }

  void _showChartPointDetails(String point) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chart Point'),
        content: Text('Selected: $point'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: const [
              ListTile(
                title: Text('New message from support'),
                subtitle: Text('2 min ago'),
              ),
              ListTile(
                title: Text('System update available'),
                subtitle: Text('1 hour ago'),
              ),
              ListTile(
                title: Text('New user registered'),
                subtitle: Text('3 hours ago'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) {
    final initialSettings = {
      'title': 'Admin Panel',
      'itemsPerPage': 10,
      'darkMode': false,
      'notificationsEnabled': true,
      'themeColor': 'Blue',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: SettingsForm(
          initialData: initialSettings,
          onSave: (newSettings) {
            // Применяем новые настройки
            print('New settings: $newSettings');
          },
        ),
      ),
    );
  }

  void _navigateToProjects(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigating to Projects...')));
  }

  void _navigateToTasks(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigating to Tasks...')));
  }

  void _createNewItem(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create New',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('New User'),
              onTap: () {
                _showAddUserForm();
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('New Project'),
              onTap: () {
                Navigator.pop(context);
                _showSnackbar('Create New Project');
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('New Task'),
              onTap: () {
                Navigator.pop(context);
                _showSnackbar('Create New Task');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class ChartData {
  final String month;
  final double value;

  ChartData(this.month, this.value);
}
