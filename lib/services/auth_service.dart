import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _user;
  UserProfile? _profile;

  User? get currentUser => _user;
  UserProfile? get currentProfile => _profile;

  AuthService() {
    _user = _supabase.auth.currentUser;
    if (_user != null) _loadProfile();
    _supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      if (_user != null) _loadProfile();
      notifyListeners();
    });
  }

  Future<void> _loadProfile() async {
    if (_user == null) return;
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', _user!.id)
        .single();
    _profile = UserProfile.fromJson(response);
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signUp(String email, String password, Map<String, dynamic> profileData) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: profileData,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}