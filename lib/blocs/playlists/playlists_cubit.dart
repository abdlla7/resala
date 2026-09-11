import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/playlist_model.dart';
import '../../repositories/playlists_repository.dart';

part 'playlists_state.dart';

/// Cubit that loads and exposes grade-filtered playlists from
/// [PlaylistsRepository].
///
/// Injecting the abstract [PlaylistsRepository] interface keeps this cubit
/// testable and allows swapping the local-JSON implementation for a Firestore
/// one without changes here.
class PlaylistsCubit extends Cubit<PlaylistsState> {
  PlaylistsCubit({required PlaylistsRepository repository})
      : _repository = repository,
        super(const PlaylistsInitial());

  final PlaylistsRepository _repository;

  /// Fetches playlists matching [grade] (e.g. `'3rd_prep'`, `'2nd_secondary'`).
  ///
  /// Emits [PlaylistsLoading] immediately, then either [PlaylistsLoaded] or
  /// [PlaylistsError].
  Future<void> loadPlaylistsByGrade(String grade) async {
    if (grade.isEmpty) return;
    emit(const PlaylistsLoading());
    try {
      final playlists = await _repository.getPlaylistsByGrade(grade);
      emit(PlaylistsLoaded(playlists: playlists, grade: grade));
    } catch (e) {
      emit(PlaylistsError(e.toString()));
    }
  }
}
