import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../constants/app_strings.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup(BuildContext context) {
    // NOTE: Email/password signup is superseded by Google Sign-In.
    // This screen is no longer routed to but is kept for reference.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('يرجى استخدام تسجيل الدخول بحساب Google.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go('/dashboard');
        } else if (state is AuthFailure) {
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
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.go('/'),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Header
                        FadeInDown(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.diversity_1,
                              color: Theme.of(context).colorScheme.primary,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInDown(
                          delay: const Duration(milliseconds: 100),
                          child: Text(
                            AppStrings.joinCommunity,
                            style: GoogleFonts.lexend(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeInDown(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            AppStrings.joinCommunitySubtitle,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Form
                        FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: Column(
                            children: [
                              CustomTextField(
                                label: AppStrings.fullName,
                                placeholder: AppStrings.namePlaceholder,
                                suffixIcon: Icons.check_circle,
                                controller: _nameController,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                label: AppStrings.emailAddress,
                                placeholder: AppStrings.emailPlaceholder,
                                controller: _emailController,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                label: AppStrings.createPassword,
                                placeholder: AppStrings.passwordPlaceholder,
                                isPassword: true,
                                suffixIcon: Icons.visibility,
                                controller: _passwordController,
                              ),
                              const SizedBox(height: 24),
                              PrimaryButton(
                                label: AppStrings.startVolunteering,
                                onPressed: isLoading
                                    ? null
                                    : () => _handleSignup(context),
                                isLoading: isLoading,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Footer
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.alreadyHaveAccount,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: Text(
                                  AppStrings.logIn,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
