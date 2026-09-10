import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/product_model.dart';
import 'package:agrisync/data/services/image_picker_helper.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/widgets/custom_text_fields.dart';
import 'package:agrisync/ui/widgets/agri_product_image.dart';
import 'package:agrisync/data/services/location_service.dart';
import 'package:agrisync/ui/screens/common/map_location_picker_screen.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? productToEdit;

  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _titleController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  final _harvestController = TextEditingController(text: '28 Agustus 2026');
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Sayuran';
  String _selectedGrade = 'Grade A';
  String _imageUrl = 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&auto=format&fit=crop&q=80';
  bool _isLoading = false;

  final List<String> _categories = ['Sayuran', 'Buah', 'Palawija', 'Karbohidrat', 'Rempah', 'Kacang'];
  final List<String> _grades = ['Grade A', 'Grade B', 'Grade C'];

  // Sample preset images for quick selection & fallback
  final List<Map<String, String>> _sampleImages = [
    {
      'title': 'Cabai Merah',
      'url': 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Tomat Segar',
      'url': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Bawang Merah',
      'url': 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Jagung Manis',
      'url': 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=600&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Kol / Kubis',
      'url': 'https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f?w=600&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Wortel Manis',
      'url': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Pisang Mas',
      'url': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Kacang Tanah',
      'url': 'https://images.unsplash.com/photo-1567892328221-1c259f37213b?w=600&auto=format&fit=crop&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);

    if (widget.productToEdit != null) {
      final p = widget.productToEdit!;
      _titleController.text = p.title;
      _stockController.text = p.stockKg.toString();
      _priceController.text = p.pricePerKg.toString();
      _harvestController.text = p.harvestEstimate;
      _locationController.text = p.farmerLocation;
      _descController.text = p.description;
      _selectedCategory = _categories.contains(p.category) ? p.category : _categories.first;
      _selectedGrade = _grades.contains(p.qualityGrade) ? p.qualityGrade : _grades.first;
      _imageUrl = p.imageUrl;
    } else {
      _locationController.text = appState.currentUser.farmLocation ?? 'Malang, Jawa Timur';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    _harvestController.dispose();
    _locationController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isCamera) async {
    try {
      final Uint8List? bytes = await AppImagePicker.pickImage(isCamera: isCamera);

      if (bytes != null && bytes.isNotEmpty) {
        final base64String = base64Encode(bytes);
        setState(() {
          _imageUrl = 'data:image/jpeg;base64,$base64String';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isCamera
                    ? 'Foto berhasil diambil dari kamera!'
                    : 'Foto berhasil dipilih dari galeri!',
              ),
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
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: AgriColors.rejectedRed,
          ),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AgriColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Ambil Foto Produk Sayuran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AgriColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih metode untuk mengambil atau memilih foto hasil panen Anda:',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AgriColors.textMuted),
                ),
                const SizedBox(height: 16),

                // Option 1: Camera
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AgriColors.badgeGreenBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AgriColors.darkOliveBtn),
                  ),
                  title: Text(
                    'Kamera (Ambil Foto Langsung)',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    'Buka kamera perangkat untuk memotret panen',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(true);
                  },
                ),
                const Divider(height: 1),

                // Option 2: Gallery
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AgriColors.lightSageBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: AgriColors.primaryGreen),
                  ),
                  title: Text(
                    'Galeri (Pilih dari Perangkat)',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    'Pilih foto panen yang sudah ada di penyimpanan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(false);
                  },
                ),
                const Divider(height: 1),

                // Option 3: Presets
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AgriColors.categorySayuranBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.collections_rounded, color: AgriColors.darkOliveBtn),
                  ),
                  title: Text(
                    'Sampel Foto Panen Berkualitas',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    'Pilih cepat dari galeri sampel tanaman AgriSync',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showSamplePickerSheet();
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSamplePickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AgriColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Pilih Sampel Foto Panen',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AgriColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ketuk salah satu foto untuk menerapkannya sebagai foto sayuran:',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AgriColors.textMuted),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _sampleImages.length,
                    itemBuilder: (context, index) {
                      final item = _sampleImages[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _imageUrl = item['url']!;
                          });
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Foto sampel ${item['title']} dipilih!'),
                              backgroundColor: AgriColors.primaryGreen,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AgriColors.cardBorder, width: 1.2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                AgriProductImage(
                                  imageUrl: item['url']!,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                    color: Colors.black54,
                                    child: Text(
                                      item['title']!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitProduct() {
    if (_titleController.text.trim().isEmpty ||
        _stockController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi nama produk, stok, dan harga')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final appState = Provider.of<AppState>(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final user = appState.currentUser;
    final title = _titleController.text.trim();
    final cat = _selectedCategory;
    final loc = _locationController.text.trim().isEmpty ? 'Malang, Jawa Timur' : _locationController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 25000;
    final stock = int.tryParse(_stockController.text.trim()) ?? 100;
    final grade = _selectedGrade;
    final harvest = _harvestController.text.trim().isEmpty ? 'Siap Panen' : _harvestController.text.trim();
    final desc = _descController.text.trim().isEmpty
        ? 'Hasil panen segar berkualitas unggul, dipanen langsung dari kebun.'
        : _descController.text.trim();

    if (widget.productToEdit != null) {
      final updatedProduct = widget.productToEdit!.copyWith(
        title: title,
        category: cat,
        farmerLocation: loc,
        pricePerKg: price,
        stockKg: stock,
        qualityGrade: grade,
        harvestEstimate: harvest,
        description: desc,
        imageUrl: _imageUrl,
        isPendingSync: appState.isOfflineMode,
      );

      appState.updateProduct(updatedProduct);

      setState(() => _isLoading = false);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            appState.isOfflineMode
                ? 'Mode Offline: Pembaruan sayuran tersimpan di cache lokal (⏳ Menunggu Sinyal Cloud)'
                : 'Data sayuran hasil panen berhasil diperbarui!',
          ),
          backgroundColor: appState.isOfflineMode ? const Color(0xFFE65100) : AgriColors.primaryGreen,
        ),
      );
    } else {
      final newProduct = ProductModel(
        id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        category: cat,
        farmerId: user.id,
        farmerName: user.name,
        farmerLocation: loc,
        isFarmerVerified: user.isVerified,
        pricePerKg: price,
        stockKg: stock,
        qualityGrade: grade,
        harvestEstimate: harvest,
        description: desc,
        imageUrl: _imageUrl,
        distanceKm: 15,
        createdAt: DateTime.now(),
        isPendingSync: appState.isOfflineMode,
      );

      appState.addProduct(newProduct);

      setState(() => _isLoading = false);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            appState.isOfflineMode
                ? 'Mode Offline: Hasil panen tersimpan di cache lokal (⏳ Menunggu Sinyal Cloud)'
                : 'Hasil panen berhasil diterbitkan ke katalog AgriSync!',
          ),
          backgroundColor: appState.isOfflineMode ? const Color(0xFFE65100) : AgriColors.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      title: isEditing ? 'Edit Hasil Panen' : 'Tambah Hasil Panen',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                isEditing ? 'Perbarui Data Sayuran' : 'Tambah Hasil Panen',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AgriColors.textMain,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Image Preview & Upload options
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _showImageSourceSheet,
                    child: Container(
                      width: 150,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AgriColors.lightSageBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AgriColors.cardBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AgriProductImage(
                          imageUrl: _imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showImageSourceSheet,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AgriColors.darkOliveBtn,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton.icon(
                onPressed: _showImageSourceSheet,
                icon: const Icon(Icons.add_a_photo_outlined, size: 16, color: AgriColors.primaryGreen),
                label: Text(
                  'Ambil / Ubah Foto Sayuran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AgriColors.primaryGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Nama Produk
            AgriTextField(
              controller: _titleController,
              labelText: 'Nama Produk Pertanian',
              hintText: 'Misal: Cabai Rawit Merah, Tomat...',
            ),
            const SizedBox(height: 14),

            // Kategori Dropdown
            Text(
              'Kategori Produk',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AgriColors.textMain),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AgriColors.surfaceWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AgriColors.inputBorder, width: 1.2),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Row: Harga & Stok
            Row(
              children: [
                Expanded(
                  child: AgriTextField(
                    controller: _priceController,
                    labelText: 'Harga per kg (Rp)',
                    hintText: '25000',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AgriTextField(
                    controller: _stockController,
                    labelText: 'Jumlah Stok (kg)',
                    hintText: '500',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Row: Kualitas & Estimasi Panen
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kualitas Grade',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AgriColors.textMain),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AgriColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AgriColors.inputBorder, width: 1.2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedGrade,
                            isExpanded: true,
                            items: _grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedGrade = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AgriTextField(
                    controller: _harvestController,
                    labelText: 'Estimasi Waktu Panen',
                    hintText: '20 Agustus 2026',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Lokasi Lahan
            AgriTextField(
              controller: _locationController,
              labelText: 'Lokasi Lahan Pertanian (Pilih di Peta)',
              hintText: 'Malang, Jawa Timur',
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
            const SizedBox(height: 14),

            // Deskripsi
            AgriTextField(
              controller: _descController,
              labelText: 'Deskripsi Produk',
              hintText: 'Karakteristik buah, kesegaran, keunggulan...',
              maxLines: 3,
            ),
            const SizedBox(height: 28),

            // Button: SUBMIT
            AgriPillButton(
              text: isEditing ? 'SIMPAN PERUBAHAN SAYURAN' : 'TERBITKAN PRODUK PANEN',
              type: AgriButtonType.darkOlive,
              isLoading: _isLoading,
              height: 50,
              onPressed: _submitProduct,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
