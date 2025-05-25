class UserModel {
  final String uid;
  final String name;
  final String email;
  final String faculty;
  final String id;
  final String regi;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.faculty,
    required this.id,
    this.profileImageUrl,
    required this.regi,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'profileImageUrl': profileImageUrl,
      'uid': uid,
      'name': name,
      'email': email,
      'faculty': faculty,
      'id': id,
      'regi': regi,
      'phone': phone,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create UserModel from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      profileImageUrl: map['profileImageUrl'] as String?,
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      faculty: map['faculty'] ?? '',
      id: map['id'] ?? '',
      regi: map['regi'] ?? '',
      phone: map['phone'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? faculty,
    String? id,
    String? regi,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      faculty: faculty ?? this.faculty,
      id: id ?? this.id,
      regi: regi ?? this.regi,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, faculty: $faculty, id: $id, regi: $regi, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode {
    return uid.hashCode;
  }
}
