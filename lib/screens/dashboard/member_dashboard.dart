import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

import '../../core/theme/app_theme.dart';

import '../../models/user_profile.dart';

import '../../services/auth_service.dart';

import '../../widgets/confirmation_dialog.dart';

import '../../widgets/role_badge.dart';

class MemberDashboard extends StatelessWidget {
  final UserProfile profile;

  final AuthService? authService;

  const MemberDashboard({super.key, required this.profile, this.authService});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context,

      title: 'Konfirmasi Keluar',

      message: 'Apakah Anda yakin ingin keluar dari akun ${profile.nama}?',

      confirmText: 'Keluar',

      cancelText: 'Batal',

      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final service = authService ?? AuthService();

      await service.signOut();
    }
  }

  /// Format informasi divisi yang ramah pengguna

  String _formatDivision(String? divisionId) {
    if (divisionId == null || divisionId.trim().isEmpty) {
      return 'Divisi belum ditentukan';
    }

    // Format nama ramah jika menggunakan ID atau slug

    final clean = divisionId.trim().replaceAll('_', ' ').replaceAll('-', ' ');

    if (clean.toLowerCase().startsWith('divisi')) {
      return clean
          .split(' ')
          .map(
            (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
          )
          .join(' ');
    }

    return 'Divisi ${clean.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),

              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,

                borderRadius: BorderRadius.circular(8),
              ),

              child: const Icon(
                Icons.hub_rounded,

                color: Colors.white,

                size: 18,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              AppConstants.appName,

              style: TextStyle(
                fontWeight: FontWeight.w800,

                letterSpacing: -0.3,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.lightBlue,
              child: Icon(
                Icons.person_rounded,
                color: AppTheme.anggotaPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // Kartu Sambutan Anggota dengan nuansa Teal/Emerald

            _buildMemberHeroCard(),

            const SizedBox(height: 24),

            // Judul dan Deskripsi Khusus Anggota
            const Text(
              'Dashboard Anggota',

              style: TextStyle(
                fontSize: 18,

                fontWeight: FontWeight.w800,

                color: AppTheme.textPrimary,

                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Aktivitas dan tugas Anda di HIMA Teknik Informatika.',

              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),

            const SizedBox(height: 16),

            // Tampilan Grid 2x2 Khusus Anggota (Berbeda secara layout dari Pengurus)
            _buildMemberGrid(),

            const SizedBox(height: 20),

            // Card Penjelasan Peran Anggota
            _buildMemberRoleInfo(),

            const SizedBox(height: 28),

            // Tombol Keluar
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.error, width: 1.2),

                foregroundColor: AppTheme.error,
              ),

              icon: const Icon(Icons.logout_rounded, size: 18),

              label: const Text(
                'Keluar dari Aplikasi',

                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              onPressed: () => _handleLogout(context),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: AppTheme.anggotaPrimary,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor: AppTheme.surface,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) return;
          final pages = ['Tugas', 'Agenda', 'Kas'];
          Navigator.of(context).push(
            _PageTurnRoute(
              page: _MemberPlaceholderPage(
                title: pages[index - 1],
                selectedIndex: index,
              ),
            ),
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available_outlined),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Kas',
          ),
        ],
      ),
    );
  }

  Widget _buildMemberHeroCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppTheme.surface,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: AppTheme.anggotaBorder, width: 1.2),

        boxShadow: [
          BoxShadow(
            color: AppTheme.anggotaPrimary.withValues(alpha: 0.05),

            blurRadius: 12,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Badge ANGGOTA

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              RoleBadge(role: profile.role),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),

                decoration: BoxDecoration(
                  color: AppTheme.anggotaBg,

                  borderRadius: BorderRadius.circular(6),

                  border: Border.all(color: AppTheme.anggotaBorder),
                ),

                child: const Text(
                  'Anggota Aktif',

                  style: TextStyle(
                    fontSize: 11,

                    fontWeight: FontWeight.w700,

                    color: AppTheme.anggotaPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Halo, ${profile.nama}!',

            style: const TextStyle(
              fontSize: 22,

              fontWeight: FontWeight.w800,

              color: AppTheme.textPrimary,

              letterSpacing: -0.4,
            ),
          ),

          const SizedBox(height: 6),

          // Info Divisi
          Row(
            children: [
              const Icon(
                Icons.workspaces_outline,

                size: 15,

                color: AppTheme.anggotaPrimary,
              ),

              const SizedBox(width: 6),

              Text(
                _formatDivision(profile.divisiId),

                style: const TextStyle(
                  fontSize: 13,

                  fontWeight: FontWeight.w600,

                  color: AppTheme.anggotaPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Divider(height: 1),

          const SizedBox(height: 14),

          // Detail Identitas Mahasiswa
          Row(
            children: [
              const Icon(
                Icons.email_outlined,
                size: 14,
                color: AppTheme.textMuted,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  profile.email,

                  style: const TextStyle(
                    fontSize: 12,

                    color: AppTheme.textSecondary,
                  ),

                  overflow: TextOverflow.ellipsis,
                ),
              ),

              if (profile.nim != null && profile.nim!.isNotEmpty) ...[
                const SizedBox(width: 10),

                const Icon(
                  Icons.badge_outlined,
                  size: 14,
                  color: AppTheme.textMuted,
                ),

                const SizedBox(width: 4),

                Text(
                  'NIM: ${profile.nim}',

                  style: const TextStyle(
                    fontSize: 12,

                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberGrid() {
    final items = [
      _MemberActionItem(
        icon: Icons.checklist_rtl_rounded,

        title: 'Tugas Saya',

        subtitle: 'Daftar penugasan pribadi',

        color: const Color(0xFF0284C7),
      ),

      _MemberActionItem(
        icon: Icons.calendar_month_rounded,

        title: 'Kegiatan',

        subtitle: 'Jadwal agenda HIMA TI',

        color: const Color(0xFF7C3AED),
      ),

      _MemberActionItem(
        icon: Icons.how_to_reg_rounded,

        title: 'Absensi',

        subtitle: 'Kehadiran rapat & acara',

        color: const Color(0xFF059669),
      ),

      _MemberActionItem(
        icon: Icons.notifications_none_rounded,

        title: 'Pengumuman',

        subtitle: 'Informasi pengurus',

        color: const Color(0xFFEA580C),
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),

      shrinkWrap: true,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,

        crossAxisSpacing: 12,

        mainAxisSpacing: 12,

        childAspectRatio: 1.15,
      ),

      itemCount: items.length,

      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: AppTheme.surface,

            borderRadius: BorderRadius.circular(16),

            border: Border.all(color: AppTheme.borderLight),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Container(
                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),

                  borderRadius: BorderRadius.circular(10),
                ),

                child: Icon(item.icon, color: item.color, size: 22),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    item.title,

                    style: const TextStyle(
                      fontSize: 14,

                      fontWeight: FontWeight.w700,

                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    item.subtitle,

                    style: const TextStyle(
                      fontSize: 11,

                      color: AppTheme.textMuted,

                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMemberRoleInfo() {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: AppTheme.anggotaBg,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: AppTheme.anggotaBorder),
      ),

      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(
            Icons.info_outline_rounded,

            size: 18,

            color: AppTheme.anggotaPrimary,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Dashboard Anggota digunakan untuk memantau aktivitas organisasi, absensi kegiatan, serta tugas individu Anda. Fitur interaktif akan tersedia pada tahap pengembangan lanjutan.',

              style: TextStyle(
                fontSize: 12,

                color: Color(0xFF115E59),

                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberActionItem {
  final IconData icon;

  final String title;

  final String subtitle;

  final Color color;

  _MemberActionItem({
    required this.icon,

    required this.title,

    required this.subtitle,

    required this.color,
  });
}

/// Halaman placeholder untuk navigasi Tugas, Agenda, dan Kas.
/// UI header dan bottom navigation dibuat sama dengan dashboard anggota.
class _MemberPlaceholderPage extends StatelessWidget {
  final String title;
  final int selectedIndex;

  const _MemberPlaceholderPage({
    required this.title,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.hub_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.lightBlue,
              child: Icon(
                Icons.person_rounded,
                color: AppTheme.anggotaPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Ini halaman $title',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        selectedItemColor: AppTheme.anggotaPrimary,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor: AppTheme.surface,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            return;
          }
          final pages = ['Tugas', 'Agenda', 'Kas'];
          Navigator.of(context).pushReplacement(
            _PageTurnRoute(
              page: _MemberPlaceholderPage(
                title: pages[index - 1],
                selectedIndex: index,
              ),
            ),
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available_outlined),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Kas',
          ),
        ],
      ),
    );
  }
}

/// Transisi halus berupa sedikit geseran horizontal dan fade, tanpa efek 3D.
class _PageTurnRoute<T> extends PageRouteBuilder<T> {
  _PageTurnRoute({required Widget page})
    : super(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final slide = Tween<Offset>(
            begin: const Offset(0.035, 0),
            end: Offset.zero,
          ).animate(curved);

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(position: slide, child: child),
          );
        },
      );
}
