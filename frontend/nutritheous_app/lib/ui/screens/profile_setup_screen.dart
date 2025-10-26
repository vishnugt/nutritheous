import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/activity_level.dart';
import '../../models/sex.dart';
import '../../models/user_profile_request.dart';
import '../../state/providers.dart';

enum UnitSystem { metric, imperial }

/// Onboarding screen for setting up user profile during registration
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Form controllers
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Imperial units controllers
  final _heightFeetController = TextEditingController();
  final _heightInchesController = TextEditingController();
  final _weightPoundsController = TextEditingController();

  Sex? _selectedSex;
  ActivityLevel? _selectedActivityLevel;
  UnitSystem _unitSystem = UnitSystem.metric;
  bool _isSaving = false;

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _weightPoundsController.dispose();
    super.dispose();
  }

  // Convert imperial to metric
  double _getHeightInCm() {
    if (_unitSystem == UnitSystem.metric) {
      return double.parse(_heightController.text);
    } else {
      final feet = int.parse(_heightFeetController.text);
      final inches = double.parse(_heightInchesController.text);
      return (feet * 30.48) + (inches * 2.54);
    }
  }

  double _getWeightInKg() {
    if (_unitSystem == UnitSystem.metric) {
      return double.parse(_weightController.text);
    } else {
      final pounds = double.parse(_weightPoundsController.text);
      return pounds * 0.453592;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if all required fields are filled
    if (_selectedSex == null || _selectedActivityLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final request = UserProfileRequest(
        age: int.parse(_ageController.text),
        heightCm: _getHeightInCm(),
        weightKg: _getWeightInKg(),
        sex: _selectedSex,
        activityLevel: _selectedActivityLevel,
      );

      final profileService = ref.read(profileServiceProvider);
      await profileService.updateUserProfile(request);

      if (mounted) {
        // Navigate to home screen after successful setup
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
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

  void _skipSetup() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (_currentStep + 1) / 2,
                        backgroundColor: Colors.grey[200],
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${_currentStep + 1}/2',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _skipSetup,
                      child: const Text('Skip'),
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: PageController(initialPage: _currentStep),
                  onPageChanged: (index) {
                    setState(() => _currentStep = index);
                  },
                  children: [
                    _buildPage1(theme),
                    _buildPage2(theme),
                  ],
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _currentStep--);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () {
                                if (_currentStep == 0) {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _currentStep++);
                                  }
                                } else {
                                  _saveProfile();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                            : Text(_currentStep == 1 ? 'Complete Setup' : 'Continue'),
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
  }

  Widget _buildPage1(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Tell us about yourself',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us calculate your personalized calorie needs',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Age field
          _buildAgeField(),
          const SizedBox(height: 24),

          // Sex selector
          _buildSexSelector(),
          const SizedBox(height: 32),

          // Unit system selector
          _buildUnitSystemSelector(),
          const SizedBox(height: 24),

          // Height field(s)
          if (_unitSystem == UnitSystem.metric)
            _buildHeightField()
          else
            _buildImperialHeightFields(),
          const SizedBox(height: 24),

          // Weight field
          if (_unitSystem == UnitSystem.metric)
            _buildWeightField()
          else
            _buildImperialWeightField(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPage2(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'How active are you?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the option that best describes your typical day',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          _buildActivityLevelSelector(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUnitSystemSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Units',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Metric (cm, kg)'),
                selected: _unitSystem == UnitSystem.metric,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _unitSystem = UnitSystem.metric);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Text('Imperial (ft, lbs)'),
                selected: _unitSystem == UnitSystem.imperial,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _unitSystem = UnitSystem.imperial);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgeField() {
    return TextFormField(
      controller: _ageController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Age',
        hintText: 'e.g. 25',
        prefixIcon: const Icon(Icons.cake),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your age';
        }
        final age = int.tryParse(value);
        if (age == null) return 'Please enter a valid number';
        if (age < 10 || age > 150) return 'Age must be between 10 and 150';
        return null;
      },
    );
  }

  Widget _buildHeightField() {
    return TextFormField(
      controller: _heightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Height (cm)',
        hintText: 'e.g. 175',
        prefixIcon: const Icon(Icons.height),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your height';
        }
        final height = double.tryParse(value);
        if (height == null) return 'Please enter a valid number';
        if (height < 50 || height > 300) {
          return 'Height must be between 50 and 300 cm';
        }
        return null;
      },
    );
  }

  Widget _buildImperialHeightFields() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _heightFeetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Feet',
              hintText: '5',
              prefixIcon: const Icon(Icons.height),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              final feet = int.tryParse(value);
              if (feet == null) return 'Invalid';
              if (feet < 2 || feet > 9) {
                return 'Must be 2-9';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _heightInchesController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Inches',
              hintText: '9',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              final inches = double.tryParse(value);
              if (inches == null) return 'Invalid';
              if (inches < 0 || inches >= 12) {
                return 'Must be 0-11.9';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeightField() {
    return TextFormField(
      controller: _weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Weight (kg)',
        hintText: 'e.g. 70',
        prefixIcon: const Icon(Icons.monitor_weight),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your weight';
        }
        final weight = double.tryParse(value);
        if (weight == null) return 'Please enter a valid number';
        if (weight < 10 || weight > 500) {
          return 'Weight must be between 10 and 500 kg';
        }
        return null;
      },
    );
  }

  Widget _buildImperialWeightField() {
    return TextFormField(
      controller: _weightPoundsController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Weight (lbs)',
        hintText: 'e.g. 154',
        prefixIcon: const Icon(Icons.monitor_weight),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your weight';
        }
        final weight = double.tryParse(value);
        if (weight == null) return 'Please enter a valid number';
        if (weight < 20 || weight > 1100) {
          return 'Weight must be between 20 and 1100 lbs';
        }
        return null;
      },
    );
  }

  Widget _buildSexSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sex',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActivityLevelSelector() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ActivityLevel.values.map((level) {
        final isSelected = _selectedActivityLevel == level;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => setState(() => _selectedActivityLevel = level),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.grey.shade300,
                  width: isSelected ? 2.5 : 1.5,
                ),
                borderRadius: BorderRadius.circular(16),
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.08)
                    : Colors.grey[50],
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
                            fontSize: 17,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          level.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? Colors.grey[700]
                                : Colors.grey.shade600,
                            height: 1.4,
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
