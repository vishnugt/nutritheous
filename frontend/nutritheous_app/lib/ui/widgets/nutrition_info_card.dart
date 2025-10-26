import 'package:flutter/material.dart';
import '../../models/nutrition_data.dart';

/// A card widget that displays detailed nutrition information
class NutritionInfoCard extends StatelessWidget {
  final NutritionData nutrition;

  const NutritionInfoCard({
    super.key,
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Calories - Main Focus
            _buildMainNutrient(
              context,
              'Calories',
              nutrition.calories.toStringAsFixed(0),
              'kcal',
              Colors.orange,
              Icons.local_fire_department,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Macronutrients Grid
            Row(
              children: [
                Expanded(
                  child: _buildMacroNutrient(
                    context,
                    'Protein',
                    nutrition.protein.toStringAsFixed(1),
                    'g',
                    Colors.blue,
                    Icons.fitness_center,
                  ),
                ),
                Expanded(
                  child: _buildMacroNutrient(
                    context,
                    'Carbs',
                    nutrition.carbs.toStringAsFixed(1),
                    'g',
                    Colors.purple,
                    Icons.grain,
                  ),
                ),
                Expanded(
                  child: _buildMacroNutrient(
                    context,
                    'Fat',
                    nutrition.fat.toStringAsFixed(1),
                    'g',
                    Colors.red,
                    Icons.water_drop,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Macronutrient Percentage Bars
            _buildNutrientBar(
              context,
              'Protein',
              nutrition.protein,
              _calculateTotal(),
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildNutrientBar(
              context,
              'Carbs',
              nutrition.carbs,
              _calculateTotal(),
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildNutrientBar(
              context,
              'Fat',
              nutrition.fat,
              _calculateTotal(),
              Colors.red,
            ),

            // Additional Nutritional Details
            if (_hasAdditionalNutrients()) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildAdditionalNutrientsSection(context),
            ],

            // Ingredients Section
            if (nutrition.ingredients != null && nutrition.ingredients!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildIngredientsSection(context, nutrition.ingredients!),
            ],

            // Allergens Section
            if (nutrition.allergens != null && nutrition.allergens!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildAllergensSection(context, nutrition.allergens!),
            ],

            // Health Notes Section
            if (nutrition.healthNotes != null && nutrition.healthNotes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildHealthNotesSection(context, nutrition.healthNotes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMainNutrient(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroNutrient(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientBar(
    BuildContext context,
    String label,
    double value,
    double total,
    Color color,
  ) {
    final percentage = total > 0 ? (value / total) * 100 : 0.0;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  double _calculateTotal() {
    // Calculate total grams (protein + carbs + fat)
    return nutrition.protein + nutrition.carbs + nutrition.fat;
  }

  bool _hasAdditionalNutrients() {
    return nutrition.sugarG != null ||
        nutrition.sodiumMg != null ||
        nutrition.saturatedFatG != null ||
        nutrition.fiberG != null ||
        nutrition.cholesterolMg != null;
  }

  Widget _buildAdditionalNutrientsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.science_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Additional Nutrients',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (nutrition.sugarG != null)
              _buildMicronutrientChip(
                'Sugar',
                nutrition.sugarG!.toStringAsFixed(1),
                'g',
                Colors.pink,
                Icons.cake,
              ),
            if (nutrition.sodiumMg != null)
              _buildMicronutrientChip(
                'Sodium',
                nutrition.sodiumMg!.toStringAsFixed(0),
                'mg',
                Colors.amber,
                Icons.water_drop_outlined,
              ),
            if (nutrition.saturatedFatG != null)
              _buildMicronutrientChip(
                'Saturated Fat',
                nutrition.saturatedFatG!.toStringAsFixed(1),
                'g',
                Colors.deepOrange,
                Icons.oil_barrel_outlined,
              ),
            if (nutrition.fiberG != null)
              _buildMicronutrientChip(
                'Fiber',
                nutrition.fiberG!.toStringAsFixed(1),
                'g',
                Colors.green,
                Icons.grass,
              ),
            if (nutrition.cholesterolMg != null)
              _buildMicronutrientChip(
                'Cholesterol',
                nutrition.cholesterolMg!.toStringAsFixed(0),
                'mg',
                Colors.red.shade700,
                Icons.favorite_border,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMicronutrientChip(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(BuildContext context, List<String> ingredients) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Ingredients',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ingredients.map((ingredient) {
            return Chip(
              label: Text(
                ingredient,
                style: const TextStyle(fontSize: 13),
              ),
              backgroundColor: Colors.green.withOpacity(0.1),
              side: BorderSide(
                color: Colors.green.withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAllergensSection(BuildContext context, List<String> allergens) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(
              'Potential Allergens',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allergens.map((allergen) {
            return Chip(
              label: Text(
                allergen,
                style: const TextStyle(fontSize: 13),
              ),
              backgroundColor: Colors.orange.withOpacity(0.1),
              side: BorderSide(
                color: Colors.orange.withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHealthNotesSection(BuildContext context, String healthNotes) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 20,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            Text(
              'Health Notes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  healthNotes,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.blue[900],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
