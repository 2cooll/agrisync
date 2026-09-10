import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/widgets/custom_text_fields.dart';
import 'package:agrisync/ui/screens/pebisnis/pebisnis_home_screen.dart';
import 'package:agrisync/ui/screens/petani/petani_home_screen.dart';
import 'package:agrisync/ui/screens/admin/admin_dashboard_screen.dart';

import 'package:agrisync/ui/screens/auth/register_pebisnis_screen.dart';
import 'package:agrisync/ui/screens/auth/register_petani_screen.dart';
import 'package:agrisync/ui/screens/auth/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final UserRole initialRole;

  const LoginScreen({super.key, this.initialRole = UserRole.pebisnis});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late UserRole _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToDashboard(BuildContext context, UserRole role) {
    Widget target;
    switch (role) {
      case UserRole.pebisnis:
        target = const  PebisnisHomeScreen();
        break;
      case UserRole.petani:
        target = const PetaniHomeScreen();
        break;
      case UserRole.admin:
        target = const AdminDashboardScreen();
        break;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => target),
      (route) => false,
    );
  }

  Future<void> _handleLogin() async {
    final input = _phoneController.text.trim();
    final pass = _passwordController.text.trim();
    final role = _selectedRole;

    if (input.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap masukkan Email/Telepon dan Kata Sandi')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final appState = Provider.of<AppState>(context, listen: false);

    final error = await appState.login(
      phone: input.contains('@') ? '' : input,
      email: input.contains('@') ? input : null,
      password: pass,
      role: role,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        if (error.contains('terdaftar sebagai peran')) {
          final isPetani = error.contains('PETANI');
          final targetRole = isPetani ? UserRole.petani : UserRole.pebisnis;
          final roleLabel = isPetani ? 'PETANI' : 'PEBISNIS';

          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded, color: AgriColors.primaryGreen, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Beralih Peran Akun',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ],
              ),
              content: Text(
                'Akun "$input" terdaftar sebagai peran $roleLabel.\n\nIngin beralih ke mode $roleLabel dan langsung masuk?',
                style: GoogleFonts.plusJakartaSans(fontSize: 13.5, height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgriColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedRole = targetRole;
                    });
                    _handleLogin();
                  },
                  child: Text(
                    'Beralih & Masuk',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red.shade700),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selamat datang kembali, ${appState.currentUser.name}!'),
            backgroundColor: AgriColors.primaryGreen,
          ),
        );
        _navigateToDashboard(context, appState.currentUser.role);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    final appState = Provider.of<AppState>(context, listen: false);

    setState(() => _isLoading = true);
    final error = await appState.loginWithGoogle(role: _selectedRole);

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Peran Akun Tidak Sesuai',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ],
            ),
            content: Text(
              error,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Mengerti',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AgriColors.primaryDark),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil masuk menggunakan Google sebagai ${_selectedRole.name.toUpperCase()}!'),
            backgroundColor: AgriColors.primaryGreen,
          ),
        );
        _navigateToDashboard(context, appState.currentUser.role);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            // Title & Role Indicator
            Text(
              'Login ${_selectedRole == UserRole.petani ? "Petani" : "Pebisnis"}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _selectedRole == UserRole.petani
                  ? 'Masuk ke akun petani / produsen hasil panen'
                  : 'Masuk ke akun usaha kuliner, restoran, atau horeka',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AgriColors.textMuted,
              ),
            ),
            const SizedBox(height: 26),

            // Field: Email atau Nomor Telepon
            AgriTextField(
              controller: _phoneController,
              hintText: 'Email atau Nomor Telepon',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),

            // Field: Kata Sandi
            AgriTextField(
              controller: _passwordController,
              hintText: 'Kata Sandi',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AgriColors.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),

            const SizedBox(height: 12),

            // Lupa Kata Sandi?
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ForgotPasswordScreen(
                        initialIdentifier: _phoneController.text.trim(),
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Lupa Kata Sandi?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AgriColors.textMain,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Button: MASUK
            AgriPillButton(
              text: 'MASUK',
              type: AgriButtonType.darkOlive,
              isLoading: _isLoading,
              height: 48,
              onPressed: _handleLogin,
            ),
            const SizedBox(height: 14),

            // Divider ATAU
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'ATAU',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AgriColors.textMuted,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 14),

            // Button: MASUK DENGAN GOOGLE
            OutlinedButton(
              onPressed: _handleGoogleLogin,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                backgroundColor: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'G',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Masuk dengan Google',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AgriColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Register bottom link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Belum punya akun? ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: AgriColors.textMuted,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showRegisterChoice(context),
                  child: Text(
                    'Daftar Sekarang',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AgriColors.darkOliveBtn,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showRegisterChoice(BuildContext context) {
    if (_selectedRole == UserRole.petani) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RegisterPetaniScreen()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RegisterPebisnisScreen()),
      );
    }
  }
}
