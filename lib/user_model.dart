import 'models.dart';
import 'kurum_models.dart';

/// Kullanıcı Rolü Enum
enum UserRole {
  ogrenci,
  veli,
  ogretmen,
  kurumYoneticisi,
  admin,
}

extension UserRoleExt on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.ogrenci:
        return "Öğrenci";
      case UserRole.veli:
        return "Veli";
      case UserRole.ogretmen:
        return "Öğretmen";
      case UserRole.kurumYoneticisi:
        return "Kurum Yöneticisi";
      case UserRole.admin:
        return "Yönetici";
    }
  }

  String get firestoreValue {
    switch (this) {
      case UserRole.ogrenci:
        return "ogrenci";
      case UserRole.veli:
        return "veli";
      case UserRole.ogretmen:
        return "ogretmen";
      case UserRole.kurumYoneticisi:
        return "kurum_yoneticisi";
      case UserRole.admin:
        return "admin";
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case "ogrenci":
      case "Öğrenci":
        return UserRole.ogrenci;
      case "veli":
      case "Veli":
        return UserRole.veli;
      case "ogretmen":
      case "Öğretmen":
        return UserRole.ogretmen;
      case "kurum_yoneticisi":
      case "KurumYoneticisi":
        return UserRole.kurumYoneticisi;
      case "admin":
      case "Yönetici":
        return UserRole.admin;
      default:
        return UserRole.ogrenci;
    }
  }
}

/// Birleşik Kullanıcı Modeli
/// Tüm kullanıcı tiplerini tek bir sınıfta yönetir
class UserModel {
  final String id;
  final UserRole rol;
  final String? kurumId;
  
  // Alt modeller (rol bazlı)
  final Ogrenci? ogrenciData;
  final Ogretmen? ogretmenData;
  final KurumYoneticisi? yoneticiData;
  final String? veliOgrenciId; // Veli için takip edilen öğrenci

  UserModel({
    required this.id,
    required this.rol,
    this.kurumId,
    this.ogrenciData,
    this.ogretmenData,
    this.yoneticiData,
    this.veliOgrenciId,
  });

  /// Kurumsal kullanıcı mı? (Dershane/Okula bağlı)
  bool get isKurumsal => kurumId != null && kurumId!.isNotEmpty;

  /// Öğrenci mi?
  bool get isOgrenci => rol == UserRole.ogrenci;

  /// Veli mi?
  bool get isVeli => rol == UserRole.veli;

  /// Öğretmen mi?
  bool get isOgretmen => rol == UserRole.ogretmen;

  /// Kurum yöneticisi mi?
  bool get isKurumYoneticisi => rol == UserRole.kurumYoneticisi;

  /// Admin mi?
  bool get isAdmin => rol == UserRole.admin;

  /// Kullanıcı adını al
  String get displayName {
    if (ogrenciData != null) return ogrenciData!.ad;
    if (ogretmenData != null) return ogretmenData!.ad;
    if (yoneticiData != null) return yoneticiData!.ad;
    return "Kullanıcı";
  }

  /// Kurumsal özelliklere erişebilir mi?
  /// (QR Yoklama, Kurum Duyurular, Randevu vb.)
  bool get canAccessKurumsalFeatures => isKurumsal && (isOgrenci || isOgretmen);

  /// Factory: Öğrenci'den UserModel oluştur
  factory UserModel.fromOgrenci(Ogrenci ogrenci) {
    return UserModel(
      id: ogrenci.id,
      rol: UserRole.ogrenci,
      kurumId: ogrenci.kurumKodu,
      ogrenciData: ogrenci,
    );
  }

  /// Factory: Öğretmen'den UserModel oluştur
  factory UserModel.fromOgretmen(Ogretmen ogretmen, {String? kurumId}) {
    return UserModel(
      id: ogretmen.id,
      rol: UserRole.ogretmen,
      kurumId: kurumId,
      ogretmenData: ogretmen,
    );
  }

  /// Factory: Kurum Yöneticisi'nden UserModel oluştur
  factory UserModel.fromKurumYoneticisi(KurumYoneticisi yonetici) {
    return UserModel(
      id: yonetici.id,
      rol: UserRole.kurumYoneticisi,
      kurumId: yonetici.kurumId,
      yoneticiData: yonetici,
    );
  }

  /// Factory: Veli için UserModel oluştur
  factory UserModel.forVeli({
    required String id,
    required String ogrenciId,
    String? kurumId,
  }) {
    return UserModel(
      id: id,
      rol: UserRole.veli,
      kurumId: kurumId,
      veliOgrenciId: ogrenciId,
    );
  }

  /// Factory: Admin için UserModel oluştur
  factory UserModel.admin() {
    return UserModel(
      id: "admin",
      rol: UserRole.admin,
    );
  }

  /// JSON'a çevir (Firestore için)
  Map<String, dynamic> toJson() => {
    'id': id,
    'rol': rol.firestoreValue,
    'kurumId': kurumId,
    'veliOgrenciId': veliOgrenciId,
  };

  /// JSON'dan oluştur
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      rol: UserRoleExt.fromString(json['rol'] ?? 'ogrenci'),
      kurumId: json['kurumId'],
      veliOgrenciId: json['veliOgrenciId'],
    );
  }

  @override
  String toString() => 'UserModel(id: $id, rol: ${rol.displayName}, kurumsal: $isKurumsal)';
}
