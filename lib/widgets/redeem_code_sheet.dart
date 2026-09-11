import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/subscription/subscription_cubit.dart';
import '../constants/app_strings.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public helper to open the sheet
// ─────────────────────────────────────────────────────────────────────────────

/// Shows the code-redemption bottom sheet.
///
/// Returns `true` when a code was successfully redeemed so the caller can
/// react (e.g. refresh the playlist list).
Future<bool> showRedeemCodeSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<SubscriptionCubit>(),
      child: const _RedeemCodeSheet(),
    ),
  );
  return result ?? false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet widget
// ─────────────────────────────────────────────────────────────────────────────

class _RedeemCodeSheet extends StatefulWidget {
  const _RedeemCodeSheet();

  @override
  State<_RedeemCodeSheet> createState() => _RedeemCodeSheetState();
}

class _RedeemCodeSheetState extends State<_RedeemCodeSheet> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    await context.read<SubscriptionCubit>().redeemCode(
          user: authState.user,
          code: _codeController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<SubscriptionCubit, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionActive) {
          // Close the sheet and return success.
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green.shade600,
              content: Text(
                AppStrings.codeRedeemedSuccess,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }
        if (state is SubscriptionFailure) {
          // Keep sheet open so user can try again.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: theme.colorScheme.error,
              content: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
          // Reset to initial so the failure doesn't linger.
          context.read<SubscriptionCubit>().reset();
        }
      },
      builder: (context, state) {
        final isLoading = state is SubscriptionLoading;

        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Lock icon + Title
                      FadeInDown(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.lock_open_rounded,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.redeemCodeTitle,
                                    style: GoogleFonts.lexend(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    AppStrings.redeemCodeSubtitle,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.55),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Code input
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: TextFormField(
                          controller: _codeController,
                          autofocus: true,
                          enabled: !isLoading,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            UpperCaseTextFormatter(),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Z0-9\-]')),
                          ],
                          decoration: InputDecoration(
                            labelText: AppStrings.scratchCodeLabel,
                            hintText: 'XXXX-XXXX-XXXX',
                            prefixIcon: const Icon(Icons.confirmation_number_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return AppStrings.enterScratchCode;
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Submit button
                      FadeInUp(
                        delay: const Duration(milliseconds: 180),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    AppStrings.redeemButton,
                                    style: GoogleFonts.lexend(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
// Input formatter: auto-uppercase
// ─────────────────────────────────────────────────────────────────────────────

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
