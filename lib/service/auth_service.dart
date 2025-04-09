class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Check credentials
    return username == 'admin' && password == '123456';
  }

  Future<void> logout() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<bool> resetPassword({required String email}) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}

