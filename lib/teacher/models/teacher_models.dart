import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// 📝 ÖDEV MODELİ
// ═══════════════════════════════════════════════════════════════
class AssignmentModel {
  final String id;
  final String teacherId;
  final String teacherName;
  final List<String> targetClassIds;
  final String lesson;
  final String topic;
  final String description;
  final DateTime dueDate;
  final String? attachmentUrl;
  final DateTime createdAt;
  final Map<String, AssignmentStatus> studentStatuses; // ogrenciId -> status

  AssignmentModel({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.targetClassIds,
    required this.lesson,
    required this.topic,
    required this.description,
    required this.dueDate,
    this.attachmentUrl,
    required this.createdAt,
    this.studentStatuses = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'teacherId': teacherId,
    'teacherName': teacherName,
    'targetClassIds': targetClassIds,
    'lesson': lesson,
    'topic': topic,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'attachmentUrl': attachmentUrl,
    'createdAt': createdAt.toIso8601String(),
    'studentStatuses': studentStatuses.map((k, v) => MapEntry(k, v.toJson())),
  };

  factory AssignmentModel.fromJson(Map<String, dynamic> json) => AssignmentModel(
    id: json['id'],
    teacherId: json['teacherId'],
    teacherName: json['teacherName'],
    targetClassIds: List<String>.from(json['targetClassIds']),
    lesson: json['lesson'],
    topic: json['topic'],
    description: json['description'],
    dueDate: DateTime.parse(json['dueDate']),
    attachmentUrl: json['attachmentUrl'],
    createdAt: DateTime.parse(json['createdAt']),
    studentStatuses: (json['studentStatuses'] as Map<String, dynamic>?)?.map(
      (k, v) => MapEntry(k, AssignmentStatus.fromJson(v)),
    ) ?? {},
  );

  // Tamamlanma yüzdesi
  double get completionRate {
    if (studentStatuses.isEmpty) return 0;
    final completed = studentStatuses.values.where((s) => s.isCompleted).length;
    return completed / studentStatuses.length;
  }

  // Durum kontrolü
  bool get isOverdue => DateTime.now().isAfter(dueDate);
}

// Öğrenci ödev durumu
class AssignmentStatus {
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isRejected; // Öğretmen reddetti
  final String? rejectionNote;

  AssignmentStatus({
    this.isCompleted = false,
    this.completedAt,
    this.isRejected = false,
    this.rejectionNote,
  });

  Map<String, dynamic> toJson() => {
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
    'isRejected': isRejected,
    'rejectionNote': rejectionNote,
  };

  factory AssignmentStatus.fromJson(Map<String, dynamic> json) => AssignmentStatus(
    isCompleted: json['isCompleted'] ?? false,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    isRejected: json['isRejected'] ?? false,
    rejectionNote: json['rejectionNote'],
  );
}

// ═══════════════════════════════════════════════════════════════
// 📋 YOKLAMA MODELİ
// ═══════════════════════════════════════════════════════════════
class AttendanceModel {
  final String id;
  final String classId;
  final String className;
  final String teacherId;
  final DateTime date;
  final String qrCode; // 6 haneli kod
  final List<AttendanceRecord> records;
  final bool isActive; // QR hala geçerli mi?

  AttendanceModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.teacherId,
    required this.date,
    required this.qrCode,
    this.records = const [],
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'classId': classId,
    'className': className,
    'teacherId': teacherId,
    'date': date.toIso8601String(),
    'qrCode': qrCode,
    'records': records.map((r) => r.toJson()).toList(),
    'isActive': isActive,
  };

  factory AttendanceModel.fromJson(Map<String, dynamic> json) => AttendanceModel(
    id: json['id'],
    classId: json['classId'],
    className: json['className'],
    teacherId: json['teacherId'],
    date: DateTime.parse(json['date']),
    qrCode: json['qrCode'],
    records: (json['records'] as List?)?.map((r) => AttendanceRecord.fromJson(r)).toList() ?? [],
    isActive: json['isActive'] ?? true,
  );

  int get presentCount => records.where((r) => r.isPresent).length;
  int get absentCount => records.where((r) => !r.isPresent).length;
}

class AttendanceRecord {
  final String studentId;
  final String studentName;
  final bool isPresent;
  final DateTime? checkInTime;

  AttendanceRecord({
    required this.studentId,
    required this.studentName,
    this.isPresent = false,
    this.checkInTime,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'studentName': studentName,
    'isPresent': isPresent,
    'checkInTime': checkInTime?.toIso8601String(),
  };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(
    studentId: json['studentId'],
    studentName: json['studentName'],
    isPresent: json['isPresent'] ?? false,
    checkInTime: json['checkInTime'] != null ? DateTime.parse(json['checkInTime']) : null,
  );
}

// ═══════════════════════════════════════════════════════════════
// 🏫 SINIF MODELİ
// ═══════════════════════════════════════════════════════════════
class ClassModel {
  final String id;
  final String name; // "12-A Sayısal"
  final String grade; // "12"
  final String section; // "A"
  final String type; // "Sayısal", "EA", "Sözel", "Dil"
  final String teacherId; // Sınıf öğretmeni
  final List<String> studentIds;
  final String? room; // "302 No'lu Sınıf"
  final String kurumId;

