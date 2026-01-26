import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope, drive.DriveApi.driveAppdataScope],
  );

  GoogleSignInAccount? _currentUser;

  /// Initialize and check if user is already signed in
  Future<void> init() async {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      _currentUser = account;
    });

    // Try to sign in silently on app start
    await _googleSignIn.signInSilently();
  }

  /// Sign in with Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      _currentUser = account;
      return account;
    } catch (e) {
      return null;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  /// Check if user is currently signed in
  bool isSignedIn() {
    return _currentUser != null;
  }

  /// Get current user
  GoogleSignInAccount? getCurrentUser() {
    return _currentUser;
  }

  /// Get authentication headers for API calls
  Future<Map<String, String>> getAuthHeaders() async {
    final account = _currentUser;
    if (account == null) {
      throw Exception('User not signed in');
    }

    final auth = await account.authentication;
    return {
      'Authorization': 'Bearer ${auth.accessToken}',
      'Content-Type': 'application/json',
    };
  }

  /// Get authenticated HTTP client for Google APIs
  Future<http.Client> getAuthenticatedClient() async {
    final account = _currentUser;
    if (account == null) {
      throw Exception('User not signed in');
    }

    final auth = await account.authentication;
    return _GoogleAuthClient(auth.accessToken!);
  }
}

/// Custom HTTP client that adds authentication headers
class _GoogleAuthClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}
