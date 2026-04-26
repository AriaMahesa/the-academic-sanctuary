// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'shared_widgets.dart';

class LoginPage extends StatefulWidget {
  // onLogin async → null = sukses, String = pesan error
  final Future<String?> Function(String identifier, String password) onLogin;
  final VoidCallback onGoToRegister;

  const LoginPage({
    super.key,
    required this.onLogin,
    required this.onGoToRegister,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool    _isLoading      = false;
  bool    _obscurePass     = true;
  String? _error;
  String? _successMessage;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() { _error = null; _successMessage = null; });

    if (_usernameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Masukkan username atau email');
      return;
    }
    if (_passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Masukkan password');
      return;
    }

    setState(() => _isLoading = true);

    final error = await widget.onLogin(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (mounted) setState(() { _isLoading = false; _error = error; });
  }

  void _handleForgotPassword() {
    setState(() { _error = null; _successMessage = null; });
    if (_usernameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Masukkan username atau email terlebih dahulu');
      return;
    }
    setState(() => _successMessage =
        'Link reset dikirim ke email yang terkait dengan "${_usernameCtrl.text.trim()}"');
    Future.delayed(const Duration(seconds: 5),
        () { if (mounted) setState(() => _successMessage = null); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const BackgroundBlobs(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: Column(
                    children: [
                      // ── Logo ──────────────────────────────────────────────
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          gradient: mainGradient,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 10))],
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 20),
                      Text('The Sanctuary',
                          style: GoogleFonts.plusJakartaSans(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -1)),
                      const SizedBox(height: 6),
                      Text('WELCOME BACK',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.outlineVariant, letterSpacing: 3)),
                      const SizedBox(height: 40),

                      // ── Card ──────────────────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [BoxShadow(color: AppColors.onSurface.withOpacity(0.06), blurRadius: 40, offset: const Offset(0, 20))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Column(
                            children: [
                              Container(height: 5, decoration: const BoxDecoration(gradient: mainGradient)),
                              Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedSize(
                                      duration: const Duration(milliseconds: 300),
                                      child: _error != null ? ErrorBanner(message: _error!) : const SizedBox.shrink(),
                                    ),
                                    if (_error != null) const SizedBox(height: 16),
                                    AnimatedSize(
                                      duration: const Duration(milliseconds: 300),
                                      child: _successMessage != null ? SuccessBanner(message: _successMessage!) : const SizedBox.shrink(),
                                    ),
                                    if (_successMessage != null) const SizedBox(height: 16),

                                    FieldLabel('Username / Email'),
                                    InputField(
                                      controller: _usernameCtrl,
                                      hint: 'johndoe123 atau john@uni.edu',
                                      icon: Icons.person_outline,
                                      enabled: !_isLoading,
                                    ),
                                    const SizedBox(height: 16),

                                    FieldLabel('Password'),
                                    InputField(
                                      controller: _passwordCtrl,
                                      hint: '••••••••',
                                      icon: Icons.lock_outline,
                                      obscure: _obscurePass,
                                      enabled: !_isLoading,
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: AppColors.outlineVariant),
                                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: _handleForgotPassword,
                                        child: Text('Lupa password?',
                                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    GradientButton(isLoading: _isLoading, label: 'Masuk', onPressed: _handleLogin),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      GestureDetector(
                        onTap: widget.onGoToRegister,
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.outlineVariant),
                            children: [
                              const TextSpan(text: 'Belum punya akun? '),
                              TextSpan(text: 'Daftar', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
