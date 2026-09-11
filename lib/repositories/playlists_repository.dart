import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/playlist_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Abstract interface
// ─────────────────────────────────────────────────────────────────────────────

/// Contract for fetching playlists.
///
/// Swap [LocalPlaylistsRepository] for a network or Firestore implementation
/// without touching any BLoC or UI code.
abstract class PlaylistsRepository {
  /// Returns every playlist whose [PlaylistModel.grade] matches [grade].
  Future<List<PlaylistModel>> getPlaylistsByGrade(String grade);

  /// Returns the complete, unfiltered catalogue.
  Future<List<PlaylistModel>> getAllPlaylists();
}

// ─────────────────────────────────────────────────────────────────────────────
// Local JSON-asset implementation
// ─────────────────────────────────────────────────────────────────────────────

/// Loads playlists from the bundled [_assetPath] JSON file and filters
/// by grade in memory.
///
/// Results are cached after the first load so subsequent calls are instant.
///
/// TODO: Replace with a network/Firestore implementation once the backend
/// catalogue endpoint is available:
///
/// ```dart
/// class FirestorePlaylistsRepository implements PlaylistsRepository {
///   @override
///   Future<List<PlaylistModel>> getPlaylistsByGrade(String grade) async {
///     final snap = await FirebaseFirestore.instance
///         .collection('playlists')
///         .where('grade', isEqualTo: grade)
///         .get();
///     return snap.docs
///         .map((d) => PlaylistModel.fromJson(d.data()))
///         .toList();
///   }
///
///   @override
///   Future<List<PlaylistModel>> getAllPlaylists() async {
///     final snap = await FirebaseFirestore.instance
///         .collection('playlists')
///         .get();
///     return snap.docs
///         .map((d) => PlaylistModel.fromJson(d.data()))
///         .toList();
///   }
/// }
/// ```
class LocalPlaylistsRepository implements PlaylistsRepository {
  static const String _assetPath = 'assets/data/playlists.json';

  List<PlaylistModel>? _cache;

  /// Loads and parses [_assetPath] once, then serves from [_cache].
  Future<List<PlaylistModel>> _load() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString(_assetPath);
    // Top-level structure is an array with one object: [{"playlists": [...]}]
    final topList = jsonDecode(jsonString) as List<dynamic>;
    final wrapper = topList.first as Map<String, dynamic>;
    final rawPlaylists = wrapper['playlists'] as List<dynamic>;

    _cache = rawPlaylists
        .map((e) => PlaylistModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return _cache!;
  }

  @override
  Future<List<PlaylistModel>> getPlaylistsByGrade(String grade) async {
    final all = await _load();
    return all.where((p) => p.grade == grade).toList();
  }

  @override
  Future<List<PlaylistModel>> getAllPlaylists() => _load();
}
