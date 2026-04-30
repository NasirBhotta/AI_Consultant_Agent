class SignUpCredentials {
  const SignUpCredentials({
    required this.email,
    required this.password,
    this.displayName,
  });

  final String email;
  final String password;
  final String? displayName;
}
