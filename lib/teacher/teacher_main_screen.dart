import 'package:flutter/material.dart';
import '../models.dart';
import '../data.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/my_classes_screen.dart';
import 'screens/give_homework_screen.dart';
import 'screens/teacher_attendance_screen.dart';

/// 👨‍🏫 Öğretmen Ana Ekranı - BottomNavigationBar ile 5 sekme
class TeacherMainScreen extends StatefulWidget {
  final Ogretmen ogretmen;
  
  const TeacherMainScreen({super.key, required this.ogretmen});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  int _currentIndex = 0;
  
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      TeacherDashboard(ogretmen: widget.ogretmen),
      MyClassesScreen(ogretmen: widget.ogretmen),
      GiveHomeworkScreen(ogretmen: widget.ogretmen),
      TeacherAttendanceScreen(ogretmen: widget.ogretmen),
      _buildProfileTab(),
    ];
  }
  
  Widget _buildProfileTab() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Profilim', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purple.withAlpha(50),
              child: const Icon(Icons.person, size: 50, color: Colors.purple),
            ),
            const SizedBox(height: 16),
            Text(
              widget.ogretmen.ad,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.ogretmen.brans,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await VeriDeposu.cikisYap();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Çıkış Yap'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: const Color(0xFF161B22),
          indicatorColor: Colors.purple.withAlpha(50),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.dashboard, color: Colors.purple),
              label: 'Kokpit',
            ),
            NavigationDestination(
              icon: Icon(Icons.class_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.class_, color: Colors.purple),
              label: 'Sınıflar',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.assignment, color: Colors.purple),
              label: 'Ödev',
            ),
            NavigationDestination(
              icon: Icon(Icons.qr_code_scanner_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.qr_code_scanner, color: Colors.teal),
              label: 'Yoklama',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Colors.grey),
              selectedIcon: Icon(Icons.person, color: Colors.purple),
              label: 'Profil',
            ),
          ],
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
    );
  }
}
