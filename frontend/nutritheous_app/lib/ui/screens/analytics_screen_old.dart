import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/meal.dart';
import '../../state/providers.dart';

/// Analytics dashboard showing nutrition trends and insights
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: _selectedDays));
    final mealsAsync = ref.watch(mealsByDateRangeProvider(startDate, now));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: mealsAsync.when(
        data: (meals) => _buildAnalytics(context, meals),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildAnalytics(BuildContext context, List<Meal> meals) {
    final theme = Theme.of(context);
    final completedMeals = meals.where((m) => m.isAnalysisComplete).toList();

    return RefreshIndicator(
      onRefresh: () async {
        final now = DateTime.now();
        final startDate = now.subtract(Duration(days: _selectedDays));
        ref.invalidate(mealsByDateRangeProvider(startDate, now));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Time Range Selector
          _buildTimeRangeSelector(theme),
          const SizedBox(height: 24),

          // Summary Cards
          if (completedMeals.isEmpty)
            _buildEmptyState()
          else ...[
            // Overview Stats
            Text(
              'Overview',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildOverviewStats(context, completedMeals),
            const SizedBox(height: 32),

            // Average Daily Nutrition
            Text(
              'Daily Average',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDailyAverageCard(context, completedMeals),
            const SizedBox(height: 32),

            // Meal Type Distribution
            Text(
              'Meal Distribution',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMealTypeDistribution(context, completedMeals),
            const SizedBox(height: 32),

            // Nutrition Breakdown
            Text(
              'Nutrition Breakdown',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildNutritionBreakdown(context, completedMeals),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Range',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 7, label: Text('7 Days')),
                ButtonSegment(value: 14, label: Text('14 Days')),
                ButtonSegment(value: 30, label: Text('30 Days')),
              ],
              selected: {_selectedDays},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _selectedDays = newSelection.first;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStats(BuildContext context, List<Meal> meals) {
    final theme = Theme.of(context);

    double totalCalories = 0;

    for (final meal in meals) {
      if (meal.nutrition != null) {
        totalCalories += meal.nutrition!.calories;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Meals',
            meals.length.toString(),
            Icons.restaurant,
            theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Total Calories',
            totalCalories.toStringAsFixed(0),
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
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyAverageCard(BuildContext context, List<Meal> meals) {
    final theme = Theme.of(context);

    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;

    for (final meal in meals) {
      if (meal.nutrition != null) {
        totalCalories += meal.nutrition!.calories;
        totalProtein += meal.nutrition!.protein;
        totalFat += meal.nutrition!.fat;
        totalCarbs += meal.nutrition!.carbs;
      }
    }

    final avgCalories = totalCalories / _selectedDays;
    final avgProtein = totalProtein / _selectedDays;
    final avgCarbs = totalCarbs / _selectedDays;
    final avgFat = totalFat / _selectedDays;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildNutrientRow(
              'Calories',
              avgCalories.toStringAsFixed(0),
              'kcal',
              Colors.orange,
              Icons.local_fire_department,
            ),
            const Divider(height: 24),
            _buildNutrientRow(
              'Protein',
              avgProtein.toStringAsFixed(1),
              'g',
              Colors.blue,
              Icons.fitness_center,
            ),
            const Divider(height: 24),
            _buildNutrientRow(
              'Carbs',
              avgCarbs.toStringAsFixed(1),
              'g',
              Colors.green,
              Icons.grain,
            ),
            const Divider(height: 24),
            _buildNutrientRow(
              'Fat',
              avgFat.toStringAsFixed(1),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
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
            Text(
              unit,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealTypeDistribution(BuildContext context, List<Meal> meals) {
    final theme = Theme.of(context);

    final Map<MealType, int> distribution = {};
    for (final meal in meals) {
      final mealType = meal.mealType ?? MealType.snack;
      distribution[mealType] = (distribution[mealType] ?? 0) + 1;
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: MealType.values.map((type) {
            final count = distribution[type] ?? 0;
            final percentage = meals.isNotEmpty ? (count / meals.length) * 100 : 0;
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
                          Icon(_getMealTypeIcon(type), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _getMealTypeName(type),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$count meals (${percentage.toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getMealTypeColor(type),
                      ),
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

  Widget _buildNutritionBreakdown(BuildContext context, List<Meal> meals) {
    final theme = Theme.of(context);

    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;

    for (final meal in meals) {
      if (meal.nutrition != null) {
        totalProtein += meal.nutrition!.protein;
        totalFat += meal.nutrition!.fat;
        totalCarbs += meal.nutrition!.carbs;
      }
    }

    final total = totalProtein + totalCarbs + totalFat;
    final proteinPercent = total > 0 ? (totalProtein / total) * 100 : 0.0;
    final carbsPercent = total > 0 ? (totalCarbs / total) * 100 : 0.0;
    final fatPercent = total > 0 ? (totalFat / total) * 100 : 0.0;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMacroPercentageRow(
              'Protein',
              proteinPercent,
              Colors.blue,
              Icons.fitness_center,
            ),
            const SizedBox(height: 16),
            _buildMacroPercentageRow(
              'Carbs',
              carbsPercent,
              Colors.green,
              Icons.grain,
            ),
            const SizedBox(height: 16),
            _buildMacroPercentageRow(
              'Fat',
              fatPercent,
              Colors.red,
              Icons.water_drop,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroPercentageRow(
    String label,
    double percentage,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No meals to analyze',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start logging meals to see your nutrition analytics',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
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
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.breakfast_dining;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.fastfood;
    }
  }

  String _getMealTypeName(MealType type) {
    return type.displayName;
  }

  Color _getMealTypeColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Colors.amber;
      case MealType.lunch:
        return Colors.green;
      case MealType.dinner:
        return Colors.deepPurple;
      case MealType.snack:
        return Colors.pink;
    }
  }
}
