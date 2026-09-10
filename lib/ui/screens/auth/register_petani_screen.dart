import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/widgets/custom_text_fields.dart';
import 'package:agrisync/ui/screens/auth/email_verification_pending_screen.dart';
import 'package:agrisync/data/services/location_service.dart';
import 'package:agrisync/ui/screens/common/map_location_picker_screen.dart';

class RegisterPetaniScreen extends StatefulWidget {
  final bool isGoogleRegister;
  final String? initialEmail;
  final String? initialName;

  const RegisterPetaniScreen({
    super.key,
    this.isGoogleRegister = false,
    this.initialEmail,
    this.initialName,
  });

  @override
  State<RegisterPetaniScreen> createState() => _RegisterPetaniScreenState();
}

class _RegisterPetaniScreenState extends State<RegisterPetaniScreen> {
  // Method selection: 'email' (Email Biasa) vs 'google' (Akun Google)
  late String _authMethod;
  bool _isGoogleVerified = false;

  late final TextEditingController _googleEmailController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  String? _uploadedDocName;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authMethod = widget.isGoogleRegister ? 'google' : 'email';
    _isGoogleVerified = widget.isGoogleRegister && (widget.initialEmail != null && widget.initialEmail!.isNotEmpty);

    _googleEmailController = TextEditingController(text: widget.initialEmail ?? '');
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _googleEmailController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _verifyGoogleAccount() {
    final googleEmail = _googleEmailController.text.trim();
    if (googleEmail.isEmpty || !googleEmail.contains('@') || !googleEmail.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan alamat email Google yang valid (misal: nama@gmail.com)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final existingUser = appState.findUserByEmailOrPhone(googleEmail);

    if (existingUser != null && existingUser.role != UserRole.petani) {
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
                  'Email Sudah Digunakan',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Text(
            'Akun Google $googleEmail telah terdaftar sebagai ${existingUser.role.name.toUpperCase()}. Aturan sistem menetapkan 1 akun Google hanya untuk 1 peran.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Tutup',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AgriColors.darkOliveBtn),
              ),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isGoogleVerified = true;
      _emailController.text = googleEmail;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Akun Google ($googleEmail) berhasil diverifikasi!')),
          ],
        ),
        backgroundColor: AgriColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final isGoogle = _authMethod == 'google';
    final email = isGoogle ? _googleEmailController.text.trim() : _emailController.text.trim();
    final password = isGoogle ? 'google_auth_token_secret' : _passwordController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _locationController.text.trim();
    final doc = _uploadedDocName;

