import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/errors/app_exception.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../repositories/playlist_repository.dart';
import 'spotify_auth_service.dart';

/// Implements [PlaylistRepository] for the Spotify platform by calling the
/// Spotify Web API. Shares the [SpotifyAuthService] instance from [main.dart]
/// so token storage and refresh logic are not duplicated.
class SpotifyPlaylistService implements PlaylistRepository {
  static const _baseUrl = 'https://api.spotify.com/v1';

  final SpotifyAuthService _auth;
  final http.Client _http;

  SpotifyPlaylistService({
    required SpotifyAuthService auth,
    http.Client? httpClient,
  })  : _auth = auth,
        _http = httpClient ?? http.Client();

  // ── PlaylistRepository ─────────────────────────────────────────────────────

  @override
  Future<List<Playlist>> fetchPlaylists(String platformId) async {
    final token = await _getToken();
    final headers = _authHeader(token);

    final playlists = <Playlist>[];
    String? nextUrl = '$_baseUrl/me/playlists?limit=50';

    try {
      while (nextUrl != null) {
        final response = await _http.get(Uri.parse(nextUrl), headers: headers);
        _assertOk(response, 'fetch playlists');

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>;

        for (final item in items) {
          if (item == null) continue;
          playlists.add(_playlistFromSpotify(item as Map<String, dynamic>));
        }

        nextUrl = data['next'] as String?;
      }
    } on PlaylistException {
      rethrow;
    } catch (e) {
      throw PlaylistException('Failed to parse playlists response: $e');
    }

    return playlists;
  }

  @override
  Future<Playlist> fetchPlaylistDetails(
      String platformId, String playlistId) async {
    final token = await _getToken();
    final headers = _authHeader(token);

    try {
      // 1. Fetch playlist metadata.
      final metaResponse = await _http.get(
        Uri.parse(
            '$_baseUrl/playlists/$playlistId?fields=id,name,description,images,tracks.total'),
        headers: headers,
      );
      _assertOk(metaResponse, 'fetch playlist metadata');

      final meta = jsonDecode(metaResponse.body) as Map<String, dynamic>;

      // 2. Paginate tracks.
      final songs = <Song>[];
      String? nextUrl =
          '$_baseUrl/playlists/$playlistId/tracks?limit=100'
          '&fields=next,items(track(id,name,artists,album.name,duration_ms,is_local))';

      while (nextUrl != null) {
        final tracksResponse =
            await _http.get(Uri.parse(nextUrl), headers: headers);
        _assertOk(tracksResponse, 'fetch playlist tracks');

        final data = jsonDecode(tracksResponse.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>;

        for (final item in items) {
          if (item == null) continue;
          final track =
              (item as Map<String, dynamic>)['track'] as Map<String, dynamic>?;
          if (track == null) continue;
          if (track['is_local'] == true) continue;
          songs.add(_songFromSpotify(track));
        }

        nextUrl = data['next'] as String?;
      }

      return _playlistFromSpotify(meta, songs: songs);
    } on PlaylistException {
      rethrow;
    } catch (e) {
      throw PlaylistException('Failed to parse playlist details: $e');
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<String> _getToken() async {
    try {
      return await _auth.getAccessToken();
    } on AuthException catch (e) {
      throw PlaylistException(
          'Spotify session expired — please re-authorize',
          code: '401');
    }
  }

  Map<String, String> _authHeader(String token) => {
        'Authorization': 'Bearer $token',
      };

  void _assertOk(http.Response response, String operation) {
    if (response.statusCode == 401) {
      throw const PlaylistException(
          'Spotify session expired — please re-authorize',
          code: '401');
    }
    if (response.statusCode != 200) {
      throw PlaylistException(
          'Failed to $operation: HTTP ${response.statusCode}',
          code: response.statusCode.toString());
    }
  }

  Playlist _playlistFromSpotify(
    Map<String, dynamic> item, {
    List<Song> songs = const [],
  }) {
    final images = item['images'] as List<dynamic>?;
    final rawDescription = item['description'] as String?;

    // tracks.total may be nested (full playlist object) or from the list endpoint.
    final tracksField = item['tracks'];
    final trackCount = tracksField is Map<String, dynamic>
        ? (tracksField['total'] as int? ?? 0)
        : (tracksField as int? ?? 0);

    return Playlist(
      id: item['id'] as String,
      name: item['name'] as String,
      description:
          (rawDescription == null || rawDescription.isEmpty) ? null : rawDescription,
      trackCount: trackCount,
      imageUrl: (images != null && images.isNotEmpty)
          ? (images[0] as Map<String, dynamic>)['url'] as String?
          : null,
      platformId: 'spotify',
      songs: songs,
    );
  }

  Song _songFromSpotify(Map<String, dynamic> track) {
    final artists = track['artists'] as List<dynamic>?;
    final artist = (artists != null && artists.isNotEmpty)
        ? (artists[0] as Map<String, dynamic>)['name'] as String? ??
            'Unknown Artist'
        : 'Unknown Artist';

    final album = track['album'] as Map<String, dynamic>?;

    return Song(
      id: track['id'] as String,
      title: track['name'] as String,
      artist: artist,
      album: album?['name'] as String?,
      durationSeconds: (track['duration_ms'] as int) ~/ 1000,
    );
  }
}
