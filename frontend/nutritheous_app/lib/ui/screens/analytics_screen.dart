import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/statistics.dart';
import '../../models/user_profile.dart';
import '../../state/providers.dart';

/// Comprehensive analytics dashboard with nutrition insights
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with AutomaticKeepAliveClientMixin {
  String _selectedPeriod = 'week'; // 'week' or 'month'
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _updateDateRange();
  }

  void _updateDateRange() {
    final now = DateTime.now();
    // Normalize to start/end of day to prevent continuous updates
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final daysToSubtract = _selectedPeriod == 'week' ? 7 : 30;
    final startDateTime = now.subtract(Duration(days: daysToSubtract));
    _startDate = DateTime(
      startDateTime.year,
      startDateTime.month,
      startDateTime.day,
      0,
      0,
      0,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);

    // Use the stored date range that only updates when period changes
    final AsyncValue<NutritionSummary> summaryAsync = ref.watch(
      nutritionSummaryProvider(startDate: _startDate, endDate: _endDate),
    );
    final AsyncValue<UserProfile> profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) => summaryAsync.when(
        data: (summary) => _buildOverviewContent(context, summary, profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error.toString()),
    );
  }

  Widget _buildOverviewContent(BuildContext context, NutritionSummary summary, UserProfile profile) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(nutritionSummaryProvider);
        ref.invalidate(userProfileProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Time Period Selector
          _buildPeriodSelector(theme),
          const SizedBox(height: 24),

          // Suggested Calorie Goal Card
          if (profile.estimatedCaloriesBurntPerDay != null) ...[
            _buildCalorieGoalCard(context, profile.estimatedCaloriesBurntPerDay!, summary.avgCaloriesPerDay),
            const SizedBox(height: 24),
          ],

          // Quick Stats Summary
          _buildQuickStats(context, summary),
          const SizedBox(height: 24),

          // Insights Card
          _buildInsightsCard(context, summary),
          const SizedBox(height: 24),

          // Average Daily Nutrition (Macros)
          Text(
            'Daily Averages - Macronutrients',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildAveragesCard(context, summary),
          const SizedBox(height: 24),

          // Micronutrients Section
          Text(
            'Daily Averages - Micronutrients',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildMicronutrientsCard(context, summary),
          const SizedBox(height: 24),

          // Meal Distribution
          Text(
            'Meal Distribution',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildMealDistribution(context, summary),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(ThemeData theme) {
    return Center(
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'week', label: Text('Last 7 Days')),
          ButtonSegment(value: 'month', label: Text('Last 30 Days')),
        ],
        selected: {_selectedPeriod},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _selectedPeriod = newSelection.first;
            _updateDateRange();
          });
        },
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, NutritionSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Meals',
            summary.totalMeals.toString(),
            Icons.restaurant,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Avg Calories',
            summary.avgCaloriesPerDay.toStringAsFixed(0),
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(BuildContext context, NutritionSummary summary) {
    final theme = Theme.of(context);
    final insights = <String>[];

    // Generate insights
    if (summary.totalMeals == 0) {
      insights.add('Start tracking meals to see insights!');
    } else {
      if (summary.highestCalorieDay != null) {
        insights.add(
          'Highest intake: ${summary.highestCalorieDay!.totalCalories} cal on ${DateFormat('MMM dd').format(summary.highestCalorieDay!.date)}',
        );
      }

      if (summary.mostCommonMealType != null) {
        insights.add(
          'Most tracked: ${summary.mostCommonMealType!.mealType.toLowerCase()} (${summary.mostCommonMealType!.percentage.toStringAsFixed(0)}%)',
        );
      }

      final avgProtein = summary.avgProteinPerDay;
      if (avgProtein < 50) {
        insights.add('Consider increasing protein intake');
      } else if (avgProtein > 150) {
        insights.add('High protein diet detected');
      } else {
        insights.add('Balanced protein intake');
      }

      if (summary.mostMealsDay != null) {
        insights.add(
          'Most active day: ${summary.mostMealsDay!.mealCount} meals on ${DateFormat('MMM dd').format(summary.mostMealsDay!.date)}',
        );
      }
    }

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_right,
                      size: 20,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAveragesCard(BuildContext context, NutritionSummary summary) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildNutrientRow(
              'Calories',
              summary.avgCaloriesPerDay.toStringAsFixed(0),
              'kcal',
              Colors.orange,
              Icons.local_fire_department,
            ),
            const Divider(height: 24),
            _buildNutrientRow(
              'Protein',
              summary.avgProteinPerDay.toStringAsFixed(1),
              'g',
              Colors.blue,
              Icons.fitness_center,
            ),
            const Divider(height: 24),
            _buildNutrientRow(
              'Carbs',
              summary.avgCarbsPerDay.toStringAsFixed(1),
              'g',
              Colors.purple,
              Icons.grain,
            ),
            const Divider(height: 24),
            _buildNutrientRow(
              'Fat',
              summary.avgFatPerDay.toStringAsFixed(1),
              'g',
              Colors.red,
              Icons.water_drop,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(unit, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildMealDistribution(
    BuildContext context,
    NutritionSummary summary,
  ) {
    final theme = Theme.of(context);

    if (summary.mealTypeDistribution.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No meal distribution data available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: summary.mealTypeDistribution.map((dist) {
            final color = _getMealTypeColor(dist.mealType);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getMealTypeIcon(dist.mealType),
                            size: 20,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dist.mealType.toLowerCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${dist.count} meals (${dist.percentage.toStringAsFixed(0)}%)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: dist.percentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCalorieGoalCard(BuildContext context, int suggestedCalories, double avgConsumed) {
    final theme = Theme.of(context);
    final difference = avgConsumed - suggestedCalories;
    final percentage = (avgConsumed / suggestedCalories) * 100;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (percentage <= 95) {
      statusColor = Colors.green;
      statusText = 'Under Goal';
      statusIcon = Icons.trending_down;
    } else if (percentage <= 110) {
      statusColor = Colors.orange;
      statusText = 'On Track';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.red;
      statusText = 'Over Goal';
      statusIcon = Icons.trending_up;
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.track_changes, size: 32, color: statusColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Calorie Goal',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$suggestedCalories kcal/day',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${difference > 0 ? "+" : ""}${difference.toStringAsFixed(0)} kcal',
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Avg consumed: ',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '${avgConsumed.toStringAsFixed(0)} kcal/day',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                Text(
                  ' (${percentage.toStringAsFixed(0)}%)',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicronutrientsCard(BuildContext context, NutritionSummary summary) {
    // Calculate averages from daily stats
    final daysCount = summary.dailyStats.length > 0 ? summary.dailyStats.length : 1;

    double totalFiber = 0;
    double totalSugar = 0;
    double totalSaturatedFat = 0;
    double totalSodium = 0;
    double totalCholesterol = 0;

    for (final day in summary.dailyStats) {
      totalFiber += day.totalFiberG ?? 0;
      totalSugar += day.totalSugarG ?? 0;
      totalSaturatedFat += day.totalSaturatedFatG ?? 0;
      totalSodium += day.totalSodiumMg ?? 0;
      totalCholesterol += day.totalCholesterolMg ?? 0;
    }

    final avgFiber = totalFiber / daysCount;
    final avgSugar = totalSugar / daysCount;
    final avgSaturatedFat = totalSaturatedFat / daysCount;
    final avgSodium = totalSodium / daysCount;
    final avgCholesterol = totalCholesterol / daysCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildNutrientRow(
              'Fiber',
              avgFiber.toStringAsFixed(1),
              'g',
              Colors.brown,
              Icons.spa,
            ),
            const Divider(height: 24),
            _buildNutrientRow(
              'Sugar',
              avgSugar.toStringAsFixed(1),
              'g',
              Colors.pink,
              Icons.cake,
            ),
            const Divider(height: 24),
            _buildNutrientRow(
              'Saturated Fat',
              avgSaturatedFat.toStringAsFixed(1),
              'g',
              Colors.deepOrange,
              Icons.warning,
            ),
            const Divider(height: 24),
            _buildNutrientRow(
              'Sodium',
              avgSodium.toStringAsFixed(0),
              'mg',
              Colors.cyan,
              Icons.opacity,
            ),
            const Divider(height: 24),
            _buildNutrientRow(
              'Cholesterol',
              avgCholesterol.toStringAsFixed(0),
              'mg',
              Colors.redAccent,
              Icons.favorite,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading analytics',
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
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toUpperCase()) {
      case 'BREAKFAST':
        return Colors.amber;
      case 'LUNCH':
        return Colors.teal;
      case 'DINNER':
        return Colors.deepPurple;
      case 'SNACK':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toUpperCase()) {
      case 'BREAKFAST':
        return Icons.breakfast_dining;
      case 'LUNCH':
        return Icons.lunch_dining;
      case 'DINNER':
        return Icons.dinner_dining;
      case 'SNACK':
        return Icons.fastfood;
      default:
        return Icons.restaurant;
    }
  }
}
