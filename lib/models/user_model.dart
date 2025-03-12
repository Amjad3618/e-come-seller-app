class UserModel {
  String name;
  String uid;
  String email;
  String password;
   String confirmpassword;


  UserModel({
    required this.name,
    required this.uid,
    required this.email,
    required this.password,
    required this.confirmpassword
  });

  // Factory constructor to create an instance from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      uid: json['uid'],
      email: json['email'],
      password: json['password'],
      confirmpassword: json['confirmpassword']
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'uid': uid,
      'email': email,
      'password': password,
    'confirmpassword': confirmpassword
    };
  }
}