class MockUser {
  const MockUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
    };
  }

  factory MockUser.fromJson(Map<String, dynamic> json) {
    return MockUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      password: json['password'] as String,
    );
  }
}
