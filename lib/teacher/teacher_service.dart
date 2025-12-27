import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'models/teacher_models.dart';
import '../models.dart';
import '../data.dart';

/// Öğretmen modülü servis katmanı
class TeacherService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // ═══════════════════════════════════════════════════════════════
  // 📚 DEMO VERİLER
  // ═══════════════════════════════════════════════════════════════
  
  /// Demo sınıflar
  static final List<ClassModel> demoClasses = [
    ClassModel(
      id: 'class_12a',
      name: '12-A Sayısal',
      grade: '12',
      section: 'A',
      type: 'Sayısal',
      teacherId: 'ogretmen1',
      studentIds: ['ogrenci1', 'ogrenci2', 'ogrenci3'],
      room: '302 No\'lu Sınıf',
      kurumId: 'kurum1',
    ),
    ClassModel(
      id: 'class_12b',
      name: '12-B Eşit Ağırlık',
      grade: '12',
      section: 'B',
      type: 'EA',
      teacherId: 'ogretmen1',
      studentIds: ['ogrenci4', 'ogrenci5'],
      room: '303 No\'lu Sınıf',
      kurumId: 'kurum1',
    ),
    ClassModel(
      id: 'class_11c',
      name: '11-C Sayısal',
      grade: '11',
      section: 'C',
      type: 'Sayısal',
      teacherId: 'ogretmen1',
      studentIds: ['ogrenci6', 'ogrenci7', 'ogrenci8'],
      room: '201 No\'lu Sınıf',
      kurumId: 'kurum1',
    ),
  ];
  
  /// Demo ders programı
  static List<LessonSchedule> getDemoSchedule(String teacherId) {
    return [
      LessonSchedule(
        id: 'lesson1',
        teacherId: teacherId,
        classId: 'class_12a',
        className: '12-A Sayısal',
        lesson: 'Matematik',
        topic: 'Türev Alma Kuralları',
        dayOfWeek: DateTime.now().weekday,
        startTime: '14:00',
        endTime: '14:40',
        room: '302 No\'lu Sınıf',
      ),
      LessonSchedule(
        id: 'lesson2',
        teacherId: teacherId,
        classId: 'class_12b',
        className: '12-B Eşit Ağırlık',
        lesson: 'Matematik',
        topic: 'İntegral',
        dayOfWeek: DateTime.now().weekday,
        startTime: '15:00',
        endTime: '15:40',
        room: '303 No\'lu Sınıf',
      ),
      LessonSchedule(
        id: 'lesson3',
        teacherId: teacherId,
        classId: 'class_11c',
        className: '11-C Sayısal',
        lesson: 'Matematik',
        topic: 'Limit',
        dayOfWeek: DateTime.now().weekday + 1,
        startTime: '09:00',
        endTime: '09:40',
        room: '201 No\'lu Sınıf',
      ),
    ];
  }
  
  /// Demo ödevler
  static List<AssignmentModel> getDemoAssignments(String teacherId) {
    return [
      AssignmentModel(
        id: 'hw1',
        teacherId: teacherId,
        teacherName: 'Ahmet Hoca',
        targetClassIds: ['class_12a'],
        lesson: 'Matematik',
        topic: 'Türev Test 4',
        description: '3D Yayınları, Sayfa 102-105 arası çözülecek.',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        studentStatuses: {
          'ogrenci1': AssignmentStatus(isCompleted: true, completedAt: DateTime.now()),
          'ogrenci2': AssignmentStatus(isCompleted: true, completedAt: DateTime.now()),
          'ogrenci3': AssignmentStatus(isCompleted: false),
        },
      ),
      AssignmentModel(
        id: 'hw2',
        teacherId: teacherId,
        teacherName: 'Ahmet Hoca',
        targetClassIds: ['class_11c'],
        lesson: 'Matematik',
        topic: 'Trigonometri Test 3',
        description: 'Palme Yayınları, Test 3-4-5 çözülecek.',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        studentStatuses: {
          'ogrenci6': AssignmentStatus(isCompleted: true, completedAt: DateTime.now()),
          'ogrenci7': AssignmentStatus(isCompleted: false),
          'ogrenci8': AssignmentStatus(isCompleted: false),
        },
      ),
    ];
  }
  
  // ═══════════════════════════════════════════════════════════════
  // 📝 ÖDEV İŞLEMLERİ
  // ═══════════════════════════════════════════════════════════════
  
  /// Yeni ödev oluştur
  static Future<String?> createAssignment(AssignmentModel assignment) async {
    try {
      final docRef = await _db.collection('assignments').add(assignment.toJson());
      
      // TODO: FCM bildirim gönder
      debugPrint('📚 Ödev oluşturuldu: ${assignment.topic}');
      
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Ödev oluşturma hatası: $e');
      return null;
    }
  }
  
  /// Öğretmenin ödevlerini getir
  static Future<List<AssignmentModel>> getTeacherAssignments(String teacherId) async {
    try {
      final snapshot = await _db
          .collection('assignments')
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => AssignmentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('❌ Ödev getirme hatası: $e');
      // Demo veriler dön
      return getDemoAssignments(teacherId);
    }
  }
  
  /// Öğrencinin ödevlerini getir
  static Future<List<AssignmentModel>> getStudentAssignments(String studentId, String classId) async {
    try {
      final snapshot = await _db
          .collection('assignments')
          .where('targetClassIds', arrayContains: classId)
          .orderBy('dueDate')
          .get();
      
      return snapshot.docs
          .map((doc) => AssignmentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('❌ Öğrenci ödev getirme hatası: $e');
      return [];
    }
  }
  
  /// Ödevi tamamla (Öğrenci)
  static Future<bool> completeAssignment(String assignmentId, String studentId) async {
    try {
      await _db.collection('assignments').doc(assignmentId).update({
        'studentStatuses.$studentId': AssignmentStatus(
          isCompleted: true,
          completedAt: DateTime.now(),
        ).toJson(),
      });
      
      // TODO: Öğretmene bildirim gönder
      debugPrint('✅ Ödev tamamlandı: $assignmentId');
      
      return true;
    } catch (e) {
      debugPrint('❌ Ödev tamamlama hatası: $e');
      return false;
    }
  }
  
  /// Ödevi reddet (Öğretmen)
  static Future<bool> rejectAssignment(String assignmentId, String studentId, String note) async {
    try {
      await _db.collection('assignments').doc(assignmentId).update({
        'studentStatuses.$studentId': AssignmentStatus(
          isCompleted: false,
          isRejected: true,
          rejectionNote: note,
        ).toJson(),
      });
      
      // TODO: Öğrenciye ve veliye bildirim gönder
      debugPrint('❌ Ödev reddedildi: $assignmentId');
      
      return true;
    } catch (e) {
      debugPrint('❌ Ödev reddetme hatası: $e');
      return false;
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // 📋 YOKLAMA İŞLEMLERİ
  // ═══════════════════════════════════════════════════════════════
  
  /// QR kod oluştur
  static String generateQRCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
  
  /// Yoklama başlat
  static Future<AttendanceModel?> startAttendance(String teacherId, ClassModel classInfo) async {
    try {
      final qrCode = generateQRCode();
      final attendance = AttendanceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        classId: classInfo.id,
        className: classInfo.name,
        teacherId: teacherId,
        date: DateTime.now(),
        qrCode: qrCode,
        isActive: true,
      );
      
      await _db.collection('attendances').doc(attendance.id).set(attendance.toJson());
      
      debugPrint('📋 Yoklama başlatıldı: ${classInfo.name} - QR: $qrCode');
      return attendance;
    } catch (e) {
      debugPrint('❌ Yoklama başlatma hatası: $e');
      return null;
    }
  }
  
  /// QR ile yoklamaya katıl (Öğrenci)
  static Future<bool> checkIn(String qrCode, String studentId, String studentName) async {
    try {
      // QR koduna göre yoklamayı bul
      final snapshot = await _db
          .collection('attendances')
          .where('qrCode', isEqualTo: qrCode)
          .where('isActive', isEqualTo: true)
          .get();
      
      if (snapshot.docs.isEmpty) {
        debugPrint('❌ Geçersiz veya süresi dolmuş QR kod');
        return false;
      }
      
      final doc = snapshot.docs.first;
      final attendance = AttendanceModel.fromJson(doc.data());
      
      // Kayıt ekle
      final newRecord = AttendanceRecord(
        studentId: studentId,
        studentName: studentName,
        isPresent: true,
        checkInTime: DateTime.now(),
      );
      
      await _db.collection('attendances').doc(doc.id).update({
        'records': FieldValue.arrayUnion([newRecord.toJson()]),
      });
      
      debugPrint('✅ Yoklama kaydı: $studentName');
      return true;
    } catch (e) {
      debugPrint('❌ Yoklama katılım hatası: $e');
      return false;
    }
  }
  
  /// Yoklamayı kapat
  static Future<bool> endAttendance(String attendanceId) async {
    try {
      await _db.collection('attendances').doc(attendanceId).update({
        'isActive': false,
      });
      
      debugPrint('📋 Yoklama kapatıldı: $attendanceId');
      return true;
    } catch (e) {
      debugPrint('❌ Yoklama kapatma hatası: $e');
      return false;
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // 👥 SINIF İŞLEMLERİ
  // ═══════════════════════════════════════════════════════════════
  
  /// Öğretmenin sınıflarını getir
  static List<ClassModel> getTeacherClasses(String teacherId) {
    // Demo için
    return demoClasses.where((c) => c.teacherId == teacherId).toList();
  }
  
  /// Sınıftaki öğrencileri getir
  static List<Ogrenci> getClassStudents(String classId) {
    final classInfo = demoClasses.firstWhere(
      (c) => c.id == classId,
      orElse: () => demoClasses.first,
    );
    
    return VeriDeposu.ogrenciler
        .where((o) => classInfo.studentIds.contains(o.id))
        .toList();
  }
  // ═══════════════════════════════════════════════════════════════
  // 📤 İÇERİK YÜKLEME (PDF/FOTO)
  // ═══════════════════════════════════════════════════════════════
  
  static Future<bool> uploadContent(TeacherContentModel content) async {
    try {
      // Demo: Collection'a yaz
      await _db.collection('teacher_contents').doc(content.id).set(content.toJson());
      debugPrint('📤 İçerik yüklendi: ${content.title} (${content.type})');
      return true;
    } catch (e) {
      debugPrint('❌ İçerik yükleme hatası: $e');
      return false; // Demo modunda olduğumuz için true dönebiliriz ama loglanması iyidir
    }
  }
}
