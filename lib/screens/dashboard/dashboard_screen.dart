import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_nav_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), // Space for Nav Bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar / Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, ${user?.displayName ?? 'Guest'}",
                              style: GoogleFonts.lexend(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.fieldReadyVolunteer,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => context.push('/settings'),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.2),
                                width: 2,
                              ),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDZ4HjCfzl0XhRDFcczg-oV8mO32MnF04acbGjPUmfpN-ttdVrOp0Tktv78WLKrgTAKFVkvMDoC1xcALTUI7-ZDejNmXrJgsDPK1qj1AN47XraDgd0Bs32dI3SN6-5V6JDHmiS9mxTPDHBmKBSAVDA4HS3KvyCLgir0P1f5lIIPHcyjIFqTgt0s49twrnMQMFiHQ0w6aP6u-9bsQ9RLleqkAlxMv4fMn9qs-_MKtawTOjmlCvL_1qj4sDixdk9_RSzdhDQz-VHwFQ',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress Widget
                  FadeInUp(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).shadowColor.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.overallProgress,
                            style: GoogleFonts.lexend(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          CircularPercentIndicator(
                            radius: 80.0,
                            lineWidth: 12.0,
                            animation: true,
                            percent: 0.75,
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "75%",
                                  style: GoogleFonts.lexend(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32.0,
                                  ),
                                ),
                                Text(
                                  l10n.completed,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            backgroundColor: Theme.of(context).dividerColor,
                            progressColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.motivationMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Learning Paths Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Icon(
                          Icons.school,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.learningPaths,
                          style: GoogleFonts.lexend(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Courses List
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildCourseCard(
                        context,
                        title: l10n.disasterRelief,
                        image:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAiGfeU0KbjZHN4o2R6C84VvNEkPRxAqKMEcbYdb3hfakDEibje3igwIYs7ro9eLDgI4hqUt-CBg6rJJcaiF-ubwgHdR9Bsx-qXOHRvccBygjZHSgIFfiHRNw3kCeJFUTG29GEFL5MeU-J8C--Xpkjw6A6KmQzUScFqb8vjJutWpJZYuZX03HOuWU1ZdwLv232mtZjfB38m2_piPnsHhna9edgNE8KTbh6m90_g5gVxLHCtPdUpicHuLPH6kXt-mGzb9dsRsD5Tpw',
                        progress: 0.7,
                        status: l10n.inProgress,
                        statusIcon: Icons.medical_services,
                        subtitle: l10n.remainingModules(3),
                        actionLabel: l10n.resume,
                        onAction: () => context.push('/learning-path'),
                      ),
                      const SizedBox(height: 16),
                      _buildCourseCard(
                        context,
                        title: l10n.communityTeaching,
                        image:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuCYBU3kgMSU0unJPIfQNIKZvYMGSWvMUf6lfQD3ZhVLcYpdjwaGCogcZLTs5YRC6rN85S4f8P6rhCio7fZ3pKc7JHGCmDsA62fzlp6JSoy2Qm0lxnvPjdZKaaCVMy5fFHfc31vnIKlNeqrQ4KxIUbQw-VGT8lEFbo9gpPf7NXBj62JyPqh80BgLdm8aWSmQRU7gI_t0nTUy-MlZx1tSpLREZPkpN6ZEf1yNnfoI1Swyz2S70aNsIkefFnHjKCn86B3CMXysr7uh8A',
                        progress: 0.0,
                        status: l10n.statusNew,
                        statusIcon: Icons.cast_for_education,
                        subtitle: l10n.notStarted,
                        actionLabel: l10n.startLearning,
                        onAction: () {},
                        isSecondary: true,
                      ),
                      const SizedBox(height: 16),
                      _buildCourseCard(
                        context,
                        title: l10n.logisticsSupply,
                        image:
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuALzMUXIl9KMmHP3w9EcIkqxSFg0O_CHYaYl-5txgOB3VVQg89RwwwNtwTEocteiUfLGjHMPunnwov_VBcQdx9g7Or4rDFFb1k_F8_pJsyd4vfwF3JtrTi-tD1ix-VxEGZDKLVEJIz5JftwgesNjKOgYVJQ4YQZxBX1RC8Lzkq1BGvrWiIbMkBSMsKcNdfJYifzV_tgEDM8eFNsdVh8rvhvpNO1vAP2ICqRjEVWcS9FZ5DC_SfsiDu-ZLWIEr_KieTY3WQzsuCtqA',
                        progress: 0.0,
                        status: '',
                        statusIcon: Icons.inventory_2,
                        subtitle: l10n.locked,
                        actionLabel: '',
                        onAction: () {},
                        isLocked: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Nav Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(
                currentIndex: 0,
                onTap: (index) {
                  if (index == 3) {
                    context.push('/settings');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context, {
    required String title,
    required String image,
    required double progress,
    required String status,
    required IconData statusIcon,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
    bool isSecondary = false,
    bool isLocked = false,
  }) {
    return FadeInUp(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Image Section
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(image, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(
                            context,
                          ).colorScheme.shadow.withValues(alpha: 0.54),
                        ],
                      ),
                    ),
                  ),
                  if (!isLocked)
                    Positioned(
                      bottom: 12,
                      left: 16,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surface.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              statusIcon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (status.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.shadow.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  else
                    const Positioned(
                      bottom: 12,
                      left: 16,
                      child: Icon(
                        Icons.inventory_2,
                        color: Colors.white,
                        size: 24,
                      ), // Just icon for locked
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (!isLocked) ...[
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Theme.of(context).dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                        if (actionLabel.isNotEmpty)
                          SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              onPressed: onAction,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSecondary
                                    ? Theme.of(context).cardColor
                                    : Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface,
                                elevation: isSecondary ? 0 : 2,
                                side: isSecondary
                                    ? BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withValues(alpha: 0.5),
                                      )
                                    : null,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                actionLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                        Icon(
                          Icons.lock,
                          color: Theme.of(context).disabledColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
