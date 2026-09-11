import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../constants/app_strings.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

/// Profile-completion screen served at `/complete-profile`.
///
/// Shown when [AuthBloc] emits [ProfileIncomplete] (first Google Sign-In).
/// On successful save the bloc emits [Authenticated] and [app_router.dart]
/// redirects to `/dashboard` automatically.
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentPhoneController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  String? _selectedGrade;

  @override
  void dispose() {
    _nameController.dispose();
    _studentPhoneController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.selectGrade),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
          CompleteProfileSubmitted(
            fullName: _nameController.text.trim(),
            studentPhone: _studentPhoneController.text.trim(),
            parentPhone: _parentPhoneController.text.trim(),
            academicGrade: _selectedGrade!,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      // GoRouter handles redirect on Authenticated; we only show errors here.
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────────────
                    FadeInDown(
                      child: Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_add_alt_1_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInDown(
                      delay: const Duration(milliseconds: 80),
                      child: Center(
                        child: Text(
                          AppStrings.completeYourProfile,
                          style: GoogleFonts.lexend(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FadeInDown(
                      delay: const Duration(milliseconds: 140),
                      child: Center(
                        child: Text(
                          AppStrings.completeProfileSubtitle,
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Full Name ────────────────────────────────────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: _ValidatedField(
                        label: AppStrings.fullName,
                        placeholder: AppStrings.namePlaceholder,
                        controller: _nameController,
                        suffixIcon: Icons.badge_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? AppStrings.fillAllFields
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Student Phone ────────────────────────────────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 260),
                      child: _ValidatedField(
                        label: AppStrings.studentPhone,
                        placeholder: AppStrings.studentPhoneHint,
                        controller: _studentPhoneController,
                        suffixIcon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) =>
                            (v == null || v.trim().length < 10)
                                ? AppStrings.phoneValidationError
                                : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Parent Phone ─────────────────────────────────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 320),
                      child: _ValidatedField(
                        label: AppStrings.parentPhone,
                        placeholder: AppStrings.parentPhoneHint,
                        controller: _parentPhoneController,
                        suffixIcon: Icons.supervisor_account_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) =>
                            (v == null || v.trim().length < 10)
                                ? AppStrings.phoneValidationError
                                : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Academic Grade Dropdown ───────────────────────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 380),
                      child: _GradeDropdown(
                        value: _selectedGrade,
                        onChanged: (v) =>
                            setState(() => _selectedGrade = v),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ── Submit ───────────────────────────────────────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 440),
                      child: PrimaryButton(
                        label: AppStrings.saveAndContinue,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : () => _submit(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [CustomTextField] with Form validation support.
class _ValidatedField extends StatelessWidget {
  const _ValidatedField({
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.validator,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final String placeholder;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: label,
          placeholder: placeholder,
          suffixIcon: suffixIcon,
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
        ),
        // Inline validation message
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, _) {
            final error = validator(value.text);
            if (error == null || value.text.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Text(
                error,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _GradeDropdown extends StatelessWidget {
  const _GradeDropdown({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, right: 4),
          child: Text(
            AppStrings.academicGradeLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3),
              width: value != null ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.04),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppStrings.selectGrade,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(12),
              items: AppStrings.gradeDisplayNames.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
