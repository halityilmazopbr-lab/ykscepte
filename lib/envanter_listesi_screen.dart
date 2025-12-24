import 'package:flutter/material.dart';
import 'envanter_models.dart';
import 'envanter_verileri.dart';
import 'envanter_coz_screen.dart';
import 'burdon_test_screen.dart';

/// Envanter Listesi Ekranı
/// Tüm testleri kartlar halinde gösterir
class EnvanterListesiEkrani extends StatelessWidget {
  const EnvanterListesiEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final envanterler = EnvanterVerileri.tumEnvanterler;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Rehberlik Envanterleri'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: envanterler.length,
        itemBuilder: (context, index) {
          final envanter = envanterler[index];
          return _buildEnvanterCard(context, envanter);
        },
      ),
    );
  }

  Widget _buildEnvanterCard(BuildContext context, Envanter envanter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shadowColor: envanter.renk.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () {
            // Burdon testi özel ekrana git
            if (envanter.id == 'burdon') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => BurdonTestEkrani(envanter: envanter),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => EnvanterCozEkrani(envanter: envanter),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  envanter.renk.withOpacity(0.1),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // İkon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: envanter.renk,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(envanter.ikon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                // İçerik
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        envanter.baslik,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        envanter.aciklama,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.timer, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            '${envanter.sureDakika} dk',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.quiz, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            envanter.id == 'burdon' 
                                ? 'Zamanlı Test' 
                                : '${envanter.sorular.length} soru',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Ok
                Icon(
                  Icons.arrow_forward_ios,
                  color: envanter.renk,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
