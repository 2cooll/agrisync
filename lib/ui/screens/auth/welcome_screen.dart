import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/agri_logo.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/screens/auth/register_petani_screen.dart';
import 'package:agrisync/ui/screens/auth/register_pebisnis_screen.dart';
import 'package:agrisync/ui/screens/auth/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AgriColors.surfaceCardGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // AgriSync Logo & Slogan
                const AgriLogo(size: 120, showSubtitle: true),

                const Spacer(flex: 3),

                // "MASUK SEBAGAI PEBISNIS" Button (Dark olive brown)
                AgriPillButton(
                  text: 'MASUK SEBAGAI PEBISNIS',
                  type: AgriButtonType.darkOlive,
                  height: 52,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(initialRole: UserRole.pebisnis),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // "MASUK SEBAGAI PETANI" Button (Light lime green)
                AgriPillButton(
                  text: 'MASUK SEBAGAI PETANI',
                  type: AgriButtonType.primaryLime,
                  height: 52,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(initialRole: UserRole.petani),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Registration text link (Menggantikan masuk manual dengan pendaftaran)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AgriColors.textMuted,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showRegistrationRolePicker(context),
                      child: Text(
                        'Daftar Sekarang',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AgriColors.darkOliveBtn,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRegistrationRolePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4.5,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Text(
                'Pilih Jenis Pendaftaran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AgriColors.textMain,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Silakan pilih peran akun yang ingin Anda daftarkan di platform AgriSync:',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: AgriColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),

              // Pilihan 1: Pebisnis
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AgriColors.lightSageBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront_rounded, color: AgriColors.darkOliveBtn, size: 24),
                ),
                title: Text(
                  'Daftar Sebagai Pebisnis',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: AgriColors.textMain,
                  ),
                ),
                subtitle: Text(
                  'Restoran, Hotel, Supermarket, Katering & Usaha Kuliner',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AgriColors.textMuted),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey.shade200, width: 1.2),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RegisterPebisnisScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Pilihan 2: Petani
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AgriColors.badgeGreenBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.agriculture_rounded, color: AgriColors.primaryGreen, size: 24),
                ),
                title: Text(
                  'Daftar Sebagai Petani',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: AgriColors.textMain,
                  ),
                ),
                subtitle: Text(
                  'Petani, Kelompok Tani, Perkebunan & Produsen Hasil Panen',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AgriColors.textMuted),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey.shade200, width: 1.2),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RegisterPetaniScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

