import 'package:flutter/material.dart';

/// Unit system for height and weight measurements
enum UnitSystem { metric, imperial }

/// Helper class for unit conversions
class UnitConverter {
  /// Convert imperial height (feet + inches) to centimeters
  static double heightToCm({required int feet, required double inches}) {
    return (feet * 30.48) + (inches * 2.54);
  }

  /// Convert centimeters to feet (returns integer feet)
  static int cmToFeet(double cm) {
    return (cm / 30.48).floor();
  }

  /// Convert centimeters to remaining inches after feet
  static double cmToInches(double cm) {
    final feet = cmToFeet(cm);
    final remainingCm = cm - (feet * 30.48);
    return remainingCm / 2.54;
  }

  /// Convert pounds to kilograms
  static double poundsToKg(double pounds) {
    return pounds * 0.453592;
  }

  /// Convert kilograms to pounds
  static double kgToPounds(double kg) {
    return kg / 0.453592;
  }
}

/// Reusable unit system selector widget
class UnitSystemSelector extends StatelessWidget {
  final UnitSystem unitSystem;
  final ValueChanged<UnitSystem> onChanged;

  const UnitSystemSelector({
    Key? key,
    required this.unitSystem,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                selected: unitSystem == UnitSystem.metric,
                onSelected: (selected) {
                  if (selected) onChanged(UnitSystem.metric);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Text('Imperial (ft, lbs)'),
                selected: unitSystem == UnitSystem.imperial,
                onSelected: (selected) {
                  if (selected) onChanged(UnitSystem.imperial);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Reusable height input widget that supports both metric and imperial
class HeightInputField extends StatelessWidget {
  final UnitSystem unitSystem;
  final TextEditingController? heightCmController;
  final TextEditingController? heightFeetController;
  final TextEditingController? heightInchesController;
  final bool filled;

  const HeightInputField({
    Key? key,
    required this.unitSystem,
    this.heightCmController,
    this.heightFeetController,
    this.heightInchesController,
    this.filled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (unitSystem == UnitSystem.metric) {
      return TextFormField(
        controller: heightCmController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Height (cm)',
          hintText: 'e.g. 175',
          prefixIcon: const Icon(Icons.height),
          filled: filled,
          fillColor: filled ? Colors.grey[50] : null,
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
          if (height < 30 || height > 300) {
            return 'Height must be between 30 and 300 cm';
          }
          return null;
        },
      );
    } else {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: heightFeetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Feet',
                hintText: '5',
                prefixIcon: const Icon(Icons.height),
                filled: filled,
                fillColor: filled ? Colors.grey[50] : null,
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
                if (feet < 1 || feet > 9) {
                  return 'Must be 1-9';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: heightInchesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Inches',
                hintText: '9',
                filled: filled,
                fillColor: filled ? Colors.grey[50] : null,
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
  }
}

/// Reusable weight input widget that supports both metric and imperial
class WeightInputField extends StatelessWidget {
  final UnitSystem unitSystem;
  final TextEditingController? weightKgController;
  final TextEditingController? weightLbsController;
  final bool filled;

  const WeightInputField({
    Key? key,
    required this.unitSystem,
    this.weightKgController,
    this.weightLbsController,
    this.filled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (unitSystem == UnitSystem.metric) {
      return TextFormField(
        controller: weightKgController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Weight (kg)',
          hintText: 'e.g. 70',
          prefixIcon: const Icon(Icons.monitor_weight),
          filled: filled,
          fillColor: filled ? Colors.grey[50] : null,
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
          if (weight < 1 || weight > 500) {
            return 'Weight must be between 1 and 500 kg';
          }
          return null;
        },
      );
    } else {
      return TextFormField(
        controller: weightLbsController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Weight (lbs)',
          hintText: 'e.g. 154',
          prefixIcon: const Icon(Icons.monitor_weight),
          filled: filled,
          fillColor: filled ? Colors.grey[50] : null,
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
          if (weight < 2 || weight > 1100) {
            return 'Weight must be between 2 and 1100 lbs';
          }
          return null;
        },
      );
    }
  }
}
