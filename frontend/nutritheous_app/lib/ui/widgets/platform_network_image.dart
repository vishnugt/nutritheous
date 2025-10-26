import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../services/image_cache_service.dart';

/// A cross-platform network image widget with persistent caching
///
/// Features:
/// - Persistent cache using Hive (max 200 images)
/// - LRU eviction when cache limit is reached
/// - Cache survives app restarts
/// - Images are downloaded only once
/// - Uses Dio for network requests with CORS handling
/// - Uses objectName (stable) for caching instead of signed URLs (which expire)
class PlatformNetworkImage extends StatefulWidget {
  final String imageUrl;
  final String? objectName; // Stable identifier for caching (preferred over imageUrl)
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, Object)? errorWidget;

  const PlatformNetworkImage({
    super.key,
    required this.imageUrl,
    this.objectName,
    this.height,
    this.width,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<PlatformNetworkImage> createState() => _PlatformNetworkImageState();
}

class _PlatformNetworkImageState extends State<PlatformNetworkImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  Object? _error;

  /// Get the cache key - prefer objectName (stable) over imageUrl (which changes)
  /// For old meals without objectName, extract the path from the URL
  String get _cacheKey {
    if (widget.objectName != null && widget.objectName!.isNotEmpty) {
      // New meals: use stable objectName
      return widget.objectName!;
    }

    // Old meals: extract path from URL (without query parameters)
    // Example: https://storage.googleapis.com/bucket/path/file.jpg?signature=...
    // Extract: path/file.jpg
    try {
      final uri = Uri.parse(widget.imageUrl);
      if (uri.pathSegments.length >= 2) {
        // Skip 'bucket' and use the rest as cache key
        return uri.pathSegments.skip(1).join('/');
      }
    } catch (e) {
      // Failed to parse URL, will use full URL as fallback
    }

    // Fallback: use full URL (will re-download each time)
    return widget.imageUrl;
  }

  @override
  void initState() {
    super.initState();
    // Check memory cache synchronously first (prevents Hero flicker)
    final cached = imageCacheService.getSync(_cacheKey);
    if (cached != null) {
      _imageBytes = cached;
      _isLoading = false;
    } else {
      // Not in memory, load asynchronously
      _loadImage();
    }
  }

  @override
  void didUpdateWidget(PlatformNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-check cache if imageUrl OR objectName changed
    final oldCacheKey = oldWidget.objectName ?? oldWidget.imageUrl;
    if (oldCacheKey != _cacheKey) {
      // Check memory cache synchronously first
      final cached = imageCacheService.getSync(_cacheKey);
      if (cached != null) {
        setState(() {
          _imageBytes = cached;
          _isLoading = false;
          _error = null;
        });
      } else {
        setState(() {
          _imageBytes = null;
          _isLoading = true;
          _error = null;
        });
        _loadImage();
      }
    }
  }

  Future<void> _loadImage() async {
    try {
      // Check persistent cache first using stable cache key
      final cachedBytes = await imageCacheService.get(_cacheKey);

      if (cachedBytes != null) {
        // Cache HIT - image available from persistent storage
        if (mounted) {
          setState(() {
            _imageBytes = cachedBytes;
            _isLoading = false;
          });
        }
        return;
      }

      // Cache MISS - fetch from network using imageUrl (which is the signed URL)

      final dio = Dio(BaseOptions(
        responseType: ResponseType.bytes,
        validateStatus: (status) => status != null && status < 500,
      ));

      final response = await dio.get<List<int>>(
        widget.imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'image/*',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data!);

        // Store in persistent cache using stable cache key (objectName if available)
        imageCacheService.put(_cacheKey, bytes);

        if (mounted) {
          setState(() {
            _imageBytes = bytes;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use persistent cache for all platforms
    if (_isLoading) {
      return widget.placeholder?.call(context, widget.imageUrl) ??
          SizedBox(
            height: widget.height,
            width: widget.width,
            child: const Center(child: CircularProgressIndicator()),
          );
    }

    if (_error != null) {
      return widget.errorWidget?.call(context, widget.imageUrl, _error!) ??
          SizedBox(
            height: widget.height,
            width: widget.width,
            child: const Center(child: Icon(Icons.error)),
          );
    }

    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        gaplessPlayback: true,
      );
    }

    return const SizedBox.shrink();
  }
}
