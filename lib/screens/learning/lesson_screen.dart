import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../constants/app_strings.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late YoutubePlayerController _controller;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'VbAYusreHb0',
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        showVideoAnnotations: false,
        pointerEvents: PointerEvents.none,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _togglePlayPause(PlayerState playerState) {
    if (playerState == PlayerState.playing) {
      _controller.pauseVideo();
    } else {
      _controller.playVideo();
    }
  }

  void _seekRelative(Duration currentPosition, Duration duration, int seconds) {
    final maxSecs = duration.inSeconds > 0 ? duration.inSeconds : 3600;
    final newSeconds = (currentPosition.inSeconds + seconds).clamp(0, maxSecs).toDouble();
    _controller.seekTo(seconds: newSeconds, allowSeekAhead: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: theme.iconTheme.color,
          ),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          AppStrings.fieldSafetyBasics,
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.appBarTheme.titleTextStyle?.color,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Player Section with Custom Controls Overlay
                  FadeInDown(
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          color: Colors.black,
                          child: Stack(
                            children: [
                              // 1. Native Youtube Player
                              Positioned.fill(
                                child: YoutubePlayer(
                                  controller: _controller,
                                ),
                              ),

                              // 2. Invisible GestureDetector layer intercepting all direct clicks
                              Positioned.fill(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      _showControls = !_showControls;
                                    });
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),

                              // 3. Custom Controls Overlay
                              if (_showControls)
                                Positioned.fill(
                                  child: StreamBuilder<YoutubePlayerValue>(
                                    stream: _controller.stream,
                                    builder: (context, playerSnapshot) {
                                      final playerState = _controller.value.playerState;
                                      final isPlaying = playerState == PlayerState.playing;
                                      final duration = _controller.metadata.duration;

                                      return Container(
                                        color: Colors.black.withValues(alpha: 0.45),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const SizedBox(height: 10),

                                            // Center Playback Controls
                                            StreamBuilder<YoutubeVideoState>(
                                              stream: _controller.videoStateStream,
                                              initialData: const YoutubeVideoState(),
                                              builder: (context, videoSnapshot) {
                                                final position = videoSnapshot.data?.position ?? Duration.zero;

                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    // Rewind 10s
                                                    IconButton(
                                                      iconSize: 36,
                                                      icon: const Icon(
                                                        Icons.replay_10_rounded,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () => _seekRelative(position, duration, -10),
                                                    ),
                                                    const SizedBox(width: 16),

                                                    // Play / Pause Toggle
                                                    GestureDetector(
                                                      onTap: () => _togglePlayPause(playerState),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(12),
                                                        decoration: const BoxDecoration(
                                                          color: Color(0xFF2BEE4B),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          isPlaying
                                                              ? Icons.pause_rounded
                                                              : Icons.play_arrow_rounded,
                                                          color: Colors.black,
                                                          size: 36,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),

                                                    // Forward 10s
                                                    IconButton(
                                                      iconSize: 36,
                                                      icon: const Icon(
                                                        Icons.forward_10_rounded,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () => _seekRelative(position, duration, 10),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),

                                            // Bottom Controls Bar (Time & Seek Slider)
                                            StreamBuilder<YoutubeVideoState>(
                                              stream: _controller.videoStateStream,
                                              initialData: const YoutubeVideoState(),
                                              builder: (context, videoSnapshot) {
                                                final position = videoSnapshot.data?.position ?? Duration.zero;
                                                final totalSeconds = duration.inSeconds > 0
                                                    ? duration.inSeconds.toDouble()
                                                    : 1.0;
                                                final currentSeconds = position.inSeconds
                                                    .clamp(0, totalSeconds.toInt())
                                                    .toDouble();

                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        _formatDuration(position),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: SliderTheme(
                                                          data: SliderTheme.of(context).copyWith(
                                                            trackHeight: 3,
                                                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                                            activeTrackColor: const Color(0xFF2BEE4B),
                                                            inactiveTrackColor: Colors.white30,
                                                            thumbColor: const Color(0xFF2BEE4B),
                                                          ),
                                                          child: Slider(
                                                            value: currentSeconds.clamp(0.0, totalSeconds),
                                                            min: 0.0,
                                                            max: totalSeconds,
                                                            onChanged: (value) {
                                                              _controller.seekTo(
                                                                seconds: value,
                                                                allowSeekAhead: true,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        _formatDuration(duration),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInUp(
                          delay: const Duration(milliseconds: 100),
                          child: Text(
                            AppStrings.lesson3,
                            style: GoogleFonts.lexend(
                              color: const Color(0xFF2BEE4B),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            AppStrings.engagingCommunity,
                            style: GoogleFonts.lexend(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: Text(
                            AppStrings.lessonBody,
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.7),
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Quick Tips Header
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lightbulb,
                                color: Color(0xFF2BEE4B),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.quickTips,
                                style: GoogleFonts.lexend(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // DO Card
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0F291E)
                                  : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(
                                  0xFF2BEE4B,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppStrings.doKey,
                                      style: GoogleFonts.lexend(
                                        color: const Color(
                                          0xFF15803D,
                                        ), // Dark Green
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppStrings.doTip,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white70
                                        : const Color(0xFF14532D),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // DON'T Card
                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2A1215)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppStrings.dontKey,
                                      style: GoogleFonts.lexend(
                                        color: const Color(
                                          0xFFB91C1C,
                                        ), // Dark Red
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Color(0xFFB91C1C),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppStrings.dontTip,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white70
                                        : const Color(0xFF7F1D1D),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Button
          FadeInUp(
            delay: const Duration(milliseconds: 700),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/quiz');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2BEE4B),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.completeLevel,
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}