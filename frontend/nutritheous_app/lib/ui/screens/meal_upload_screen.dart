import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/meal.dart';
import '../../state/providers.dart';

class MealUploadScreen extends ConsumerStatefulWidget {
  final VoidCallback? onUploadComplete;

  const MealUploadScreen({super.key, this.onUploadComplete});

  @override
  ConsumerState<MealUploadScreen> createState() => _MealUploadScreenState();
}

class _MealUploadScreenState extends ConsumerState<MealUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _pickedFile;
  MealType _selectedMealType = MealType.breakfast;
  DateTime _selectedDateTime = DateTime.now();
  bool _isUploading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    // On web, only gallery is available
    if (kIsWeb) {
      await _pickImage(ImageSource.gallery);
      return;
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _uploadMeal() async {
    // Validate that at least one of image or description is provided
    final hasImage = _pickedFile != null;
    final hasDescription = _descriptionController.text.trim().isNotEmpty;

    if (!hasImage && !hasDescription) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide either an image or description'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      final meal = await ref.read(mealsListProvider.notifier).uploadMeal(
            imageFile: _pickedFile, // Can be null now
            mealType: _selectedMealType,
            mealTime: _selectedDateTime,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
          );

      if (mounted) {
        // Invalidate meals list to refresh
        ref.invalidate(mealsListProvider);
        ref.invalidate(todayMealsProvider);

        // Start polling for analysis
        _pollForAnalysis(meal.id);

        // Clear the form
        setState(() {
          _pickedFile = null;
          _descriptionController.clear();
          _selectedDateTime = DateTime.now();
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal uploaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back to meals tab if callback provided
        if (widget.onUploadComplete != null) {
          widget.onUploadComplete!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pollForAnalysis(String mealId) async {
    try {
      final mealService = ref.read(mealServiceProvider);
      await mealService.pollMealAnalysis(mealId);

      // Refresh the meals list
      ref.read(mealsListProvider.notifier).refresh();
    } catch (e) {
      // Analysis polling failed, but meal was uploaded
      // User can refresh manually
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        children: [
            // Image Preview
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: _pickedFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: kIsWeb
                            ? Image.network(
                                _pickedFile!.path,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(_pickedFile!.path),
                                fit: BoxFit.cover,
                              ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add meal photo (optional)',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You can also just add a description below',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Meal Type
            Text(
              'Meal Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<MealType>(
              segments: const [
                ButtonSegment(
                  value: MealType.breakfast,
                  label: Text('Breakfast'),
                  icon: Icon(Icons.breakfast_dining),
                ),
                ButtonSegment(
                  value: MealType.lunch,
                  label: Text('Lunch'),
                  icon: Icon(Icons.lunch_dining),
                ),
                ButtonSegment(
                  value: MealType.dinner,
                  label: Text('Dinner'),
                  icon: Icon(Icons.dinner_dining),
                ),
                ButtonSegment(
                  value: MealType.snack,
                  label: Text('Snack'),
                  icon: Icon(Icons.fastfood),
                ),
              ],
              selected: {_selectedMealType},
              onSelectionChanged: (Set<MealType> newSelection) {
                setState(() {
                  _selectedMealType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),

            // Date & Time
            Text(
              'Date & Time',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedDateTime)),
              trailing: const Icon(Icons.edit),
              onTap: _selectDateTime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outline),
              ),
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              'Description (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add details to help AI analyze better (e.g., "coffee with sugar", "grilled chicken")',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'e.g., black coffee, 2 eggs with toast...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              maxLength: 50,
            ),
            const SizedBox(height: 32),

            // Upload Button
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadMeal,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Upload Meal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      );
  }
}
