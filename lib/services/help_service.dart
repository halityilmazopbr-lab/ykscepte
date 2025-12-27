import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/help_request_model.dart';
import '../models/solution_model.dart';

class HelpService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String requestsCollection = 'help_requests';
  final String solutionsCollection = 'solutions';

  // --- PERSONA GENERATOR (ANONİMLİK) ---
  static const List<String> adjectives = ['Dahi', 'Hızlı', 'Zeki', 'Usta', 'Meraklı', 'Çalışkan'];
  static const List<String> nouns = ['Baykuş', 'Aslan', 'Tilki', 'Panda', 'Kartal', 'Arı'];
  
  String generatePersonaName(String userId) {
    // Statik bir hash ile her kullanıcıya her zaman aynı rastgele ismi verelim
    final index1 = userId.length % adjectives.length;
    final index2 = (userId.length + 5) % nouns.length;
    return "${adjectives[index1]} ${nouns[index2]}";
  }

  // --- AI GUARDIAN (KISA FİLTRE) ---
  bool isContentSafe(String text) {
    final badWords = ['argo1', 'küfür2', 'taciz3']; // Bu liste zenginleştirilecek
    final lowerText = text.toLowerCase();
    for (var word in badWords) {
      if (lowerText.contains(word)) return false;
    }
    return true;
  }

  // --- SORU İŞLEMLERİ ---

  Future<void> soruSor(HelpRequestModel request) async {
    if (!isContentSafe(request.description)) {
      throw Exception("Uygunsuz içerik tespit edildi!");
    }
    await _db.collection(requestsCollection).doc(request.id).set(request.toMap());
  }

  Stream<QuerySnapshot> soruAkisiGetir({String? lesson}) {
    Query query = _db.collection(requestsCollection)
        .where('isSolved', isEqualTo: false)
        .orderBy('timestamp', descending: true);
    
    if (lesson != null) {
      query = query.where('lesson', isEqualTo: lesson);
    }
    
    return query.snapshots();
  }

  // --- ÇÖZÜM İŞLEMLERİ ---

  Future<void> cozumGonder(SolutionModel solution) async {
    if (solution.text != null && !isContentSafe(solution.text!)) {
      throw Exception("Cevabınız uygunsuz içerik barındırıyor!");
    }

    // Transaction: Hem çözümü kaydet hem de sorudaki cevap sayısını artır
    await _db.runTransaction((transaction) async {
      final soruRef = _db.collection(requestsCollection).doc(solution.requestId);
      final querySnapshot = await transaction.get(soruRef);
      
      if (!querySnapshot.exists) throw Exception("Soru bulunamadı!");

      final cozumDoc = _db.collection(requestsCollection)
          .doc(solution.requestId)
          .collection(solutionsCollection)
          .doc();

      transaction.set(cozumDoc, solution.toMap());
      transaction.update(soruRef, {
        'solutionCount': FieldValue.increment(1),
      });
    });
  }

  Stream<QuerySnapshot> cozumleriGetir(String requestId) {
    return _db.collection(requestsCollection)
        .doc(requestId)
        .collection(solutionsCollection)
        .orderBy('isBestSolution', descending: true)
        .orderBy('timestamp', ascending: true)
        .snapshots();
  }

  Future<void> enIyiCevapSec(String requestId, String solutionId) async {
    await _db.runTransaction((transaction) async {
      final soruRef = _db.collection(requestsCollection).doc(requestId);
      final cozumRef = soruRef.collection(solutionsCollection).doc(solutionId);

      transaction.update(soruRef, {'isSolved': true});
      transaction.update(cozumRef, {'isBestSolution': true});
      
      // Not: Burada çözene Coin/XP ödülü eklenecek
    });
  }
}
