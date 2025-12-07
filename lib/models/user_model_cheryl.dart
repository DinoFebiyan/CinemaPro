// TODO: Perlu ditambahkan field 'password' ke dalam model ini untuk sistem autentikasi baru
// Petunjuk untuk developer:
// 1. Tambahkan field: final String password;
// 2. Tambahkan ke constructor: required this.password
// 3. Sertakan dalam toMapCheryl(): 'password' : password
// 4. Sertakan dalam fromMapCheryl(): password: map['password'] ?? ''
class UserModelCheryl {
  final String uid;
  final String email;
  final String username;
  final int balance;

  UserModelCheryl ({
    required this.uid,
    required this.email,
    required this.username,
    required this.balance
  });

  Map<String, dynamic> toMapCheryl() {
    return {
      'uid' : uid,
      'email' : email,
      'username' : username,
      'balance' : balance
    };
  }

  factory UserModelCheryl.fromMapCheryl(Map<String, dynamic> map) {
    return UserModelCheryl(
      uid:map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      balance: (map['balance'] ?? 0).toInt(),
      );
  }
}