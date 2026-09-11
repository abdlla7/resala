import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_strings.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/dashboard'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.learningPathTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // Header Image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FadeInDown(
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAOBLPGiEvXBij1PppCS2ikUMyhII6YA_lfM_hRN5LrwaDnZcrYl7P5556gcJw2KCFXVwyC-T-h4SyFhMizuSSc8Xfk0XHeFO7Kk25Wtc8fWS4DKHs8HIO6EbjhEyAf9R3nf-649Am7GfiKOD3S-DdqQ-iUjmB6CYa_8ZZ2bWfmr3rNvXxc8jMraIFPMgsvrB_tDgoNv2Sr62CvcJEassNyQx4Wd8dMugTPNvn7XYYwy1epA8GDJI_5MlcC39P4XSArb2NYnbmJtA',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black54, Colors.transparent],
                            ),
                          ),
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.volunteer_activism,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  AppStrings.volunteerTrack,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Headline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.disasterReliefBasics,
                            style: GoogleFonts.lexend(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.disasterReliefDescription,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progress
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppStrings.levelsComplete('3', '8'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Text(
                                  '35%',
                                  style: TextStyle(
                                    color: Color(0xFF2BEE4B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: const LinearProgressIndicator(
                                value: 0.35,
                                minHeight: 8,
                                backgroundColor: Color(0xFFEEEEEE),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2BEE4B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Timeline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      children: [
                        // Vertical Line
                        Positioned(
                          left: 19,
                          top: 24,
                          bottom: 40,
                          width: 2,
                          child: Container(color: Colors.grey.shade300),
                        ),

                        Column(
                          children: [
                            _buildTimelineItem(
                              context,
                              level: 1,
                              title: AppStrings.orientation,
                              description: AppStrings.orientationDesc,
                              status: TimelineStatus.completed,
                              delay: 300,
                            ),
                            const SizedBox(height: 24),
                            _buildTimelineItem(
                              context,
                              level: 2,
                              title: AppStrings.safetyProtocols,
                              description: AppStrings.safetyProtocolsDesc,
                              status: TimelineStatus.completed,
                              delay: 400,
                            ),
                            const SizedBox(height: 24),
                            _buildTimelineItem(
                              context,
                              level: 3,
                              title: AppStrings.engagingCommunity,
                              description: AppStrings.engagingCommunityDesc,
                              status: TimelineStatus.current,
                              delay: 500,
                              onAction: () => context.push('/lesson'),
                            ),
                            const SizedBox(height: 24),
                            _buildTimelineItem(
                              context,
                              level: 4,
                              title: AppStrings.crisisCommunication,
                              description: AppStrings.crisisCommunicationDesc,
                              status: TimelineStatus.locked,
                              delay: 600,
                            ),
                            const SizedBox(height: 24),
                            _buildTimelineItem(
                              context,
                              level: 5,
                              title: AppStrings.fieldDeployment,
                              description: AppStrings.fieldDeploymentDesc,
                              status: TimelineStatus.locked,
                              delay: 700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required int level,
    required String title,
    required String description,
    required TimelineStatus status,
    required int delay,
    VoidCallback? onAction,
  }) {
    bool isCompleted = status == TimelineStatus.completed;
    bool isCurrent = status == TimelineStatus.current;

    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Node
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isCurrent)
                  Pulse(
                    infinite: true,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFCD34D), // Amber
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Container(
                  width: isCurrent ? 32 : 40,
                  height: isCurrent ? 32 : 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF2BEE4B)
                        : isCurrent
                        ? const Color(0xFFFCD34D)
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check
                        : (isCurrent ? Icons.play_arrow : Icons.lock),
                    size: 20,
                    color: isCompleted || isCurrent
                        ? Colors.black
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Card
          Expanded(
            child: Opacity(
              opacity: status == TimelineStatus.locked ? 0.6 : 1.0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Theme.of(context).cardColor
                      : (status == TimelineStatus.locked
                            ? Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.5)
                            : Theme.of(context).cardColor),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFFFCD34D)
                        : Theme.of(context).dividerColor.withValues(alpha: 0.5),
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFFFCD34D,
                            ).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isCurrent)
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFCD34D,
                                  ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  AppStrings.currentLevel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              )
                            else
                              Text(
                                AppStrings.levelN(level),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted
                                      ? const Color(0xFF2BEE4B)
                                      : Colors.grey,
                                ),
                              ),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (isCompleted)
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF2BEE4B),
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (isCurrent && onAction != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2BEE4B),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.resumeLearning,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum TimelineStatus { completed, current, locked }
