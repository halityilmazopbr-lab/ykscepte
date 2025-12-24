import 'package:flutter/foundation.dart';
import 'user_model.dart';
import 'models.dart';
import 'kurum_models.dart';
import 'data.dart';

/// Kullanıcı State Yönetimi Provider
/// Uygulama genelinde kullanıcı durumunu yönetir
class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Kullanıcı giriş yapmış mı?
  bool get isAuthenticated => _currentUser != null;
  
  /// Kurumsal kullanıcı mı?
  bool get isKurumsal => _currentUser?.isKurumsal ?? false;
  
  /// Kullanıcı rolü
  UserRole? get userRole => _currentUser?.rol;
  
  /// Öğrenci verisi (varsa)
  Ogrenci? get ogrenciData => _currentUser?.ogrenciData;
  
  /// Öğretmen verisi (varsa)
  Ogretmen? get ogretmenData => _currentUser?.ogretmenData;
  
  /// Kurum yöneticisi verisi (varsa)
  KurumYoneticisi? get yoneticiData => _currentUser?.yoneticiData;

  /// Kurumsal özelliklere erişim
  bool get canAccessKurumsalFeatures => _currentUser?.canAccessKurumsalFeatures ?? false;

  /// SharedPreferences'tan kullanıcı bilgisini yükle
  Future<void> loadUserFromPrefs() async {
    _isLoading = true;
    notifyListeners();

    try {
      // VeriDeposu'dan mevcut sistem ile uyumlu yükleme
      String? kayitliId = VeriDeposu.aktifKullaniciId;
      String? kayitliRol = VeriDeposu.aktifKullaniciRol;

      if (kayitliId != null && kayitliRol != null) {
        await _loadUserByIdAndRole(kayitliId, kayitliRol);
      }
    } catch (e) {
      _errorMessage = "Kullanıcı yüklenirken hata: $e";
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ID ve rol ile kullanıcı yükle
  Future<void> _loadUserByIdAndRole(String id, String rol) async {
    switch (rol) {
      case "Öğrenci":
        final ogrenci = VeriDeposu.ogrenciler.firstWhere(
          (e) => e.id == id,
          orElse: () => VeriDeposu.ogrenciler.first,
        );
        _currentUser = UserModel.fromOgrenci(ogrenci);
        break;
        
      case "Öğretmen":
        final ogretmen = VeriDeposu.ogretmenler.firstWhere(
          (e) => e.id == id,
          orElse: () => VeriDeposu.ogretmenler.first,
        );
        _currentUser = UserModel.fromOgretmen(ogretmen);
        break;
        
      case "Veli":
        // Veli için öğrenci ID'sini çıkar (veli_101 -> 101)
        final ogrenciId = id.replaceFirst("veli_", "");
        _currentUser = UserModel.forVeli(id: id, ogrenciId: ogrenciId);
        break;
        
      case "KurumYoneticisi":
        final yonetici = VeriDeposu.kurumYoneticileri.firstWhere(
          (e) => e.id == id,
          orElse: () => VeriDeposu.kurumYoneticileri.first,
        );
        _currentUser = UserModel.fromKurumYoneticisi(yonetici);
        break;
        
      case "Yönetici":
        _currentUser = UserModel.admin();
        break;
    }
  }

  /// Öğrenci girişi
  Future<bool> loginAsOgrenci(String kullaniciAdi, String sifre) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = VeriDeposu.girisKontrol(kullaniciAdi, sifre);
      
      if (user != null && user is Ogrenci) {
        _currentUser = UserModel.fromOgrenci(user);
        await VeriDeposu.girisKaydet(user.id, "Öğrenci");
        notifyListeners();
        return true;
      }
      
      _errorMessage = "Hatalı kullanıcı adı veya şifre";
      return false;
    } catch (e) {
      _errorMessage = "Giriş hatası: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Öğretmen girişi
  Future<bool> loginAsOgretmen(String kullaniciAdi, String sifre) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = VeriDeposu.girisKontrol(kullaniciAdi, sifre);
      
      if (user != null && user is Ogretmen) {
        _currentUser = UserModel.fromOgretmen(user);
        await VeriDeposu.girisKaydet(user.id, "Öğretmen");
        notifyListeners();
        return true;
      }
      
      _errorMessage = "Hatalı kullanıcı adı veya şifre";
      return false;
    } catch (e) {
      _errorMessage = "Giriş hatası: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Veli girişi
  Future<bool> loginAsVeli(String ogrenciId, String erisimKodu) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ogrenci = VeriDeposu.veliGirisKontrol(ogrenciId, erisimKodu);
      
      if (ogrenci != null) {
        _currentUser = UserModel.forVeli(
          id: "veli_${ogrenci.id}",
          ogrenciId: ogrenci.id,
          kurumId: ogrenci.kurumKodu,
        );
        await VeriDeposu.girisKaydet("veli_${ogrenci.id}", "Veli");
        notifyListeners();
        return true;
      }
      
      _errorMessage = "Hatalı öğrenci ID veya erişim kodu";
      return false;
    } catch (e) {
      _errorMessage = "Giriş hatası: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Kurum yöneticisi girişi
  Future<bool> loginAsKurumYoneticisi(String kurumId, String sifre) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final (yonetici, kurum) = VeriDeposu.kurumYoneticisiGirisKontrol(kurumId, sifre);
      
      if (yonetici != null && kurum != null) {
        _currentUser = UserModel.fromKurumYoneticisi(yonetici);
        VeriDeposu.aktifKurum = kurum;
        await VeriDeposu.girisKaydet(yonetici.id, "KurumYoneticisi");
        notifyListeners();
        return true;
      }
      
      _errorMessage = "Hatalı kurum ID veya şifre";
      return false;
    } catch (e) {
      _errorMessage = "Giriş hatası: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Admin girişi
  Future<bool> loginAsAdmin(String kullaniciAdi, String sifre) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = VeriDeposu.girisKontrol(kullaniciAdi, sifre);
      
      if (user == "admin") {
        _currentUser = UserModel.admin();
        await VeriDeposu.girisKaydet("admin", "Yönetici");
        notifyListeners();
        return true;
      }
      
      _errorMessage = "Hatalı yönetici bilgileri";
      return false;
    } catch (e) {
      _errorMessage = "Giriş hatası: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Çıkış yap
  Future<void> logout() async {
    await VeriDeposu.cikisYap();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Kullanıcı bilgisini güncelle
  void updateUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Öğrenci verisini güncelle (Pro satın alma vb.)
  void updateOgrenciData(Ogrenci ogrenci) {
    if (_currentUser?.isOgrenci == true) {
      _currentUser = UserModel.fromOgrenci(ogrenci);
      notifyListeners();
    }
  }

  /// Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
