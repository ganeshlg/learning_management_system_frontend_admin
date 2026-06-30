import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system_trainer/domain/entities/activity.dart';
import 'package:learning_management_system_trainer/domain/entities/dashboard_stats.dart';
import 'package:learning_management_system_trainer/domain/repositories/dashboard_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'package:learning_management_system_trainer/domain/screen_stabilizer/screen_stabilizer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  return await getIt<DashboardRepository>().getDashboardStats();
});

final recentActivitiesProvider = FutureProvider<List<Activity>>((ref) async {
  return await getIt<DashboardRepository>().getRecentActivities();
});

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      body: ScreenStabilizer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard Overview',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              statsAsync.when(
                data: (stats) => _DashboardStatsGrid(stats: stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Error: $e'),
              ),
              const SizedBox(height: 32),
              statsAsync.when(
                data: (stats) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _ChartCard(
                        title: 'Enrollment Trends',
                        child: AspectRatio(
                          aspectRatio: 10,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: true, drawVerticalLine: false),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() >= 0 && value.toInt() < stats.enrollmentTrend.length) {
                                        final month = stats.enrollmentTrend[value.toInt()].month;
                                        // Display only the month name or part of the string
                                        return Text(month.split('-').last, style: const TextStyle(fontSize: 10));
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: stats.enrollmentTrend.asMap().entries.map((e) {
                                    return FlSpot(e.key.toDouble(), e.value.count.toDouble());
                                  }).toList(),
                                  isCurved: true,
                                  color: Theme.of(context).colorScheme.primary,
                                  barWidth: 4,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),
              statsAsync.when(
                data: (stats) => _RecentActivityTable(activities: stats.recentActivities),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Error loading activities: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardStatsGrid extends StatelessWidget {
  final DashboardStats stats;

  const _DashboardStatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1200 ? 5 : (constraints.maxWidth > 800 ? 3 : 2);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _StatCard(title: 'Total Courses', value: stats.totalCourses.toString(), icon: Icons.book, color: Colors.blue),
            _StatCard(title: 'Total Modules', value: stats.totalModules.toString(), icon: Icons.view_module, color: Colors.orange),
            _StatCard(title: 'Total Lessons', value: stats.totalLessons.toString(), icon: Icons.play_lesson, color: Colors.green),
            _StatCard(title: 'Total Students', value: stats.totalStudents.toString(), icon: Icons.people, color: Colors.purple),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class _RecentActivityTable extends StatelessWidget {
  final List<Activity> activities;
  const _RecentActivityTable({required this.activities});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade50),
                  children: const [
                    Padding(padding: EdgeInsets.all(12), child: Text('Activity', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(12), child: Text('User', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(12), child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                ...activities.map((activity) => _activityRow(
                      activity.activity,
                      activity.user,
                      DateFormat('MMM dd, HH:mm').format(activity.timestamp),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _activityRow(String activity, String user, String date) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(activity)),
        Padding(padding: const EdgeInsets.all(12), child: Text(user)),
        Padding(padding: const EdgeInsets.all(12), child: Text(date)),
      ],
    );
  }
}
