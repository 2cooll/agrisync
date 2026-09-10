import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/screens/pebisnis/pebisnis_home_screen.dart';
import 'package:agrisync/ui/screens/petani/petani_home_screen.dart';
import 'package:agrisync/ui/screens/auth/login_screen.dart';

class EmailVerificationPendingScreen extends StatefulWidget {
  final String email;
  final UserRole role;
  final String userName;
  final bool isGoogle;

  const EmailVerificationPendingScreen({
    super.key,
    required this.email,
    required this.role,
    required this.userName,
    this.isGoogle = false,
  });

  @override
  State<EmailVerificationPendingScreen> createState() =>
      _EmailVerificationPendingScreenState();
}

class _EmailVerificationPendingScreenState
    extends State<EmailVerificationPendingScreen> {
  bool _isChecking = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  Timer? _countdownTimer;
  Timer? _periodicCheckTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Secara otomatis cek status setiap 5 detik jika pengguna sudah klik link di tab/browser lain
    _periodicCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        _checkVerification(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _periodicCheckTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        if (mounted) {
          setState(() => _resendCountdown--);
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleResendEmail() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() => _isResending = true);
    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.sendEmailVerification();

    if (mounted) {
      setState(() => _isResending = false);
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  success
                      ? 'Link verifikasi baru telah dikirimkan ke ${widget.email}'
                      : 'Email verifikasi telah dipicu ke ${widget.email}. Silakan periksa inbox/spam.',
                ),
              ),
            ],
          ),
          backgroundColor: AgriColors.primaryGreen,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _checkVerification({bool silent = false}) async {
    if (_isChecking) return;
    if (!silent) setState(() => _isChecking = true);

    final appState = Provider.of<AppState>(context, listen: false);
    final isVerified = await appState.checkEmailVerified();

    if (mounted) {
      if (!silent) setState(() => _isChecking = false);

      if (isVerified || appState.currentUser.isVerified) {
        _periodicCheckTimer?.cancel();
        _countdownTimer?.cancel();
        _navigateToDashboard(context, widget.role);
      } else if (!silent) {
        _showNotVerifiedDialog();
      }
    }
  }

  void _forceSimulateVerify() {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;
    final verifications = appState.verifications;
    final userVerifs = verifications.where((v) => v.userId == user.id).toList();

    if (userVerifs.isNotEmpty) {
      appState.approveVerification(userVerifs.first.id);
    } else {
      appState.approveVerification('ver_${user.id}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Email Berhasil Terverifikasi! Mengalihkan ke Beranda...'),
        backgroundColor: AgriColors.primaryGreen,
        duration: Duration(seconds: 2),
      ),
    );

    _periodicCheckTimer?.cancel();
    _countdownTimer?.cancel();
    _navigateToDashboard(context, widget.role);
  }

  void _navigateToDashboard(BuildContext context, UserRole role) {
    Widget target;
    switch (role) {
      case UserRole.pebisnis:
        target = const PebisnisHomeScreen();
        break;
      case UserRole.petani:
        target = const PetaniHomeScreen();
        break;
      case UserRole.admin:
        target = const PebisnisHomeScreen();
        break;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => target),
      (route) => false,
    );
  }

  void _showNotVerifiedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 26),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Belum Terverifikasi',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tautan di email "${widget.email}" belum diklik atau server belum menerima konfirmasi.',
              style: GoogleFonts.plusJakartaSans(fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AgriColors.lightSageBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '💡 Tips: Periksa folder "Spam" atau "Promosi" di aplikasi Gmail jika email belum muncul di Inbox utama.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AgriColors.darkOliveBtn,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _forceSimulateVerify();
            },
            child: Text(
              'Verifikasi Langsung (Demo)',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AgriColors.primaryGreen,
                fontSize: 12,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AgriColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Mengerti',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 14),

              // Animated/Highlighted Icon
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: AgriColors.lightSageBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AgriColors.primaryGreen.withOpacity(0.3), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AgriColors.primaryGreen.withOpacity(0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mark_email_unread_rounded,
                  color: AgriColors.primaryGreen,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Verifikasi Email Anda',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AgriColors.textMain,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                'Tautan verifikasi resmi telah dikirim ke alamat email:',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: AgriColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),

              // Email Pill Container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AgriColors.primaryGreen, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.email_outlined, size: 18, color: AgriColors.darkOliveBtn),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.email,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AgriColors.darkOliveBtn,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Instructions Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Langkah Verifikasi:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AgriColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStepRow('1', 'Buka aplikasi Gmail atau mail client Anda.'),
                    _buildStepRow('2', 'Cari pesan dari "AgriSync" (periksa juga folder Spam).'),
                    _buildStepRow('3', 'Klik tautan verifikasi yang ada di dalam email.'),
                    _buildStepRow('4', 'Kembali ke aplikasi ini dan tekan tombol di bawah.'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Primary Action: SAYA SUDAH VERIFIKASI
              AgriPillButton(
                text: 'SAYA SUDAH VERIFIKASI',
                type: AgriButtonType.darkOlive,
                isLoading: _isChecking,
                height: 50,
                onPressed: () => _checkVerification(silent: false),
              ),
              const SizedBox(height: 14),

              // Secondary Action: Kirim Ulang Email
              OutlinedButton(
                onPressed: _resendCountdown == 0 ? _handleResendEmail : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  side: BorderSide(
                    color: _resendCountdown == 0 ? AgriColors.primaryGreen : Colors.grey.shade300,
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: _isResending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AgriColors.primaryGreen),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: _resendCountdown == 0 ? AgriColors.darkOliveBtn : AgriColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _resendCountdown > 0
                                ? 'Kirim Ulang Email (${_resendCountdown}s)'
                                : 'Kirim Ulang Email Verifikasi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: _resendCountdown == 0 ? AgriColors.darkOliveBtn : AgriColors.textMuted,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 18),

              // Bottom Link: Kembali ke Login
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(initialRole: widget.role),
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  'Kembali ke Halaman Login',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AgriColors.textMuted,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AgriColors.lightSageBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AgriColors.darkOliveBtn,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AgriColors.textMain,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
