import 'package:cloud_firestore/cloud_firestore.dart';

/// Danışman Deneyim Seviyesi
enum CounselorLevel { beginner, standard, expert }

/// Başvuru Durumu
enum ApplicationStatus { pending, approved, rejected }

/// Danışman Modeli
class Counselor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final List<String> specializations; // ["Sınav Kaygısı", "Motivasyon"]
  final int experienceYears;
  final CounselorLevel level;
  final String bio;
  final double rating; // 0.0 - 5.0
  final int totalReviews;
  final bool isActive;
  final double monthlyPrice; // Aylık paket fiyatı
  final DateTime createdAt;
  final DateTime? approvedAt;

  Counselor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.specializations,
    required this.experienceYears,
    required this.level,
    required this.bio,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.isActive = true,
    required this.monthlyPrice,
    required this.createdAt,
    this.approvedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'photoUrl': photoUrl,
        'specializations': specializations,
        'experienceYears': experienceYears,
        'level': level.toString(),
        'bio': bio,
        'rating': rating,
        'totalReviews': totalReviews,
        'isActive': isActive,
        'monthlyPrice': monthlyPrice,
        'createdAt': Timestamp.fromDate(createdAt),
        'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      };

  factory Counselor.fromJson(Map<String, dynamic> json) => Counselor(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        photoUrl: json['photoUrl'],
        specializations: List<String>.from(json['specializations']),
        experienceYears: json['experienceYears'],
        level: CounselorLevel.values.firstWhere((e) => e.toString() == json['level']),
        bio: json['bio'],
        rating: (json['rating'] ?? 0.0).toDouble(),
        totalReviews: json['totalReviews'] ?? 0,
        isActive: json['isActive'] ?? true,
        monthlyPrice: (json['monthlyPrice']).toDouble(),
        createdAt: (json['createdAt'] as Timestamp).toDate(),
        approvedAt: json['approvedAt'] != null ? (json['approvedAt'] as Timestamp).toDate() : null,
      );

  /// Seviyeye göre fiyat önerisi
  static double getPriceForLevel(CounselorLevel level) {
    switch (level) {
      case CounselorLevel.beginner:
        return 1199;
      case CounselorLevel.standard:
        return 1599;
      case CounselorLevel.expert:
        return 1999;
    }
  }

  /// Komisyon hesaplama (%20)
  double get platformCommission => monthlyPrice * 0.20;
  double get counselorEarnings => monthlyPrice * 0.80;
}

/// Danışman Başvuru Modeli
class CounselorApplication {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? resumeUrl; // CV linki
  final String? diplomaUrl; // Diploma linki
  final List<String> specializations;
  final int experienceYears;
  final String bio;
  final ApplicationStatus status;
  final String? rejectionReason;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  CounselorApplication({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.resumeUrl,
    this.diplomaUrl,
    required this.specializations,
    required this.experienceYears,
    required this.bio,
    this.status = ApplicationStatus.pending,
    this.rejectionReason,
    required this.submittedAt,
    this.reviewedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'resumeUrl': resumeUrl,
        'diplomaUrl': diplomaUrl,
        'specializations': specializations,
        'experienceYears': experienceYears,
        'bio': bio,
        'status': status.toString(),
        'rejectionReason': rejectionReason,
        'submittedAt': Timestamp.fromDate(submittedAt),
        'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      };

  factory CounselorApplication.fromJson(Map<String, dynamic> json) => CounselorApplication(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        resumeUrl: json['resumeUrl'],
        diplomaUrl: json['diplomaUrl'],
        specializations: List<String>.from(json['specializations']),
        experienceYears: json['experienceYears'],
        bio: json['bio'],
        status: ApplicationStatus.values.firstWhere((e) => e.toString() == json['status']),
        rejectionReason: json['rejectionReason'],
        submittedAt: (json['submittedAt'] as Timestamp).toDate(),
        reviewedAt: json['reviewedAt'] != null ? (json['reviewedAt'] as Timestamp).toDate() : null,
      );

  /// Deneyime göre otomatik seviye belirleme
  CounselorLevel get suggestedLevel {
    if (experienceYears >= 8) return CounselorLevel.expert;
    if (experienceYears >= 4) return CounselorLevel.standard;
    return CounselorLevel.beginner;
  }
}

/// Seans Değerlendirme Modeli
class SessionReview {
  final String id;
  final String studentId;
  final String counselorId;
  final String sessionId;
  final int rating; // 1-5
  final String? comment;
  final bool wouldRecommend;
  final DateTime createdAt;

  SessionReview({
    required this.id,
    required this.studentId,
    required this.counselorId,
    required this.sessionId,
    required this.rating,
    this.comment,
    required this.wouldRecommend,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'counselorId': counselorId,
        'sessionId': sessionId,
        'rating': rating,
        'comment': comment,
        'wouldRecommend': wouldRecommend,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory SessionReview.fromJson(Map<String, dynamic> json) => SessionReview(
        id: json['id'],
        studentId: json['studentId'],
        counselorId: json['counselorId'],
        sessionId: json['sessionId'],
        rating: json['rating'],
        comment: json['comment'],
        wouldRecommend: json['wouldRecommend'],
        createdAt: (json['createdAt'] as Timestamp).toDate(),
      );
}

/// Uzmanlık Alanları (Sabit Liste)
class Specializations {
  static const List<String> all = [
    'Sınav Kaygısı',
    'Motivasyon',
    'Burnout / Tükenmişlik',
    'Aile İlişkileri',
    'Kariyer Danışmanlığı',
    'Öfke Yönetimi',
    'Sosyal Kaygı',
    'Depresyon',
  ];
}
