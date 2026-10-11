import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../enums/user_role.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/division_service.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/division_name_text.dart';

class ManagementDashboard extends StatefulWidget {
  final UserProfile profile;
  final AuthService? authService;
  final DivisionNameLoader? divisionNameLoader;

  const ManagementDashboard({
    super.key,
    required this.profile,
    this.authService,
    this.divisionNameLoader,
  });

  @override
  State<ManagementDashboard> createState() => _ManagementDashboardState();
}

class _ManagementDashboardState extends State<ManagementDashboard> {
  int _selectedIndex = 0;

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Konfirmasi Keluar',
      message:
          'Apakah Anda yakin ingin keluar dari akun ${widget.profile.nama}?',
      confirmText: 'Keluar',
      cancelText: 'Batal',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final service = widget.authService ?? AuthService();
      await service.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = _dashboardByRole[widget.profile.role]!;

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
          // Tombol notifikasi (paling kiri)
          IconButton(
            tooltip: 'Notifikasi',
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppTheme.textPrimary,
            ),
            onPressed: () {
              // TODO: aksi notifikasi
            },
          ),
          // Avatar profil (paling kanan)
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.lightBlue,
              backgroundImage: widget.profile.fotoUrl?.isNotEmpty == true
                  ? NetworkImage(widget.profile.fotoUrl!)
                  : null,
              child: widget.profile.fotoUrl?.isNotEmpty == true
                  ? null
                  : const Icon(
                      Icons.person_rounded,
                      color: AppTheme.primaryBlue,
                      size: 18,
                    ),
            ),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 22),
                  _buildSummaryCards(dashboard),
                  const SizedBox(height: 24),
                  _buildSectionHeading(
                    dashboard.approvalTitle,
                    '${dashboard.pendingCount} tertunda',
                  ),
                  const SizedBox(height: 10),
                  ...dashboard.approvals.map(_buildApprovalCard),
                  const SizedBox(height: 18),
                  _buildSectionHeading(
                    'Agenda Berikutnya',
                    'Semua',
                    isAction: true,
                  ),
                  const SizedBox(height: 10),
                  _buildUpcomingAgenda(),
                  const SizedBox(height: 20),
                  _buildManagementNote(),
                  const SizedBox(height: 20),
                  _buildLogoutButton(context),
                ],
              ),
            )
          : _buildPlaceholderPage(_managementPages[_selectedIndex].label),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surface,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: _managementPages
            .map(
              (page) => BottomNavigationBarItem(
                icon: Icon(page.icon),
                label: page.label,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPlaceholderPage(String label) {
    return Center(
      child: Text(
        'Ini halaman $label',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${widget.profile.nama} 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                if (widget.profile.role == UserRole.kepalaDivisi)
                  DivisionNameText(
                    divisionId: widget.profile.divisiId,
                    prefix: widget.profile.role.label,
                    divisionNameLoader: widget.divisionNameLoader,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  )
                else
                  Text(
                    '${widget.profile.role.label} • HIMA TI',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: widget.profile.isActive
                  ? AppTheme.successBg
                  : AppTheme.warningBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.profile.isActive ? 'Aktif' : 'Nonaktif',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: widget.profile.isActive
                    ? AppTheme.success
                    : AppTheme.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(_ManagementDashboardContent dashboard) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildSummaryCard(dashboard.firstSummary)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard(dashboard.secondSummary)),
      ],
    );
  }

  Widget _buildSummaryCard(_SummaryCardContent content) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  content.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  content.icon,
                  size: 17,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            content.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 21,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(
    String title,
    String trailingLabel, {
    bool isAction = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        if (isAction)
          Text(
            trailingLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.errorBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailingLabel,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildApprovalCard(_ApprovalCardContent approval) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  approval.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  approval.status,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(approval.dueIcon, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 5),
              Text(
                approval.dueLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.visibility_outlined, size: 17),
              label: Text(approval.actionLabel),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.primaryBlue,
                disabledForegroundColor: Colors.white,
                minimumSize: const Size.fromHeight(42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAgenda() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppTheme.primaryBlue,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rapat Evaluasi Bersama BPH & BO',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Besok, 20:00 WIB (Online)',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
                SizedBox(height: 4),
                Text(
                  'Lihat Jadwal →',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primaryBlue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Catatan Pengurus\nFokus minggu ini: finalisasi persiapan dan koordinasi agenda organisasi.',
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _handleLogout(context),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Keluar Akun'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.error,
          side: const BorderSide(color: AppTheme.error, width: 1.2),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// Informasi dashboard untuk tiap role pengurus
const List<_ManagementPage> _managementPages = [
  _ManagementPage(label: 'Beranda', icon: Icons.dashboard_outlined),
  _ManagementPage(label: 'Tugas', icon: Icons.assignment_outlined),
  _ManagementPage(label: 'Agenda', icon: Icons.event_available_outlined),
  _ManagementPage(label: 'Kas', icon: Icons.account_balance_wallet_outlined),
];

const Map<UserRole, _ManagementDashboardContent> _dashboardByRole = {
  UserRole.ketua: _ManagementDashboardContent(
    firstSummary: _SummaryCardContent(
      title: 'Persetujuan',
      value: '1 Menunggu',
      subtitle: 'Perlu ditinjau',
      icon: Icons.rule_rounded,
    ),
    secondSummary: _SummaryCardContent(
      title: 'Proker Berjalan',
      value: '2 Proker',
      subtitle: 'Dari total 6 proker',
      icon: Icons.folder_open_rounded,
    ),
    approvalTitle: 'Persetujuan Penting',
    pendingCount: 2,
    approvals: [
      _ApprovalCardContent(
        title: 'Proposal IT Fest (Revisi Anggaran)',
        status: 'Menunggu Persetujuan',
        dueLabel: 'Hari ini, 20:00 WIB',
        dueIcon: Icons.access_time_rounded,
        actionLabel: 'Tinjau Proposal',
      ),
      _ApprovalCardContent(
        title: 'LPJ Makrab Mahasiswa Baru',
        status: 'Menunggu',
        dueLabel: 'Besok, 17:00 WIB',
        dueIcon: Icons.event_outlined,
        actionLabel: 'Lihat Detail',
      ),
    ],
  ),
  UserRole.wakilKetua: _ManagementDashboardContent(
    firstSummary: _SummaryCardContent(
      title: 'Program Dipantau',
      value: '3 Program',
      subtitle: 'Perlu evaluasi',
      icon: Icons.track_changes_rounded,
    ),
    secondSummary: _SummaryCardContent(
      title: 'Proker Berjalan',
      value: '2 Proker',
      subtitle: 'Dari total 6 proker',
      icon: Icons.folder_open_rounded,
    ),
    approvalTitle: 'Pemantauan Penting',
    pendingCount: 2,
    approvals: [
      _ApprovalCardContent(
        title: 'Evaluasi Progres IT Fest',
        status: 'Perlu Ditinjau',
        dueLabel: 'Hari ini, 20:00 WIB',
        dueIcon: Icons.access_time_rounded,
        actionLabel: 'Tinjau Progres',
      ),
      _ApprovalCardContent(
        title: 'Laporan Kegiatan Divisi',
        status: 'Menunggu',
        dueLabel: 'Besok, 17:00 WIB',
        dueIcon: Icons.event_outlined,
        actionLabel: 'Lihat Detail',
      ),
    ],
  ),
  UserRole.sekretaris: _ManagementDashboardContent(
    firstSummary: _SummaryCardContent(
      title: 'Surat Masuk',
      value: '2 Surat',
      subtitle: 'Perlu ditindaklanjuti',
      icon: Icons.mail_outline_rounded,
    ),
    secondSummary: _SummaryCardContent(
      title: 'Agenda Tercatat',
      value: '4 Agenda',
      subtitle: 'Bulan ini',
      icon: Icons.event_note_rounded,
    ),
    approvalTitle: 'Dokumen Perlu Ditinjau',
    pendingCount: 2,
    approvals: [
      _ApprovalCardContent(
        title: 'Surat Permohonan Peminjaman Ruang',
        status: 'Menunggu Pemeriksaan',
        dueLabel: 'Hari ini, 20:00 WIB',
        dueIcon: Icons.access_time_rounded,
        actionLabel: 'Tinjau Surat',
      ),
      _ApprovalCardContent(
        title: 'Notulen Rapat Pengurus',
        status: 'Perlu Dilengkapi',
        dueLabel: 'Besok, 17:00 WIB',
        dueIcon: Icons.event_outlined,
        actionLabel: 'Lihat Detail',
      ),
    ],
  ),
  UserRole.bendahara: _ManagementDashboardContent(
    firstSummary: _SummaryCardContent(
      title: 'Pengajuan Dana',
      value: '1 Menunggu',
      subtitle: 'Perlu diperiksa',
      icon: Icons.payments_outlined,
    ),
    secondSummary: _SummaryCardContent(
      title: 'Transaksi',
      value: '8 Data',
      subtitle: 'Perlu direkap',
      icon: Icons.account_balance_wallet_outlined,
    ),
    approvalTitle: 'Persetujuan Keuangan',
    pendingCount: 2,
    approvals: [
      _ApprovalCardContent(
        title: 'Pengajuan Dana Kegiatan',
        status: 'Menunggu Pemeriksaan',
        dueLabel: 'Hari ini, 20:00 WIB',
        dueIcon: Icons.access_time_rounded,
        actionLabel: 'Tinjau Pengajuan',
      ),
      _ApprovalCardContent(
        title: 'Laporan Pertanggungjawaban',
        status: 'Menunggu',
        dueLabel: 'Besok, 17:00 WIB',
        dueIcon: Icons.event_outlined,
        actionLabel: 'Lihat Detail',
      ),
    ],
  ),
  UserRole.kepalaDivisi: _ManagementDashboardContent(
    firstSummary: _SummaryCardContent(
      title: 'Tugas Divisi',
      value: '3 Tugas',
      subtitle: '1 perlu ditinjau',
      icon: Icons.checklist_rounded,
    ),
    secondSummary: _SummaryCardContent(
      title: 'Proker Divisi',
      value: '2 Proker',
      subtitle: 'Sedang berjalan',
      icon: Icons.workspaces_outline,
    ),
    approvalTitle: 'Tindak Lanjut Divisi',
    pendingCount: 2,
    approvals: [
      _ApprovalCardContent(
        title: 'Pembaruan Progres Program Kerja',
        status: 'Perlu Ditinjau',
        dueLabel: 'Hari ini, 20:00 WIB',
        dueIcon: Icons.access_time_rounded,
        actionLabel: 'Tinjau Progres',
      ),
      _ApprovalCardContent(
        title: 'Laporan Tugas Anggota Divisi',
        status: 'Menunggu',
        dueLabel: 'Besok, 17:00 WIB',
        dueIcon: Icons.event_outlined,
        actionLabel: 'Lihat Detail',
      ),
    ],
  ),
};

class _ManagementPage {
  final String label;
  final IconData icon;

  const _ManagementPage({required this.label, required this.icon});
}

class _ManagementDashboardContent {
  final _SummaryCardContent firstSummary;
  final _SummaryCardContent secondSummary;
  final String approvalTitle;
  final int pendingCount;
  final List<_ApprovalCardContent> approvals;

  const _ManagementDashboardContent({
    required this.firstSummary,
    required this.secondSummary,
    required this.approvalTitle,
    required this.pendingCount,
    required this.approvals,
  });
}

class _SummaryCardContent {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _SummaryCardContent({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });
}

class _ApprovalCardContent {
  final String title;
  final String status;
  final String dueLabel;
  final IconData dueIcon;
  final String actionLabel;

  const _ApprovalCardContent({
    required this.title,
    required this.status,
    required this.dueLabel,
    required this.dueIcon,
    required this.actionLabel,
  });
}
