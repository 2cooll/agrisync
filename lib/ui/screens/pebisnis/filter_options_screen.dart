import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/ui/theme/app_colors.dart';
import 'package:agrisync/ui/widgets/curved_header_scaffold.dart';
import 'package:agrisync/ui/widgets/custom_buttons.dart';
import 'package:agrisync/ui/widgets/custom_text_fields.dart';

class FilterOptionsScreen extends StatefulWidget {
  const FilterOptionsScreen({super.key});

  @override
  State<FilterOptionsScreen> createState() => _FilterOptionsScreenState();
}

class _FilterOptionsScreenState extends State<FilterOptionsScreen> {
  late RangeValues _priceRange;
  late RangeValues _stockRange;
  late String _selectedQuality;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _priceRange = RangeValues(appState.filterMinPrice, appState.filterMaxPrice > 0 ? appState.filterMaxPrice : 100000);
    _stockRange = RangeValues(appState.filterMinStock, appState.filterMaxStock > 0 ? appState.filterMaxStock : 5000);
    _selectedQuality = appState.filterQuality;
    _locationController = TextEditingController(text: appState.filterLocation);
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setFilters(
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      minStock: _stockRange.start,
      maxStock: _stockRange.end,
      quality: _selectedQuality,
      location: _locationController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return AgriCurvedScaffold(
      headerHeight: 70,
      showBack: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Filter Options',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AgriColors.textMain,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // 1. Harga Filter Slider matching mockup
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Harga (per kg)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AgriColors.textMain,
                  ),
                ),
                Text(
                  '${currencyFormatter.format(_priceRange.start)} - ${currencyFormatter.format(_priceRange.end)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AgriColors.darkOliveBtn,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AgriColors.primaryGreen,
                inactiveTrackColor: AgriColors.cardBorder,
                thumbColor: AgriColors.darkOliveBtn,
                overlayColor: AgriColors.primaryGreen.withOpacity(0.2),
                trackHeight: 4,
              ),
              child: RangeSlider(
                values: _priceRange,
                min: 0,
                max: 100000,
                divisions: 20,
                onChanged: (values) {
                  setState(() => _priceRange = values);
                },
              ),
            ),
            const SizedBox(height: 24),

            // 2. Jumlah Stok Slider matching mockup
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jumlah Stok (kg)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AgriColors.textMain,
                  ),
                ),
                Text(
                  '${_stockRange.start.toInt()} kg - ${_stockRange.end.toInt()} kg',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AgriColors.darkOliveBtn,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AgriColors.primaryGreen,
                inactiveTrackColor: AgriColors.cardBorder,
                thumbColor: AgriColors.darkOliveBtn,
                trackHeight: 4,
              ),
              child: RangeSlider(
                values: _stockRange,
                min: 0,
                max: 5000,
                divisions: 50,
                onChanged: (values) {
                  setState(() => _stockRange = values);
                },
              ),
            ),
            const SizedBox(height: 24),

            // 3. Kualitas Quality Grade Selector matching mockup
            Text(
              'Kualitas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildQualityChip('Semua'),
                const SizedBox(width: 8),
                _buildQualityChip('Grade A'),
                const SizedBox(width: 8),
                _buildQualityChip('Grade B'),
                const SizedBox(width: 8),
                _buildQualityChip('Grade C'),
              ],
            ),
            const SizedBox(height: 26),

            // 4. Lokasi Input matching mockup
            Text(
              'Lokasi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AgriColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            AgriTextField(
              controller: _locationController,
              hintText: 'Malang, Jawa Timur...',
              prefixIcon: const Icon(Icons.location_on_outlined, color: AgriColors.darkOliveBtn, size: 20),
            ),

            const SizedBox(height: 40),

            // Button: TERAPKAN FILTER
            AgriPillButton(
              text: 'TERAPKAN FILTER',
              type: AgriButtonType.darkOlive,
              height: 48,
              onPressed: _applyFilter,
            ),
            const SizedBox(height: 12),

            // Reset Filter link
            Center(
              child: TextButton(
                onPressed: () {
                  final appState = Provider.of<AppState>(context, listen: false);
                  appState.resetFilters();
                  setState(() {
                    _priceRange = const RangeValues(0, 100000);
                    _stockRange = const RangeValues(0, 5000);
                    _selectedQuality = 'Semua';
                    _locationController.clear();
                  });
                },
                child: Text(
                  'Reset Semua Filter',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AgriColors.textMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityChip(String grade) {
    final isSelected = _selectedQuality == grade;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedQuality = grade);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AgriColors.darkOliveBtn : AgriColors.surfaceWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AgriColors.darkOliveBtn : AgriColors.inputBorder,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            grade,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AgriColors.textMain,
            ),
          ),
        ),
      ),
    );
  }
}

