import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../app_theme.dart';

/// 🚪 4 Kapılı Giriş Portalı
/// 
/// Rol Tabanlı Erişim Kontrolü (RBAC):
/// - 🎓 Öğrenci: Google + Email, Kayıt Ol var
/// - 👩‍🏫 Öğretmen: Kurum şifresi ile, Kayıt yok
/// - 👨‍👩‍👧 Veli: SMS veya Öğrenci Kodu ile
/// - 🏢 Kurum: Yönetici Paneli Girişi
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1117), Color(0xFF161B22)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // ═══════════════════════════════════════════════════════
                // LOGO VE BAŞLIK
                // ═══════════════════════════════════════════════════════
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade700, Colors.blue.shade600],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withAlpha(100),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.hub, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  "YKS Cepte'ye Hoş Geldiniz",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Devam etmek için lütfen kimliğinizi seçin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
                const SizedBox(height: 40),

                // ═══════════════════════════════════════════════════════
                // 4 FARKLI ROL KARTI
                // ═══════════════════════════════════════════════════════
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      _buildRoleCard(
                        context,
                        title: "Öğrenci",
                        subtitle: "Ders çalış, sınav kazan",
                        icon: Icons.school_outlined,
                        color: Colors.orange,
                        roleId: "ogrenci",
                      ),
                      _buildRoleCard(
                        context,
                        title: "Öğretmen",
                        subtitle: "Öğrencilerini takip et",
                        icon: Icons.history_edu,
                        color: Colors.purple,
                        roleId: "ogretmen",
                      ),
                      _buildRoleCard(
                        context,
                        title: "Veli",
                        subtitle: "Çocuğunun gelişimini izle",
                        icon: Icons.family_restroom,
                        color: Colors.green,
                        roleId: "veli",
                      ),
                      _buildRoleCard(
                        context,
                        title: "Kurum",
                        subtitle: "Dershane yönetimi",
                        icon: Icons.business,
                        color: Colors.indigo,
                        roleId: "kurum",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Alt bilgi
                Text(
                  "v2.0 • YKS Cepte © 2025",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String roleId,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoleLoginScreen(selectedRole: roleId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF21262D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(60)),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(30),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Giriş Yap →",
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
