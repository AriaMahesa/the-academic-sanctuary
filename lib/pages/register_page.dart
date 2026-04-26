// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/user_data.dart';
import '../main.dart';
import 'shared_widgets.dart';

class RegisterPage extends StatefulWidget {
  // onRegister sekarang async dan return String? (null = sukses, isi = pesan error)
  final Future<String?> Function(UserData, String password) onRegister;
  final VoidCallback onGoToLogin;

  const RegisterPage({
    super.key,
    required this.onRegister,
    required this.onGoToLogin,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _fullNameCtrl    = TextEditingController();
  final _usernameCtrl    = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool    _isLoading     = false;
  String? _error;
  bool    _obscurePass    = true;
  bool    _obscureConfirm = true;

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
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _error = null);

    if (_fullNameCtrl.text.trim().isEmpty ||
        _usernameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.isEmpty ||
        _confirmPassCtrl.text.isEmpty) {
      setState(() => _error = 'Semua field wajib diisi');
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter');
      return;
    }
    if (_passwordCtrl.text != _confirmPassCtrl.text) {
      setState(() => _error = 'Password tidak cocok');
      return;
    }

    setState(() => _isLoading = true);

    final error = await widget.onRegister(
      UserData(
        fullName:   _fullNameCtrl.text.trim(),
        username:   _usernameCtrl.text.trim(),
        email:      _emailCtrl.text.trim(),
        nim:        '21040120140155',
        kelas:      'Internasional A',
        prodi:      'Computer Science',
        tahunMasuk: '2021',
      ),
      _passwordCtrl.text,
    );

    if (mounted) setState(() { _isLoading = false; _error = error; });
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      // ── Logo ──────────────────────────────────────────────
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          gradient: mainGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 16),
                      Text('Create Account',
                          style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      Text('Join The Academic Sanctuary',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.outlineVariant)),
                      const SizedBox(height: 32),

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
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedSize(
                                      duration: const Duration(milliseconds: 300),
                                      child: _error != null ? ErrorBanner(message: _error!) : const SizedBox.shrink(),
                                    ),
                                    if (_error != null) const SizedBox(height: 16),

                                    FieldLabel('Nama Lengkap'),
                                    InputField(controller: _fullNameCtrl, hint: 'John Doe', icon: Icons.person_outline, enabled: !_isLoading),
                                    const SizedBox(height: 16),

                                    FieldLabel('Username'),
                                    InputField(controller: _usernameCtrl, hint: 'johndoe123', icon: Icons.alternate_email, enabled: !_isLoading),
                                    const SizedBox(height: 16),

                                    FieldLabel('Email Address'),
                                    InputField(controller: _emailCtrl, hint: 'john@university.edu', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress, enabled: !_isLoading),
                                    const SizedBox(height: 16),

                                    Row(
                                      children: [
                                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          FieldLabel('Password'),
                                          InputField(
                                            controller: _passwordCtrl, hint: '••••••', icon: Icons.lock_outline,
                                            obscure: _obscurePass, enabled: !_isLoading,
                                            suffixIcon: IconButton(
                                              icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: AppColors.outlineVariant),
                                              onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                            ),
                                          ),
                                        ])),
                                        const SizedBox(width: 12),
                                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          FieldLabel('Konfirmasi'),
                                          InputField(
                                            controller: _confirmPassCtrl, hint: '••••••', icon: Icons.lock_outline,
                                            obscure: _obscureConfirm, enabled: !_isLoading,
                                            suffixIcon: IconButton(
                                              icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: AppColors.outlineVariant),
                                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                            ),
                                          ),
                                        ])),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    GradientButton(isLoading: _isLoading, label: 'Sign Up', onPressed: _handleSubmit),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      GestureDetector(
                        onTap: widget.onGoToLogin,
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.outlineVariant),
                            children: [
                              const TextSpan(text: 'Sudah punya akun? '),
                              TextSpan(text: 'Login', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700)),
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
