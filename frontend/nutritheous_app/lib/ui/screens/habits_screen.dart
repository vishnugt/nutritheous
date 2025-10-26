import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/statistics.dart';
import '../../models/user_profile.dart';
import '../../models/periodic_summary_stats.dart';
import '../../state/providers.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int _selectedDays = 7; // Default to 7 days for calendar view
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: _selectedDays - 1));
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final statsAsync = ref.watch(
      dailyStatsProvider(startDate: startDate, endDate: endDate),
    );
    final profileAsync = ref.watch(userProfileProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dailyStatsProvider);
        ref.invalidate(userProfileProvider);
      },
      child: CustomScrollView(
        slivers: [
          profileAsync.when(
            data: (profile) => statsAsync.when(
              data: (stats) {
                if (stats.isEmpty) {
                  return SliverFillRemaining(
                    child: _buildEmptyState(),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSummaryStatsWrapper(profile),
                      const SizedBox(height: 24),
                      _buildCalendarView(stats, profile),
                    ]),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: _buildErrorState(error.toString()),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDayChip(7, '7 days'),
            _buildDayChip(14, '14 days'),
            _buildDayChip(30, '30 days'),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(int days, String label) {
    final isSelected = _selectedDays == days;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedDays = days);
        }
      },
    );
  }

  Widget _buildSuggestedCaloriesCard(int suggestedCalories) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.track_changes,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Calorie Goal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$suggestedCalories kcal',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _buildColorLegend('At/Under', Colors.green, 10),
                _buildColorLegend('Over', Colors.red, 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorLegend(String label, Color color, double size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(List<DailyNutritionStats> stats, UserProfile profile) {
    // Create a map for quick lookup
    final statsMap = {
      for (var stat in stats)
        DateFormat('yyyy-MM-dd').format(stat.date): stat,
    };

    // Generate all days in the range (reverse order - today at top)
    final now = DateTime.now();
    final days = List.generate(_selectedDays, (index) {
      return DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: index));
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Tracker',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...days.map((day) {
              final dateKey = DateFormat('yyyy-MM-dd').format(day);
              final stat = statsMap[dateKey];
              return _buildDayRow(day, stat, profile);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(DateTime day, DailyNutritionStats? stat, UserProfile profile) {
    final theme = Theme.of(context);
    final isToday = DateUtils.isSameDay(day, DateTime.now());
    final hasMeals = stat != null && stat.mealCount > 0;

    // Calculate calorie status color
    Color? calorieStatusColor;
    if (hasMeals && profile.estimatedCaloriesBurntPerDay != null) {
      final suggestedCalories = profile.estimatedCaloriesBurntPerDay!;
      final consumed = stat!.totalCalories;
      final percentage = (consumed / suggestedCalories);

      if (percentage <= 1.0) {
        // At or under goal (green)
        calorieStatusColor = Colors.green;
      } else {
        // Over goal (red)
        calorieStatusColor = Colors.red;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: calorieStatusColor != null
            ? Border.all(color: calorieStatusColor, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Date column
          SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEE').format(day),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  DateFormat('MMM d').format(day),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Meal count indicator (colored based on calorie status)
          _buildMealCountBadge(stat?.mealCount ?? 0, theme, calorieStatusColor),
          const SizedBox(width: 16),
          // Calories column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasMeals) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: calorieStatusColor ?? Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${stat!.totalCalories} kcal',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: calorieStatusColor,
                        ),
                      ),
                      if (profile.estimatedCaloriesBurntPerDay != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '/ ${profile.estimatedCaloriesBurntPerDay}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _buildMacroChip(
                        'P: ${stat.totalProteinG.toStringAsFixed(0)}g',
                        Colors.blue,
                      ),
                      _buildMacroChip(
                        'C: ${stat.totalCarbohydratesG.toStringAsFixed(0)}g',
                        Colors.purple,
                      ),
                      _buildMacroChip(
                        'F: ${stat.totalFatG.toStringAsFixed(0)}g',
                        Colors.red,
                      ),
                    ],
                  ),
                ] else
                  Text(
                    'No meals logged',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCountBadge(int count, ThemeData theme, Color? calorieStatusColor) {
    // Determine badge color based on calorie status
    Color badgeColor;
    Color textColor;

    if (count == 0) {
      // No meals - grey
      badgeColor = theme.colorScheme.surfaceContainerHighest;
      textColor = theme.colorScheme.onSurface.withOpacity(0.3);
    } else if (calorieStatusColor != null) {
      // Has meals and calorie status - use red/green
      badgeColor = calorieStatusColor;
      textColor = Colors.white;
    } else {
      // Has meals but no calorie goal set - use primary color
      badgeColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.onPrimary;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$count',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildMacroChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSummaryStatsWrapper(UserProfile profile) {
    final theme = Theme.of(context);
    final periodicStatsAsync = ref.watch(periodicSummaryStatsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // TabBar for period selection
            TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Last week'),
                Tab(text: 'Last month'),
                Tab(text: 'Last 6 months'),
              ],
            ),
            const SizedBox(height: 16),
            // TabBarView for content
            SizedBox(
              height: 120,
              child: periodicStatsAsync.when(
                data: (periodicStats) => TabBarView(
                  controller: _tabController,
                  children: [
                    _SummaryTabContent(periodStats: periodicStats.week, totalDays: 7),
                    _SummaryTabContent(periodStats: periodicStats.month, totalDays: 30),
                    _SummaryTabContent(periodStats: periodicStats.sixMonths, totalDays: 180),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(
                  child: Text(
                    'Error loading summary',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getStreakColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No data yet.\nStart logging meals to track your habits!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading habits data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for each summary tab content - displays pre-loaded data
class _SummaryTabContent extends StatelessWidget {
  final PeriodStats periodStats;
  final int totalDays;

  const _SummaryTabContent({
    required this.periodStats,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryStat(
          'Total Meals',
          '${periodStats.totalMeals}',
          Icons.restaurant_menu,
          Colors.green,
        ),
        _buildSummaryStat(
          'Avg Calories',
          '${periodStats.avgCalories.toInt()}',
          Icons.local_fire_department,
          Colors.orange,
        ),
        _buildSummaryStat(
          'Active Days',
          '${periodStats.activeDays}/$totalDays',
          Icons.calendar_today,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildSummaryStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
