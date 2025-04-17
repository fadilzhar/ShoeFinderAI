import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String apiKey = 'AIzaSyDPptntdbZwMbJXsjYLDd1gQzfyYt6oK1I';

  static Future<Map<String, dynamic>> generateShoeRecommendations(
      String shoe) async {
    final prompt =
        "Kamu AI yang dapat memberikan rekomendasi sepatu bedasarkan style yang dibutuhkan pengguna. Model harus mengembalikan respons dalam format JSON dengan struktur sebagai berikut:\n\n" +
            "Input: Gaya\n\n" +
            "Output (JSON):\n" +
            "{\n  \"Shoe\": \"$shoe\",\n  \"recommended_shoe\": [\n    {\n      \"Sepatu\": \"Nama Sepatu\",\n      \"category\": \"Kategori (Skena, Aesthetic, Casual, dan lain lain.)\",\n      \"description\": \"Deskripsi singkat tentang sepatu yang disarankan\",\n      \"estimated_cost\": \"Estimasi biaya sepatu\"\n    }\n  ],\n ";

    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
    );

    final chat = model.startChat(history: [
      Content.multi([
        TextPart(prompt),
      ]),
    ]);
    final message = shoe;
    final content = Content.text(message);

   try {
      final response = await chat.sendMessage(content);
      final responseText =
          (response.candidates.first.content.parts.first as TextPart).text;

      if (responseText.isEmpty) {
        return {"error": "Gagal mendapatkan rekomendasi sepatu"};
      }

      RegExp jsonPattern = RegExp(r'\{.*\}', dotAll: true);
      final match = jsonPattern.firstMatch(responseText);

      if (match != null) {
        final jsonResponse = json.decode(match.group(0)!);
        return jsonResponse;
      }
      return jsonDecode(responseText);
    } catch (e) {
      return {"error": "Gagal mendapatkan rekomendasi sepatu \n$e"};
    }
  }
}
