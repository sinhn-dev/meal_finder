class User {
  const User({
    required this.id,
    required this.userName,
    required this.displayName,
  });

  final String id;
  final String userName;
  final String displayName;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      userName: json['userName'] as String,
      displayName: json['displayName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'userName': userName, 'displayName': displayName};
  }
}
