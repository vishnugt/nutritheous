import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/meal.dart';
import '../../state/providers.dart';
import '../widgets/nutrition_info_card.dart';
import '../widgets/platform_network_image.dart';
import 'meal_edit_screen.dart';

class MealDetailScreen extends ConsumerStatefulWidget {
  final String mealId;
  final Meal? meal; // Optional pre-loaded meal to avoid refetching

  const MealDetailScreen({super.key, required this.mealId, this.meal});

  @override
  ConsumerState<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends ConsumerState<MealDetailScreen> {
  bool _useProvidedMeal = true;

  @override
  Widget build(BuildContext context) {
    // If meal was provided and not refreshed, use it; otherwise fetch from API
    final mealAsync = (widget.meal != null && _useProvidedMeal)
        ? AsyncValue.data(widget.meal!)
        : ref.watch(mealProvider(widget.mealId));
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Meal Details'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          // Delete button - only show when meal is loaded
          mealAsync.when(
            data: (meal) => IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete meal',
              onPressed: () => _showDeleteConfirmation(context, meal),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _useProvidedMeal = false;
              });
              ref.invalidate(mealProvider(widget.mealId));
            },
          ),
        ],
      ),
      body: mealAsync.when(
        data: (meal) => _buildMealDetails(context, meal),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildMealDetails(BuildContext context, Meal meal) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: true,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Meal Image (only show if available)
            if (meal.imageUrl != null && meal.imageUrl!.isNotEmpty)
              Hero(
                tag: 'meal-${meal.id}',
                child: PlatformNetworkImage(
                  imageUrl: meal.imageUrl!,
                  objectName: meal.objectName,
                  height: 300,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 300,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 300,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: TextStyle(
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
                height: 200,
                padding: const EdgeInsets.all(32),
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
                        size: 64,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        meal.description ?? 'Text-only meal entry',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Text-only entry',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal Type and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        avatar: Icon(
                          _getMealTypeIcon(meal.mealType ?? MealType.snack),
                          size: 18,
                        ),
                        label: Text(
                          _getMealTypeName(meal.mealType ?? MealType.snack),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy - hh:mm a',
                        ).format(meal.mealTime),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description (only show if there's also an image, to avoid duplication)
                  if (meal.description != null &&
                      meal.description!.isNotEmpty &&
                      meal.imageUrl != null &&
                      meal.imageUrl!.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(meal.description!, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 24),
                  ],

                  // Analysis Status
                  _buildAnalysisStatus(context, meal),
                  const SizedBox(height: 24),

                  // Nutrition Information
                  if (meal.isAnalysisComplete && meal.nutrition != null) ...[
                    Text(
                      'Nutritional Information',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    NutritionInfoCard(nutrition: meal.nutrition!),
                    const SizedBox(height: 24),

                    // Raw Analysis (if available)
                    if (meal.nutrition!.rawAnalysis != null) ...[
                      ExpansionTile(
                        title: const Text('Detailed Analysis'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              meal.nutrition!.rawAnalysis.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                  // Add bottom spacing to prevent overflow
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisStatus(BuildContext context, Meal meal) {
    final theme = Theme.of(context);

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

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            if (meal.isAnalysisPending) ...[
              const Spacer(),
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
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
              'Error loading meal details',
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

  Future<void> _showDeleteConfirmation(BuildContext context, Meal meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text(
          'Are you sure you want to delete this meal? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteMeal(meal);
    }
  }

  Future<void> _deleteMeal(Meal meal) async {
    try {
      final mealService = ref.read(mealServiceProvider);
      await mealService.deleteMeal(meal.id);

      // Invalidate meal lists to refresh
      ref.invalidate(mealsListProvider);
      ref.invalidate(todayMealsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Go back to list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete meal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
