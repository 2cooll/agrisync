import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/data/services/location_service.dart';
import 'package:agrisync/data/services/image_picker_helper.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/widgets/custom_text_fields.dart';
import 'package:agrisync/ui/screens/common/map_location_picker_screen.dart';
import 'package:agrisync/ui/widgets/agri_user_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _locationController;
  late final TextEditingController _extraController;
  String? _selectedAvatarUrl;
  bool _isLoading = false;

  final List<Map<String, String>> _avatarPresets = [
    {
      'label': 'Ikon Default',
      'url': '',
    },
    {
      'label': 'Pak Tani Organik',
      'url': 'https://api.dicebear.com/7.x/avataaars/png?seed=PetaniOrganik&backgroundColor=b6e3f4',
    },
    {
      'label': 'Ibu Tani Horti',
      'url': 'https://api.dicebear.com/7.x/avataaars/png?seed=SariKebun&backgroundColor=c0aede',
    },
    {
      'label': 'Mitra Bisnis Agro',
      'url': 'https://api.dicebear.com/7.x/avataaars/png?seed=AgroBisnis&backgroundColor=d1d4f9',
    },
    {
      'label': 'Chef & Resto',
      'url': 'https://api.dicebear.com/7.x/avataaars/png?seed=ChefKuliner&backgroundColor=ffd5dc',
    },
    {
      'label': 'Smart Agronom',
      'url': 'https://api.dicebear.com/7.x/avataaars/png?seed=SmartAgri&backgroundColor=ffdfbf',
    },
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppState>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _emailController = TextEditingController(text: user.email ?? 'user@agrisync.id');
    _locationController = TextEditingController(text: user.farmLocation ?? 'Batu, Jawa Timur');
    _extraController = TextEditingController(
      text: user.role == UserRole.pebisnis
          ? (user.businessType ?? 'Kuliner & Restoran')
          : 'Lahan Sayuran Organik (2.5 Hektar)',
    );
    _selectedAvatarUrl = user.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromSource({required bool isCamera}) async {
    try {
      final Uint8List? bytes = await AppImagePicker.pickImage(isCamera: isCamera);
      if (bytes != null && bytes.isNotEmpty) {
        final base64String = base64Encode(bytes);
        final dataUri = 'data:image/jpeg;base64,$base64String';
        setState(() {
          _selectedAvatarUrl = dataUri;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isCamera ? 'Foto dari kamera berhasil diambil!' : 'Foto dari galeri berhasil dipilih!'),
              backgroundColor: AgriColors.primaryGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: $e'),
            backgroundColor: AgriColors.rejectedRed,
          ),
        );
      }
    }
  }

  void _showAvatarPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Foto Profil',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AgriColors.textMain,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Gunakan kamera untuk mengambil foto baru atau pilih dari galeri perangkat Anda:',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AgriColors.textMuted),
                ),
                const SizedBox(height: 16),

                // 1. Tombol Kamera & Galeri Utama
                Row(
                  children: [
                    // Kamera
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(ctx);
                          await _pickImageFromSource(isCamera: true);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AgriColors.badgeGreenBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AgriColors.primaryGreen.withOpacity(0.5), width: 1.5),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AgriColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Ambil Kamera',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AgriColors.darkOliveBtn,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Foto langsung',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AgriColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Galeri
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(ctx);
                          await _pickImageFromSource(isCamera: false);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AgriColors.lightSageBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AgriColors.cardBorder, width: 1.5),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AgriColors.darkOliveBtn,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Buka Galeri',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AgriColors.darkOliveBtn,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pilih dari file/foto',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AgriColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Divider & Avatar Karakter
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.black12)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'ATAU PILIH AVATAR KARAKTER',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AgriColors.textHint,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.black12)),
                  ],
                ),
                const SizedBox(height: 14),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _avatarPresets.length,
                  itemBuilder: (context, index) {
                    final item = _avatarPresets[index];
                    final isSelected = (_selectedAvatarUrl ?? '') == item['url'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedAvatarUrl = item['url'];
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Avatar "${item['label']}" dipilih!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? AgriColors.lightSageBg : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AgriColors.primaryGreen : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AgriUserAvatar(
                              imageUrl: item['url'],
                              radius: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['label']!,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? AgriColors.darkOliveBtn : AgriColors.textMain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Tombol Hapus / Ikon Default
                if (_selectedAvatarUrl != null && _selectedAvatarUrl!.isNotEmpty)
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedAvatarUrl = '';
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Foto profil direset ke ikon default.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AgriColors.rejectedRed),
                      label: Text(
                        'Hapus Foto Profil',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AgriColors.rejectedRed,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final loc = _locationController.text.trim();
    final extra = _extraController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Nomor Telepon tidak boleh kosong.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;

    appState.updateProfile(
      name: name,
      email: email.isNotEmpty ? email : user.email,
      phone: phone,
      avatarUrl: _selectedAvatarUrl,
      farmLocation: user.role == UserRole.petani ? loc : null,
      businessType: user.role == UserRole.pebisnis ? extra : null,
    );

    setState(() => _isLoading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil Anda berhasil diperbarui dan tersimpan!'),
        backgroundColor: AgriColors.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppState>(context).currentUser;

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      title: 'Edit Profil',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with edit badge
            Center(
              child: GestureDetector(
                onTap: _showAvatarPickerBottomSheet,
                child: Stack(
                  children: [
                    AgriUserAvatar(
                      imageUrl: _selectedAvatarUrl,
                      name: user.name,
                      radius: 46,
                      border: Border.all(color: Colors.white, width: 3),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x24000000),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AgriColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showAvatarPickerBottomSheet,
              child: Text(
                'Ganti Foto / Avatar Profil',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AgriColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nama Lengkap
            AgriTextField(
              controller: _nameController,
              labelText: 'Nama Lengkap / Usaha',
              hintText: 'Nama lengkap Anda',
            ),
            const SizedBox(height: 16),

            // Email
            AgriTextField(
              controller: _emailController,
              labelText: 'Alamat Email',
              hintText: 'email@agrisync.id',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Telepon
            AgriTextField(
              controller: _phoneController,
              labelText: 'Nomor WhatsApp / Telepon',
              hintText: '081234567890',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Lokasi / Alamat dengan Peta
            AgriTextField(
              controller: _locationController,
              labelText: user.role == UserRole.petani ? 'Lokasi Lahan Kebun' : 'Alamat Outlet / Resto',
              hintText: 'Pilih lokasi di peta...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.map_rounded, color: AgriColors.primaryGreen),
                tooltip: 'Pilih Titik di Peta (OSM)',
                onPressed: () async {
                  final LocationResult? result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MapLocationPickerScreen(
                        title: 'Pilih Lokasi di Peta',
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

            // Informasi Tambahan
            AgriTextField(
              controller: _extraController,
              labelText: user.role == UserRole.pebisnis ? 'Kategori Bisnis' : 'Deskripsi & Luas Lahan',
              hintText: user.role == UserRole.pebisnis ? 'Restoran / Swalayan / Grosir' : 'Sayuran organik, 2 ha',
            ),
            const SizedBox(height: 28),

            // Simpan Perubahan Button
            AgriPillButton(
              text: 'SIMPAN PERUBAHAN',
              type: AgriButtonType.darkOlive,
              isLoading: _isLoading,
              height: 50,
              onPressed: _saveProfile,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
