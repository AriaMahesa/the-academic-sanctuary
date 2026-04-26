// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/user_data.dart';
import '../main.dart';

class ProfilePage extends StatefulWidget {
  final UserData user;
  final void Function(UserData) onUpdateUser;
  final void Function(AppView) onNavigate;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.user,
    required this.onUpdateUser,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool _isEditModalOpen = false;

  late TextEditingController _fullNameCtrl;
  late TextEditingController _nimCtrl;
  late TextEditingController _kelasCtrl;
  late TextEditingController _prodiCtrl;
  late TextEditingController _tahunCtrl;
  bool _isSaved = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  void _initControllers() {
    _fullNameCtrl = TextEditingController(text: widget.user.fullName);
    _nimCtrl = TextEditingController(text: widget.user.nim);
    _kelasCtrl = TextEditingController(text: widget.user.kelas);
    _prodiCtrl = TextEditingController(text: widget.user.prodi);
    _tahunCtrl = TextEditingController(text: widget.user.tahunMasuk);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _fullNameCtrl.dispose();
    _nimCtrl.dispose();
    _kelasCtrl.dispose();
    _prodiCtrl.dispose();
    _tahunCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onUpdateUser(widget.user.copyWith(
      fullName: _fullNameCtrl.text.trim(),
      nim: _nimCtrl.text.trim(),
      kelas: _kelasCtrl.text.trim(),
      prodi: _prodiCtrl.text.trim(),
      tahunMasuk: _tahunCtrl.text.trim(),
    ));
    setState(() => _isSaved = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _isSaved = false;
        _isEditModalOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildAppBar()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildProfileHeader(),
                        const SizedBox(height: 28),
                        _buildIdentityCard(),
                        const SizedBox(height: 16),
                        _buildGpaCard(),
                        const SizedBox(height: 16),
                        _buildQuickActions(),
                        const SizedBox(height: 16),
                        _buildLogoutButton(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Nav
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomNav(),
          ),

          // Edit Modal
          if (_isEditModalOpen) _buildEditModal(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: AppColors.white.withOpacity(0.85),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.onNavigate(AppView.dashboard),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceContainer,
                  child: Text(
                    widget.user.fullName.isNotEmpty
                        ? widget.user.fullName[0].toUpperCase()
                        : 'U',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'The Sanctuary',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded,
                color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainer,
                  border: Border.all(
                    color: AppColors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.onSurface.withOpacity(0.10),
                      blurRadius: 24, offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: AppColors.surfaceContainer,
                  child: Text(
                    widget.user.fullName.isNotEmpty
                        ? widget.user.fullName[0].toUpperCase()
                        : 'U',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  onTap: () {
                    _initControllers();
                    setState(() {
                      _isEditModalOpen = true;
                      _isSaved = false;
                    });
                  },
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: mainGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.user.fullName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'UNDERGRADUATE CANDIDATE • ${widget.user.tahunMasuk}',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.05),
            blurRadius: 20, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Student Identity',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              Icon(Icons.verified_user_outlined,
                  color: AppColors.primaryContainer, size: 22),
            ],
          ),
          const SizedBox(height: 20),
          _infoGroup('Nama Lengkap', widget.user.fullName),
          _divider(),
          _infoGroup('Nomor Induk Mahasiswa', widget.user.nim),
          _divider(),
          Row(
            children: [
              Expanded(child: _infoGroup('Kelas', widget.user.kelas)),
              Expanded(
                  child: _infoGroup('Tahun Masuk', widget.user.tahunMasuk)),
            ],
          ),
          _divider(),
          _infoGroup('Program Studi', widget.user.prodi),
          const SizedBox(height: 16),
          // Badges
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _badge("Dean's List", AppColors.tertiaryContainer,
                  AppColors.onTertiaryContainer),
              _badge('Research Assistant', AppColors.surfaceContainerHighest,
                  const Color(0xFF596064)),
              _badge('Thesis Phase', AppColors.primary.withOpacity(0.1),
                  AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoGroup(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.outlineVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        color: AppColors.surfaceContainer,
        margin: const EdgeInsets.symmetric(vertical: 4),
      );

  Widget _badge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildGpaCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'CURRENT GPA',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.outlineVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '3.92',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 60,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 8,
              color: AppColors.surfaceContainer,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.92,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: mainGradient,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Tuition & Fees'},
      {'icon': Icons.description_outlined, 'label': 'Academic Transcript'},
      {'icon': Icons.security_outlined, 'label': 'Privacy Settings'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.05),
            blurRadius: 20, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: actions.map((a) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(a['icon'] as IconData,
                          size: 20, color: AppColors.outlineVariant),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        a['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.outlineVariant),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton(
      onPressed: widget.onLogout,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout_rounded,
              color: Color(0xFFDC2626), size: 20),
          const SizedBox(width: 8),
          Text(
            'Sign Out',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.92),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.08),
            blurRadius: 30, offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: false,
                onTap: () => widget.onNavigate(AppView.dashboard),
              ),
              _NavItem(
                icon: Icons.calendar_today_rounded,
                label: 'Schedule',
                isActive: false,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.newspaper_rounded,
                label: 'News',
                isActive: false,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditModal() {
    return GestureDetector(
      onTap: () => setState(() => _isEditModalOpen = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.all(28),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Edit Biodata',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isEditModalOpen = false),
                            child: Icon(Icons.close,
                                color: AppColors.outlineVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _editField('Nama Lengkap', _fullNameCtrl),
                      const SizedBox(height: 14),
                      _editField('Nomor Induk Mahasiswa', _nimCtrl),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _editField('Kelas', _kelasCtrl)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _editField('Tahun Masuk', _tahunCtrl)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _editField('Program Studi', _prodiCtrl),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _isSaved ? null : _handleSave,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: _isSaved ? null : mainGradient,
                            color: _isSaved
                                ? const Color(0xFF16A34A)
                                : null,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: _isSaved
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Tersimpan',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'Simpan Perubahan',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _editField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.outlineVariant,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: ctrl,
            style:
                GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isActive
              ? Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 22),
                )
              : Icon(icon, color: AppColors.outlineVariant, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.primary : AppColors.outlineVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
