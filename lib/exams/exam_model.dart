import 'package:cloud_firestore/cloud_firestore.dart';

/// 📝 Deneme Sınavı Modeli
class ExamModel {
  final String id;
  final String title;
  final String visibility; // 'public' veya 'private'
  final String? targetInstitutionId; // Kuruma özel ise kurum ID'si
  final String? pdfUrl;
  final DateTime date;
  final bool isActive;
  final DateTime createdAt;

  ExamModel({
    required this.id,
    required this.title,
    required this.visibility,
    this.targetInstitutionId,
    this.pdfUrl,
    required this.date,
    this.isActive = true,
    required this.createdAt,
  });

  /// Firestore'dan gelen veriyi modele çevir
  factory ExamModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExamModel(
      id: doc.id,
      title: data['title'] ?? '',
      visibility: data['visibility'] ?? 'public',
      targetInstitutionId: data['target_institution_id'],
      pdfUrl: data['pdf_url'],
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['is_active'] ?? true,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Modeli Firestore'a yazılacak formata çevir
  Map<String, dynamic> toFirestore() => {
    'title': title,
    'visibility': visibility,
    'target_institution_id': targetInstitutionId,
    'pdf_url': pdfUrl,
    'date': Timestamp.fromDate(date),
    'is_active': isActive,
    'created_at': FieldValue.serverTimestamp(),
  };

  /// Kullanıcıya görünür mü?
  bool isVisibleTo(String userRole, String? userInstitutionId) {
    // Public sınavlar herkese açık
    if (visibility == 'public') return true;
    
    // Private sınavlar sadece ilgili kurum öğrencilerine
    if (visibility == 'private') {
      return userInstitutionId == targetInstitutionId;
    }
    
    return false;
  }
}