  ClassModel({
    required this.id,
    required this.name,
    required this.grade,
    required this.section,
    required this.type,
    required this.teacherId,
    this.studentIds = const [],
    this.room,
    required this.kurumId,
  });

  int get studentCount => studentIds.length;
}

// ═══════════════════════════════════════════════════════════════
// 📅 DERS PROGRAMI MODELİ
// ═══════════════════════════════════════════════════════════════
class LessonSchedule {
  final String id;
  final String teacherId;
  final String classId;
  final String className;
  final String lesson; // "Matematik"
  final String topic; // "Türev"
  final int dayOfWeek; // 1=Pazartesi, 5=Cuma
  final String startTime; // "14:00"
  final String endTime; // "14:40"
  final String? room;

  LessonSchedule({
    required this.id,
    required this.teacherId,
    required this.classId,
    required this.className,
    required this.lesson,
    this.topic = "",
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
  });
}

// ═══════════════════════════════════════════════════════════════
// 📚 ÖĞRETMEN İÇERİK MODELİ (PDF/FOTO)
// ═══════════════════════════════════════════════════════════════
enum ContentType { pdf, image }
enum ContentCategory { quiz, trial, summary, question, other }

class TeacherContentModel {
  final String id;
  final String title;
  final String description;
  final ContentType type;
  final ContentCategory category;
  final String fileUrl;
  final String teacherId;
  final String teacherName;
  final String? classId; // Tüm sınıfa
  final String? studentId; // Tek öğrenciye
  final DateTime createdAt;

  TeacherContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.fileUrl,
    required this.teacherId,
    required this.teacherName,
    this.classId,
    this.studentId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.toString(),
    'category': category.toString(),
    'fileUrl': fileUrl,
    'teacherId': teacherId,
    'teacherName': teacherName,
    'classId': classId,
    'studentId': studentId,
    'createdAt': createdAt.toIso8601String(),
  };
}

// ═══════════════════════════════════════════════════════════════
// ❓ SORU ÇÖZÜM MERKEZİ MODELLERİ
// ═══════════════════════════════════════════════════════════════

enum SolutionType { text, image, audio, hybrid }
enum QuestionStatus { pending, solved, rejected }

class TeacherSolutionModel {
  final String text; // Metin çözümü
  final String? imageUrl; // Fotoğraf çözümü
  final String? audioUrl; // Sesli anlatım
  final SolutionType type;
  final DateTime solvedAt;

  TeacherSolutionModel({
    required this.text,
    this.imageUrl,
    this.audioUrl,
    required this.type,
    required this.solvedAt,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'imageUrl': imageUrl,
    'audioUrl': audioUrl,
    'type': type.toString(),
    'solvedAt': solvedAt.toIso8601String(),
  };

  factory TeacherSolutionModel.fromJson(Map<String, dynamic> json) => TeacherSolutionModel(
    text: json['text'] ?? '',
    imageUrl: json['imageUrl'],
    audioUrl: json['audioUrl'],
    type: SolutionType.values.firstWhere((e) => e.toString() == json['type'], orElse: () => SolutionType.text),
    solvedAt: DateTime.parse(json['solvedAt']),
  );
}

class StudentQuestionModel {
  final String id;
  final String studentId;
  final String studentName;
  final String teacherId; // Hedef öğretmen
  final String lesson;
  final String imageUrl; // Öğrenci soru fotosu
  final String? note; // Öğrenci notu
  final DateTime createdAt;
  final QuestionStatus status;
  final TeacherSolutionModel? solution;

  StudentQuestionModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.teacherId,
    required this.lesson,
    required this.imageUrl,
    this.note,
    required this.createdAt,
    this.status = QuestionStatus.pending,
    this.solution,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'studentName': studentName,
    'teacherId': teacherId,
    'lesson': lesson,
    'imageUrl': imageUrl,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'status': status.toString(),
    'solution': solution?.toJson(),
  };

  factory StudentQuestionModel.fromJson(Map<String, dynamic> json) => StudentQuestionModel(
    id: json['id'],
    studentId: json['studentId'],
    studentName: json['studentName'],
    teacherId: json['teacherId'],
    lesson: json['lesson'],
    imageUrl: json['imageUrl'],
    note: json['note'],
    createdAt: DateTime.parse(json['createdAt']),
    status: QuestionStatus.values.firstWhere((e) => e.toString() == json['status'], orElse: () => QuestionStatus.pending),
    solution: json['solution'] != null ? TeacherSolutionModel.fromJson(json['solution']) : null,
  );
}
