import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system_trainer/domain/entities/dashboard_stats.dart';
import 'package:learning_management_system_trainer/domain/repositories/dashboard_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';
import 'package:learning_management_system_trainer/domain/screen_stabilizer/screen_stabilizer.dart';
import 'package:fl_chart/fl_chart.dart';

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  return await getIt<DashboardRepository>().getDashboardStats();
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _ChartCard(
                      title: 'Enrollment Trends',
                      child: AspectRatio(
                        aspectRatio: 1.5,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  const FlSpot(0, 3),
                                  const FlSpot(2, 2),
                                  const FlSpot(4, 5),
                                  const FlSpot(6, 3.5),
                                  const FlSpot(8, 4),
                                  const FlSpot(10, 7),
                                ],
                                isCurved: true,
                                color: Theme.of(context).colorScheme.primary,
                                barWidth: 4,
                                dotData: const FlDotData(show: false),
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
                  Expanded(
                    child: _ChartCard(
                      title: 'Course Distribution',
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                color: Theme.of(context).colorScheme.primary,
                                value: 40,
                                title: 'Web',
                                radius: 50,
                                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              PieChartSectionData(
                                color: Theme.of(context).colorScheme.secondary,
                                value: 30,
                                title: 'Business',
                                radius: 50,
                                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              PieChartSectionData(
                                color: Theme.of(context).colorScheme.tertiary,
                                value: 30,
                                title: 'Design',
                                radius: 50,
                                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const _RecentActivityTable(),
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
            _StatCard(title: 'Live Sessions', value: stats.activeLiveSessions.toString(), icon: Icons.live_tv, color: Colors.red),
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
  const _RecentActivityTable();

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
                _activityRow('Course "Flutter Basics" Published', 'Admin Jane', '2 hours ago'),
                _activityRow('New Student Enrolled', 'John Doe', '5 hours ago'),
                _activityRow('Live Session Scheduled', 'Admin Jane', 'Yesterday'),
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
