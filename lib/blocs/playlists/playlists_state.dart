part of 'playlists_cubit.dart';

abstract class PlaylistsState extends Equatable {
  const PlaylistsState();

  @override
  List<Object?> get props => [];
}

/// Before any fetch has been triggered.
class PlaylistsInitial extends PlaylistsState {
  const PlaylistsInitial();
}

/// Fetch in progress.
class PlaylistsLoading extends PlaylistsState {
  const PlaylistsLoading();
}

/// Playlists loaded successfully for [grade].
class PlaylistsLoaded extends PlaylistsState {
  const PlaylistsLoaded({required this.playlists, required this.grade});

  final List<PlaylistModel> playlists;

  /// The grade key that was used to filter, e.g. `'3rd_prep'`.
  final String grade;

  @override
  List<Object?> get props => [playlists, grade];
}

/// An error occurred during the fetch.
class PlaylistsError extends PlaylistsState {
  const PlaylistsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
