import 'package:cloud_firestore/cloud_firestore.dart';

class SolutionModel {
  final String id;
  final String requestId; // Hangi soruya ait?
  final String solverUserId;
  final String solverPersonaName;
  final String solverPersonaAvatar;
  final String? text;
  final String? photoUrl;
  final String? voiceUrl;
  final int likes;
  final bool isBestSolution;
  final DateTime timestamp;

  SolutionModel({
    required this.id,
    required this.requestId,
    required this.solverUserId,
    required this.solverPersonaName,
    required this.solverPersonaAvatar,
    this.text,
    this.photoUrl,
    this.voiceUrl,
    this.likes = 0,
    this.isBestSolution = false,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'solverUserId': solverUserId,
      'solverPersonaName': solverPersonaName,
      'solverPersonaAvatar': solverPersonaAvatar,
      'text': text,
      'photoUrl': photoUrl,
      'voiceUrl': voiceUrl,
      'likes': likes,
      'isBestSolution': isBestSolution,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory SolutionModel.fromMap(Map<String, dynamic> map, String id) {
    return SolutionModel(
      id: id,
      requestId: map['requestId'] ?? '',
      solverUserId: map['solverUserId'] ?? '',
      solverPersonaName: map['solverPersonaName'] ?? 'YKS Yolcusu',
      solverPersonaAvatar: map['solverPersonaAvatar'] ?? 'default_avatar',
      text: map['text'],
      photoUrl: map['photoUrl'],
      voiceUrl: map['voiceUrl'],
      likes: map['likes'] ?? 0,
      isBestSolution: map['isBestSolution'] ?? false,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
