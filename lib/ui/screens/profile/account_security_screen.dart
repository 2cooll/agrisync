import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/custom_text_fields.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final current = _currentPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirm = _confirmPassController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua kolom kata sandi')),
      );
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi baru minimal 6 karakter')),
      );
      return;
    }

    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi baru tidak cocok')),
      );
      return;
    }

    if (current == newPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi baru tidak boleh sama dengan kata sandi lama')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final appState = Provider.of<AppState>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final error = await appState.changePassword(
      oldPassword: current,
      newPassword: newPass,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red.shade700,
          ),
        );
      } else {
        _currentPassController.clear();
        _newPassController.clear();
        _confirmPassController.clear();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Kata sandi berhasil diperbarui dengan aman!'),
            backgroundColor: AgriColors.primaryGreen,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context, String userId) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final nav = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Text(
              'Konfirmasi Hapus Akun',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus akun ini secara permanen?\n\n'
          '⚠️ PERINGATAN: Seluruh data autentikasi, dokumen, dan SEMUA PRODUK PANEN yang didaftarkan oleh akun ini akan langsung dihapus permanen dari Cloud Database untuk mencegah data yatim (orphan data).',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Ya, Hapus Permanen',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await appState.deleteUserAccountCascade(userId);
      nav.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppState>(context).currentUser;

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      title: 'Keamanan Akun',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengaturan Keamanan & Password',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Kelola kata sandi, otentikasi dua langkah, dan proteksi akun Anda.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AgriColors.textMuted),
            ),
            const SizedBox(height: 20),

            // Card: Ubah Kata Sandi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AgriColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_reset_rounded, color: AgriColors.darkOliveBtn, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Ubah Kata Sandi',
                        style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AgriTextField(
                    controller: _currentPassController,
                    labelText: 'Kata Sandi Saat Ini',
                    hintText: '••••••••',
                    obscureText: _obscureCurrent,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AgriTextField(
                    controller: _newPassController,
                    labelText: 'Kata Sandi Baru (Min. 6 Karakter)',
                    hintText: '••••••••',
                    obscureText: _obscureNew,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AgriTextField(
                    controller: _confirmPassController,
                    labelText: 'Konfirmasi Kata Sandi Baru',
                    hintText: '••••••••',
                    obscureText: _obscureConfirm,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AgriColors.darkOliveBtn,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : _changePassword,
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'UPDATE KATA SANDI',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card: Autentikasi 2FA & Biometrik
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AgriColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Autentikasi & Verifikasi Tambahan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Verifikasi 2 Langkah (2FA OTP)',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Minta kode verifikasi SMS / WA setiap login perangkat baru',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
                    ),
                    activeColor: AgriColors.primaryGreen,
                    value: Provider.of<AppState>(context).twoFactorEnabled,
                    onChanged: (val) {
                      Provider.of<AppState>(context, listen: false).setTwoFactorEnabled(val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val ? 'Verifikasi 2 langkah (2FA) diaktifkan.' : 'Verifikasi 2 langkah dinonaktifkan.'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Kunci Sidik Jari / Face Unlock',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Buka aplikasi lebih cepat dengan biometrik ponsel',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
                    ),
                    activeColor: AgriColors.primaryGreen,
                    value: Provider.of<AppState>(context).biometricEnabled,
                    onChanged: (val) {
                      Provider.of<AppState>(context, listen: false).setBiometricEnabled(val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val ? 'Kunci Biometrik perangkat diaktifkan.' : 'Kunci Biometrik dinonaktifkan.'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card: Akun Google Terhubung & Sesi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AgriColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Akun Terhubung & Sesi Login',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('G', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4285F4))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Google Sign-In',
                              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              user.email ?? 'cvzcrazy@gmail.com',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Terhubung',
                        style: TextStyle(color: AgriColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.devices_rounded, size: 20, color: AgriColors.darkOliveBtn),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sesi Aktif: Perangkat Ini (Online)',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await Provider.of<AppState>(context, listen: false).invalidateOtherSessions();
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Semua sesi di perangkat lain telah diakhiri secara aman.'),
                              backgroundColor: AgriColors.primaryGreen,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 16),
                      label: Text(
                        'Keluar Dari Sesi Perangkat Lain',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Danger Zone: Hapus Akun & Seluruh Data Terkait
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Zona Bahaya',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Menghapus akun akan secara permanen menghapus akun autentikasi Anda, seluruh produk hasil panen yang terdaftar, dan data transaksi dari Cloud Database.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.red.shade900,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _confirmDeleteAccount(context, user.id),
                      icon: const Icon(Icons.delete_forever_rounded, size: 18),
                      label: Text(
                        'Hapus Akun & Seluruh Produk Saya',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
