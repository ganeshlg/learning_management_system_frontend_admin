import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

class NetworkManager {
  late final Dio _dio;

  NetworkManager({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
    bool allowBadCertificates = false,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    /// SSL Certificate Verification
    if(!kIsWeb) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();

        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          if (allowBadCertificates) {
            return true;
          }

          /// Implement certificate pinning logic here if needed.
          return false;
        };

        return client;
      };
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token dynamically if needed
          // final token = locator<AuthService>().token;
          // options.headers['Authorization'] = 'Bearer $token';

          print(
            '''
        🚀 REQUEST
        URL: ${options.uri}
        METHOD: ${options.method}
        HEADERS: ${options.headers}
        BODY: ${options.data}
        ''',
          );

          handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '''
        ✅ RESPONSE
        URL: ${response.requestOptions.uri}
        STATUS: ${response.statusCode}
        DATA: ${response.data}
        ''',
          );

          handler.next(response);
        },
        onError: (error, handler) {
          print(
            '''
        ❌ ERROR
        URL: ${error.requestOptions.uri}
        TYPE: ${error.type}
        MESSAGE: ${error.message}
        ''',
          );

          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: _mapError(error),
              message: _mapError(error),
            ),
          );
        },
      ),
    );
  }

  Future<T> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    required T Function(dynamic data) converter,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return converter(response.data);
    } on DioException catch (e) {
      throw NetworkException(
        message: e.message ?? 'Unknown network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<T> post<T>({
    required String path,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    required T Function(dynamic data) converter,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return converter(response.data);
    } on DioException catch (e) {
      throw NetworkException(
        message: e.message ?? 'Unknown network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<T> put<T>({
    required String path,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    required T Function(dynamic data) converter,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return converter(response.data);
    } on DioException catch (e) {
      throw NetworkException(
        message: e.message ?? 'Unknown network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  Future<T> delete<T>({
    required String path,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    required T Function(dynamic data) converter,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return converter(response.data);
    } on DioException catch (e) {
      throw NetworkException(
        message: e.message ?? 'Unknown network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  String _mapError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';

      case DioExceptionType.sendTimeout:
        return 'Send timeout';

      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';

      case DioExceptionType.badResponse:
        return error.response?.data?['message'] ??
            'Server returned an invalid response';

      case DioExceptionType.cancel:
        return 'Request cancelled';

      case DioExceptionType.connectionError:
        return 'No internet connection';

      case DioExceptionType.badCertificate:
        return 'Certificate validation failed';

      case DioExceptionType.unknown:
        return 'Unexpected network error';
    }
  }
}

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() {
    return 'NetworkException(message: $message, statusCode: $statusCode)';
  }
}