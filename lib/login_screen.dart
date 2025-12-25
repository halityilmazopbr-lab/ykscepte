import 'package:flutter/material.dart';
import 'data.dart';
import 'models.dart';
import 'kurum_models.dart';

/// 🔐 Rol Tabanlı Dinamik Giriş Ekranı
/// 
/// Seçilen role göre form değişir:
/// - Öğrenci: Email + Şifre, Kayıt Ol, Google ile Giriş
/// - Öğretmen: Email + Şifre (Kayıt yok - kurum ekler)
/// - Veli: Telefon + Öğrenci Kodu
/// - Kurum: Email + Şifre (Yönetici)
class RoleLoginScreen extends StatefulWidget {
  final String selectedRole;

  const RoleLoginScreen({super.key, required this.selectedRole});

  @override
  State<RoleLoginScreen> createState() => _RoleLoginScreenState();
}

class _RoleLoginScreenState extends State<RoleLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentCodeController = TextEditingController();
  
  bool isLoginMode = true;
  bool isLoading = false;
  bool obscurePassword = true;

  // Role göre Ayarlar
  Map<String, dynamic> get roleConfig {
    switch (widget.selectedRole) {
      case 'ogrenci':
        return {
          'title': 'Öğrenci Girişi',
          'subtitle': 'Hedefine bir adım daha yaklaş',
          'color': Colors.orange,
          'icon': Icons.school,
          'canRegister': true,
          'showGoogle': true,
          'inputLabel': 'E-Posta',
          'inputIcon': Icons.email,
        };
      case 'ogretmen':
        return {
          'title': 'Öğretmen Paneli',
          'subtitle': 'Öğrencilerinizi takip edin',
          'color': Colors.purple,
          'icon': Icons.history_edu,
          'canRegister': false,
          'showGoogle': false,
          'inputLabel': 'E-Posta / Kullanıcı Adı',
          'inputIcon': Icons.person,
        };
      case 'veli':
        return {
          'title': 'Veli Bilgilendirme',
          'subtitle': 'Çocuğunuzun gelişimini izleyin',
          'color': Colors.green,
          'icon': Icons.family_restroom,
          'canRegister': false,
          'showGoogle': false,
          'inputLabel': 'Telefon Numarası',
          'inputIcon': Icons.phone,
        };
      case 'kurum':
        return {
          'title': 'Kurum Yönetimi',
          'subtitle': 'Dershane & Okul paneli',
          'color': Colors.indigo,
          'icon': Icons.business,
          'canRegister': false,
          'showGoogle': false,
          'inputLabel': 'Yönetici E-Postası',
          'inputIcon': Icons.admin_panel_settings,
        };
      default:
        return {
          'title': 'Giriş Yap',
          'color': Colors.blue,
          'icon': Icons.login,
          'canRegister': false,
          'showGoogle': false,
          'inputLabel': 'E-Posta',
          'inputIcon': Icons.email,
        };
    }
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => isLoading = true);
    
    // Simüle edilmiş giriş - Gerçek Firebase entegrasyonu için güncelle
    await Future.delayed(const Duration(seconds: 1));
    
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    
    // Role göre farklı login işlemleri
    switch (widget.selectedRole) {
      case 'ogrenci':
        // Öğrenci girişi
        final ogrenci = VeriDeposu.ogrenciler.firstWhere(
          (o) => (o.email == email || o.tcNo == email) && o.sifre == password,
          orElse: () => Ogrenci(id: '', ad: '', sinif: ''),
        );
        if (ogrenci.id.isNotEmpty) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/ogrenciAnaSayfa', arguments: ogrenci);
        } else {
          _showError('Geçersiz e-posta veya şifre');
        }
        break;
        
      case 'ogretmen':
        // Öğretmen girişi
        final ogretmen = VeriDeposu.ogretmenler.firstWhere(
          (o) => o.tcNo == email && o.sifre == password,
          orElse: () => Ogretmen(id: '', ad: '', brans: ''),
        );
        if (ogretmen.id.isNotEmpty) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/ogretmenAnaSayfa', arguments: ogretmen);
        } else {
          _showError('Geçersiz kullanıcı adı veya şifre');
        }
        break;
        
      case 'veli':
        // Veli girişi - Öğrenci kodu ile
        String veliKodu = _studentCodeController.text.trim();
        final ogrenci = VeriDeposu.ogrenciler.firstWhere(
          (o) => o.veliErisimKodu == veliKodu,
          orElse: () => Ogrenci(id: '', ad: '', sinif: ''),
        );
        if (ogrenci.id.isNotEmpty) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/veliAnaSayfa', arguments: ogrenci);
        } else {
          _showError('Geçersiz öğrenci kodu');
        }
        break;
        
      case 'kurum':
        // Kurum girişi
        final kurum = VeriDeposu.kurumlar.firstWhere(
          (k) => k.adminEmail == email && k.adminSifre == password,
          orElse: () => Kurum(id: '', ad: '', adres: '', latitude: 0, longitude: 0),
        );
        if (kurum.id.isNotEmpty) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/kurumPaneli', arguments: kurum);
        } else {
          _showError('Geçersiz yönetici bilgileri');
        }
        break;
    }
    
    setState(() => isLoading = false);
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = roleConfig;
    final Color themeColor = config['color'];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ═══════════════════════════════════════════════════════
              // HEADER
              // ═══════════════════════════════════════════════════════
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(config['icon'], size: 40, color: themeColor),
              ),
              const SizedBox(height: 20),
              
              Text(
                config['title'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                config['subtitle'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade400),
              ),
              const SizedBox(height: 40),

              // ═══════════════════════════════════════════════════════
              // FORM ALANLARI
              // ═══════════════════════════════════════════════════════
              _buildTextField(
                controller: _emailController,
                label: config['inputLabel'],
                icon: config['inputIcon'],
                themeColor: themeColor,
                keyboardType: widget.selectedRole == 'veli' 
                    ? TextInputType.phone 
                    : TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Veli için Öğrenci Kodu alanı
              if (widget.selectedRole == 'veli') ...[
                _buildTextField(
                  controller: _studentCodeController,
                  label: 'Öğrenci Erişim Kodu',
                  icon: Icons.key,
                  themeColor: themeColor,
                ),
                const SizedBox(height: 16),
              ],
              
              // Şifre alanı (Veli hariç)
              if (widget.selectedRole != 'veli')
                _buildTextField(
                  controller: _passwordController,
                  label: 'Şifre',
                  icon: Icons.lock,
                  themeColor: themeColor,
                  isPassword: true,
                ),

              const SizedBox(height: 10),
              
              // Şifremi Unuttum
              if (widget.selectedRole != 'veli')
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text("Şifremi Unuttum", style: TextStyle(color: themeColor)),
                  ),
                ),

              const SizedBox(height: 24),

              // ═══════════════════════════════════════════════════════
              // GİRİŞ BUTONU
              // ═══════════════════════════════════════════════════════
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: themeColor.withAlpha(100),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isLoginMode ? "Giriş Yap" : "Kayıt Ol", 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // ═══════════════════════════════════════════════════════
              // SADECE ÖĞRENCİLER İÇİN KAYIT OL
              // ═══════════════════════════════════════════════════════
              if (config['canRegister']) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLoginMode ? "Hesabın yok mu?" : "Zaten hesabın var mı?",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () => setState(() => isLoginMode = !isLoginMode),
                      child: Text(
                        isLoginMode ? "Kayıt Ol" : "Giriş Yap",
                        style: TextStyle(fontWeight: FontWeight.bold, color: themeColor),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Google ile Giriş
              if (config['showGoogle']) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade700)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("veya", style: TextStyle(color: Colors.grey.shade500)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade700)),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Image.network(
                    'https://www.google.com/favicon.ico',
                    height: 20,
                    errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata),
                  ),
                  label: const Text("Google ile Devam Et"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade700),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],

              // ═══════════════════════════════════════════════════════
              // ÖĞRETMEN VE KURUM İÇİN BİLGİ NOTU
              // ═══════════════════════════════════════════════════════
              if (!config['canRegister'])
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21262D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeColor.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: themeColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.selectedRole == 'veli' 
                            ? "İlk giriş için öğrencinizden 'Veli Davet Kodu'nu isteyiniz."
                            : "Hesabınız kurum yöneticiniz tarafından oluşturulmalıdır.",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color themeColor,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && obscurePassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label gerekli';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: themeColor),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade500,
                ),
                onPressed: () => setState(() => obscurePassword = !obscurePassword),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF21262D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _studentCodeController.dispose();
    super.dispose();
  }
}
