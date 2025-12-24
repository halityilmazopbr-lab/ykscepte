/// Excel Sonuç Import Servisi
/// 
/// Kurumların yüklediği Excel dosyalarını parse eder ve
/// öğrenci bazlı deneme sonuçlarına dönüştürür.

import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'data.dart';

/// Eşleştirme kriteri
enum EslestirmeKriteri {
  ogrenciNo,  // Öğrenci numarasına göre
  ogrenciAd,  // Öğrenci adına göre
}

/// Excel import sonucu
class ExcelImportSonuc {
  final int basarili;
  final int basarisiz;
  final List<String> hatalar;
  final List<DenemeSonucu> eklenenSonuclar;

  ExcelImportSonuc({
    required this.basarili,
    required this.basarisiz,
    required this.hatalar,
    required this.eklenenSonuclar,
  });

  bool get tamamenBasarili => basarisiz == 0;
}

/// Excel Import Servisi
class ExcelImportService {
  
  /// Excel dosyasını parse et ve deneme sonuçlarına dönüştür
  static ExcelImportSonuc parseExcel({
    required Uint8List bytes,
    required String denemeTuru, // TYT, AYT Sayısal, vs.
    required String denemeAdi,
    required EslestirmeKriteri kriter,
    required String kurumId,
  }) {
    int basarili = 0;
    int basarisiz = 0;
    List<String> hatalar = [];
    List<DenemeSonucu> sonuclar = [];

    try {
      final excel = Excel.decodeBytes(bytes);
      
      // İlk sheet'i al
      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null || sheet.rows.isEmpty) {
        hatalar.add("Excel dosyası boş veya okunamadı.");
        return ExcelImportSonuc(
          basarili: 0, basarisiz: 1, hatalar: hatalar, eklenenSonuclar: [],
        );
      }

      // İlk satır başlık satırı, atla
      final rows = sheet.rows.skip(1).toList();

      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        
        try {
          // Excel formatı:
          // [0]: Öğrenci No
          // [1]: Öğrenci Adı
          // [2]: Türkçe D, [3]: Türkçe Y
          // [4]: Mat D, [5]: Mat Y
          // [6]: Fizik D, [7]: Fizik Y
          // ... (ders sayısına göre devam eder)
          
          final ogrenciNo = _getCellValue(row[0]);
          final ogrenciAd = _getCellValue(row[1]);
          
          if (ogrenciNo.isEmpty && ogrenciAd.isEmpty) continue;

          // Öğrenciyi bul
          Ogrenci? ogrenci = _findOgrenci(
            kriter: kriter,
            no: ogrenciNo,
            ad: ogrenciAd,
            kurumId: kurumId,
          );

          if (ogrenci == null) {
            basarisiz++;
            hatalar.add("Satır ${i + 2}: Öğrenci bulunamadı ($ogrenciNo / $ogrenciAd)");
            continue;
          }

          // Ders netlerini parse et
          Map<String, double> dersNetleri = _parseDersNetleri(row, denemeTuru);
          double toplamNet = dersNetleri.values.fold(0.0, (sum, net) => sum + net);

          // Deneme sonucu oluştur
          final sonuc = DenemeSonucu(
            ogrenciId: ogrenci.id,
            tur: denemeTuru,
            tarih: DateTime.now(),
            toplamNet: toplamNet,
            dersNetleri: dersNetleri,
          );

          sonuclar.add(sonuc);
          basarili++;

        } catch (e) {
          basarisiz++;
          hatalar.add("Satır ${i + 2}: Parse hatası - $e");
        }
      }
    } catch (e) {
      hatalar.add("Excel dosyası okunamadı: $e");
      return ExcelImportSonuc(
        basarili: 0, basarisiz: 1, hatalar: hatalar, eklenenSonuclar: [],
      );
    }

    return ExcelImportSonuc(
      basarili: basarili,
      basarisiz: basarisiz,
      hatalar: hatalar,
      eklenenSonuclar: sonuclar,
    );
  }

  /// Öğrenciyi bul
  static Ogrenci? _findOgrenci({
    required EslestirmeKriteri kriter,
    required String no,
    required String ad,
    required String kurumId,
  }) {
    // Kuruma ait öğrencileri filtrele
    final kurumOgrencileri = VeriDeposu.ogrenciler
        .where((o) => o.kurumKodu == kurumId)
        .toList();

    if (kriter == EslestirmeKriteri.ogrenciNo) {
      try {
        return kurumOgrencileri.firstWhere(
          (o) => o.id == no || o.okulNo == no || o.tcNo == no,
        );
      } catch (e) {
        return null;
      }
    } else {
      // Ad ile eşleştir
      try {
        final normalizedAd = ad.toLowerCase().trim();
        return kurumOgrencileri.firstWhere(
          (o) => o.ad.toLowerCase().trim() == normalizedAd ||
                 o.ad.toLowerCase().replaceAll(" ", "") == normalizedAd.replaceAll(" ", ""),
        );
      } catch (e) {
        return null;
      }
    }
  }

  /// Ders netlerini parse et
  static Map<String, double> _parseDersNetleri(List<Data?> row, String denemeTuru) {
    Map<String, double> netler = {};
    
    // Ders listesini al
    List<String> dersler;
    if (denemeTuru == "TYT") {
      dersler = ["Türkçe", "Matematik", "Fizik", "Kimya", "Biyoloji", "Tarih", "Coğrafya", "Felsefe", "Din Kültürü"];
    } else if (denemeTuru == "AYT Sayısal") {
      dersler = ["Matematik", "Fizik", "Kimya", "Biyoloji"];
    } else if (denemeTuru == "AYT Eşit Ağırlık" || denemeTuru == "AYT EA") {
      dersler = ["Edebiyat", "Tarih-1", "Coğrafya-1", "Matematik"];
    } else {
      dersler = ["Edebiyat", "Tarih-1", "Coğrafya-1", "Tarih-2", "Coğrafya-2", "Felsefe Grubu", "Din Kültürü"];
    }

    // Excel'de 2. sütundan itibaren her ders için D ve Y var
    int colIndex = 2; // 0: No, 1: Ad, 2'den itibaren dersler
    
    for (String ders in dersler) {
      if (colIndex + 1 >= row.length) break;
      
      int dogru = _getCellValueInt(row[colIndex]);
      int yanlis = _getCellValueInt(row[colIndex + 1]);
      double net = dogru - (yanlis / 4);
      netler[ders] = net;
      
      colIndex += 2; // Sonraki derse geç
    }

    return netler;
  }

  /// Hücre değerini string olarak al
  static String _getCellValue(Data? cell) {
    if (cell == null || cell.value == null) return "";
    final value = cell.value;
    // Excel 4.x: CellValue is a sealed class
    if (value is TextCellValue) return value.value.toString().trim();
    if (value is IntCellValue) return value.value.toString();
    if (value is DoubleCellValue) return value.value.toString();
    return value.toString().trim();
  }

  /// Hücre değerini int olarak al
  static int _getCellValueInt(Data? cell) {
    if (cell == null || cell.value == null) return 0;
    final value = cell.value;
    // Excel 4.x: CellValue is a sealed class
    if (value is IntCellValue) return value.value;
    if (value is DoubleCellValue) return value.value.toInt();
    if (value is TextCellValue) return int.tryParse(value.value.toString()) ?? 0;
    return 0;
  }

  /// Sonuçları kaydet
  static void sonuclariKaydet(List<DenemeSonucu> sonuclar) {
    for (var sonuc in sonuclar) {
      VeriDeposu.denemeListesi.add(sonuc);
    }
    VeriDeposu.kaydet();
  }
}

/// Excel şablonu oluştur (indirme için)
class ExcelTemplateGenerator {
  static List<List<String>> tytSablonu() {
    return [
      ["Öğrenci No", "Öğrenci Adı", "Türkçe D", "Türkçe Y", "Mat D", "Mat Y", 
       "Fizik D", "Fizik Y", "Kimya D", "Kimya Y", "Biyoloji D", "Biyoloji Y",
       "Tarih D", "Tarih Y", "Coğrafya D", "Coğrafya Y", "Felsefe D", "Felsefe Y",
       "Din K. D", "Din K. Y"],
      ["101", "Ahmet Yılmaz", "35", "5", "40", "8", "5", "2", "5", "2", "4", "2", 
       "4", "1", "4", "1", "4", "1", "4", "1"],
    ];
  }
}
