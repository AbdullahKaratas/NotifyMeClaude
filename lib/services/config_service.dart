import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const _keySupabaseUrl = 'supabase_url';
  static const _keySupabaseAnonKey = 'supabase_anon_key';
  static const _keyDeviceToken = 'device_token';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Check if Supabase is configured
  static bool get isConfigured {
    final url = _prefs?.getString(_keySupabaseUrl);
    final key = _prefs?.getString(_keySupabaseAnonKey);
    return url != null && url.isNotEmpty && key != null && key.isNotEmpty;
  }

  /// Get Supabase URL
  static String? get supabaseUrl => _prefs?.getString(_keySupabaseUrl);

  /// Get Supabase Anon Key
  static String? get supabaseAnonKey => _prefs?.getString(_keySupabaseAnonKey);

  /// Save Supabase configuration
  static Future<void> saveSupabaseConfig({
    required String url,
    required String anonKey,
  }) async {
    await _prefs?.setString(_keySupabaseUrl, url);
    await _prefs?.setString(_keySupabaseAnonKey, anonKey);
  }

  /// Clear configuration (for logout/reset)
  static Future<void> clearConfig() async {
    await _prefs?.remove(_keySupabaseUrl);
    await _prefs?.remove(_keySupabaseAnonKey);
  }

  /// Get device token for push notifications
  static String? get deviceToken => _prefs?.getString(_keyDeviceToken);

  /// Save device token
  static Future<void> saveDeviceToken(String token) async {
    await _prefs?.setString(_keyDeviceToken, token);
  }
}
