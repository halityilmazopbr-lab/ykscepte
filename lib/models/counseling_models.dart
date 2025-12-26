import 'package:cloud_firestore/cloud_firestore.dart';

/// Danışmanlık Paket Türleri
enum CounselingPackageType { standard, premium, vip }

/// Danışmanlık Paketi Modeli
class CounselingPackage {
  final String id;
  final CounselingPackageType type;
  final String name;
  final double price;
  final int sessionsPerMonth;
  final int sessionDurationMinutes;
  final String whatsappSupportLevel; // "48h", "24h", "12h"
  final bool includesProgressReport;
  final bool includesParentMeeting;
  final bool includesEmergencySession;
  final List<String> features;

  CounselingPackage({
    required this.id,
    required this.type,
    required this.name,
    required this.price,
    required this.sessionsPerMonth,
    required this.sessionDurationMinutes,
    required this.whatsappSupportLevel,
    this.includesProgressReport = false,
    this.includesParentMeeting = false,
    this.includesEmergencySession = false,
    required this.features,
  });

  /// Öndeğer paketler
  static List<CounselingPackage> getDefaultPackages() {
    return [
      CounselingPackage(
        id: 'standard',
        type: CounselingPackageType.standard,
        name: 'Standart Paket',
        price: 1499,
        sessionsPerMonth: 4,
        sessionDurationMinutes: 30,
        whatsappSupportLevel: '48 saat içinde yanıt',
        includesProgressReport: false,
        features: [
          'Ayda 4 × 30 dk seans',
          'WhatsApp destek (48 saat)',
          'Basit ilerleme takibi',
        ],
      ),
      CounselingPackage(
        id: 'premium',
        type: CounselingPackageType.premium,
        name: 'Premium Paket',
        price: 1990,
        sessionsPerMonth: 4,
        sessionDurationMinutes: 30,
        whatsappSupportLevel: '24 saat içinde yanıt',
        includesProgressReport: true,
        features: [
          'Ayda 4 × 30 dk seans',
          'WhatsApp öncelikli (24 saat)',
          'Aylık detaylı ilerleme raporu',
          'Kişiselleştirilmiş ödev planı',
        ],
      ),
      CounselingPackage(
        id: 'vip',
        type: CounselingPackageType.vip,
        name: 'VIP Paket',
        price: 2990,
        sessionsPerMonth: 4,
        sessionDurationMinutes: 45,
        whatsappSupportLevel: '12 saat içinde yanıt',
        includesProgressReport: true,
        includesParentMeeting: true,
        includesEmergencySession: true,
        features: [
          '👑 SADECE 3 KİŞİYE ÖZEL (Sınırlı Kontenjan)',
          'Ayda 4 × 45 dk seans',
          'WhatsApp Ultra Hızlı (12 saat)',
          'Veli ile aylık bilgilendirme',
          'Kriz anlarında acil görüşme',
          'Detaylı ilerleme raporu',
        ],
      ),
    ];
  }
}

/// Randevu Durumu
enum AppointmentStatus { scheduled, completed, cancelled, noShow }

/// Randevu Modeli
class CounselingAppointment {
  final String id;
  final String studentId;
  final String counselorId;
  final DateTime scheduledTime;
  final int durationMinutes;
  final AppointmentStatus status;
  final String? meetingLink; // Zoom/Google Meet linki
  final String? notes; // Seans notları (danışman yazar)
  final DateTime? completedAt;

  CounselingAppointment({
    required this.id,
    required this.studentId,
    required this.counselorId,
    required this.scheduledTime,
    required this.durationMinutes,
    this.status = AppointmentStatus.scheduled,
    this.meetingLink,
    this.notes,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'counselorId': counselorId,
        'scheduledTime': Timestamp.fromDate(scheduledTime),
        'durationMinutes': durationMinutes,
        'status': status.toString(),
        'meetingLink': meetingLink,
        'notes': notes,
        'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      };

  factory CounselingAppointment.fromJson(Map<String, dynamic> json) => CounselingAppointment(
        id: json['id'],
        studentId: json['studentId'],
        counselorId: json['counselorId'],
        scheduledTime: (json['scheduledTime'] as Timestamp).toDate(),
        durationMinutes: json['durationMinutes'],
        status: AppointmentStatus.values.firstWhere((e) => e.toString() == json['status']),
        meetingLink: json['meetingLink'],
        notes: json['notes'],
        completedAt: json['completedAt'] != null ? (json['completedAt'] as Timestamp).toDate() : null,
      );
}

/// Öğrenci Paket Aboneliği
class StudentCounselingSubscription {
  final String id;
  final String studentId;
  final CounselingPackageType packageType;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final int remainingSessions; // Kalan seans hakkı
  final DateTime lastRenewalDate;

  StudentCounselingSubscription({
    required this.id,
    required this.studentId,
    required this.packageType,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.remainingSessions,
    required this.lastRenewalDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'packageType': packageType.toString(),
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'isActive': isActive,
        'remainingSessions': remainingSessions,
        'lastRenewalDate': Timestamp.fromDate(lastRenewalDate),
      };

  factory StudentCounselingSubscription.fromJson(Map<String, dynamic> json) => StudentCounselingSubscription(
        id: json['id'],
        studentId: json['studentId'],
        packageType: CounselingPackageType.values.firstWhere((e) => e.toString() == json['packageType']),
        startDate: (json['startDate'] as Timestamp).toDate(),
        endDate: json['endDate'] != null ? (json['endDate'] as Timestamp).toDate() : null,
        isActive: json['isActive'],
        remainingSessions: json['remainingSessions'],
        lastRenewalDate: (json['lastRenewalDate'] as Timestamp).toDate(),
      );
}
