import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VideoModel
// ─────────────────────────────────────────────────────────────────────────────

/// A single YouTube video within a playlist.
class VideoModel extends Equatable {
  const VideoModel({
    required this.title,
    required this.url,
    required this.durationSeconds,
  });

  final String title;
  final String url;

  /// Duration in seconds as stored in the JSON `duration` field.
  final int durationSeconds;

  // ── Computed helpers ───────────────────────────────────────────────────────

  /// Extracts the YouTube video ID from the URL.
  ///
  /// Handles the two most common formats:
  ///   • `https://www.youtube.com/watch?v=VIDEO_ID`
  ///   • `https://youtu.be/VIDEO_ID`
  ///
  /// Returns an empty string if the ID cannot be determined.
  String get videoId {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';
    // Standard watch URL
    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v']!;
    }
    // Short URL (youtu.be)
    if (uri.host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }
    return '';
  }

  /// Formats [durationSeconds] as `h:mm:ss` (when ≥ 1 hour) or `mm:ss`.
  String get formattedDuration {
    final d = Duration(seconds: durationSeconds);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  // ── Deserialisation ────────────────────────────────────────────────────────

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
        title: (json['title'] as String?) ?? '',
        url: (json['url'] as String?) ?? '',
        durationSeconds: (json['duration'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [title, url, durationSeconds];
}

// ─────────────────────────────────────────────────────────────────────────────
// PlaylistModel
// ─────────────────────────────────────────────────────────────────────────────

/// A playlist containing multiple [VideoModel] items.
class PlaylistModel extends Equatable {
  const PlaylistModel({
    required this.playlistTitle,
    required this.playlistUrl,
    required this.videosCount,
    required this.grade,
    required this.videos,
  });

  final String playlistTitle;
  final String playlistUrl;
  final int videosCount;

  /// Normalised grade key matching [UserEntity.academicGrade],
  /// e.g. `'3rd_prep'`, `'2nd_secondary'`, `'1st_secondary'`.
  ///
  /// Raw keys from the JSON are mapped via [_normalizeGrade] so the
  /// repository's `.where(p.grade == grade)` filter works correctly even when
  /// the source data uses `_sec` suffixes or contains typos.
  final String grade;

  final List<VideoModel> videos;

  // ── Deserialisation ────────────────────────────────────────────────────────

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    final rawGrade = (json['grade'] as String?) ?? '';
    return PlaylistModel(
      playlistTitle: (json['playlist_title'] as String?) ?? '',
      playlistUrl: (json['playlist_url'] as String?) ?? '',
      videosCount: (json['videos_count'] as num?)?.toInt() ?? 0,
      grade: _normalizeGrade(rawGrade),
      videos: ((json['videos'] as List<dynamic>?) ?? [])
          .map((v) => VideoModel.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  // ── Grade key normalisation ───────────────────────────────────────────────

  /// Maps raw JSON grade keys to the app's internal convention.
  ///
  /// | Raw (JSON)  | Normalised             | Note                          |
  /// |-------------|------------------------|-------------------------------|
  /// | `1st_sec`   | `1st_secondary`        | suffix expansion              |
  /// | `2nd_sec`   | `2nd_secondary`        | suffix expansion              |
  /// | `3rd_sec`   | `3rd_secondary`        | suffix expansion              |
  /// | `2st_sec`   | `2nd_secondary`        | **fixes data-entry typo**     |
  /// | `3rd_prep`  | `3rd_prep`             | unchanged (already canonical) |
  /// | `1st_prep`  | `1st_prep`             | unchanged                     |
  /// | `2nd_prep`  | `2nd_prep`             | unchanged                     |
  static String _normalizeGrade(String raw) {
    const mapping = <String, String>{
      '1st_sec': '1st_secondary',
      '2nd_sec': '2nd_secondary',
      '3rd_sec': '3rd_secondary',
      // Typo in the source data ("2st" instead of "2nd")
      '2st_sec': '2nd_secondary',
    };
    return mapping[raw] ?? raw;
  }

  @override
  List<Object?> get props => [playlistTitle, playlistUrl, grade];
}
