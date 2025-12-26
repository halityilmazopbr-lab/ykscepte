import 'package:flutter/material.dart';
import '../../models/reward_models.dart';

class RewardCatalogScreen extends StatefulWidget {
  const RewardCatalogScreen({super.key});

  @override
  _RewardCatalogScreenState createState() => _RewardCatalogScreenState();
}

class _RewardCatalogScreenState extends State<RewardCatalogScreen> {
  RewardCategory selectedCategory = RewardCategory.all;

  // MOCK DATA (Katalog)
  final List<RewardItem> allRewards = [
    RewardItem(id: "1", name: "D&R 200 TL Hediye Çeki", imagePath: "assets/brands/dr.png", price: 210, category: RewardCategory.education, isParentApproved: true, description: "Kitap ve kırtasiye alışverişi için"),
    RewardItem(id: "2", name: "1450 Valorant VP", imagePath: "assets/brands/valorant.png", price: 180, category: RewardCategory.gaming, description: "Valorant oyun içi para"),
    RewardItem(id: "3", name: "Starbucks Tall Kahve", imagePath: "assets/brands/starbucks.png", price: 80, category: RewardCategory.lifestyle, description: "Bir kahve molası"),
    RewardItem(id: "4", name: "Steam 10 USD Cüzdan", imagePath: "assets/brands/steam.png", price: 340, category: RewardCategory.gaming, description: "PC oyunları için"),
    RewardItem(id: "5", name: "Trendyol 100 TL Cüzdan", imagePath: "assets/brands/trendyol.png", price: 110, category: RewardCategory.lifestyle, description: "Online alışveriş"),
    RewardItem(id: "6", name: "Kunduz 1 Aylık Paket", imagePath: "assets/brands/kunduz.png", price: 250, category: RewardCategory.education, isParentApproved: true, description: "Soru çözüm desteği"),
  ];

  @override
  Widget build(BuildContext context) {
    // Filtreleme Mantığı
    List<RewardItem> displayedRewards = selectedCategory == RewardCategory.all
        ? allRewards
        : allRewards.where((i) => i.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Ödül Mağazası", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.grey), onPressed: () {})
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: displayedRewards.length,
              itemBuilder: (context, index) {
                return _buildRewardCard(displayedRewards[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _filterChip("Tümü", RewardCategory.all),
          _filterChip("🎓 Eğitim", RewardCategory.education),
          _filterChip("🎮 Oyun", RewardCategory.gaming),
          _filterChip("🍔 Yaşam", RewardCategory.lifestyle),
        ],
      ),
    );
  }

  Widget _filterChip(String label, RewardCategory category) {
    bool isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            selectedCategory = category;
          });
        },
        selectedColor: const Color(0xFF2563EB),
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
        backgroundColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildRewardCard(RewardItem item) {
    return GestureDetector(
      onTap: () {
        _showDetailModal(item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resim Alanı
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.card_giftcard, size: 60, color: Colors.grey),
                    ),
                    if (item.isParentApproved)
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green, borderRadius:BorderRadius.circular(4)),
                          child: const Text("Veli Dostu", style: TextStyle(color: Colors.white, fontSize: 8)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Bilgi Alanı
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("₺${item.price.toInt()}", style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 16)),
                        const Icon(Icons.add_circle, color: Color(0xFF2563EB)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailModal(RewardItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.card_giftcard, color: Colors.grey, size: 30),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Değer: ₺${item.price.toInt()}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
              const Divider(height: 30),
              const Text("Nasıl Kazanabilirsin?", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                item.description.isEmpty ? "Bu ödülü kazanmak için kendine bir çalışma hedefi belirle ve velinden onay iste." : item.description,
                style: TextStyle(color: Colors.grey[600], fontSize: 13)
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hedef oluşturma yakında eklenecek!")));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("BUNU HEDEF OLARAK SEÇ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
