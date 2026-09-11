import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../constants/app_strings.dart';
import '../../models/playlist_model.dart';

/// Displays all videos in a [PlaylistModel].
///
/// Layout:
///   • Top: inline YouTube player for the currently selected video.
///   • Below: scrollable list of [_VideoTile] items; tapping any tile loads
///     that video into the player.
///
/// Received via GoRouter `extra` parameter — see [app_router.dart].
class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen({super.key, required this.playlist});

  final PlaylistModel playlist;

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late YoutubePlayerController _controller;
  late int _selectedIndex;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _controller = _buildController(_selectedIndex);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  YoutubePlayerController _buildController(int index) {
    final video = widget.playlist.videos[index];
    return YoutubePlayerController.fromVideoId(
      videoId: video.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  void _selectVideo(int index) {
    if (index == _selectedIndex) return;
    _controller.close();
    setState(() {
      _selectedIndex = index;
      _controller = _buildController(index);
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final playlist = widget.playlist;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Player ───────────────────────────────────────────────
            SizedBox(
              height: 220,
              width: double.infinity,
              child: YoutubePlayer(
                controller: _controller,
              ),
            ),

            // ── Playlist header ──────────────────────────────────────
            _PlaylistHeader(
              playlist: playlist,
              selectedIndex: _selectedIndex,
              onBack: () => context.pop(),
            ),

            const Divider(height: 1),

            // ── Video list ───────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: playlist.videos.length,
                itemBuilder: (context, index) {
                  return _VideoTile(
                    video: playlist.videos[index],
                    index: index,
                    isSelected: index == _selectedIndex,
                    onTap: () => _selectVideo(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Playlist header (title + meta)
// ─────────────────────────────────────────────────────────────────────────────

class _PlaylistHeader extends StatelessWidget {
  const _PlaylistHeader({
    required this.playlist,
    required this.selectedIndex,
    required this.onBack,
  });

  final PlaylistModel playlist;
  final int selectedIndex;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final currentVideo = playlist.videos[selectedIndex];
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + playlist title row
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  playlist.playlistTitle,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Currently playing video title
          Text(
            currentVideo.title,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Meta chips
          Row(
            children: [
              _Chip(
                icon: Icons.play_circle_outline,
                label: AppStrings.videoCountLabel(playlist.videos.length),
              ),
              const SizedBox(width: 8),
              _Chip(
                icon: Icons.access_time,
                label: currentVideo.formattedDuration,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual video tile
// ─────────────────────────────────────────────────────────────────────────────

class _VideoTile extends StatelessWidget {
  const _VideoTile({
    required this.video,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  final VideoModel video;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return FadeInUp(
      delay: Duration(milliseconds: index * 40),
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: isSelected
              ? primary.withValues(alpha: 0.08)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Thumbnail / index ─────────────────────────────────────
              _Thumbnail(
                videoId: video.videoId,
                isSelected: isSelected,
                index: index,
              ),
              const SizedBox(width: 12),

              // ── Title + duration ──────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? primary
                            : theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          video.formattedDuration,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppStrings.nowPlaying,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Thumbnail widget
// ─────────────────────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.videoId,
    required this.isSelected,
    required this.index,
  });

  final String videoId;
  final bool isSelected;
  final int index;

  /// YouTube's standard thumbnail URL pattern.
  String get _thumbUrl =>
      'https://img.youtube.com/vi/$videoId/mqdefault.jpg';

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: videoId.isNotEmpty
              ? Image.network(
                  _thumbUrl,
                  width: 100,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _fallback(context),
                )
              : _fallback(context),
        ),
        if (isSelected)
          Container(
            width: 100,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: 28,
            ),
          )
        else
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
      ],
    );
  }

  Widget _fallback(BuildContext context) => Container(
        width: 100,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
}
