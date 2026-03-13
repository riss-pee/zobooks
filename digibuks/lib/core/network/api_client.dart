import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../exceptions/api_exception.dart';

class ApiClient {
  late Dio _dio;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl + AppConfig.apiVersion,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConfig.accessTokenKey);

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/users/auth/login') &&
              !error.requestOptions.path.contains('/users/auth/refresh')) {
            try {
              final refreshToken =
                  await _storage.read(key: AppConfig.refreshTokenKey);

              if (refreshToken != null && refreshToken.isNotEmpty) {
                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: AppConfig.baseUrl + AppConfig.apiVersion,
                    headers: {'Content-Type': 'application/json'},
                  ),
                );

                final refreshRes = await refreshDio.post(
                  '/users/auth/refresh',
                  data: {'refresh_token': refreshToken},
                );

                if (refreshRes.statusCode == 200) {
                  final newAccess = refreshRes.data['access_token'];
                  final newRefresh = refreshRes.data['refresh_token'];

                  if (newAccess != null) {
                    await _storage.write(
                        key: AppConfig.accessTokenKey, value: newAccess);

                    error.requestOptions.headers['Authorization'] =
                        'Bearer $newAccess';
                  }

                  if (newRefresh != null) {
                    await _storage.write(
                        key: AppConfig.refreshTokenKey, value: newRefresh);
                  }

                  final cloneReq = await refreshDio.request(
                    error.requestOptions.path,
                    options: Options(
                      method: error.requestOptions.method,
                      headers: error.requestOptions.headers,
                    ),
                    data: error.requestOptions.data,
                    queryParameters: error.requestOptions.queryParameters,
                  );

                  return handler.resolve(cloneReq);
                }
              }
            } catch (_) {
              // refresh failed
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      print('API SUCCESS: ${response.realUri}');
      return response;
    } on DioException catch (e) {
      print(
          'API ERROR URI: ${e.response?.realUri} CODE: ${e.response?.statusCode} MSG: ${e.message}');

      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
