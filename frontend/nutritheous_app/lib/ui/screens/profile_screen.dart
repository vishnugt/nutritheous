import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/activity_level.dart';
import '../../models/sex.dart';
import '../../models/user_profile.dart';
import '../../models/user_profile_request.dart';
import '../../state/providers.dart';
import '../widgets/unit_selection_widgets.dart';

/// Profile screen for managing user biometric and activity data
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Imperial unit controllers
  final _heightFeetController = TextEditingController();
  final _heightInchesController = TextEditingController();
  final _weightLbsController = TextEditingController();

  Sex? _selectedSex;
  ActivityLevel? _selectedActivityLevel;
  UnitSystem _unitSystem = UnitSystem.metric;
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _weightLbsController.dispose();
    super.dispose();
  }

  void _initializeFormData(UserProfile profile) {
    if (!_isInitialized) {
      if (profile.age != null) _ageController.text = profile.age.toString();

      // Initialize metric fields (always from backend)
      if (profile.heightCm != null) {
        _heightController.text = profile.heightCm!.toStringAsFixed(1);
        // Also pre-populate imperial fields for convenience
        final feet = UnitConverter.cmToFeet(profile.heightCm!);
        final inches = UnitConverter.cmToInches(profile.heightCm!);
        _heightFeetController.text = feet.toString();
        _heightInchesController.text = inches.toStringAsFixed(1);
      }

      if (profile.weightKg != null) {
        _weightController.text = profile.weightKg!.toStringAsFixed(1);
        // Also pre-populate imperial fields for convenience
        final lbs = UnitConverter.kgToPounds(profile.weightKg!);
        _weightLbsController.text = lbs.toStringAsFixed(1);
      }

      _selectedSex = profile.sex;
      _selectedActivityLevel = profile.activityLevel;
      _isInitialized = true;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      // Convert imperial to metric if needed
      double? heightCm;
      double? weightKg;

      if (_unitSystem == UnitSystem.metric) {
        heightCm = _heightController.text.isEmpty ? null : double.parse(_heightController.text);
        weightKg = _weightController.text.isEmpty ? null : double.parse(_weightController.text);
      } else {
        // Convert imperial to metric
        if (_heightFeetController.text.isNotEmpty && _heightInchesController.text.isNotEmpty) {
          heightCm = UnitConverter.heightToCm(
            feet: int.parse(_heightFeetController.text),
            inches: double.parse(_heightInchesController.text),
          );
        }
        if (_weightLbsController.text.isNotEmpty) {
          weightKg = UnitConverter.poundsToKg(double.parse(_weightLbsController.text));
        }
      }

      final request = UserProfileRequest(
        age: _ageController.text.isEmpty ? null : int.parse(_ageController.text),
        heightCm: heightCm,
        weightKg: weightKg,
        sex: _selectedSex,
        activityLevel: _selectedActivityLevel,
      );

      final profileService = ref.read(profileServiceProvider);
      await profileService.updateUserProfile(request);

      // Invalidate the provider to refresh all screens using profile data
      ref.invalidate(userProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save profile: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      // Re-throw the error so it can be caught by error monitoring
      rethrow;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        elevation: 0,
      ),
      body: profileAsync.when(
        data: (profile) {
          // Initialize form data with profile on first load
          _initializeFormData(profile);

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card with calories
                  if (profile.estimatedCaloriesBurntPerDay != null)
                    _buildCalorieCard(profile),
                  const SizedBox(height: 24),

                  // Personal Information Section
                  _buildSectionTitle('Personal Information'),
                  const SizedBox(height: 12),
                  _buildAgeField(),
                  const SizedBox(height: 16),
                  _buildSexSelector(),
                  const SizedBox(height: 24),

                  // Physical Information Section
                  _buildSectionTitle('Physical Information'),
                  const SizedBox(height: 12),
                  UnitSystemSelector(
                    unitSystem: _unitSystem,
                    onChanged: (system) {
                      setState(() => _unitSystem = system);
                    },
                  ),
                  const SizedBox(height: 16),
                  HeightInputField(
                    unitSystem: _unitSystem,
                    heightCmController: _heightController,
                    heightFeetController: _heightFeetController,
                    heightInchesController: _heightInchesController,
                    filled: false,
                  ),
                  const SizedBox(height: 16),
                  WeightInputField(
                    unitSystem: _unitSystem,
                    weightKgController: _weightController,
                    weightLbsController: _weightLbsController,
                    filled: false,
                  ),
                  const SizedBox(height: 24),

                  // Activity Level Section
                  _buildSectionTitle('Activity Level'),
                  const SizedBox(height: 12),
                  _buildActivityLevelSelector(),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Save Profile',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && mounted) {
                          await ref.read(currentUserProvider.notifier).logout();
                          if (mounted) {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Logout', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(userProfileProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalorieCard(UserProfile profile) {
    final calories = profile.estimatedCaloriesBurntPerDay!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Calorie Target',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$calories',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'kcal/day',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Daily Calorie Target'),
                  content: const Text(
                    'This is your estimated Total Daily Energy Expenditure (TDEE), '
                    'calculated based on your age, sex, weight, height, and activity level.\n\n'
                    'This represents the total calories you burn in a day and can serve '
                    'as a baseline for your nutrition goals.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Learn more',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAgeField() {
    return TextFormField(
      controller: _ageController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Age',
        hintText: 'Enter your age',
        prefixIcon: const Icon(Icons.cake),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        final age = int.tryParse(value);
        if (age == null) return 'Please enter a valid number';
        if (age < 10 || age > 150) return 'Age must be between 10 and 150';
        return null;
      },
    );
  }

  Widget _buildSexSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sex',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: Sex.values.map((sex) {
            final isSelected = _selectedSex == sex;
            return ChoiceChip(
              label: Text(sex.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedSex = sex);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActivityLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ActivityLevel.values.map((level) {
        final isSelected = _selectedActivityLevel == level;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => setState(() => _selectedActivityLevel = level),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? Colors.blue.shade50 : null,
              ),
              child: Row(
                children: [
                  Radio<ActivityLevel>(
                    value: level,
                    groupValue: _selectedActivityLevel,
                    onChanged: (value) {
                      setState(() => _selectedActivityLevel = value);
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isSelected ? Colors.blue.shade900 : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          level.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
