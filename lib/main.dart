// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/user_data.dart';
import 'data/database_helper.dart';
import 'pages/register_page.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(const AcademicSanctuaryApp());
}

// ─── Color Tokens ─────────────────────────────────────────────────────────────
class AppColors {
  static const primary                = Color(0xFF24619D);
  static const primaryContainer       = Color(0xFF87BCFE);
  static const background             = Color(0xFFF7F9FB);
  static const onSurface              = Color(0xFF2C3437);
  static const surfaceContainer       = Color(0xFFEAEFF2);
  static const surfaceContainerLow    = Color(0xFFF0F4F7);
  static const surfaceContainerHighest= Color(0xFFDCE4E8);
  static const tertiaryContainer      = Color(0xFFD3C8F9);
  static const onTertiaryContainer    = Color(0xFF484068);
  static const outlineVariant         = Color(0xFFACB3B7);
  static const white                  = Color(0xFFFFFFFF);
}

const mainGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF24619D), Color(0xFF87BCFE)],
);

// ─── App ──────────────────────────────────────────────────────────────────────
class AcademicSanctuaryApp extends StatelessWidget {
  const AcademicSanctuaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Academic Sanctuary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      home: const AppNavigator(),
    );
  }
}

// ─── Navigator / State ────────────────────────────────────────────────────────
enum AppView { register, login, dashboard, profile }

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});
  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  final _db = DatabaseHelper.instance;

  AppView      _view     = AppView.register;
  UserData?    _user;
  int?         _userId;            // ← ID dari tabel users di SQLite
  List<Course> _schedules = [];

  // ── Register ───────────────────────────────────────────────────────────────
  Future<String?> _handleRegister(UserData data, String password) async {
    final id = await _db.registerUser(data, password);
    if (id == -1) return 'Username atau email sudah terdaftar';
    setState(() => _view = AppView.login);
    return null; // sukses
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<String?> _handleLogin(String identifier, String password) async {
    final result = await _db.loginUser(identifier, password);
    if (result == null) return 'Kredensial tidak valid';
    final schedules = await _db.getSchedules(result.id);
    setState(() {
      _user      = result.user;
      _userId    = result.id;
      _schedules = schedules;
      _view      = AppView.dashboard;
    });
    return null; // sukses
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  void _handleLogout() => setState(() {
        _user      = null;
        _userId    = null;
        _schedules = [];
        _view      = AppView.login;
      });

  // ── Update user ───────────────────────────────────────────────────────────
  Future<void> _handleUpdateUser(UserData updated) async {
    if (_userId == null) return;
    await _db.updateUser(_userId!, updated);
    setState(() => _user = updated);
  }

  // ── Update schedules ──────────────────────────────────────────────────────
  Future<void> _handleUpdateSchedules(List<Course> updated) async {
    if (_userId == null) return;
    await _db.saveSchedules(_userId!, updated);
    setState(() => _schedules = updated);
  }

  void _navigate(AppView view) => setState(() => _view = view);

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    switch (_view) {
      case AppView.register:
        return RegisterPage(
          onRegister: _handleRegister,
          onGoToLogin: () => _navigate(AppView.login),
        );
      case AppView.login:
        return LoginPage(
          onLogin: _handleLogin,
          onGoToRegister: () => _navigate(AppView.register),
        );
      case AppView.dashboard:
        return DashboardPage(
          user: _user!,
          schedules: _schedules,
          onUpdateSchedules: _handleUpdateSchedules,
          onNavigate: _navigate,
        );
      case AppView.profile:
        return ProfilePage(
          user: _user!,
          onUpdateUser: _handleUpdateUser,
          onNavigate: _navigate,
          onLogout: _handleLogout,
        );
    }
  }
}
