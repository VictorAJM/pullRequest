/// All Spotify Web API OAuth scopes.
///
/// Source: https://developer.spotify.com/documentation/web-api/concepts/scopes
///
/// Usage — build the space-separated string Spotify expects:
/// ```dart
/// final scopeString = SpotifyScope.encode({
///   SpotifyScope.playlistReadPrivate,
///   SpotifyScope.playlistReadCollaborative,
/// });
/// ```
enum SpotifyScope {
  // ── Images ─────────────────────────────────────────────────────────────────

  /// Write access to user-provided images.
  ugcImageUpload('ugc-image-upload'),

  // ── Spotify Connect ────────────────────────────────────────────────────────

  /// Read access to a user's player state.
  userReadPlaybackState('user-read-playback-state'),

  /// Write access to a user's playback state.
  userModifyPlaybackState('user-modify-playback-state'),

  /// Read access to a user's currently playing content.
  userReadCurrentlyPlaying('user-read-currently-playing'),

  // ── Playback ───────────────────────────────────────────────────────────────

  /// Remote control via Spotify iOS / Android SDK.
  appRemoteControl('app-remote-control'),

  /// Control playback via Web Playback SDK (Premium required).
  streaming('streaming'),

  // ── Playlists ──────────────────────────────────────────────────────────────

  /// Read access to user's private playlists.
  playlistReadPrivate('playlist-read-private'),

  /// Include collaborative playlists when requesting a user's playlists.
  playlistReadCollaborative('playlist-read-collaborative'),

  /// Write access to a user's private playlists.
  playlistModifyPrivate('playlist-modify-private'),

  /// Write access to a user's public playlists.
  playlistModifyPublic('playlist-modify-public'),

  // ── Follow ─────────────────────────────────────────────────────────────────

  /// Write/delete access to the list of artists and other users that the user follows.
  userFollowModify('user-follow-modify'),

  /// Read access to the list of artists and other users that the user follows.
  userFollowRead('user-follow-read'),

  // ── Listening History ──────────────────────────────────────────────────────

  /// Read access to a user's playback position in content.
  userReadPlaybackPosition('user-read-playback-position'),

  /// Read access to a user's top artists and tracks.
  userTopRead('user-top-read'),

  /// Read access to a user's recently played tracks.
  userReadRecentlyPlayed('user-read-recently-played'),

  // ── Library ────────────────────────────────────────────────────────────────

  /// Write/delete access to a user's 'Your Music' library.
  userLibraryModify('user-library-modify'),

  /// Read access to a user's library.
  userLibraryRead('user-library-read'),

  // ── Users ──────────────────────────────────────────────────────────────────

  /// Read access to user's email address.
  userReadEmail('user-read-email'),

  /// Read access to user's subscription details (country, product).
  userReadPrivate('user-read-private'),

  // ── Open Access (platform-partner only) ───────────────────────────────────

  /// Link partner user accounts to a Spotify user account.
  userSoaLink('user-soa-link'),

  /// Unlink partner user accounts from a Spotify user account.
  userSoaUnlink('user-soa-unlink'),

  /// Modify entitlements for linked users.
  soaManageEntitlements('soa-manage-entitlements'),

  /// Update partner information.
  soaManagePartner('soa-manage-partner'),

  /// Create new partners (restricted to Spotify platform partners).
  soaCreatePartner('soa-create-partner');

  const SpotifyScope(this.value);

  /// The raw scope string sent in the OAuth authorization URL.
  final String value;

  /// Encodes a set of scopes into the space-separated string Spotify expects.
  static String encode(Set<SpotifyScope> scopes) =>
      scopes.map((s) => s.value).join(' ');
}
