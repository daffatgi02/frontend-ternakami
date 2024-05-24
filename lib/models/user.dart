class User {
  final String email;
  final String fullname;
  final String token;
  final int userid;

  User({
    required this.email,
    required this.fullname,
    required this.token,
    required this.userid,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      fullname: json['fullname'],
      token: json['token'],
      userid: json['userid'],
    );
  }
}
