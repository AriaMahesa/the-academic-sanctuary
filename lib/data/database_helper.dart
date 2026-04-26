// lib/data/database_helper.dart
//
// Singleton database helper — semua operasi SQLite ada di sini.
// Tabel:
//   users     → id, full_name, username, email, password, nim, kelas, prodi, tahun_masuk
//   schedules → id, user_id (FK), no, day, time, course, lecturer, status, room, sks

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'user_data.dart';

class DatabaseHelper {
  // ── Singleton ──────────────────────────────────────────────────────────────
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  // ── Init & Schema ──────────────────────────────────────────────────────────
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'academic_sanctuary.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Tabel users
    await db.execute('''
      CREATE TABLE users (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name   TEXT    NOT NULL,
        username    TEXT    NOT NULL UNIQUE,
        email       TEXT    NOT NULL UNIQUE,
        password    TEXT    NOT NULL,
        nim         TEXT    NOT NULL,
        kelas       TEXT    NOT NULL,
        prodi       TEXT    NOT NULL,
        tahun_masuk TEXT    NOT NULL
      )
    ''');

    // Tabel schedules — relasi ke users via user_id
    await db.execute('''
      CREATE TABLE schedules (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id   INTEGER NOT NULL,
        no        TEXT    NOT NULL,
        day       TEXT    NOT NULL,
        time      TEXT    NOT NULL,
        course    TEXT    NOT NULL,
        lecturer  TEXT    NOT NULL,
        status    TEXT    NOT NULL DEFAULT 'Mendatang',
        room      TEXT    NOT NULL,
        sks       INTEGER NOT NULL DEFAULT 2,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  // ── USER OPERATIONS ────────────────────────────────────────────────────────

  /// Daftarkan user baru. Return id jika sukses, -1 jika username/email sudah ada.
  Future<int> registerUser(UserData user, String password) async {
    final db = await database;
    try {
      final id = await db.insert(
        'users',
        {
          'full_name':   user.fullName,
          'username':    user.username,
          'email':       user.email,
          'password':    password,
          'nim':         user.nim,
          'kelas':       user.kelas,
          'prodi':       user.prodi,
          'tahun_masuk': user.tahunMasuk,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      // Insert jadwal default untuk user baru
      await _insertDefaultSchedules(db, id);
      return id;
    } catch (_) {
      return -1; // username atau email sudah terdaftar
    }
  }

  /// Login: cari user berdasarkan username/email dan password.
  /// Return UserData + id jika cocok, null jika gagal.
  Future<({UserData user, int id})?> loginUser(
      String identifier, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: '(username = ? OR email = ?) AND password = ?',
      whereArgs: [identifier, identifier, password],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return (
      user: _rowToUserData(row),
      id: row['id'] as int,
    );
  }

  /// Update biodata user (tidak update password).
  Future<void> updateUser(int userId, UserData user) async {
    final db = await database;
    await db.update(
      'users',
      {
        'full_name':   user.fullName,
        'nim':         user.nim,
        'kelas':       user.kelas,
        'prodi':       user.prodi,
        'tahun_masuk': user.tahunMasuk,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ── SCHEDULE OPERATIONS ───────────────────────────────────────────────────

  /// Ambil semua jadwal milik user.
  Future<List<Course>> getSchedules(int userId) async {
    final db = await database;
    final rows = await db.query(
      'schedules',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'no ASC',
    );
    return rows.map(_rowToCourse).toList();
  }

  /// Tambah jadwal baru.
  Future<int> insertSchedule(int userId, Course course) async {
    final db = await database;
    return await db.insert('schedules', _courseToRow(userId, course));
  }

  /// Update jadwal yang sudah ada (by no & user_id).
  Future<void> updateSchedule(int userId, Course course) async {
    final db = await database;
    await db.update(
      'schedules',
      _courseToRow(userId, course),
      where: 'user_id = ? AND no = ?',
      whereArgs: [userId, course.no],
    );
  }

  /// Simpan seluruh list jadwal (insert atau update tiap item).
Future<void> saveSchedules(int userId, List<Course> schedules) async {
  final db = await database;
  final batch = db.batch();
  
  // Hapus semua jadwal lama milik user ini dulu
  batch.delete('schedules', where: 'user_id = ?', whereArgs: [userId]);
  
  // Insert ulang semua dari awal
  for (final c in schedules) {
    batch.insert('schedules', _courseToRow(userId, c));
  }
  await batch.commit(noResult: true);
}

  /// Hapus satu jadwal.
  Future<void> deleteSchedule(int userId, String no) async {
    final db = await database;
    await db.delete(
      'schedules',
      where: 'user_id = ? AND no = ?',
      whereArgs: [userId, no],
    );
  }

  // ── PRIVATE HELPERS ───────────────────────────────────────────────────────

  Future<void> _insertDefaultSchedules(Database db, int userId) async {
    final batch = db.batch();
    for (final c in defaultSchedules) {
      batch.insert('schedules', _courseToRow(userId, c));
    }
    await batch.commit(noResult: true);
  }

  UserData _rowToUserData(Map<String, dynamic> row) {
    return UserData(
      fullName:   row['full_name']   as String,
      username:   row['username']    as String,
      email:      row['email']       as String,
      nim:        row['nim']         as String,
      kelas:      row['kelas']       as String,
      prodi:      row['prodi']       as String,
      tahunMasuk: row['tahun_masuk'] as String,
    );
  }

  Course _rowToCourse(Map<String, dynamic> row) {
    return Course(
      no:       row['no']       as String,
      day:      row['day']      as String,
      time:     row['time']     as String,
      course:   row['course']   as String,
      lecturer: row['lecturer'] as String,
      status:   row['status']   as String,
      room:     row['room']     as String,
      sks:      row['sks']      as int,
    );
  }

  Map<String, dynamic> _courseToRow(int userId, Course c) {
    return {
      'user_id':  userId,
      'no':       c.no,
      'day':      c.day,
      'time':     c.time,
      'course':   c.course,
      'lecturer': c.lecturer,
      'status':   c.status,
      'room':     c.room,
      'sks':      c.sks,
    };
  }

  /// Tutup koneksi DB (opsional, biasanya tidak perlu di-call manual).
  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
