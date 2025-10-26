import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Global instance of the image cache service
/// Initialize this in main.dart before running the app
final imageCacheService = ImageCacheService();

/// In-memory cache for instant access (prevents Hero animation flicker)
/// This is a fast LRU cache that sits on top of the persistent Hive cache
class _MemoryCache {
  static final Map<String, Uint8List> _cache = {};
  static final List<String> _accessOrder = [];
  static const int maxSize = 50; // Keep 50 most recent images in memory

  static Uint8List? get(String url) {
    if (_cache.containsKey(url)) {
      _accessOrder.remove(url);
      _accessOrder.add(url);
      return _cache[url];
    }
    return null;
  }

  static void put(String url, Uint8List bytes) {
    if (_cache.containsKey(url)) {
      _accessOrder.remove(url);
    }
    _cache[url] = bytes;
    _accessOrder.add(url);

    // Evict oldest if too large
    while (_accessOrder.length > maxSize) {
      final oldest = _accessOrder.removeAt(0);
      _cache.remove(oldest);
    }
  }
}

/// Metadata for cached images
class CachedImageMetadata {
  final String url;
  final int lastAccessedTimestamp;
  final int size;

  CachedImageMetadata({
    required this.url,
    required this.lastAccessedTimestamp,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'lastAccessedTimestamp': lastAccessedTimestamp,
        'size': size,
      };

  factory CachedImageMetadata.fromJson(Map<String, dynamic> json) {
    return CachedImageMetadata(
      url: json['url'] as String,
      lastAccessedTimestamp: json['lastAccessedTimestamp'] as int,
      size: json['size'] as int,
    );
  }
}

/// Persistent image cache service with LRU eviction
/// Stores up to 200 images and persists across app restarts
class ImageCacheService {
  static const String _imagesBoxName = 'cached_images';
  static const String _metadataBoxName = 'image_metadata';
  static const int maxCacheSize = 200;

  Box<List<int>>? _imagesBox;
  Box<Map<dynamic, dynamic>>? _metadataBox;

  bool _initialized = false;

  /// Initialize the cache service
  Future<void> initialize() async {
    if (_initialized && _imagesBox != null && _imagesBox!.isOpen) {
      return; // Already initialized and boxes are open
    }

    try {
      // Hive should already be initialized in main.dart
      // Just open the boxes
      _imagesBox = await Hive.openBox<List<int>>(_imagesBoxName);
      _metadataBox = await Hive.openBox<Map<dynamic, dynamic>>(_metadataBoxName);

      _initialized = true;

      print('✅ Image cache initialized (${_imagesBox!.length} images)');
    } catch (e) {
      print('❌ Error initializing image cache: $e');
      _initialized = false;
      // Don't crash - cache will work without persistence
    }
  }

  /// Generate a unique key from URL (using hash to avoid key length issues)
  String _generateKey(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    final key = digest.toString();
    print('🔑 Generated key for URL: ${url.substring(0, url.length > 50 ? 50 : url.length)}... → $key');
    return key;
  }

  /// Get cached image bytes by URL (synchronous check for memory cache)
  Uint8List? getSync(String url) {
    return _MemoryCache.get(url);
  }

  /// Get cached image bytes by URL
  Future<Uint8List?> get(String url) async {
    // Check in-memory cache first (instant)
    final memCached = _MemoryCache.get(url);
    if (memCached != null) {
      return memCached;
    }

    // Initialize if needed (first time only)
    if (!_initialized) {
      try {
        await initialize();
      } catch (e) {
        // If initialization fails, just return null (will fetch from network)
        return null;
      }
    }

    // Try persistent cache if initialized
    if (_imagesBox == null || !_imagesBox!.isOpen) {
      return null;
    }

    final key = _generateKey(url);

    try {
      final imageData = _imagesBox!.get(key);
      if (imageData == null) {
        return null;
      }

      final bytes = Uint8List.fromList(imageData);

      // Add to memory cache for fast access
      _MemoryCache.put(url, bytes);

      return bytes;
    } catch (e) {
      return null;
    }
  }

  /// Store image bytes with URL
  Future<void> put(String url, Uint8List bytes) async {
    // Store in memory cache immediately (always works)
    _MemoryCache.put(url, bytes);

    // Initialize if needed (first time only)
    if (!_initialized) {
      try {
        await initialize();
      } catch (e) {
        // If initialization fails, memory cache still works
        return;
      }
    }

    // Try to store in persistent cache if available
    if (_imagesBox == null || !_imagesBox!.isOpen) {
      return;
    }

    final key = _generateKey(url);

    try {
      // Store image data and metadata
      await _imagesBox!.put(key, bytes.toList());

      final metadata = CachedImageMetadata(
        url: url,
        lastAccessedTimestamp: DateTime.now().millisecondsSinceEpoch,
        size: bytes.length,
      );
      await _metadataBox!.put(key, metadata.toJson());

      // Enforce max size in background
      _enforceMaxSize();
    } catch (e) {
      // Ignore errors - memory cache still works
    }
  }

  /// Remove least recently used items if cache exceeds max size
  Future<void> _enforceMaxSize() async {
    if (_metadataBox == null || !_metadataBox!.isOpen) return;
    if (_metadataBox!.length <= maxCacheSize) return;

    // Get all metadata entries sorted by last accessed time
    final entries = <String, CachedImageMetadata>{};
    for (final key in _metadataBox!.keys) {
      final metadataMap = _metadataBox!.get(key);
      if (metadataMap != null) {
        entries[key as String] = CachedImageMetadata.fromJson(
          Map<String, dynamic>.from(metadataMap),
        );
      }
    }

    // Sort by last accessed timestamp (oldest first)
    final sortedKeys = entries.keys.toList()
      ..sort((a, b) {
        final aTime = entries[a]!.lastAccessedTimestamp;
        final bTime = entries[b]!.lastAccessedTimestamp;
        return aTime.compareTo(bTime);
      });

    // Remove oldest entries until we're at max size
    final itemsToRemove = _metadataBox!.length - maxCacheSize;
    for (int i = 0; i < itemsToRemove; i++) {
      final keyToRemove = sortedKeys[i];
      await _imagesBox!.delete(keyToRemove);
      await _metadataBox!.delete(keyToRemove);
    }
  }

  /// Check if an image is cached
  Future<bool> contains(String url) async {
    if (!_initialized || _imagesBox == null || !_imagesBox!.isOpen) {
      await initialize();
    }
    final key = _generateKey(url);
    return _imagesBox!.containsKey(key);
  }

  /// Clear all cached images
  Future<void> clear() async {
    if (!_initialized || _imagesBox == null || !_imagesBox!.isOpen) {
      await initialize();
    }
    await _imagesBox!.clear();
    await _metadataBox!.clear();
    _MemoryCache._cache.clear();
    _MemoryCache._accessOrder.clear();
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getStats() async {
    if (!_initialized || _metadataBox == null || !_metadataBox!.isOpen) {
      await initialize();
    }

    int totalSize = 0;
    for (final key in _metadataBox!.keys) {
      final metadataMap = _metadataBox!.get(key);
      if (metadataMap != null) {
        final metadata = CachedImageMetadata.fromJson(
          Map<String, dynamic>.from(metadataMap),
        );
        totalSize += metadata.size;
      }
    }

    return {
      'count': _imagesBox!.length,
      'totalSizeBytes': totalSize,
      'maxSize': maxCacheSize,
    };
  }
}
