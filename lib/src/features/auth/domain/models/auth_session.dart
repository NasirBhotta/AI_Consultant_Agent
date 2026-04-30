class AuthSession {
  const AuthSession({
    required this.userId,
    required this.email,
    required this.emailVerified,
    this.displayName,
  });

  final String userId;
  final String email;
  final bool emailVerified;
  final String? displayName;
}
