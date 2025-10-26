import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/statistics.dart';
import '../../models/user_profile.dart';
import '../../state/providers.dart';

/// Nutrition trends screen with interactive charts
class TrendsScreen extends ConsumerStatefulWidget {
  const TrendsScreen({super.key});

  @override
  ConsumerState<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends ConsumerState<TrendsScreen>
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
    _startDate = DateTime(startDateTime.year, startDateTime.month, startDateTime.day, 0, 0, 0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);

    // Use the stored date range that only updates when period changes
    final AsyncValue<NutritionSummary> summaryAsync = ref.watch(
      nutritionSummaryProvider(
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
    final AsyncValue<UserProfile> profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) => summaryAsync.when(
        data: (summary) => _buildTrendsContent(context, summary, profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error.toString()),
    );
  }

  Widget _buildTrendsContent(BuildContext context, NutritionSummary summary, UserProfile profile) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(nutritionSummaryProvider);
        ref.invalidate(userProfileProvider);
      },
      child: summary.dailyStats.length < 2
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Not enough data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add more meals to see trends over time',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Time Period Selector
                _buildPeriodSelector(theme),
                const SizedBox(height: 24),

                // Nutrition Trends Charts
                _buildNutritionCharts(context, summary, profile),

                const SizedBox(height: 32),

                // Macronutrients Section
                Text(
                  'Macronutrients',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Macronutrient summary cards could go here if needed

                const SizedBox(height: 24),

                // Micronutrients Section
                Text(
                  'Micronutrients',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Micronutrient Trends Charts
                _buildMicronutrientCharts(context, summary),
              ],
            ),
    );
  }

  Widget _buildPeriodSelector(ThemeData theme) {
    return Center(
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: 'week',
            label: Text('Last 7 Days'),
          ),
          ButtonSegment(
            value: 'month',
            label: Text('Last 30 Days'),
          ),
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

  Widget _buildCalorieGoalCard(BuildContext context, int suggestedCalories, NutritionSummary summary) {
    final theme = Theme.of(context);

    // Calculate average consumed calories
    double avgConsumed = 0;
    if (summary.dailyStats.isNotEmpty) {
      final totalCalories = summary.dailyStats.fold<double>(
        0,
        (sum, day) => sum + day.totalCalories,
      );
      avgConsumed = totalCalories / summary.dailyStats.length;
    }

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.track_changes,
                  size: 32,
                  color: statusColor,
                ),
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
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 18,
                        ),
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
                  'Average: ${avgConsumed.toStringAsFixed(0)} kcal',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _buildNutritionCharts(BuildContext context, NutritionSummary summary, UserProfile profile) {
    return Column(
      children: [
        _buildChart(
          context,
          'Calories',
          summary.dailyStats,
          (day) => day.totalCalories.toDouble(),
          Colors.orange,
          'kcal',
          goalValue: profile.estimatedCaloriesBurntPerDay?.toDouble(),
        ),
        const SizedBox(height: 16),
        _buildChart(
          context,
          'Protein',
          summary.dailyStats,
          (day) => day.totalProteinG,
          Colors.blue,
          'g',
        ),
        const SizedBox(height: 16),
        _buildChart(
          context,
          'Carbs',
          summary.dailyStats,
          (day) => day.totalCarbohydratesG,
          Colors.purple,
          'g',
        ),
        const SizedBox(height: 16),
        _buildChart(
          context,
          'Fat',
          summary.dailyStats,
          (day) => day.totalFatG,
          Colors.red,
          'g',
        ),
      ],
    );
  }

  Widget _buildMicronutrientCharts(BuildContext context, NutritionSummary summary) {
    return Column(
      children: [
        _buildChart(
          context,
          'Fiber',
          summary.dailyStats,
          (day) => day.totalFiberG ?? 0.0,
          Colors.brown,
          'g',
        ),
        const SizedBox(height: 16),
        _buildChart(
          context,
          'Sugar',
          summary.dailyStats,
          (day) => day.totalSugarG ?? 0.0,
          Colors.pink,
          'g',
        ),
        const SizedBox(height: 16),
        _buildChart(
          context,
          'Saturated Fat',
          summary.dailyStats,
          (day) => day.totalSaturatedFatG ?? 0.0,
          Colors.deepOrange,
          'g',
        ),
        const SizedBox(height: 16),
        _buildChart(
          context,
          'Sodium',
          summary.dailyStats,
          (day) => day.totalSodiumMg ?? 0.0,
          Colors.cyan,
          'mg',
        ),
        const SizedBox(height: 16),
        _buildChart(
          context,
          'Cholesterol',
          summary.dailyStats,
          (day) => day.totalCholesterolMg ?? 0.0,
          Colors.redAccent,
          'mg',
        ),
      ],
    );
  }

  Widget _buildChart(
    BuildContext context,
    String title,
    List<DailyNutritionStats> stats,
    double Function(DailyNutritionStats) getValue,
    Color color,
    String unit, {
    double? goalValue,
  }) {
    final theme = Theme.of(context);

    // Get data points
    final spots = <FlSpot>[];
    double maxY = 0;
    double minY = double.infinity;

    for (int i = 0; i < stats.length; i++) {
      final value = getValue(stats[i]);
      spots.add(FlSpot(i.toDouble(), value));
      if (value > maxY) maxY = value;
      if (value < minY) minY = value;
    }

    // Include goal value in min/max calculation if provided
    if (goalValue != null) {
      if (goalValue > maxY) maxY = goalValue;
      if (goalValue < minY) minY = goalValue;
    }

    // Handle edge case where all values are the same
    if (maxY == minY) {
      maxY = minY + (minY * 0.2).clamp(10, double.infinity);
      minY = (minY - (minY * 0.2)).clamp(0, double.infinity);
    }

    // Add padding to y-axis
    final range = maxY - minY;
    final yPadding = range * 0.1;
    maxY += yPadding;
    minY = (minY - yPadding).clamp(0, double.infinity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getChartIcon(title),
                  size: 20,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${getValue(stats.last).toStringAsFixed(title == 'Calories' ? 0 : 1)} $unit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: ((maxY - minY) / 4).clamp(1, double.infinity),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        interval: ((maxY - minY) / 4).clamp(1, double.infinity),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: stats.length > 7 ? 2 : 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= stats.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('M/d').format(stats[index].date),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                      left: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: color,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.1),
                      ),
                    ),
                    // Add goal line if provided
                    if (goalValue != null)
                      LineChartBarData(
                        spots: [
                          FlSpot(0, goalValue),
                          FlSpot(stats.length - 1.0, goalValue),
                        ],
                        isCurved: false,
                        color: Colors.green,
                        barWidth: 2,
                        dashArray: [5, 5],
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => color.withOpacity(0.9),
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final index = touchedSpot.x.toInt();
                          if (index < 0 || index >= stats.length) {
                            return null;
                          }
                          final date = DateFormat('MMM dd').format(stats[index].date);
                          final value = touchedSpot.y.toStringAsFixed(
                            title == 'Calories' ? 0 : 1,
                          );
                          return LineTooltipItem(
                            '$date\n$value $unit',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getChartIcon(String title) {
    switch (title) {
      case 'Calories':
        return Icons.local_fire_department;
      case 'Protein':
        return Icons.fitness_center;
      case 'Carbs':
        return Icons.grain;
      case 'Fat':
        return Icons.water_drop;
      case 'Fiber':
        return Icons.spa;
      case 'Sugar':
        return Icons.cake;
      case 'Saturated Fat':
        return Icons.warning;
      case 'Sodium':
        return Icons.opacity;
      case 'Cholesterol':
        return Icons.favorite;
      default:
        return Icons.show_chart;
    }
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
              'Error loading trends',
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
}
