import 'package:cloud_firestore/cloud_firestore.dart';

class HelpRequestModel {
  final String id;
  final String senderUserId;
  final String senderPersonaName; // Örn: "Gizemli Matematikçi"
  final String senderPersonaAvatar; // Örn: "owl_avatar"
  final String photoUrl;
  final String lesson;
  final String topic;
  final String description;
  final int coinsOffered;
  final int solutionCount;
  final bool isSolved;
  final DateTime timestamp;

  HelpRequestModel({
    required this.id,
    required this.senderUserId,
    required this.senderPersonaName,
    required this.senderPersonaAvatar,
    required this.photoUrl,
    required this.lesson,
    required this.topic,
    required this.description,
    this.coinsOffered = 15,
    this.solutionCount = 0,
    this.isSolved = false,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderUserId': senderUserId,
      'senderPersonaName': senderPersonaName,
      'senderPersonaAvatar': senderPersonaAvatar,
      'photoUrl': photoUrl,
      'lesson': lesson,
      'topic': topic,
      'description': description,
      'coinsOffered': coinsOffered,
      'solutionCount': solutionCount,
      'isSolved': isSolved,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory HelpRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return HelpRequestModel(
      id: id,
      senderUserId: map['senderUserId'] ?? '',
      senderPersonaName: map['senderPersonaName'] ?? 'Anonim Öğrenci',
      senderPersonaAvatar: map['senderPersonaAvatar'] ?? 'default_avatar',
      photoUrl: map['photoUrl'] ?? '',
      lesson: map['lesson'] ?? '',
      topic: map['topic'] ?? '',
      description: map['description'] ?? '',
      coinsOffered: map['coinsOffered'] ?? 15,
      solutionCount: map['solutionCount'] ?? 0,
      isSolved: map['isSolved'] ?? false,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
