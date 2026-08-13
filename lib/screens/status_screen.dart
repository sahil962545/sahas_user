import 'dart:async';
import 'package:flutter/material.dart';
import '../services/review_service.dart';

enum StatusState { sending, success, failure }

class StatusScreen extends StatefulWidget {
  final String employeeName;
  final String mobile;
  final String mood;
  final String unitId;
  final VoidCallback onSuccess;

  const StatusScreen({
    super.key,
    required this.employeeName,
    required this.mobile,
    required this.mood,
    required this.unitId,
    required this.onSuccess,
  });

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  StatusState _state = StatusState.sending;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _submitReviewReport();
  }

  Future<void> _submitReviewReport() async {
    setState(() {
      _state = StatusState.sending;
      _errorMessage = null;
    });

    try {
      final success = await ReviewService.submitReview(
        name: widget.employeeName,
        mobile: widget.mobile,
        review: widget.mood,
        unitId: widget.unitId,
      );

      if (success && mounted) {
        setState(() {
          _state = StatusState.success;
        });
        widget.onSuccess(); // Clear fields in HomeScreen
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = StatusState.failure;
          _errorMessage = e
              .toString()
              .replaceFirst('Exception: ', '')
              .replaceFirst('TimeoutException: ', '');
        });
      }
    }
  }

  Widget _buildSendingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
            strokeWidth: 4.0,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Submitting Review...',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            'BHAROSA is uploading your review safely to the cloud. Please keep your device connected.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Glowing Green check mark container
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22C55E).withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF0FDF4),
                border: Border.all(
                  color: const Color(0xFF22C55E).withOpacity(0.4),
                  width: 2.5,
                ),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: Color(0xFF22C55E),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Review Submitted!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            'Your status details have been successfully uploaded and processed. Form fields have been cleared.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 48),
        // Return Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context); // Return to home
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF22C55E).withOpacity(0.5),
                  width: 1.5,
                ),
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Return to Home',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF15803D),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFailureWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Glowing Red warning container
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFEF2F2),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.4),
                  width: 2.5,
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Submission Failed',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            _errorMessage ??
                'An error occurred while attempting to send the report.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 48),

        // Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              // Retry Button
              InkWell(
                onTap: _submitReviewReport,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Retry Submission',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Cancel Button
              InkWell(
                onTap: () {
                  Navigator.pop(
                    context,
                  ); // Return to home (keeps fields filled)
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Cancel & Edit Form',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F5F9), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: AnimatedCrossFade(
                firstChild: _state == StatusState.sending
                    ? _buildSendingWidget()
                    : _buildSuccessWidget(),
                secondChild: _buildFailureWidget(),
                crossFadeState: _state == StatusState.failure
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
