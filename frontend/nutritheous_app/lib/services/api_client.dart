import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/api_config.dart';

/// Base API client for making HTTP requests to the backend
class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();

  ApiClient({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('Request: ${options.method} ${options.path}');
          _logger.d('Headers: ${options.headers}');
          _logger.d('Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('Response: ${response.statusCode} ${response.requestOptions.path}');
          _logger.d('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Error: ${error.message}');
          _logger.e('Response: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  /// Set the JWT token for authenticated requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear the JWT token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Get request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.e('GET request failed: $e');
      rethrow;
    }
  }

  /// Post request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.e('POST request failed: $e');
      rethrow;
    }
  }

  /// Put request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.e('PUT request failed: $e');
      rethrow;
    }
  }

  /// Delete request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.e('DELETE request failed: $e');
      rethrow;
    }
  }

  /// Upload file with multipart/form-data (supports both mobile and web)
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalData,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      _logger.e('File upload failed: $e');
      rethrow;
    }
  }

  /// Upload XFile (works on both mobile and web)
  /// If file is null, sends multipart/form-data without a file (useful for text-only uploads)
  Future<Response<T>> uploadXFile<T>(
    String path,
    XFile? file, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {};

      // Only add file if it's provided
      if (file != null) {
        MultipartFile multipartFile;

        if (kIsWeb) {
          // On web, use bytes
          final bytes = await file.readAsBytes();
          multipartFile = MultipartFile.fromBytes(
            bytes,
            filename: file.name,
          );
        } else {
          // On mobile, use file path
          multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: file.name,
          );
        }

        formDataMap[fieldName] = multipartFile;
      }

      // Add additional data if provided
      if (additionalData != null) {
        formDataMap.addAll(additionalData);
      }

      final formData = FormData.fromMap(formDataMap);

      return await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      _logger.e('XFile upload failed: $e');
      rethrow;
    }
  }
}
