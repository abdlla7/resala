import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/playlists/playlists_cubit.dart';
import '../../blocs/subscription/subscription_cubit.dart';
import '../../constants/app_strings.dart';
import '../../models/playlist_model.dart';
import '../../models/user_entity.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/redeem_code_sheet.dart';

/// Grade-aware dashboard with subscription-aware playlist locking.
///
/// Reads [UserEntity] from [AuthBloc], playlist data from [PlaylistsCubit],
/// and subscription status from [SubscriptionCubit] — all provided globally
/// via [MultiBlocProvider] in `main.dart` or scoped in the router.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<PlaylistsCubit>()
          .loadPlaylistsByGrade(authState.user.academicGrade);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(user: user),
                  // ── Subscription banner (only when sub state is known) ──
                  const _SubscriptionBanner(),
                  _ProgressCard(),
                  const SizedBox(height: 24),
                  const _PlaylistsSection(),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(
                currentIndex: 0,
                onTap: (index) {
                  switch (index) {
                    case 1:
                      context.push('/learning-path');
                    case 2:
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.comingSoon)),
                      );
                    case 3:
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.user});
  final UserEntity? user;

  @override
  Widget build(BuildContext context) {
    final gradeName = user != null
        ? AppStrings.gradeDisplayName(user!.academicGrade)
        : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.hi(user?.fullName ?? 'ضيف'),
                  style: GoogleFonts.lexend(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (gradeName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppStrings.gradeLabel(gradeName),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                else
                  Text(
                    AppStrings.fieldReadyVolunteer,
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.push('/settings'),
            child: _Avatar(user: user),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});
  final UserEntity? user;

  @override
  Widget build(BuildContext context) {
    final initials = (user?.fullName.isNotEmpty ?? false)
        ? user!.fullName.trim()[0].toUpperCase()
        : '؟';

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: 0.15),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.25),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subscription banner
// ─────────────────────────────────────────────────────────────────────────────

class _SubscriptionBanner extends StatelessWidget {
  const _SubscriptionBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionInitial || state is SubscriptionLoading) {
          return const SizedBox.shrink();
        }

        if (state is SubscriptionActive) {
          return _BannerTile(
            icon: Icons.verified_rounded,
            color: Colors.green.shade600,
            text: AppStrings.subscriptionActiveBanner,
            subtitle: AppStrings.subscriptionDaysLeft(state.remainingDays),
          );
        }

        if (state is SubscriptionExpired) {
          return _BannerTile(
            icon: Icons.lock_rounded,
            color: Colors.orange.shade700,
            text: AppStrings.subscriptionExpiredBanner,
            onTap: () => showRedeemCodeSheet(context),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _BannerTile extends StatelessWidget {
  const _BannerTile({
    required this.icon,
    required this.color,
    required this.text,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String text;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 14,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: color.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_left_rounded,
                    color: color.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress card
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).shadowColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              AppStrings.overallProgress,
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
              percent: 0.0,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '0%',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      fontSize: 32.0,
                    ),
                  ),
                  Text(
                    AppStrings.completed,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4),
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: Theme.of(context).dividerColor,
              progressColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.motivationMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Playlists section — driven by PlaylistsCubit + SubscriptionCubit
// ─────────────────────────────────────────────────────────────────────────────

class _PlaylistsSection extends StatelessWidget {
  const _PlaylistsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.playlistsSectionTitle,
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        BlocBuilder<PlaylistsCubit, PlaylistsState>(
          builder: (context, playlistState) {
            if (playlistState is PlaylistsLoading ||
                playlistState is PlaylistsInitial) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (playlistState is PlaylistsError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  playlistState.message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            }

            if (playlistState is PlaylistsLoaded) {
              if (playlistState.playlists.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 40),
                  child: Center(
                    child: Text(
                      AppStrings.noPlaylistsFound,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                );
              }

              // Use BlocBuilder for subscription so cards react to redemption.
              return BlocBuilder<SubscriptionCubit, SubscriptionState>(
                builder: (context, subState) {
                  final isSubscribed = subState is SubscriptionActive;
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: playlistState.playlists.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) => _PlaylistCard(
                      playlist: playlistState.playlists[index],
                      isLocked: !isSubscribed,
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Playlist card with lock guard
// ─────────────────────────────────────────────────────────────────────────────

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({
    required this.playlist,
    required this.isLocked,
  });

  final PlaylistModel playlist;
  final bool isLocked;

  Future<void> _handleTap(BuildContext context) async {
    if (isLocked) {
      await showRedeemCodeSheet(context);
    } else {
      context.push('/playlist-detail', extra: playlist);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeInUp(
      child: GestureDetector(
        onTap: () => _handleTap(context),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Thumbnail / lock overlay ─────────────────────────────
              _PlaylistThumbnailStrip(
                playlist: playlist,
                isLocked: isLocked,
              ),

              // ── Info row ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.playlistTitle,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLocked
                            ? theme.colorScheme.onSurface
                                .withValues(alpha: 0.45)
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isLocked
                              ? Icons.lock_rounded
                              : Icons.play_circle_filled_rounded,
                          size: 16,
                          color: isLocked
                              ? theme.colorScheme.error
                                  .withValues(alpha: 0.7)
                              : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isLocked
                              ? AppStrings.contentLockedSubtitle
                              : AppStrings.videoCountLabel(
                                  playlist.videos.length),
                          style: TextStyle(
                            fontSize: 13,
                            color: isLocked
                                ? theme.colorScheme.error
                                    .withValues(alpha: 0.7)
                                : theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        _ActionButton(isLocked: isLocked),
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.isLocked});
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isLocked
        ? theme.colorScheme.error.withValues(alpha: 0.85)
        : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLocked ? Icons.lock_open_rounded : Icons.play_arrow_rounded,
            size: 14,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            isLocked ? AppStrings.redeemButton : AppStrings.watchPlaylist,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Playlist thumbnail strip with optional lock overlay
// ─────────────────────────────────────────────────────────────────────────────

class _PlaylistThumbnailStrip extends StatelessWidget {
  const _PlaylistThumbnailStrip({
    required this.playlist,
    required this.isLocked,
  });

  final PlaylistModel playlist;
  final bool isLocked;

  String _thumbUrl(String videoId) =>
      'https://img.youtube.com/vi/$videoId/mqdefault.jpg';

  @override
  Widget build(BuildContext context) {
    final preview = playlist.videos.take(1).toList();

    if (preview.isEmpty || preview.first.videoId.isEmpty) {
      return _fallbackBanner(context);
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(
        children: [
          // ── Thumbnail image ─────────────────────────────────────────
          ColorFiltered(
            colorFilter: isLocked
                ? const ColorFilter.matrix(<double>[
                    0.2126, 0.7152, 0.0722, 0, 0, //
                    0.2126, 0.7152, 0.0722, 0, 0, //
                    0.2126, 0.7152, 0.0722, 0, 0, //
                    0, 0, 0, 1, 0,
                  ])
                : const ColorFilter.mode(
                    Colors.transparent, BlendMode.multiply),
            child: Image.network(
              _thumbUrl(preview.first.videoId),
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _fallbackBanner(context),
            ),
          ),

          // ── Gradient overlay ────────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: isLocked ? 0.75 : 0.55),
                  ],
                ),
              ),
            ),
          ),

          // ── Lock overlay (when locked) ──────────────────────────────
          if (isLocked)
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.contentLocked,
                      style: GoogleFonts.lexend(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Video count badge (always visible) ──────────────────────
          Positioned(
            bottom: 8,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.queue_play_next,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.videoCountLabel(playlist.videos.length),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Play button (only when unlocked) ────────────────────────
          if (!isLocked)
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallbackBanner(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          colors: [
            Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: isLocked ? 0.25 : 0.7),
            Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: isLocked ? 0.1 : 0.4),
          ],
        ),
      ),
      child: Icon(
        isLocked ? Icons.lock_rounded : Icons.video_library_rounded,
        color: Colors.white,
        size: 48,
      ),
    );
  }
}
