import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/custom_text_fields.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _allFaqs = [
    {
      'q': 'Bagaimana cara kerja Rekber Escrow AgriSync?',
      'a': 'Uang pembayaran pembeli disimpan aman di rekening bersama AgriSync hingga komoditas panen sampai dan diverifikasi kualitasnya oleh pembeli. Setelah pembeli menekan konfirmasi, dana langsung diteruskan ke rekening petani.',
      'tags': 'escrow rekber pembayaran transaksi uang dana bayar',
    },
    {
      'q': 'Bagaimana cara melakukan tawar-menawar harga?',
      'a': 'Pebisnis dapat masuk ke halaman detail sayuran lalu menekan tombol "Nego Harga". Fitur chat real-time memungkinkan petani menerima atau mengajukan penawaran balik.',
      'tags': 'nego tawar harga chat obrolan',
    },
    {
      'q': 'Apa keuntungan upgrade ke AgriSync PRO?',
      'a': 'Member PRO mendapatkan potongan komisi transaksi dari 2.5% menjadi 1.0%, akses data prediksi tren harga pasar sayuran, serta prioritas pencarian komoditas.',
      'tags': 'pro membership langganan komisi diskon tren',
    },
    {
      'q': 'Bagaimana jika kualitas panen tidak sesuai pesanan?',
      'a': 'Pembeli dapat mengajukan klaim resolusi sebelum menyetujui pelepasan escrow. Tim mediasi AgriSync akan membantu penyesuaian dana atau penggantian hasil panen.',
      'tags': 'komplain klaim rusak kualitas busuk resolusi garansi',
    },
    {
      'q': 'Bagaimana cara verifikasi dokumen identitas kebun / usaha?',
      'a': 'Masuk ke menu Profil > Status Verifikasi Dokumen, lalu unggah foto KTP atau SIUP/NIB usaha Anda. Admin AgriSync akan memproses verifikasi dalam 1x24 jam kerja.',
      'tags': 'verifikasi dokumen ktp siup nib legalitas',
    },
    {
      'q': 'Bagaimana cara mencairkan saldo hasil penjualan?',
      'a': 'Petani dapat menarik saldo hasil panen langsung ke rekening bank lokal (BCA, Mandiri, BRI, BNI) atau dompet digital terdaftar kapan saja tanpa biaya penarikan.',
      'tags': 'cair withdraw saldo rekening bank dompet tarik',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateTicketDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'Transaksi & Escrow';
    final categories = [
      'Transaksi & Escrow',
      'Negosiasi & Chat Mitra',
      'Kualitas Sayuran / Pengiriman',
      'Akun & Verifikasi Dokumen',
      'Masalah Teknis Aplikasi',
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined, color: AgriColors.primaryGreen, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Kirim Tiket Bantuan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kategori Kendala',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AgriColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AgriColors.cardBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            items: categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat, style: GoogleFonts.plusJakartaSans(fontSize: 12.5)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => selectedCategory = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AgriTextField(
                        controller: subjectController,
                        labelText: 'Judul Kendala',
                        hintText: 'Contoh: Masalah pelepasan escrow #ORD-92',
                      ),
                      const SizedBox(height: 12),
                      AgriTextField(
                        controller: descController,
                        labelText: 'Deskripsi Kendala Lengkap',
                        hintText: 'Tuliskan kronologi dan rincian masalah Anda secara jelas...',
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgriColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final subj = subjectController.text.trim();
                    final desc = descController.text.trim();

                    if (subj.isEmpty || desc.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Harap lengkapi judul dan deskripsi masalah.')),
                      );
                      return;
                    }

                    final appState = Provider.of<AppState>(context, listen: false);
                    final ticketId = appState.submitSupportTicket(
                      category: selectedCategory,
                      subject: subj,
                      message: desc,
                    );

                    Navigator.pop(dialogCtx);

                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        title: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: AgriColors.primaryGreen, size: 24),
                            SizedBox(width: 8),
                            Text('Tiket Terkirim!'),
                          ],
                        ),
                        content: Text(
                          'Tiket pengaduan nomor #$ticketId telah berhasil dibuat.\n\nTim CS AgriSync telah menerima laporan Anda dan notifikasi status pembaruan akan dikirim ke aplikasi Anda.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.4),
                        ),
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AgriColors.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('OK, Mengerti'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Kirim Tiket',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _allFaqs.where((f) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final q = f['q']!.toLowerCase();
      final a = f['a']!.toLowerCase();
      final tags = (f['tags'] ?? '').toLowerCase();
      return q.contains(query) || a.contains(query) || tags.contains(query);
    }).toList();

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      title: 'Pusat Bantuan & CS',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Layanan Bantuan & Dukungan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Temukan jawaban cepat atau hubungi tim customer care resmi AgriSync.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AgriColors.textMuted),
            ),
            const SizedBox(height: 18),

            // Kontak CS Cepat Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF263211), Color(0xFF4A5D23)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.support_agent_rounded, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Customer Care 24/7',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Online',
                          style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Punya kendala transaksi, negosiasi, atau pengiriman? Tim kami siap melayani Anda.',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AgriColors.darkOliveBtn,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: '+6281234567890'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nomor WhatsApp CS (+62 812-3456-7890) berhasil disalin! Buka WhatsApp untuk memulai obrolan.'),
                                backgroundColor: Color(0xFF25D366),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_outlined, size: 16, color: Color(0xFF25D366)),
                          label: Text(
                            'Chat WhatsApp',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: 'support@agrisync.id'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email support@agrisync.id berhasil disalin ke clipboard!'),
                                backgroundColor: AgriColors.primaryGreen,
                              ),
                            );
                          },
                          icon: const Icon(Icons.mail_outline_rounded, size: 16, color: Colors.white),
                          label: Text(
                            'Kirim Email',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF81C784),
                        foregroundColor: const Color(0xFF1B5E20),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showCreateTicketDialog(context),
                      icon: const Icon(Icons.add_task_rounded, size: 16),
                      label: Text(
                        'Buat Tiket Bantuan CS (Prioritas)',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live FAQ Search Field
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Cari pertanyaan (contoh: escrow, nego, komisi)...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AgriColors.textHint),
                prefixIcon: const Icon(Icons.search, color: AgriColors.primaryGreen, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AgriColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AgriColors.cardBorder),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // FAQ Accordion List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pertanyaan Yang Sering Diajukan (FAQ)',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AgriColors.textMain),
                ),
                Text(
                  '${filteredFaqs.length} artikel',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (filteredFaqs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AgriColors.cardBorder),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.search_off_rounded, size: 40, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      'Tidak ada FAQ untuk "$_searchQuery"',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Coba kata kunci lain atau kirim tiket bantuan ke tim CS.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AgriColors.textMuted),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AgriColors.cardBorder),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredFaqs.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (ctx, i) {
                    final faq = filteredFaqs[i];
                    return ExpansionTile(
                      title: Text(
                        faq['q']!,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      children: [
                        Text(
                          faq['a']!,
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.45, color: AgriColors.textMuted),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),

            // Tentang Aplikasi Card
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
                      const Icon(Icons.info_outline_rounded, color: AgriColors.darkOliveBtn, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tentang AgriSync',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AgriSync adalah platform digital rantai pasok hortikultura & komoditas panen segar yang menghubungkan petani produsen dengan pebisnis kuliner/restoran secara transparan, adil, dan terpercaya.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.45, color: AgriColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Versi Aplikasi', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
                      Text('v1.0.0+1 (2026)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
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

