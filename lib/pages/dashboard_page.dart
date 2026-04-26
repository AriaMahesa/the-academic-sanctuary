// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/user_data.dart';
import '../main.dart';

class DashboardPage extends StatefulWidget {
  final UserData user;
  final List<Course> schedules;
  final Future<void> Function(List<Course>) onUpdateSchedules;
  final void Function(AppView) onNavigate;

  const DashboardPage({
    super.key,
    required this.user,
    required this.schedules,
    required this.onUpdateSchedules,
    required this.onNavigate,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentTab = 0; // 0=Home, 1=Schedule, 2=News, 3=Profile

  NewsItem? _selectedNews;
  Course?   _selectedCourse;
  bool      _isEditModalOpen = false;
  Course?   _editingCourse;
  String?   _activeToast;

  void _triggerToast(String msg) {
    setState(() => _activeToast = msg);
    Future.delayed(const Duration(seconds: 3),
        () { if (mounted) setState(() => _activeToast = null); });
  }

  void _openEditModal([Course? course]) {
    final existing = course;
    setState(() {
      _editingCourse = existing ??
          Course(
            no:       '${widget.schedules.length + 1}'.padLeft(2, '0'),
            day:      'Senin',
            time:     '08:00 - 10:30',
            course:   '',
            lecturer: '',
            status:   'Mendatang',
            room:     '',
            sks:      2,
          );
      _isEditModalOpen = true;
    });
  }

  void _saveEditCourse() {
    if (_editingCourse == null) return;
    final updated = List<Course>.from(widget.schedules);
    final idx = updated.indexWhere((c) => c.no == _editingCourse!.no);
    if (idx >= 0) {
      updated[idx] = _editingCourse!;
    } else {
      updated.add(_editingCourse!);
    }
    widget.onUpdateSchedules(updated);
    setState(() => _isEditModalOpen = false);
    _triggerToast('Jadwal berhasil diperbarui');
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Berlangsung': return AppColors.tertiaryContainer;
      case 'Dibatalkan':  return const Color(0xFFFEE2E2);
      default:            return AppColors.surfaceContainerHighest;
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'Berlangsung': return AppColors.onTertiaryContainer;
      case 'Dibatalkan':  return const Color(0xFFB91C1C);
      default:            return const Color(0xFF596064);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Konten utama berdasarkan tab aktif ──────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: IndexedStack(
                    index: _currentTab,
                    children: [
                      _HomeTab(
                        user:            widget.user,
                        schedules:       widget.schedules,
                        statusColor:     _statusColor,
                        statusTextColor: _statusTextColor,
                        onTapCourse:     (c) => setState(() => _selectedCourse = c),
                        onEditCourse:    _openEditModal,
                        onAddCourse:     () => _openEditModal(),
                        onTapNews:       (n) => setState(() => _selectedNews = n),
                      ),
                      _ScheduleTab(
                        schedules:       widget.schedules,
                        statusColor:     _statusColor,
                        statusTextColor: _statusTextColor,
                        onTapCourse:     (c) => setState(() => _selectedCourse = c),
                        onEditCourse:    _openEditModal,
                        onAddCourse:     () => _openEditModal(),
                      ),
                      _NewsTab(
                        onTapNews: (n) => setState(() => _selectedNews = n),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Nav ────────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomNav(),
          ),

          // ── Toast ─────────────────────────────────────────────────────
          if (_activeToast != null)
            Positioned(
              bottom: 100, left: 20, right: 20,
              child: _ToastWidget(message: _activeToast!),
            ),

          // ── Modals ────────────────────────────────────────────────────
          if (_selectedNews != null)
            _NewsModal(
              news:    _selectedNews!,
              onClose: () => setState(() => _selectedNews = null),
            ),

          if (_selectedCourse != null)
            _CourseDetailModal(
              course:          _selectedCourse!,
              onClose:         () => setState(() => _selectedCourse = null),
              onEdit:          () {
                final c = _selectedCourse!;
                setState(() => _selectedCourse = null);
                _openEditModal(c);
              },
              statusColor:     _statusColor(_selectedCourse!.status),
              statusTextColor: _statusTextColor(_selectedCourse!.status),
            ),

          if (_isEditModalOpen && _editingCourse != null)
            _EditCourseModal(
              course:    _editingCourse!,
              onClose:   () => setState(() => _isEditModalOpen = false),
              onChanged: (c) => setState(() => _editingCourse = c),
              onSave:    _saveEditCourse,
            ),
        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: AppColors.white.withOpacity(0.92),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.onNavigate(AppView.profile),
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

  // ── Bottom Nav ─────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      (Icons.home_rounded,          Icons.home_outlined,          'Home'),
      (Icons.calendar_month_rounded,Icons.calendar_month_outlined, 'Schedule'),
      (Icons.newspaper_rounded,     Icons.newspaper_outlined,      'News'),
      (Icons.person_rounded,        Icons.person_outline_rounded,  'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = _currentTab == i;
              final item = items[i];
              return GestureDetector(
                onTap: () {
                  if (i == 3) {
                    widget.onNavigate(AppView.profile);
                  } else {
                    setState(() => _currentTab = i);
                  }
                },
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
                            child: Icon(item.$1,
                                color: AppColors.primary, size: 22),
                          )
                        : Icon(item.$2,
                            color: AppColors.outlineVariant, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      item.$3,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB: HOME
// ══════════════════════════════════════════════════════════════════════════════
class _HomeTab extends StatelessWidget {
  final UserData user;
  final List<Course> schedules;
  final Color Function(String) statusColor;
  final Color Function(String) statusTextColor;
  final void Function(Course) onTapCourse;
  final void Function(Course) onEditCourse;
  final VoidCallback onAddCourse;
  final void Function(NewsItem) onTapNews;

  const _HomeTab({
    required this.user,
    required this.schedules,
    required this.statusColor,
    required this.statusTextColor,
    required this.onTapCourse,
    required this.onEditCourse,
    required this.onAddCourse,
    required this.onTapNews,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 28),
          _buildScheduleSection(),
          const SizedBox(height: 28),
          _buildNewsSection(),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: mainGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${user.fullName.split(' ').first} 👋',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${user.prodi} • ${user.kelas}',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8))),
                const SizedBox(height: 2),
                Text('NIM: ${user.nim}',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.school_rounded,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalSks =
        schedules.fold<int>(0, (sum, c) => sum + c.sks);
    final active =
        schedules.where((c) => c.status == 'Berlangsung').length;
    final items = [
      (Icons.book_outlined,        '${schedules.length}', 'Total MK'),
      (Icons.layers_outlined,      '$totalSks',           'Total SKS'),
      (Icons.play_circle_outline,  '$active',             'Aktif'),
    ];
    return Row(
      children: List.generate(items.length, (i) {
        final item = items[i];
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(item.$1, color: AppColors.primary, size: 20),
                const SizedBox(height: 6),
                Text(item.$2,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface)),
                Text(item.$3,
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.outlineVariant)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildScheduleSection() {
    // Hanya tampil 3 jadwal pertama di Home
    final preview = schedules.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Jadwal Kuliah',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    letterSpacing: -0.3)),
            const Spacer(),
            GestureDetector(
              onTap: onAddCourse,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: mainGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text('Tambah',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...preview.map((c) => _ScheduleCard(
              course:          c,
              statusColor:     statusColor(c.status),
              statusTextColor: statusTextColor(c.status),
              onTap:           () => onTapCourse(c),
              onEdit:          () => onEditCourse(c),
            )),
        if (schedules.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Center(
              child: Text(
                '+ ${schedules.length - 3} jadwal lainnya — lihat di tab Schedule',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Berita & Pengumuman',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -0.3)),
        const SizedBox(height: 12),
        ...newsData.map((n) =>
            _NewsCard(news: n, onTap: () => onTapNews(n))),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB: SCHEDULE
// ══════════════════════════════════════════════════════════════════════════════
class _ScheduleTab extends StatelessWidget {
  final List<Course> schedules;
  final Color Function(String) statusColor;
  final Color Function(String) statusTextColor;
  final void Function(Course) onTapCourse;
  final void Function(Course) onEditCourse;
  final VoidCallback onAddCourse;

  const _ScheduleTab({
    required this.schedules,
    required this.statusColor,
    required this.statusTextColor,
    required this.onTapCourse,
    required this.onEditCourse,
    required this.onAddCourse,
  });

  @override
  Widget build(BuildContext context) {
    // Kelompokkan berdasarkan hari
    final days = ['Senin','Selasa','Rabu','Kamis','Jumat'];
    final grouped = <String, List<Course>>{};
    for (final d in days) {
      final list = schedules.where((c) => c.day == d).toList();
      if (list.isNotEmpty) grouped[d] = list;
    }
    // Jadwal tanpa hari standar
    final others = schedules
        .where((c) => !days.contains(c.day))
        .toList();
    if (others.isNotEmpty) grouped['Lainnya'] = others;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('Semua Jadwal',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      letterSpacing: -0.3)),
              const Spacer(),
              GestureDetector(
                onTap: onAddCourse,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: mainGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text('Tambah',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${schedules.length} mata kuliah terdaftar',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.outlineVariant)),
          const SizedBox(height: 20),

          if (schedules.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 64,
                        color: AppColors.outlineVariant),
                    const SizedBox(height: 16),
                    Text('Belum ada jadwal',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.outlineVariant)),
                    const SizedBox(height: 8),
                    Text('Tap tombol Tambah untuk menambahkan jadwal',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.outlineVariant)),
                  ],
                ),
              ),
            )
          else
            ...grouped.entries.map((entry) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day header
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              entry.key,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.surfaceContainerHighest,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...entry.value.map((c) => _ScheduleCard(
                          course:          c,
                          statusColor:     statusColor(c.status),
                          statusTextColor: statusTextColor(c.status),
                          onTap:           () => onTapCourse(c),
                          onEdit:          () => onEditCourse(c),
                        )),
                    const SizedBox(height: 8),
                  ],
                )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB: NEWS
// ══════════════════════════════════════════════════════════════════════════════
class _NewsTab extends StatelessWidget {
  final void Function(NewsItem) onTapNews;

  const _NewsTab({required this.onTapNews});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Berita & Pengumuman',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.3)),
          const SizedBox(height: 4),
          Text('Informasi terkini seputar kampus',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.outlineVariant)),
          const SizedBox(height: 20),

          // Featured — item pertama ditampilkan besar
          _NewsFeaturedCard(
              news: newsData.first, onTap: () => onTapNews(newsData.first)),
          const SizedBox(height: 14),

          // Sisanya card biasa
          ...newsData.skip(1).map((n) =>
              _NewsCard(news: n, onTap: () => onTapNews(n))),
        ],
      ),
    );
  }
}

// ── Featured news card (besar, di tab News) ───────────────────────────────────
class _NewsFeaturedCard extends StatelessWidget {
  final NewsItem news;
  final VoidCallback onTap;

  const _NewsFeaturedCard({required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: Image.network(
                'https://picsum.photos/seed/${news.imageSeed}/600/280',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180, color: AppColors.surfaceContainer,
                  child: Icon(Icons.image_outlined,
                      color: AppColors.outlineVariant, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(news.type,
                        style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 1)),
                  ),
                  const SizedBox(height: 8),
                  Text(news.title,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          height: 1.3)),
                  const SizedBox(height: 6),
                  Text(news.description,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.outlineVariant,
                          height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED CARDS & WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _ScheduleCard extends StatelessWidget {
  final Course course;
  final Color statusColor;
  final Color statusTextColor;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _ScheduleCard({
    required this.course,
    required this.statusColor,
    required this.statusTextColor,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(course.no,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                  Text(course.day.substring(0, 3),
                      style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.outlineVariant)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.course,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface)),
                  const SizedBox(height: 2),
                  Text(course.lecturer,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.outlineVariant)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 11, color: AppColors.outlineVariant),
                      const SizedBox(width: 3),
                      Text(course.time,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.outlineVariant)),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on_outlined,
                          size: 11, color: AppColors.outlineVariant),
                      const SizedBox(width: 2),
                      Text(course.room,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.outlineVariant)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(course.status,
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusTextColor)),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.edit_outlined,
                        size: 14, color: AppColors.outlineVariant),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem news;
  final VoidCallback onTap;

  const _NewsCard({required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18)),
              child: Image.network(
                'https://picsum.photos/seed/${news.imageSeed}/160/120',
                width: 96, height: 96,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 96, height: 96,
                  color: AppColors.surfaceContainer,
                  child: Icon(Icons.image_outlined,
                      color: AppColors.outlineVariant),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(news.type,
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 1)),
                    ),
                    const SizedBox(height: 5),
                    Text(news.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            height: 1.3)),
                    const SizedBox(height: 3),
                    Text(news.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.outlineVariant,
                            height: 1.4)),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded,
                  color: AppColors.outlineVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Toast ─────────────────────────────────────────────────────────────────────
class _ToastWidget extends StatelessWidget {
  final String message;
  const _ToastWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.onSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppColors.tertiaryContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── News Modal ────────────────────────────────────────────────────────────────
class _NewsModal extends StatelessWidget {
  final NewsItem news;
  final VoidCallback onClose;

  const _NewsModal({required this.news, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28)),
                      child: Stack(
                        children: [
                          Image.network(
                            'https://picsum.photos/seed/${news.imageSeed}/600/280',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 180,
                              color: AppColors.surfaceContainer,
                            ),
                          ),
                          Positioned(
                            top: 12, right: 12,
                            child: GestureDetector(
                              onTap: onClose,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                    color: Colors.black38,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(news.type,
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: 1.5)),
                          const SizedBox(height: 8),
                          Text(news.title,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                  height: 1.2,
                                  letterSpacing: -0.3)),
                          const SizedBox(height: 10),
                          Container(
                            height: 4, width: 40,
                            decoration: BoxDecoration(
                              gradient: mainGradient,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(news.fullText,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.onSurface.withOpacity(0.7),
                                  height: 1.6)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Course Detail Modal ───────────────────────────────────────────────────────
class _CourseDetailModal extends StatelessWidget {
  final Course course;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final Color statusColor;
  final Color statusTextColor;

  const _CourseDetailModal({
    required this.course,
    required this.onClose,
    required this.onEdit,
    required this.statusColor,
    required this.statusTextColor,
  });

  Widget _row(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.outlineVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.onSurface)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54,
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(course.course,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface)),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: Icon(Icons.close,
                          color: AppColors.outlineVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _row(Icons.person_outline, course.lecturer),
                _row(Icons.access_time_rounded,
                    '${course.day}, ${course.time}'),
                _row(Icons.location_on_outlined, course.room),
                _row(Icons.layers_outlined, '${course.sks} SKS'),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(course.status,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusTextColor)),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: mainGradient,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Text('Edit Jadwal',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Edit Course Modal ─────────────────────────────────────────────────────────
class _EditCourseModal extends StatefulWidget {
  final Course course;
  final VoidCallback onClose;
  final void Function(Course) onChanged;
  final VoidCallback onSave;

  const _EditCourseModal({
    required this.course,
    required this.onClose,
    required this.onChanged,
    required this.onSave,
  });

  @override
  State<_EditCourseModal> createState() => _EditCourseModalState();
}

class _EditCourseModalState extends State<_EditCourseModal> {
  late TextEditingController _courseCtrl;
  late TextEditingController _lecturerCtrl;
  late TextEditingController _timeCtrl;
  late TextEditingController _roomCtrl;
  late TextEditingController _sksCtrl;
  String _selectedDay = 'Senin';
  String _selectedStatus = 'Mendatang';

  @override
  void initState() {
    super.initState();
    _courseCtrl   = TextEditingController(text: widget.course.course);
    _lecturerCtrl = TextEditingController(text: widget.course.lecturer);
    _timeCtrl     = TextEditingController(text: widget.course.time);
    _roomCtrl     = TextEditingController(text: widget.course.room);
    _sksCtrl      = TextEditingController(text: '${widget.course.sks}');
    _selectedDay    = widget.course.day;
    _selectedStatus = widget.course.status;
  }

  @override
  void dispose() {
    _courseCtrl.dispose(); _lecturerCtrl.dispose();
    _timeCtrl.dispose();   _roomCtrl.dispose();
    _sksCtrl.dispose();
    super.dispose();
  }

  void _emit() => widget.onChanged(widget.course.copyWith(
    course:   _courseCtrl.text,
    lecturer: _lecturerCtrl.text,
    day:      _selectedDay,
    time:     _timeCtrl.text,
    room:     _roomCtrl.text,
    status:   _selectedStatus,
    sks:      int.tryParse(_sksCtrl.text) ?? widget.course.sks,
  ));

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Text(label.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.outlineVariant,
                  letterSpacing: 1.2)),
        ),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            onChanged: (_) => _emit(),
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.onSurface),
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

  Widget _dropdown<T>(String label, T value, List<T> items,
      void Function(T?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Text(label.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.outlineVariant,
                  letterSpacing: 1.2)),
        ),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.onSurface),
              items: items
                  .map((v) => DropdownMenuItem(
                      value: v, child: Text(v.toString())))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
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
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Edit Mata Kuliah',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onSurface)),
                          ),
                          GestureDetector(
                            onTap: widget.onClose,
                            child: Icon(Icons.close,
                                color: AppColors.outlineVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _field('Nama Mata Kuliah', _courseCtrl),
                      const SizedBox(height: 12),
                      _field('Dosen Pengampu', _lecturerCtrl),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _dropdown<String>(
                              'Hari', _selectedDay,
                              ['Senin','Selasa','Rabu','Kamis','Jumat'],
                              (v) { if (v != null) { setState(() => _selectedDay = v); _emit(); } },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _field('Jam', _timeCtrl)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _field('Ruangan', _roomCtrl)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field('SKS', _sksCtrl,
                                keyboardType: TextInputType.number),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _dropdown<String>(
                        'Status', _selectedStatus,
                        ['Berlangsung', 'Mendatang', 'Dibatalkan'],
                        (v) { if (v != null) { setState(() => _selectedStatus = v); _emit(); } },
                      ),
                      const SizedBox(height: 22),
                      GestureDetector(
                        onTap: widget.onSave,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: mainGradient,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: Text('Simpan Perubahan',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
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
}