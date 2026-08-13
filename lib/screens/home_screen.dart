import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/review_service.dart';
import 'status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  String? _selectedMood;

  List<Map<String, dynamic>> _units = [];
  String? _selectedUnitId;
  bool _isLoadingUnits = true;
  String? _unitFetchError;

  @override
  void initState() {
    super.initState();
    loadUnits();
  }

  Future<void> loadUnits() async {
    print('[HOME SCREEN] Reloading units API data...');
    setState(() {
      _isLoadingUnits = true;
      _unitFetchError = null;
    });
    try {
      final units = await ReviewService.fetchUnits();
      if (mounted) {
        setState(() {
          _units = units;
          _isLoadingUnits = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _unitFetchError = 'Failed to load units. Tap to retry.';
          _isLoadingUnits = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _mobileController.clear();
      _selectedMood = null;
      _selectedUnitId = null;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      // Navigate to StatusScreen to handle transmission and error retries
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StatusScreen(
            employeeName: _nameController.text.trim(),
            mobile: _mobileController.text.trim(),
            mood: _selectedMood!,
            unitId: _selectedUnitId!,
            onSuccess: () {
              _clearForm();
            },
          ),
        ),
      );
    }
  }

  Widget _buildMoodCard(
    String value,
    String label,
    Color activeColor,
    Color activeBg,
    FormFieldState<String> state,
  ) {
    final isSelected = _selectedMood == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMood = value;
          });
          state.didChange(value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFCBD5E1),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.12),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.split(' ').last, // emoji
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? activeColor : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rotated Full-Bleed Top Banner Image with Zero White Space
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.414,
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Image.asset(
                          'assets/home_banner.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // Form Content Body
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Submit Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Employee Name Input
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Color(0xFF1E293B)),
                          decoration: InputDecoration(
                            labelText: 'Employee Name',
                            labelStyle: const TextStyle(
                              color: Color(0xFF64748B),
                            ),
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF6366F1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFF6366F1),
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFEF4444),
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Employee Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Mobile Number Input
                        TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          style: const TextStyle(color: Color(0xFF1E293B)),
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                            labelStyle: const TextStyle(
                              color: Color(0xFF64748B),
                            ),
                            prefixIcon: const Icon(
                              Icons.phone_android_rounded,
                              color: Color(0xFF6366F1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFF6366F1),
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFEF4444),
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Mobile Number is required';
                            }
                            final cleanValue = value.trim();
                            final regExp = RegExp(r'^[0-9]{10}$');
                            if (!regExp.hasMatch(cleanValue)) {
                              return 'Enter a valid 10-digit mobile number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Unit Dropdown Input
                        if (_isLoadingUnits)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF6366F1),
                                ),
                              ),
                            ),
                          )
                        else if (_unitFetchError != null)
                          Center(
                            child: TextButton.icon(
                              onPressed: loadUnits,
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: Color(0xFF6366F1),
                              ),
                              label: Text(
                                _unitFetchError!,
                                style: const TextStyle(
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ),
                          )
                        else
                          DropdownButtonFormField<String>(
                            value: _selectedUnitId,
                            style: const TextStyle(color: Color(0xFF1E293B)),
                            decoration: InputDecoration(
                              labelText: 'Select Unit',
                              labelStyle: const TextStyle(
                                color: Color(0xFF64748B),
                              ),
                              prefixIcon: const Icon(
                                Icons.business_rounded,
                                color: Color(0xFF6366F1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF6366F1),
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFEF4444),
                                  width: 1.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: _units.map((unit) {
                              return DropdownMenuItem<String>(
                                value: unit['_id']?.toString() ?? '',
                                child: Text(
                                  unit['name']?.toString() ?? '',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedUnitId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a unit';
                              }
                              return null;
                            },
                          ),
                        const SizedBox(height: 24),

                        // Custom Mood FormField Segmented Selection Cards
                        FormField<String>(
                          validator: (value) {
                            if (_selectedMood == null) {
                              return 'Mood is required';
                            }
                            return null;
                          },
                          builder: (FormFieldState<String> state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Mood',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _buildMoodCard(
                                      'Happy',
                                      'Happy 😊',
                                      const Color(0xFF10B981),
                                      const Color(0xFFECFDF5),
                                      state,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildMoodCard(
                                      'Unhappy',
                                      'Unhappy 🙁',
                                      const Color(0xFFF59E0B),
                                      const Color(0xFFFEF3C7),
                                      state,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildMoodCard(
                                      'Emergency',
                                      'Emergency 🚨',
                                      const Color(0xFFEF4444),
                                      const Color(0xFFFEF2F2),
                                      state,
                                    ),
                                  ],
                                ),
                                if (state.hasError) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    state.errorText!,
                                    style: const TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 36),

                        // Submit Action Button
                        InkWell(
                          onTap: _submitForm,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF4F46E5,
                                  ).withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
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
