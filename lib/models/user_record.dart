class UserRecord {
  final int id;
  final String rfidCode;
  final String name;
  final String? imageUrl; // Peut être null
  final DateTime timestamp;

  UserRecord({
    required this.id,
    required this.rfidCode,
    required this.name,
    this.imageUrl,
    required this.timestamp,
  });

  // Méthode de conversion à partir d'un Map
  factory UserRecord.fromMap(Map<String, dynamic> map) {
    return UserRecord(
      id: map['id'] as int,
      rfidCode: map['rfidcode'] ?? '', // Valeur par défaut si null
      name: map['name'] ?? '', // Valeur par défaut si null
      imageUrl: map['image'], // Peut rester null
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(), // Valeur par défaut si null
    );
  }

  // Convertir l'objet en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rfidcode': rfidCode,
      'name': name,
      'image': imageUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
