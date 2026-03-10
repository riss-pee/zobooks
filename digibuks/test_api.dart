import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://3.106.193.213/api',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  try {
    print('Fetching data...');
    final response = await dio.get('/reader/published-books/grouped');
    print('Status: ${response.statusCode}');
    print('Data type: ${response.data.runtimeType}');
    
    // Test parsing
    try {
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        print('Parsed as List. length: ${data.length}');
        
        for (var item in data) {
           print('Category: ${item['category']}');
           final books = item['books'] as List?;
           print('Books count: ${books?.length}');
           
           if (books != null && books.isNotEmpty) {
             print('First book type: ${books[0].runtimeType}');
             print('First book keys: ${books[0].keys}');
           }
        }
      }
    } catch (parseError) {
      print('Parse Error: $parseError');
    }
  } catch (e) {
    print('API Error: $e');
  }
}
