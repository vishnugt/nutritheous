import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/meal.dart';
import '../../state/providers.dart';

/// Screen for editing meal metadata and nutritional information
class MealEditScreen extends ConsumerStatefulWidget {
  final Meal meal;

  const MealEditScreen({
    Key? key,
    required this.meal,
  }) : super(key: key);

  @override
  ConsumerState<MealEditScreen> createState() => _MealEditScreenState();
}

class _MealEditScreenState extends ConsumerState<MealEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Basic metadata controllers
  late TextEditingController _descriptionController;
  late TextEditingController _servingSizeController;
  late MealType _selectedMealType;
  late DateTime _selectedMealTime;

  // Nutritional data controllers
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _saturatedFatController;
  late TextEditingController _fiberController;
  late TextEditingController _sugarController;
  late TextEditingController _sodiumController;
  late TextEditingController _cholesterolController;

  // Additional metadata controllers
  late TextEditingController _healthNotesController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with current meal data
    _descriptionController = TextEditingController(text: widget.meal.description ?? '');
    _servingSizeController = TextEditingController(text: widget.meal.servingSize ?? '');
    _selectedMealType = widget.meal.mealType ?? MealType.snack;
    _selectedMealTime = widget.meal.mealTime;

    // Nutritional data
    _caloriesController = TextEditingController(
      text: widget.meal.calories?.toString() ?? '',
    );
    _proteinController = TextEditingController(
      text: widget.meal.proteinG?.toStringAsFixed(1) ?? '',
    );
    _carbsController = TextEditingController(
      text: widget.meal.carbohydratesG?.toStringAsFixed(1) ?? '',
    );
    _fatController = TextEditingController(
      text: widget.meal.fatG?.toStringAsFixed(1) ?? '',
    );
    _saturatedFatController = TextEditingController(
      text: widget.meal.saturatedFatG?.toStringAsFixed(1) ?? '',
    );
    _fiberController = TextEditingController(
      text: widget.meal.fiberG?.toStringAsFixed(1) ?? '',
    );
    _sugarController = TextEditingController(
      text: widget.meal.sugarG?.toStringAsFixed(1) ?? '',
    );
    _sodiumController = TextEditingController(
      text: widget.meal.sodiumMg?.toStringAsFixed(0) ?? '',
    );
    _cholesterolController = TextEditingController(
      text: widget.meal.cholesterolMg?.toStringAsFixed(0) ?? '',
    );

    // Additional metadata
    _healthNotesController = TextEditingController(text: widget.meal.healthNotes ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _saturatedFatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    _cholesterolController.dispose();
    _healthNotesController.dispose();
    super.dispose();
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final mealService = ref.read(mealServiceProvider);

      await mealService.updateMeal(
        id: widget.meal.id,
        mealType: _selectedMealType,
        mealTime: _selectedMealTime,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        servingSize: _servingSizeController.text.isNotEmpty ? _servingSizeController.text : null,
        calories: _caloriesController.text.isNotEmpty ? int.tryParse(_caloriesController.text) : null,
        proteinG: _proteinController.text.isNotEmpty ? double.tryParse(_proteinController.text) : null,
        carbohydratesG: _carbsController.text.isNotEmpty ? double.tryParse(_carbsController.text) : null,
        fatG: _fatController.text.isNotEmpty ? double.tryParse(_fatController.text) : null,
        saturatedFatG: _saturatedFatController.text.isNotEmpty ? double.tryParse(_saturatedFatController.text) : null,
        fiberG: _fiberController.text.isNotEmpty ? double.tryParse(_fiberController.text) : null,
        sugarG: _sugarController.text.isNotEmpty ? double.tryParse(_sugarController.text) : null,
        sodiumMg: _sodiumController.text.isNotEmpty ? double.tryParse(_sodiumController.text) : null,
        cholesterolMg: _cholesterolController.text.isNotEmpty ? double.tryParse(_cholesterolController.text) : null,
        healthNotes: _healthNotesController.text.isNotEmpty ? _healthNotesController.text : null,
      );

      // Invalidate meals list to refresh
      ref.invalidate(mealsListProvider);
      ref.invalidate(todayMealsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update meal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Meal'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveMeal,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information Section
            Text(
              'Basic Information',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Meal Type Selector
            DropdownButtonFormField<MealType>(
              value: _selectedMealType,
              decoration: const InputDecoration(
                labelText: 'Meal Type',
                prefixIcon: Icon(Icons.restaurant),
              ),
              items: MealType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMealType = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Meal Time Picker
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedMealTime,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedMealTime),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedMealTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Meal Time',
                  prefixIcon: Icon(Icons.access_time),
                ),
                child: Text(
                  '${_selectedMealTime.toString().split('.')[0]}',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                hintText: 'Enter meal description',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Serving Size
            TextFormField(
              controller: _servingSizeController,
              decoration: const InputDecoration(
                labelText: 'Serving Size',
                prefixIcon: Icon(Icons.scale),
                hintText: 'e.g., 1 cup, 200g',
              ),
            ),
            const SizedBox(height: 32),

            // Macronutrients Section
            Text(
              'Macronutrients',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Calories
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Calories',
                prefixIcon: Icon(Icons.local_fire_department),
                suffixText: 'kcal',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final num = int.tryParse(value);
                  if (num == null || num < 0) return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    decoration: const InputDecoration(
                      labelText: 'Protein',
                      suffixText: 'g',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = double.tryParse(value);
                        if (num == null || num < 0) return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    decoration: const InputDecoration(
                      labelText: 'Carbs',
                      suffixText: 'g',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = double.tryParse(value);
                        if (num == null || num < 0) return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _fatController,
                    decoration: const InputDecoration(
                      labelText: 'Fat',
                      suffixText: 'g',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = double.tryParse(value);
                        if (num == null || num < 0) return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Micronutrients Section
            Text(
              'Micronutrients',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _saturatedFatController,
                    decoration: const InputDecoration(
                      labelText: 'Saturated Fat',
                      suffixText: 'g',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _fiberController,
                    decoration: const InputDecoration(
                      labelText: 'Fiber',
                      suffixText: 'g',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sugarController,
                    decoration: const InputDecoration(
                      labelText: 'Sugar',
                      suffixText: 'g',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _sodiumController,
                    decoration: const InputDecoration(
                      labelText: 'Sodium',
                      suffixText: 'mg',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _cholesterolController,
              decoration: const InputDecoration(
                labelText: 'Cholesterol',
                prefixIcon: Icon(Icons.favorite_border),
                suffixText: 'mg',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 32),

            // Health Notes Section
            Text(
              'Health Notes',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _healthNotesController,
              decoration: const InputDecoration(
                labelText: 'Health Notes',
                prefixIcon: Icon(Icons.info_outline),
                hintText: 'Add any health-related notes',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveMeal,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
