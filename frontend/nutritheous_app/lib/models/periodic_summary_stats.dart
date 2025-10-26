import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'periodic_summary_stats.g.dart';

/// Combined statistics for multiple time periods
@JsonSerializable()
class PeriodicSummaryStats extends Equatable {
  final PeriodStats week;
  final PeriodStats month;
  final PeriodStats sixMonths;

  const PeriodicSummaryStats({
    required this.week,
    required this.month,
    required this.sixMonths,
  });

  factory PeriodicSummaryStats.fromJson(Map<String, dynamic> json) =>
      _$PeriodicSummaryStatsFromJson(json);

  Map<String, dynamic> toJson() => _$PeriodicSummaryStatsToJson(this);

  @override
  List<Object?> get props => [week, month, sixMonths];
}

/// Statistics for a single time period
@JsonSerializable()
class PeriodStats extends Equatable {
  final int totalMeals;
  final int totalDays;
  final int activeDays;
  final double avgCalories;
  final double totalCalories;
  final double avgProtein;
  final double avgCarbs;
  final double avgFat;

  const PeriodStats({
    required this.totalMeals,
    required this.totalDays,
    required this.activeDays,
    required this.avgCalories,
    required this.totalCalories,
    required this.avgProtein,
    required this.avgCarbs,
    required this.avgFat,
  });

  factory PeriodStats.fromJson(Map<String, dynamic> json) =>
      _$PeriodStatsFromJson(json);

  Map<String, dynamic> toJson() => _$PeriodStatsToJson(this);

  @override
  List<Object?> get props => [
        totalMeals,
        totalDays,
        activeDays,
        avgCalories,
        totalCalories,
        avgProtein,
        avgCarbs,
        avgFat,
      ];
}
