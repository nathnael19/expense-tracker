// ignore_for_file: deprecated_member_use

import 'package:expense_tracker_offline/presentation/blocs/debt_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/local/storage_service.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/blocs/theme_cubit.dart';
import 'presentation/blocs/settings_cubit.dart';
import 'presentation/blocs/category_cubit.dart';
import 'presentation/blocs/expense_cubit.dart';
import 'presentation/blocs/shortcut_cubit.dart';
import 'presentation/blocs/budget_cubit.dart';
import 'presentation/blocs/stats_cubit.dart';
import 'presentation/blocs/sync_cubit.dart';
import 'data/services/notification_service.dart';
import 'presentation/screens/app_lock_screen.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services in parallel
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    StorageService.init(),
    NotificationService.init(),
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => SettingsCubit()),
        BlocProvider(create: (_) => CategoryCubit()),
        BlocProvider(create: (_) => ExpenseCubit()),
        BlocProvider(create: (_) => ShortcutCubit()),
        BlocProvider(create: (_) => DebtCubit()),
        BlocProvider(create: (_) => BudgetCubit()),
        BlocProvider(
          create: (context) =>
              StatsCubit(expenseCubit: context.read<ExpenseCubit>()),
        ),
        BlocProvider(create: (_) => SyncCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Expense Tracker',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2C3E50),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
              textTheme: GoogleFonts.interTextTheme().copyWith(
                displayLarge: GoogleFonts.inter(),
                displayMedium: GoogleFonts.inter(),
                displaySmall: GoogleFonts.inter(),
                headlineLarge: GoogleFonts.inter(),
                headlineMedium: GoogleFonts.inter(),
                headlineSmall: GoogleFonts.inter(),
                titleLarge: GoogleFonts.inter(),
                titleMedium: GoogleFonts.inter(),
                titleSmall: GoogleFonts.inter(),
                bodyLarge: GoogleFonts.inter(),
                bodyMedium: GoogleFonts.inter(),
                bodySmall: GoogleFonts.inter(),
                labelLarge: GoogleFonts.inter(),
                labelMedium: GoogleFonts.inter(),
                labelSmall: GoogleFonts.inter(),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4e54c8),
                brightness: Brightness.dark,
                surface: const Color(0xFF1E1E1E),
                background: const Color(0xFF121212),
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF121212),
              textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
                  .copyWith(
                    displayLarge: GoogleFonts.inter(),
                    displayMedium: GoogleFonts.inter(),
                    displaySmall: GoogleFonts.inter(),
                    headlineLarge: GoogleFonts.inter(),
                    headlineMedium: GoogleFonts.inter(),
                    headlineSmall: GoogleFonts.inter(),
                    titleLarge: GoogleFonts.inter(),
                    titleMedium: GoogleFonts.inter(),
                    titleSmall: GoogleFonts.inter(),
                    bodyLarge: GoogleFonts.inter(),
                    bodyMedium: GoogleFonts.inter(),
                    bodySmall: GoogleFonts.inter(),
                    labelLarge: GoogleFonts.inter(),
                    labelMedium: GoogleFonts.inter(),
                    labelSmall: GoogleFonts.inter(),
                  ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  bool _isLocked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLockStatus();
  }

  void _checkLockStatus() {
    final lockEnabled = StorageService.settingsBox.get(
      'isAppLockEnabled',
      defaultValue: false,
    );
    setState(() {
      _isLocked = lockEnabled;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLocked) {
      return AppLockScreen(
        onAuthenticated: () {
          setState(() {
            _isLocked = false;
          });
        },
      );
    }

    return const HomeScreen();
  }
}
