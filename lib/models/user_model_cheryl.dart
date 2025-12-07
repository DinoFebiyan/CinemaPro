
class UserModelCheryl {
  final String uid;
  final String email;
  final String username;
  final String password;
  final int balance;

  UserModelCheryl ({
    required this.uid,
    required this.email,
    required this.username,
    required this.password,
    required this.balance
  });

  Map<String, dynamic> toMapCheryl() {
    return {
      'uid' : uid,
      'email' : email,
      'username' : username,
      'password' : password,
      'balance' : balance
    };
  }

  factory UserModelCheryl.fromMapCheryl(Map<String, dynamic> map) {
    return UserModelCheryl(
      uid:map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      balance: (map['balance'] ?? 0).toInt(),
      );
  }
}