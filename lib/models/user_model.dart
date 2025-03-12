class UserModel {
  String name;
  int id;
  String email;
  String password;

  UserModel({
    required this.name,
    required this.id,
    required this.email,
    required this.password,
  });

  // Factory constructor to create an instance from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      id: json['id'],
      email: json['email'],
      password: json['password'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'email': email,
      'password': password,
    };
  }
}