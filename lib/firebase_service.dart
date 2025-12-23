import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'models.dart';

/// Firebase servisleri - Hata Defteri için Storage ve Firestore işlemleri
class HataDefterService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'mistakes';

  /// Fotoğrafı sıkıştırıp Firebase Storage'a yükler
  /// Dönen değer: İndirme URL'i
  static Future<String?> uploadImage(File originalFile, String userId) async {
    try {
      // 1. Geçici dizin al
      final tempDir = await getTemporaryDirectory();
      final outPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_out.jpg';

      // 2. Sıkıştırma işlemi (10MB -> ~150KB)
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        originalFile.path,
        outPath,
        quality: 60, // Kaliteyi %60'a düşür
        minWidth: 1024,
        minHeight: 1024,
      );

      if (compressedFile == null) {
        print('Sıkıştırma başarısız');
        return null;
      }

      // 3. Firebase Storage'a yükle
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('mistakes/$userId/$fileName');
      await ref.putFile(File(compressedFile.path));

      // 4. İndirme URL'ini al ve döndür
      final url = await ref.getDownloadURL();
      print('Yüklenen Resim URL: $url');
      return url;
    } catch (e) {
      print('Resim yükleme hatası: $e');
      return null;
    }
  }

  /// Yeni hata sorusu ekle
  static Future<String?> addMistake(HataSorusu soru) async {
    try {
      final docRef = await _firestore.collection(_collection).add(soru.toJson());
      return docRef.id;
    } catch (e) {
      print('Hata sorusu ekleme hatası: $e');
      return null;
    }
  }

  /// Öğrencinin tüm hata sorularını getir
  static Future<List<HataSorusu>> getMistakes(String ogrenciId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('ogrenciId', isEqualTo: ogrenciId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HataSorusu.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Hata soruları getirme hatası: $e');
      return [];
    }
  }

  /// Çözülmemiş soruları rastgele getir (Beni Sına modu için)
  static Future<List<HataSorusu>> getUnresolvedRandom(
      String ogrenciId, int limit) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('ogrenciId', isEqualTo: ogrenciId)
          .where('isResolved', isEqualTo: false)
          .get();

      final list = snapshot.docs
          .map((doc) => HataSorusu.fromJson(doc.data(), doc.id))
          .toList();

      // Karıştır ve limit kadar döndür
      list.shuffle();
      return list.take(limit).toList();
    } catch (e) {
      print('Rastgele sorular getirme hatası: $e');
      return [];
    }
  }

  /// Çözüldü olarak işaretle
  static Future<bool> markAsResolved(String docId, bool resolved) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(docId)
          .update({'isResolved': resolved});
      return true;
    } catch (e) {
      print('Çözüldü güncelleme hatası: $e');
      return false;
    }
  }

  /// Hata sorusunu sil (Storage'dan da)
  static Future<bool> deleteMistake(HataSorusu soru) async {
    try {
      // Firestore'dan sil
      if (soru.id != null) {
        await _firestore.collection(_collection).doc(soru.id).delete();
      }

      // Storage'dan sil (URL'den referans al)
      try {
        final ref = _storage.refFromURL(soru.imageUrl);
        await ref.delete();
      } catch (e) {
        print('Storage silme hatası (göz ardı edildi): $e');
      }

      return true;
    } catch (e) {
      print('Silme hatası: $e');
      return false;
    }
  }

  /// Derse göre filtrele
  static Future<List<HataSorusu>> getMistakesByLesson(
      String ogrenciId, String ders) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('ogrenciId', isEqualTo: ogrenciId)
          .where('ders', isEqualTo: ders)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HataSorusu.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Derse göre filtreleme hatası: $e');
      return [];
    }
  }
}
