import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';
import 'exam_service.dart';

/// 👨‍💻 Admin Deneme Yükleme Ekranı
/// Süper Admin: Görünürlük seçebilir (Public/Private)
/// Kurum Admin: Sadece kendi kurumuna yükleyebilir (Zorunlu Kısıtlama)
class AdminExamUploadScreen extends StatefulWidget {
  const AdminExamUploadScreen({super.key});

  @override
  State<AdminExamUploadScreen> createState() => _AdminExamUploadScreenState();
}

class _AdminExamUploadScreenState extends State<AdminExamUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form kontrolleri
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pdfUrlController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  
  String _visibility = 'public'; // Varsayılan: Herkese Açık
  String? _selectedInstitutionId;
  bool _isLoading = false;
  
  // Kurum listesi (Firebase'den yüklenir)
  List<Map<String, String>> _institutions = [];
  
  // Rol kontrolü
  late bool _isSuperAdmin;
  late String? _userInstitutionId;

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
  }
  
  Future<void> _loadInstitutions() async {
    final institutions = await ExamService().getInstitutions();
    if (mounted) {
      setState(() => _institutions = institutions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    // Rol belirleme: admin = süper admin, kurum_yoneticisi = kurum admin
    _isSuperAdmin = userProvider.currentUserRole == 'admin';
    _userInstitutionId = userProvider.currentUser?.kurumKodu;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: _isSuperAdmin ? Colors.deepPurple : Colors.indigo,
        title: Text(
          _isSuperAdmin ? "🔱 Yönetici: Deneme Yükle" : "🏫 Kurum: Deneme Yükle",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rol Bilgi Kartı
              _buildRoleInfoCard(),
              
              const SizedBox(height: 24),
              
              // 1. SINAV BAŞLIĞI
              _buildLabel("📝 Sınav Başlığı"),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Örn: TYT Türkiye Geneli - Ocak 2025"),
                validator: (val) => val!.isEmpty ? "Başlık giriniz" : null,
              ),
              
              const SizedBox(height: 20),
              
              // 2. GÖRÜNÜRLÜK AYARI (SADECE SÜPER ADMİN GÖRÜR) 🔒
              if (_isSuperAdmin) ...[
                _buildLabel("🔐 Görünürlük (Yetkili Alanı)"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21262D),
                    border: Border.all(color: Colors.grey.shade700),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _visibility,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF21262D),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(
                          value: 'public',
                          child: Row(
                            children: [
                              Icon(Icons.public, color: Colors.green),
                              SizedBox(width: 8),
                              Text("🌍 Herkese Açık (Türkiye Geneli)"),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'private',
                          child: Row(
                            children: [
                              Icon(Icons.lock, color: Colors.orange),
                              SizedBox(width: 8),
                              Text("🔒 Kuruma Özel (Kapalı Devre)"),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (val) => setState(() => _visibility = val!),
                    ),
                  ),
                ),
                
                // 3. EĞER "PRIVATE" İSE OKUL SEÇTİR
                if (_visibility == 'private') ...[
                  const SizedBox(height: 20),
                  _buildLabel("🏫 Hangi Kuruma Atanacak?"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(20),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedInstitutionId,
                        hint: Text("Kurum Seçiniz", style: TextStyle(color: Colors.orange.shade200)),
                        isExpanded: true,
                        dropdownColor: const Color(0xFF21262D),
                        style: const TextStyle(color: Colors.white),
                        items: _institutions.map((kurum) {
                          return DropdownMenuItem(
                            value: kurum['id'],
                            child: Text(kurum['name']!),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedInstitutionId = val),
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
              ] else ...[
                // Kurum yöneticisi için bilgi kartı
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Bu sınav sadece kurumunuzun öğrencilerine görünür olacaktır.",
                          style: TextStyle(color: Colors.blue.shade200, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // 4. SINAV TARİHİ
              _buildLabel("📅 Sınav Tarihi"),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21262D),
                    border: Border.all(color: Colors.grey.shade700),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(_selectedDate),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.deepPurple),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 5. PDF LİNKİ
              _buildLabel("📄 PDF Dosya Linki (Opsiyonel)"),
              TextFormField(
                controller: _pdfUrlController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("https://firebasestorage..."),
              ),
              
              const SizedBox(height: 40),
              
              // YAYINLA BUTONU
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _uploadExam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSuperAdmin
                        ? (_visibility == 'public' ? Colors.green : Colors.orange)
                        : Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(
                    _isLoading ? "Yükleniyor..." : "SINAVI YAYINLA",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Buton altı bilgi
              Center(
                child: Text(
                  _isSuperAdmin
                      ? (_visibility == 'public' 
                          ? "🌍 Tüm kullanıcılar görecek" 
                          : "🔒 Sadece seçilen kurum görecek")
                      : "🏫 Sadece kurumunuzun öğrencileri görecek",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRoleInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isSuperAdmin 
              ? [Colors.deepPurple.shade700, Colors.purple.shade500]
              : [Colors.indigo.shade700, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isSuperAdmin ? Icons.admin_panel_settings : Icons.business,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSuperAdmin ? "Süper Admin Paneli" : "Kurum Yöneticisi Paneli",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isSuperAdmin 
                      ? "Tüm kurumlar ve bireysel kullanıcılar için sınav yükleyebilirsiniz"
                      : "Sadece kurumunuzun öğrencileri için sınav yükleyebilirsiniz",
                  style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
  
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade600),
      filled: true,
      fillColor: const Color(0xFF21262D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
    );
  }
  
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.deepPurple,
              surface: Color(0xFF21262D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
  
  String _formatDate(DateTime date) {
    final months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
                    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
  
  // 🔥 GÜVENLİ YÜKLEME MANTIĞI
  void _uploadExam() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Kurum seçilmediyse uyar (sadece süper admin için)
    if (_isSuperAdmin && _visibility == 'private' && _selectedInstitutionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Lütfen bir kurum seçiniz!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Güvenlik: Rol bazlı değer belirleme
      String finalVisibility;
      String? finalTargetInstitution;
      
      if (_isSuperAdmin) {
        // Süper admin: Seçtiği değerler kullanılır
        finalVisibility = _visibility;
        finalTargetInstitution = _visibility == 'private' ? _selectedInstitutionId : null;
      } else {
        // Kurum yöneticisi: ZORLA private ve kendi kurumu
        finalVisibility = 'private';
        finalTargetInstitution = _userInstitutionId;
      }
      
      // Firebase'e kaydet
      final examId = await ExamService().uploadExam(
        title: _titleController.text.trim(),
        visibility: finalVisibility,
        targetInstitutionId: finalTargetInstitution,
        pdfUrl: _pdfUrlController.text.trim().isEmpty ? null : _pdfUrlController.text.trim(),
        date: _selectedDate,
      );
      
      if (mounted && examId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Sınav Başarıyla Yayınlandı!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Hata: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _pdfUrlController.dispose();
    super.dispose();
  }
}
