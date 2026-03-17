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
        print('Full data structure: $response.data');

        // Handle both Map and List
        if (response.data is Map<String, dynamic>) {
          final mapData = response.data as Map<String, dynamic>;
          print('Keys in response: ${mapData.keys}');

          // Try to get the list from common keys
          List<dynamic>? data;
          if (mapData.containsKey('data')) {
            data = mapData['data'];
          } else if (mapData.containsKey('books')) {
            data = mapData['books'];
          } else if (mapData.containsKey('categories')) {
            data = mapData['categories'];
          }

          if (data is List) {
            print('Found list with ${data.length} items');
            for (var item in data) {
              if (item is Map) {
                print('Category: ${item['category']}');
                final books = item['books'] as List?;
                print('Books count: ${books?.length}');
              }
            }
          } else {
            print('No list found. All keys: ${mapData.keys.join(', ')}');
          }
        } else if (response.data is List) {
          final List<dynamic> data = response.data as List<dynamic>;
          print('Parsed as List. length: ${data.length}');

          for (var item in data) {
            if (item is Map) {
              print('Category: ${item['category']}');
              final books = item['books'] as List?;
              print('Books count: ${books?.length}');
            }
          }
        }
      }
    } catch (parseError) {
      print('Parse Error: $parseError');
      print('Stack trace:');
      print(parseError);
    }
  } catch (e) {
    print('API Error: $e');
  }
}
