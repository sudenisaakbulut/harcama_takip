import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HarcamaTakipApp());
}

class HarcamaTakipApp extends StatelessWidget {
  const HarcamaTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harcama Takip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          primary: const Color(0xFF3F51B5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// Model Sınıfı (JSON serileştirme ile)
class Islem {
  final String id;
  final String baslik;
  final double tutar;
  final bool isGelir;
  final DateTime tarih;

  Islem({
    required this.id,
    required this.baslik,
    required this.tutar,
    required this.isGelir,
    required this.tarih,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baslik': baslik,
      'tutar': tutar,
      'isGelir': isGelir,
      'tarih': tarih.toIso8601String(),
    };
  }

  factory Islem.fromMap(Map<String, dynamic> map) {
    return Islem(
      id: map['id'],
      baslik: map['baslik'],
      tutar: (map['tutar'] as num).toDouble(),
      isGelir: map['isGelir'],
      tarih: DateTime.parse(map['tarih']),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Islem> islemler = [];
  bool isLoading = true;

  // Sayı formatlayıcı: 164.740,00 ₺
  final NumberFormat paraFormati = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  // SharedPreferences'tan verileri okuma
  Future<void> _verileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final String? kayitliVeri = prefs.getString('islemler');

    if (kayitliVeri != null) {
      final List<dynamic> cozulenVeri = jsonDecode(kayitliVeri);
      setState(() {
        islemler = cozulenVeri.map((e) => Islem.fromMap(e)).toList();
        isLoading = false;
      });
    } else {
      // Başlangıç için varsayılan örnek veriler
      setState(() {
        islemler = [
          Islem(
            id: '1',
            baslik: 'Netflix',
            tutar: 260.00,
            isGelir: false,
            tarih: DateTime(2026, 11, 11),
          ),
          Islem(
            id: '2',
            baslik: 'Maaş',
            tutar: 165000.00,
            isGelir: true,
            tarih: DateTime(2026, 11, 11),
          ),
        ];
        isLoading = false;
      });
      _verileriKaydet();
    }
  }

  // SharedPreferences'a verileri yazma
  Future<void> _verileriKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonStr = jsonEncode(islemler.map((e) => e.toMap()).toList());
    await prefs.setString('islemler', jsonStr);
  }

  double get toplamGelir => islemler
      .where((islem) => islem.isGelir)
      .fold(0.0, (sum, item) => sum + item.tutar);

  double get toplamGider => islemler
      .where((islem) => !islem.isGelir)
      .fold(0.0, (sum, item) => sum + item.tutar);

  double get toplamBakiye => toplamGelir - toplamGider;

  void _islemSil(String id) {
    setState(() {
      islemler.removeWhere((item) => item.id == id);
    });
    _verileriKaydet();
  }

  void _yeniIslemEkle(String baslik, double tutar, bool isGelir) {
    final yeniIslem = Islem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      baslik: baslik,
      tutar: tutar,
      isGelir: isGelir,
      tarih: DateTime.now(),
    );
    setState(() {
      islemler.insert(0, yeniIslem);
    });
    _verileriKaydet();
  }

  void _showAddDialog() {
    final baslikController = TextEditingController();
    final tutarController = TextEditingController();
    bool isGelir = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Yeni İşlem Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: baslikController,
                decoration: const InputDecoration(labelText: 'Başlık (Örn: Market)'),
              ),
              TextField(
                controller: tutarController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Tutar (₺)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Gider'),
                    selected: !isGelir,
                    onSelected: (val) => setDialogState(() => isGelir = false),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Gelir'),
                    selected: isGelir,
                    onSelected: (val) => setDialogState(() => isGelir = true),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final baslik = baslikController.text.trim();
                final tutar = double.tryParse(tutarController.text.replaceAll(',', '.')) ?? 0.0;
                if (baslik.isNotEmpty && tutar > 0) {
                  _yeniIslemEkle(baslik, tutar, isGelir);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harcama Takip', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFE0E2EC),
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Özet Kartı
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F51B5),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Toplam Bakiye',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              paraFormati.format(toplamBakiye),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Color(0xFF5C6BC0),
                                      child: Icon(Icons.arrow_upward, size: 16, color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Gelir', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                        Text(
                                          paraFormati.format(toplamGelir),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Color(0xFF5C6BC0),
                                      child: Icon(Icons.arrow_downward, size: 16, color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Gider', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                        Text(
                                          paraFormati.format(toplamGider),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Liste Başlığı ve Elemanlar
                      Expanded(
                        child: ListView.separated(
                          itemCount: islemler.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final islem = islemler[index];
                            final tarihStr = DateFormat('dd.MM.yyyy').format(islem.tarih);
                            return Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: islem.isGelir ? Colors.green.shade50 : Colors.indigo.shade50,
                                  child: Icon(
                                    islem.isGelir ? Icons.arrow_upward : Icons.credit_card,
                                    size: 18,
                                    color: islem.isGelir ? Colors.green : Colors.indigo,
                                  ),
                                ),
                                title: Text(
                                  islem.baslik,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                subtitle: Text(
                                  tarihStr,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${islem.isGelir ? '+' : '-'}${paraFormati.format(islem.tutar)}',
                                      style: TextStyle(
                                        color: islem.isGelir ? Colors.green.shade700 : Colors.red.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () => _islemSil(islem.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}