    if (isGoogle && !_isGoogleVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap klik "Verifikasi Akun Google" terlebih dahulu sebelum mendaftar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap masukkan Nama Lengkap Petani')),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap masukkan format email yang valid')),
      );
      return;
    }

    if (!isGoogle && (password.isEmpty || password.length < 6)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi minimal 6 karakter')),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap masukkan Nomor Telepon / WhatsApp Petani')),
      );
      return;
    }

    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap tentukan Lokasi Lahan Pertanian (Gunakan tombol Pilih di Peta)')),
      );
      return;
    }

    if (doc == null || doc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap upload KTP / Sertifikat Kelompok Tani untuk verifikasi legalitas.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final appState = Provider.of<AppState>(context, listen: false);

    final error = await appState.registerPetani(
      name: name,
      phone: phone,
      email: email,
      password: password,
      farmLocation: location,
      documentPath: doc,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red.shade700),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isGoogle
                ? 'Pendaftaran Google Berhasil! Selamat datang di AgriSync, $name.'
                : 'Akun Petani berhasil didaftarkan! Link verifikasi telah dikirim ke $email. Silakan periksa inbox Gmail Anda.'),
            backgroundColor: AgriColors.primaryGreen,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => EmailVerificationPendingScreen(
              email: email,
              role: UserRole.petani,
              userName: name,
              isGoogle: isGoogle,
            ),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGoogle = _authMethod == 'google';

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            // Title
            Text(
              'Pendaftaran Petani',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AgriColors.textMain,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Jual hasil panen langsung ke pebisnis tanpa perantara tengkulak.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: AgriColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Pilihan Metode Autentikasi: Email Biasa vs Google
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AgriColors.lightSageBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AgriColors.cardBorder, width: 1.2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _authMethod = 'email';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: _authMethod == 'email' ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _authMethod == 'email'
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 17,
                              color: _authMethod == 'email' ? AgriColors.darkOliveBtn : AgriColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Email Biasa',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: _authMethod == 'email' ? FontWeight.w700 : FontWeight.w500,
                                color: _authMethod == 'email' ? AgriColors.darkOliveBtn : AgriColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _authMethod = 'google';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: _authMethod == 'google' ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _authMethod == 'google'
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4285F4),
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                'G',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Akun Google',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: _authMethod == 'google' ? FontWeight.w700 : FontWeight.w500,
                                color: _authMethod == 'google' ? const Color(0xFF4285F4) : AgriColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Google Verification Box
            if (isGoogle) ...[
              if (!_isGoogleVerified)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF4285F4).withOpacity(0.5), width: 1.4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4285F4).withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F0FE),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              'G',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4285F4),
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Verifikasi Akun Google Anda',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: AgriColors.textMain,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Masukkan alamat email Google untuk verifikasi identitas petani:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: AgriColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _googleEmailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'nama.anda@gmail.com',
                                filled: true,
                                fillColor: AgriColors.background,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4285F4),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _verifyGoogleAccount,
                            child: const Text('Verifikasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                // KETIKA GOOGLE SUDAH DIVERIFIKASI -> FORM / CARD BERUBAH HIJAU
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9), // Hijau muda cerah
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AgriColors.primaryGreen, width: 1.8), // Border hijau
                    boxShadow: [
                      BoxShadow(
                        color: AgriColors.primaryGreen.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: AgriColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Akun Google Terverifikasi',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: AgriColors.darkOliveBtn,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AgriColors.primaryGreen,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'VALID',
                                    style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _googleEmailController.text.trim(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AgriColors.textMain,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AgriColors.darkOliveBtn),
                        tooltip: 'Ganti Akun Google',
                        onPressed: () {
                          setState(() {
                            _isGoogleVerified = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),
            ],

            // Field: Nama Lengkap (Masih lanjut di halaman yang sama)
            AgriTextField(
              controller: _nameController,
              hintText: 'Nama Lengkap Petani',
            ),
            const SizedBox(height: 16),

            // Field: Email Akun (Jika email biasa)
            if (!isGoogle) ...[
              AgriTextField(
                controller: _emailController,
                hintText: 'Email Akun (misal: budi@gmail.com)',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Field: Kata Sandi
              AgriTextField(
                controller: _passwordController,
                hintText: 'Kata Sandi (min 6 karakter)',
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
              const SizedBox(height: 16),
            ],

            // Field: Nomor Telepon / WhatsApp
            AgriTextField(
              controller: _phoneController,
              hintText: 'Nomor Telepon / WhatsApp',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Field: Lokasi Pertanian (dengan Peta OpenStreetMap)
            AgriTextField(
              controller: _locationController,
              hintText: 'Lokasi Lahan Pertanian (Pilih di Peta)',
              suffixIcon: IconButton(
                icon: const Icon(Icons.map_rounded, color: AgriColors.primaryGreen),
                tooltip: 'Pilih di Peta (OpenStreetMap)',
                onPressed: () async {
                  final LocationResult? result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MapLocationPickerScreen(
                        title: 'Pilih Lokasi Lahan Kebun',
                        initialAddress: _locationController.text,
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _locationController.text = result.fullFormattedAddress;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Field: Upload KTP / Sertifikat
            AgriFileUploadField(
              label: 'Upload KTP / Sertifikat Tani',
              fileName: _uploadedDocName,
              onTap: () {
                setState(() {
                  _uploadedDocName = 'KTP_${_nameController.text.isNotEmpty ? _nameController.text.split(" ").first : "Petani"}.pdf (Terlampir)';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('File KTP/Sertifikat berhasil dipilih!'),
                    backgroundColor: AgriColors.primaryGreen,
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // Button Submit
            AgriPillButton(
              text: isGoogle ? 'DAFTARKAN AKUN GOOGLE PETANI' : 'BUAT AKUN PETANI',
              type: AgriButtonType.darkOlive,
              isLoading: _isLoading,
              height: 48,
              onPressed: _handleRegister,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
