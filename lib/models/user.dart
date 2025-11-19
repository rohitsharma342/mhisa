class User {
  final String id;
  final String name;
  final String avatarUrl;
  final int age;
  final String gender;
  final String bio;
  final bool isOnline;
  final DateTime lastSeen;
  final List<String> interests;
  
  User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.age,
    required this.gender,
    required this.bio,
    required this.isOnline,
    required this.lastSeen,
    required this.interests,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      age: json['age'],
      gender: json['gender'],
      bio: json['bio'],
      isOnline: json['isOnline'],
      lastSeen: DateTime.parse(json['lastSeen']),
      interests: List<String>.from(json['interests']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'age': age,
      'gender': gender,
      'bio': bio,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'interests': interests,
    };
  }
}