import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/meal.dart';
import 'platform_network_image.dart';

/// A card widget that displays meal information in a list
class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MealCard({
    super.key,
    required this.meal,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Image (only show if available)
            if (meal.imageUrl != null && meal.imageUrl!.isNotEmpty)
              Hero(
                tag: 'meal-${meal.id}',
                child: PlatformNetworkImage(
                  imageUrl: meal.imageUrl!,
                  objectName: meal.objectName,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              // Show description text for text-only meals
              Container(
                height: 120,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.secondaryContainer,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 32,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        meal.description ?? 'Text-only meal entry',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

            // Meal Information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal Type and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getMealTypeIcon(meal.mealType ?? MealType.snack),
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getMealTypeName(meal.mealType ?? MealType.snack),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: theme.colorScheme.primary,
                          onPressed: onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Edit meal',
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy - hh:mm a').format(meal.mealTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),

                  // Description (only show if there's also an image, to avoid duplication)
                  if (meal.description != null &&
                      meal.description!.isNotEmpty &&
                      meal.imageUrl != null &&
                      meal.imageUrl!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      meal.description!,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Analysis Status and Nutrition Summary
                  if (meal.isAnalysisComplete && meal.nutrition != null)
                    _buildNutritionSummary(context)
                  else
                    _buildAnalysisStatus(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSummary(BuildContext context) {
    final nutrition = meal.nutrition!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNutritionItem(
          context,
          'Calories',
          nutrition.calories.toStringAsFixed(0),
          'kcal',
          Colors.orange,
        ),
        _buildNutritionItem(
          context,
          'Protein',
          nutrition.protein.toStringAsFixed(1),
          'g',
          Colors.blue,
        ),
        _buildNutritionItem(
          context,
          'Carbs',
          nutrition.carbs.toStringAsFixed(1),
          'g',
          Colors.purple,
        ),
        _buildNutritionItem(
          context,
          'Fat',
          nutrition.fat.toStringAsFixed(1),
          'g',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildNutritionItem(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisStatus(BuildContext context) {
    IconData icon;
    Color color;
    String message;

    switch (meal.analysisStatus) {
      case AnalysisStatus.pending:
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        message = 'Analysis in progress...';
        break;
      case AnalysisStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        message = 'Analysis complete';
        break;
      case AnalysisStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        message = 'Analysis failed';
        break;
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          message,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (meal.isAnalysisPending) ...[
          const SizedBox(width: 8),
          SizedBox(
            height: 12,
            width: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ],
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
}
