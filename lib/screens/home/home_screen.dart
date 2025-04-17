import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:schedule_generator/screens/history/history_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:schedule_generator/network/gemini_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String? errorMessage;

  List<Map<dynamic, dynamic>> recommendations = [];

  final TextEditingController _shoeController = TextEditingController();

  void saveRecommendation(
      String city, List<Map<dynamic, dynamic>> recommendations) {
    final box = Hive.box('history');
    final existingData = box.get(city,
        defaultValue: <Map<dynamic, dynamic>>[]).cast<Map<dynamic, dynamic>>();
    box.put(city, [...existingData, ...recommendations]);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Berhasil Menyimpan", 
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 15,
            fontWeight: FontWeight.bold
          )
        ),
        duration: Duration(milliseconds: 300),
        backgroundColor: Colors.white,
      )
    );
  }


  Future<void> generateRecommendations() async {
    if (_shoeController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });
    try {
      final result = await GeminiService.generateShoeRecommendations(_shoeController.text);
      print("Result from GeminiService: $result");
      if (result.containsKey('error')) {
        setState(() {
          _isLoading = false;
          recommendations.clear();
          errorMessage = result['error'];
        });
        return;
      }
      setState(() {
        recommendations = (result['recommended_shoe'] as List).map((place)=>{
          'Sepatu': place['Sepatu'] ?? 'tidak ada sepatu',
          'category': place['category'] ?? 'category tidak ditemukan',
          'description': place['description'] ?? 'Deskripsi tidak tersedia',
          'estimated_cost': place['estimated_cost'] ?? 'Tidak diketahui',
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        recommendations.clear();
        errorMessage = 'Gagal mendapatkan rekomendasi\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: const Text(
          'ShoeFinder',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: GestureDetector(
          onTap: (){
            Navigator.push(context, 
            MaterialPageRoute(builder: (context)=>const HistoryScreen()));
          },
          child: const Icon(Icons.bookmark, color: Colors.white, size: 30),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blueAccent.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Masukan nama gaya kamu dan dapatkan sepatu impian kamu!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _shoeController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                label: const Text("Gaya"),
                labelStyle: const TextStyle(color: Colors.white),
                hintText: 'Masukkan Gaya Kamu',
                hintStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: generateRecommendations,
              label: Text(
                _isLoading ? 'Mencari...' : 'Cari Rekomendasi',
                style: const TextStyle(color: Colors.white),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(Icons.search, color: Colors.white),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.blueAccent.shade100,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              Shimmer.fromColors(
                baseColor: Colors.blueAccent.shade100,
                highlightColor: Colors.white54,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const SizedBox(height: 100, width: double.infinity),
                ),
              ),
            if (!_isLoading && errorMessage != null && errorMessage!.isNotEmpty)
              Card(
                color: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!_isLoading && recommendations.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Rekomendasi Sepatu:',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recommendations
                        .map((place) => Card(
                              color: Colors.blueAccent.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place['Sepatu']!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      place['description']!,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Estimasi Biaya: ${place['estimated_cost']}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        saveRecommendation(
                                            _shoeController.text, [place]);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                                
                                      ),
                                      child: const Icon(Icons.bookmark_add, color: Colors.white)
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                    ),
                  ),
                ]
              ),
          ],
        ),
      ),
    );
  }
}
