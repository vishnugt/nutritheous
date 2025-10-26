import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/storage_service.dart';
import 'services/image_cache_service.dart';
import 'state/providers.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  // Wrap everything in error handler to catch any crashes
  FlutterError.onError = (FlutterErrorDetails details) {
    print('❌ Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting app initialization...');

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
    print('✅ Environment variables loaded');
  } catch (e) {
    print('⚠️  Failed to load .env file: $e');
    print('⚠️  Using default configuration');
  }

  // Initialize Hive and open essential boxes for authentication
  try {
    await Hive.initFlutter();
    print('✅ Hive initialized');

    // Open secure box for auth tokens (critical for auto-login)
    if (!Hive.isBoxOpen('secure_storage')) {
      await Hive.openBox<String>('secure_storage');
      print('✅ Secure storage box opened');
    }
  } catch (e) {
    print('⚠️  Hive initialization failed: $e');
  }

  runApp(
    const ProviderScope(
      child: NutritheousApp(),
    ),
  );
}

class NutritheousApp extends ConsumerWidget {
  const NutritheousApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Nutritheous',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

/// Wrapper to handle authentication state and route to appropriate screen
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    print('🔐 AuthWrapper initialized');
  }

  @override
  Widget build(BuildContext context) {
    print('🔐 AuthWrapper building...');

    try {
      final currentUserAsync = ref.watch(currentUserProvider);

      return currentUserAsync.when(
        data: (user) {
          print('✅ User data loaded: ${user != null ? "logged in" : "not logged in"}');
          if (user != null) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
        loading: () {
          print('⏳ Loading user data...');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        error: (error, stack) {
          print('❌ Error loading user: $error');
          print('Stack: $stack');
          return const LoginScreen();
        },
      );
    } catch (e, stack) {
      print('❌ CRITICAL ERROR in AuthWrapper: $e');
      print('Stack trace: $stack');
      // Fallback to login screen if anything goes wrong
      return const LoginScreen();
    }
  }
}
