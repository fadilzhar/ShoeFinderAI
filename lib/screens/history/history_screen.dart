import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Box historyBox;

  @override
  void initState() {
    super.initState();
    historyBox = Hive.box('history');
  }

  void saveRecommendation(
      String city, List<Map<dynamic, dynamic>> recommendations) {
    final existingData = historyBox.get(city,
        defaultValue: <Map<dynamic, dynamic>>[]).cast<Map<dynamic, dynamic>>();
    historyBox.put(city, [...existingData, ...recommendations]);
  }

  void deleteHistory(String city){
    historyBox.delete(city);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Berhasil Mengapus", 
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Simpenan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.blueAccent,
      body: ValueListenableBuilder(
        valueListenable: historyBox.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('Belum ada simpenan', style: TextStyle(color: Colors.white),));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final city = box.keyAt(index);
              final places = List<Map<dynamic, dynamic>>.from(box.get(city));

              return Card(
                color: Colors.blueAccent.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            city,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: ()=>deleteHistory(city), 
                            icon: const Icon(Icons.delete, color: Colors.red)
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...places.map((place) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '- ${place['name']} | ${place['estimated_cost']}',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          )),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
