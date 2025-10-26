import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/providers.dart';
import '../../models/activity_level.dart';
import '../../models/sex.dart';
import '../../models/user_profile_request.dart';
import '../widgets/unit_selection_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'demo@nutritheous.com');
  final _passwordController = TextEditingController(text: 'demo123');

  // Profile fields (only for registration)
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

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _weightLbsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // For registration, validate profile fields
    if (!_isLogin) {
      // Check metric or imperial fields based on selected unit system
      bool heightFilled = _unitSystem == UnitSystem.metric
          ? _heightController.text.isNotEmpty
          : (_heightFeetController.text.isNotEmpty &&
              _heightInchesController.text.isNotEmpty);

      bool weightFilled = _unitSystem == UnitSystem.metric
          ? _weightController.text.isNotEmpty
          : _weightLbsController.text.isNotEmpty;

      if (_ageController.text.isEmpty ||
          !heightFilled ||
          !weightFilled ||
          _selectedSex == null ||
          _selectedActivityLevel == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all required fields'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final currentUserNotifier = ref.read(currentUserProvider.notifier);

      if (_isLogin) {
        await currentUserNotifier.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        // Convert imperial to metric if needed
        double heightCm;
        double weightKg;

        if (_unitSystem == UnitSystem.metric) {
          heightCm = double.parse(_heightController.text);
          weightKg = double.parse(_weightController.text);
        } else {
          // Convert imperial to metric
          heightCm = UnitConverter.heightToCm(
            feet: int.parse(_heightFeetController.text),
            inches: double.parse(_heightInchesController.text),
          );
          weightKg = UnitConverter.poundsToKg(
            double.parse(_weightLbsController.text),
          );
        }

        // Register user with profile data (always in metric)
        await currentUserNotifier.register(
          _emailController.text.trim(),
          _passwordController.text,
          age: int.parse(_ageController.text),
          heightCm: heightCm,
          weightKg: weightKg,
          sex: _selectedSex,
          activityLevel: _selectedActivityLevel,
        );
      }

      // Check for errors after login/registration
      final userState = ref.read(currentUserProvider);
      if (userState.hasError) {
        throw Exception(userState.error.toString());
      }

      // Check if user is actually logged in
      if (userState.value == null) {
        throw Exception(_isLogin
            ? 'Login failed - no user data returned'
            : 'Registration failed - no user data returned');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isLogin
                  ? 'Login failed: ${e.toString().replaceAll('Exception: ', '')}'
                  : 'Registration failed: ${e.toString().replaceAll('Exception: ', '')}',
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo/Title
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nutritheous',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI-Powered Meal & Nutrition Tracker',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: _isLogin ? TextInputAction.done : TextInputAction.next,
                    onFieldSubmitted: (_) => _isLogin ? _submit() : null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  // Registration-specific fields
                  if (!_isLogin) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Profile Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Help us calculate your daily calorie needs',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Age Field
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake),
                        hintText: 'Enter your age',
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (!_isLogin) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          final age = int.tryParse(value);
                          if (age == null) return 'Please enter a valid number';
                          if (age < 10 || age > 150) {
                            return 'Age must be between 10 and 150';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Sex Selector
                    Column(
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
                    ),
                    const SizedBox(height: 16),

                    // Unit System Selector
                    UnitSystemSelector(
                      unitSystem: _unitSystem,
                      onChanged: (system) {
                        setState(() => _unitSystem = system);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Height Field
                    HeightInputField(
                      unitSystem: _unitSystem,
                      heightCmController: _heightController,
                      heightFeetController: _heightFeetController,
                      heightInchesController: _heightInchesController,
                      filled: false,
                    ),
                    const SizedBox(height: 16),

                    // Weight Field
                    WeightInputField(
                      unitSystem: _unitSystem,
                      weightKgController: _weightController,
                      weightLbsController: _weightLbsController,
                      filled: false,
                    ),
                    const SizedBox(height: 16),

                    // Activity Level Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Activity Level',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        ...ActivityLevel.values.map((level) {
                          final isSelected = _selectedActivityLevel == level;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () => setState(() => _selectedActivityLevel = level),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
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
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            level.displayName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: isSelected ? Colors.blue.shade900 : null,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            level.description,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isSelected
                                                  ? Colors.blue.shade700
                                                  : Colors.grey.shade600,
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
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _isLogin ? 'Login' : 'Register',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Toggle Login/Register
                  TextButton(
                    onPressed: () {
                      setState(() => _isLogin = !_isLogin);
                    },
                    child: Text(
                      _isLogin
                          ? "Don't have an account? Register"
                          : 'Already have an account? Login',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
