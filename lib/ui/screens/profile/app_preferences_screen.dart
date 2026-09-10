import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';

class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
  bool _isClearingCache = false;

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Mode Gelap (Dark Mode)';
      case ThemeMode.system:
        return 'Ikuti Pengaturan Sistem';
      case ThemeMode.light:
      default:
        return 'Mode Terang (Standar)';
    }
  }

  ThemeMode _stringToThemeMode(String val) {
    if (val.contains('Gelap')) return ThemeMode.dark;
    if (val.contains('Sistem')) return ThemeMode.system;
    return ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentThemeStr = _themeModeToString(appState.themeMode);

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      title: 'Tampilan & Bahasa',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferensi Tampilan & Regional',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sesuaikan bahasa, tema visual, dan satuan komoditas sesuai kebutuhan Anda.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AgriColors.textMuted),
            ),
            const SizedBox(height: 20),

            // Card: Bahasa
            _buildSelectionCard(
              title: 'Bahasa Aplikasi',
              icon: Icons.language_rounded,
              currentValue: appState.selectedLanguage,
              options: const ['Bahasa Indonesia', 'English (US)', 'Basa Jawa'],
              onSelected: (val) {
                appState.setLanguage(val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bahasa diubah ke $val.'),
                    duration: const Duration(milliseconds: 1000),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Card: Tema Tampilan
            _buildSelectionCard(
              title: 'Tema Tampilan',
              icon: Icons.palette_outlined,
              currentValue: currentThemeStr,
              options: const ['Mode Terang (Standar)', 'Mode Gelap (Dark Mode)', 'Ikuti Pengaturan Sistem'],
              onSelected: (val) {
                final mode = _stringToThemeMode(val);
                appState.setThemeMode(mode);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tema diatur ke $val.'),
                    duration: const Duration(milliseconds: 1000),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Card: Satuan Berat
            _buildSelectionCard(
              title: 'Satuan Standar Berat Komoditas',
              icon: Icons.scale_rounded,
              currentValue: appState.weightUnit,
              options: const ['Kilogram (kg)', 'Kuintal (100 kg)', 'Ton (1.000 kg)'],
              onSelected: (val) {
                appState.setWeightUnit(val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Satuan komoditas diubah ke $val.'),
                    duration: const Duration(milliseconds: 1000),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Card: Format Mata Uang
            _buildSelectionCard(
              title: 'Mata Uang Pembayaran',
              icon: Icons.attach_money_rounded,
              currentValue: appState.currency,
              options: const ['IDR (Rupiah Indonesia - Rp)', 'USD (US Dollar - \$)'],
              onSelected: (val) {
                appState.setCurrency(val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mata uang diatur ke $val.'),
                    duration: const Duration(milliseconds: 1000),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Card: Cache & Data
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
                    'Penyimpanan & Data Lokal',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AgriColors.lightSageBg,
                      child: Icon(Icons.cleaning_services_rounded, color: AgriColors.darkOliveBtn, size: 20),
                    ),
                    title: Text(
                      'Hapus Cache & File Sementara',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      _isClearingCache
                          ? 'Membersihkan memori cache gambar...'
                          : 'Bersihkan data cache lokal & optimalkan memori',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
                    ),
                    trailing: _isClearingCache
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AgriColors.primaryGreen),
                          )
                        : TextButton(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              setState(() => _isClearingCache = true);
                              final clearedMb = await appState.clearAppCache();
                              await Future.delayed(const Duration(milliseconds: 400));
                              if (mounted) {
                                setState(() => _isClearingCache = false);
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Berhasil membersihkan $clearedMb MB cache gambar dan data sementara!'),
                                    backgroundColor: AgriColors.primaryGreen,
                                  ),
                                );
                              }
                            },
                            child: const Text('Bersihkan'),
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

  Widget _buildSelectionCard({
    required String title,
    required IconData icon,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    return Container(
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
              Icon(icon, size: 20, color: AgriColors.darkOliveBtn),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...options.map((opt) {
            final isSelected = opt == currentValue;
            return InkWell(
              onTap: () => onSelected(opt),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AgriColors.lightSageBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AgriColors.primaryGreen : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      opt,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AgriColors.darkOliveBtn : AgriColors.textMain,
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded, color: AgriColors.primaryGreen, size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

