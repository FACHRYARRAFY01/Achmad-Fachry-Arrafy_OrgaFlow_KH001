import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_orgaflow/enums/user_role.dart';
import 'package:flutter_orgaflow/models/user_profile.dart';
import 'package:flutter_orgaflow/screens/auth/login_screen.dart';
import 'package:flutter_orgaflow/screens/dashboard/management_dashboard.dart';
import 'package:flutter_orgaflow/screens/dashboard/member_dashboard.dart';
import 'package:flutter_orgaflow/services/auth_service.dart';
import 'package:flutter_orgaflow/widgets/role_badge.dart';

class FakeAuthService implements AuthService {
  @override
  Stream<User?> get authStateChanges => Stream.value(null);

  @override
  User? get currentUser => null;

  @override
  Future<UserProfile> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    throw const AuthServiceException('Simulasi error login.');
  }

  @override
  Future<void> changePassword({required String newPassword}) async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  group('Widget UI & Dashboard Tests', () {
    testWidgets('RoleBadge menampilkan PENGURUS dan ANGGOTA dengan benar', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                RoleBadge(role: UserRole.ketua, showSpecificRole: true),
                RoleBadge(role: UserRole.anggota),
              ],
            ),
          ),
        ),
      );

      expect(find.text('PENGURUS'), findsOneWidget);
      expect(find.text('Ketua'), findsOneWidget);
      expect(find.text('ANGGOTA'), findsOneWidget);
    });

    testWidgets('ManagementDashboard menampilkan dashboard khusus Ketua', (
      tester,
    ) async {
      final officerProfile = UserProfile(
        uid: 'uid-ketua',
        nama: 'Fakhri Herlambang',
        email: 'fakhri@hima-ti.org',
        nim: '22001122',
        role: UserRole.ketua,
        wajibGantiPassword: false,
        statusAkun: 'aktif',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ManagementDashboard(
            profile: officerProfile,
            authService: FakeAuthService(),
          ),
        ),
      );

      expect(find.text('Aktif'), findsOneWidget);
      expect(find.text('Halo, Fakhri Herlambang 👋'), findsOneWidget);
      expect(find.text('Persetujuan'), findsOneWidget);
      expect(find.text('Proker Berjalan'), findsOneWidget);
      expect(find.text('Persetujuan Penting'), findsOneWidget);
      expect(find.text('Proposal IT Fest (Revisi Anggaran)'), findsOneWidget);
      expect(find.text('Agenda Berikutnya'), findsOneWidget);
      expect(find.text('Rapat Evaluasi Bersama BPH & BO'), findsOneWidget);
    });

    testWidgets('Navigasi bawah membuka placeholder dan kembali ke Beranda', (
      tester,
    ) async {
      final officerProfile = UserProfile(
        uid: 'uid-ketua',
        nama: 'Fakhri Herlambang',
        email: 'fakhri@hima-ti.org',
        role: UserRole.ketua,
        wajibGantiPassword: false,
        statusAkun: 'aktif',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ManagementDashboard(
            profile: officerProfile,
            authService: FakeAuthService(),
          ),
        ),
      );

      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Tugas'), findsOneWidget);
      expect(find.text('Agenda'), findsOneWidget);
      expect(find.text('Kas'), findsOneWidget);

      await tester.tap(find.text('Tugas'));
      await tester.pumpAndSettle();
      expect(find.text('Ini halaman Tugas'), findsOneWidget);

      await tester.tap(find.text('Agenda'));
      await tester.pumpAndSettle();
      expect(find.text('Ini halaman Agenda'), findsOneWidget);

      await tester.tap(find.text('Kas'));
      await tester.pumpAndSettle();
      expect(find.text('Ini halaman Kas'), findsOneWidget);

      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();
      expect(find.text('Persetujuan Penting'), findsOneWidget);
    });

    testWidgets(
      'ManagementDashboard menyesuaikan ringkasan tiap role dan agenda tetap sama',
      (tester) async {
        final roles = {
          UserRole.wakilKetua: ('Program Dipantau', 'Pemantauan Penting'),
          UserRole.sekretaris: ('Surat Masuk', 'Dokumen Perlu Ditinjau'),
          UserRole.bendahara: ('Pengajuan Dana', 'Persetujuan Keuangan'),
          UserRole.kepalaDivisi: ('Tugas Divisi', 'Tindak Lanjut Divisi'),
        };

        for (final entry in roles.entries) {
          final profile = UserProfile(
            uid: 'uid-${entry.key.firestoreValue}',
            nama: 'Pengurus',
            email: 'pengurus@hima-ti.org',
            role: entry.key,
            wajibGantiPassword: false,
            statusAkun: 'aktif',
          );

          await tester.pumpWidget(
            MaterialApp(
              home: ManagementDashboard(
                profile: profile,
                authService: FakeAuthService(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text(entry.value.$1), findsOneWidget);
          expect(find.text(entry.value.$2), findsOneWidget);
          expect(find.text('Agenda Berikutnya'), findsOneWidget);
          expect(find.text('Rapat Evaluasi Bersama BPH & BO'), findsOneWidget);
        }
      },
    );

    testWidgets(
      'MemberDashboard menampilkan identitas Anggota dan layout berbeda',
      (tester) async {
        final memberProfile = UserProfile(
          uid: 'uid-anggota',
          nama: 'Budi Santoso',
          email: 'budi@hima-ti.org',
          nim: '22003344',
          role: UserRole.anggota,
          divisiId: 'divisi_media_dan_informasi',
          wajibGantiPassword: false,
          statusAkun: 'aktif',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MemberDashboard(
              profile: memberProfile,
              authService: FakeAuthService(),
            ),
          ),
        );

        expect(find.text('ANGGOTA'), findsOneWidget);
        expect(find.text('Halo, Budi Santoso!'), findsOneWidget);
        expect(find.text('Dashboard Anggota'), findsOneWidget);
        expect(find.text('Tugas Saya'), findsOneWidget);
        expect(find.text('Kegiatan'), findsOneWidget);
        expect(find.text('Absensi'), findsOneWidget);
        expect(find.text('Pengumuman'), findsOneWidget);
        expect(find.text('Keluar dari Aplikasi'), findsOneWidget);
      },
    );

    testWidgets('LoginScreen memvalidasi input kosong', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: LoginScreen(authService: FakeAuthService())),
      );

      expect(find.text('Selamat Datang di OrgaFlow'), findsOneWidget);
      expect(find.text('Masuk ke OrgaFlow'), findsOneWidget);

      // Tekan tombol Masuk tanpa mengisi form
      await tester.tap(find.text('Masuk ke OrgaFlow'));
      await tester.pumpAndSettle();

      expect(find.text('Email wajib diisi.'), findsOneWidget);
      expect(find.text('Password wajib diisi.'), findsOneWidget);
    });
  });
}
