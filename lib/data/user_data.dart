// lib/data/user_data.dart

class UserData {
  String fullName;
  String username;
  String email;
  String nim;
  String kelas;
  String prodi;
  String tahunMasuk;

  UserData({
    required this.fullName,
    required this.username,
    required this.email,
    required this.nim,
    required this.kelas,
    required this.prodi,
    required this.tahunMasuk,
  });

  UserData copyWith({
    String? fullName,
    String? username,
    String? email,
    String? nim,
    String? kelas,
    String? prodi,
    String? tahunMasuk,
  }) {
    return UserData(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      nim: nim ?? this.nim,
      kelas: kelas ?? this.kelas,
      prodi: prodi ?? this.prodi,
      tahunMasuk: tahunMasuk ?? this.tahunMasuk,
    );
  }
}

class Course {
  String no;
  String day;
  String time;
  String course;
  String lecturer;
  String status;
  String room;
  int sks;

  Course({
    required this.no,
    required this.day,
    required this.time,
    required this.course,
    required this.lecturer,
    required this.status,
    required this.room,
    required this.sks,
  });

  Course copyWith({
    String? no,
    String? day,
    String? time,
    String? course,
    String? lecturer,
    String? status,
    String? room,
    int? sks,
  }) {
    return Course(
      no: no ?? this.no,
      day: day ?? this.day,
      time: time ?? this.time,
      course: course ?? this.course,
      lecturer: lecturer ?? this.lecturer,
      status: status ?? this.status,
      room: room ?? this.room,
      sks: sks ?? this.sks,
    );
  }
}

class NewsItem {
  final String type;
  final String title;
  final String description;
  final String fullText;
  final String imageSeed;

  const NewsItem({
    required this.type,
    required this.title,
    required this.description,
    required this.fullText,
    required this.imageSeed,
  });
}

// ─── Default Schedule Data ────────────────────────────────────────────────────
final List<Course> defaultSchedules = [
  Course(
    no: '01',
    day: 'Senin',
    time: '08:00 - 10:30',
    course: 'Kecerdasan Buatan',
    lecturer: 'Dr. Budi Santoso',
    status: 'Berlangsung',
    room: 'Lab AI-1',
    sks: 3,
  ),
  Course(
    no: '02',
    day: 'Selasa',
    time: '13:00 - 15:30',
    course: 'Interaksi Manusia & Komputer',
    lecturer: 'Maya Wijaya, M.Kom',
    status: 'Mendatang',
    room: 'R.402',
    sks: 2,
  ),
  Course(
    no: '03',
    day: 'Rabu',
    time: '09:00 - 11:30',
    course: 'Etika Digital',
    lecturer: 'Prof. Agus Salim',
    status: 'Mendatang',
    room: 'R.301',
    sks: 2,
  ),
  Course(
    no: '04',
    day: 'Kamis',
    time: '10:00 - 12:30',
    course: 'Keamanan Jaringan',
    lecturer: 'Indra Pratama, Ph.D',
    status: 'Mendatang',
    room: 'Lab Jaringan',
    sks: 3,
  ),
  Course(
    no: '05',
    day: 'Jumat',
    time: '14:00 - 16:30',
    course: 'Desain UI/UX',
    lecturer: 'Siska Amelia, M.Ds',
    status: 'Dibatalkan',
    room: 'Studio DKV',
    sks: 3,
  ),
];

// ─── Default News Data ────────────────────────────────────────────────────────
final List<NewsItem> newsData = [
  const NewsItem(
    type: 'PENGUMUMAN',
    title: 'Renovasi Perpustakaan Pusat Dimulai Pekan Depan',
    description:
        'Peningkatan fasilitas digital dan ruang baca kolektif untuk kenyamanan mahasiswa.',
    fullText:
        'Pihak rektorat telah menyetujui anggaran renovasi perpustakaan pusat tahap II. Mulai senin depan, lantai 3 akan ditutup sementara untuk instalasi High-Speed WiFi dan pod belajar privat. Mahasiswa disarankan menggunakan perpustakaan fakultas selama masa renovasi berlangsung.',
    imageSeed: 'library',
  ),
  const NewsItem(
    type: 'EVENT',
    title: 'Seminar Internasional: Masa Depan AI di Indonesia',
    description:
        'Menghadirkan pembicara dari Silicon Valley untuk membahas tren teknologi terkini.',
    fullText:
        'Artificial Intelligence bukan lagi masa depan, melainkan hari ini. Dalam seminar ini, kita akan mendalami bagaimana model bahasa besar (LLM) dapat diintegrasikan dalam kurikulum akademik untuk meningkatkan produktivitas riset mahasiswa.',
    imageSeed: 'technology',
  ),
  const NewsItem(
    type: 'AKADEMIK',
    title: 'Beasiswa Prestasi Semester Ganjil Telah Dibuka',
    description:
        'Peluang bagi mahasiswa aktif dengan IPK di atas 3.75 untuk mendapatkan bantuan dana.',
    fullText:
        'Capaian akademik Anda layak mendapatkan apresiasi lebih. Daftarkan diri Anda di portal kemahasiswaan dengan mengunggah KHS terakhir dan surat keterangan aktif organisasi. Penutupan pendaftaran adalah hari Jumat pekan ketiga bulan ini.',
    imageSeed: 'scholarship',
  ),
];
