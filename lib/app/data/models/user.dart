class User {
  final int? id;
  final String name;
  final String email;
  final String role; // 'caisse', 'cuisine', 'distribution' ou 'admin'
  final String? phoneNumber;
  final DateTime? createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.createdAt,
  });

  // Convertir un JSON de l'API Laravel en objet User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phoneNumber: json['phone_number'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
    );
  }

  // Convertir l'objet User en JSON pour l'envoyer à l'API ou le stocker localement
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone_number': phoneNumber,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Fonctions d'aide (Helpers) pour vérifier les rôles rapidement dans l'UI GetX
  bool get isCaisse => role == 'caisse';
  bool get isCuisine => role == 'cuisine';
  bool get isDistribution => role == 'distribution';
  bool get isAdmin => role == 'admin';
}