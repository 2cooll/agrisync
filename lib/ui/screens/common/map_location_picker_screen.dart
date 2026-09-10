import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:agrisync/data/services/location_service.dart';
import 'package:agrisync/data/config/env_config.dart';
import 'package:agrisync/ui/theme/app_colors.dart';

class MapLocationPickerScreen extends StatefulWidget {
  final String title;
  final LatLng? initialPosition;
  final String? initialAddress;

  const MapLocationPickerScreen({
    super.key,
    this.title = 'Pilih Titik Lokasi di Peta',
    this.initialPosition,
    this.initialAddress,
  });

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  late final MapController _mapController;
  late LatLng _selectedPoint;
  LocationResult? _currentLocationResult;
  bool _isLoadingAddress = false;
  bool _isTrackingGPS = false;
  Timer? _debounceTimer;
  final _searchController = TextEditingController();
  List<LocationResult> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Default coordinate: Batu, Malang (Sentra Pertanian Jatim) atau dari initialPosition
    _selectedPoint = widget.initialPosition ?? const LatLng(-7.8712, 112.5271);

    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      _currentLocationResult = LocationResult(
        addressName: widget.initialAddress!,
        district: 'Lokasi Terpilih',
        cityOrRegency: 'Indonesia',
        province: '',
        latitude: _selectedPoint.latitude,
        longitude: _selectedPoint.longitude,
        fullFormattedAddress: widget.initialAddress!,
      );
    } else {
      _fetchAddressForPoint(_selectedPoint);
    }

    // Auto-detect accurate user GPS if no initial position provided
    if (widget.initialPosition == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _trackCurrentLocation(showFeedback: false);
      });
    }
  }

  Future<void> _trackCurrentLocation({bool showFeedback = true}) async {
    if (!mounted) return;
    setState(() {
      _isTrackingGPS = true;
      _isLoadingAddress = true;
    });

    final loc = await LocationService.getCurrentUserLocation();

    if (mounted) {
      setState(() {
        _selectedPoint = loc.toLatLng;
        _currentLocationResult = loc;
        _isTrackingGPS = false;
        _isLoadingAddress = false;
      });

      try {
        _mapController.move(loc.toLatLng, 16.0);
      } catch (_) {}

      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lokasi GPS berhasil dilacak: ${loc.addressName} (${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)})',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AgriColors.verifiedGreen,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAddressForPoint(LatLng point) async {
    setState(() {
      _selectedPoint = point;
      _isLoadingAddress = true;
    });

    final result = await LocationService.reverseGeocode(point.latitude, point.longitude);

    if (mounted) {
      setState(() {
        _currentLocationResult = result;
        _isLoadingAddress = false;
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    _debounceTimer?.cancel();
    _mapController.move(point, _mapController.camera.zoom);
    _fetchAddressForPoint(point);
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 600), () {
        _fetchAddressForPoint(camera.center);
      });
    }
  }

  void _selectPreset(LocationResult preset) {
    final point = preset.toLatLng;
    _mapController.move(point, 15.0);
    setState(() {
      _selectedPoint = point;
      _currentLocationResult = preset;
      _isSearching = false;
      _searchResults = [];
      _searchController.clear();
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await LocationService.searchLocation(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriColors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: AgriColors.darkOliveBtn,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Info Peta Gratis',
            icon: const Icon(Icons.info_outline_rounded, size: 20),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: [
                      const Icon(Icons.map_rounded, color: AgriColors.primaryGreen, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Peta OpenStreetMap',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: Text(
                    'Peta ini menggunakan OpenStreetMap & Nominatim Geocoding yang 100% gratis tanpa biaya API key.\n\n'
                    'Anda dapat menggeser peta, memperbesar (zoom), mencari nama kecamatan/kota, atau mengetuk titik lokasi kebun/pengiriman.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.4),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. OPENSTREETMAP INTERACTIVE MAP VIEW
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPoint,
              initialZoom: 14.0,
              minZoom: 4.0,
              maxZoom: 18.0,
              onTap: _onMapTap,
              onPositionChanged: _onPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: EnvConfig.mapTileUrl,
                userAgentPackageName: 'com.agrisync.agrisync',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPoint,
                    width: 50,
                    height: 50,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 46,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. SEARCH BAR & POPULAR AGRICULTURAL CHIPS (TOP)
          Positioned(
            top: 12,
            left: 14,
            right: 14,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      _debounceTimer?.cancel();
                      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                        _performSearch(val);
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari nama daerah / sentra tani (misal: Batu, Lembang)...',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade500),
                      prefixIcon: const Icon(Icons.search_rounded, color: AgriColors.darkOliveBtn),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AgriColors.primaryGreen),
                              ),
                            )
                          : (_searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchResults = [];
                                      _isSearching = false;
                                    });
                                  },
                                )
                              : null),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),

                // Search Results Dropdown List
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (ctx, idx) {
                        final item = _searchResults[idx];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.location_on, color: AgriColors.primaryGreen, size: 20),
                          title: Text(
                            item.addressName,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            item.fullFormattedAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AgriColors.textMuted),
                          ),
                          onTap: () => _selectPreset(item),
                        );
                      },
                    ),
                  ),

                // Horizontal Preset Chips
                if (_searchResults.isEmpty)
                  Container(
                    height: 40,
                    margin: const EdgeInsets.only(top: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: LocationService.agriculturalPresets.length,
                      itemBuilder: (ctx, i) {
                        final preset = LocationService.agriculturalPresets[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            avatar: const Icon(Icons.eco_rounded, size: 14, color: AgriColors.darkOliveBtn),
                            label: Text(
                              preset.cityOrRegency.replaceAll('Kab. ', '').replaceAll('Kota ', ''),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AgriColors.darkOliveBtn,
                              ),
                            ),
                            backgroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: Colors.black12,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            onPressed: () => _selectPreset(preset),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // 3. MAP CONTROLS (ZOOM & GPS)
          Positioned(
            right: 14,
            bottom: 190,
            child: Column(
              children: [
                // Zoom In
                FloatingActionButton.small(
                  heroTag: 'map_zoom_in',
                  backgroundColor: Colors.white,
                  foregroundColor: AgriColors.darkOliveBtn,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_selectedPoint, currentZoom + 1);
                  },
                  child: const Icon(Icons.add_rounded),
                ),
                const SizedBox(height: 8),
                // Zoom Out
                FloatingActionButton.small(
                  heroTag: 'map_zoom_out',
                  backgroundColor: Colors.white,
                  foregroundColor: AgriColors.darkOliveBtn,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_selectedPoint, currentZoom - 1);
                  },
                  child: const Icon(Icons.remove_rounded),
                ),
                const SizedBox(height: 8),
                // Center / GPS My Location
                FloatingActionButton.small(
                  heroTag: 'map_my_location',
                  backgroundColor: _isTrackingGPS ? AgriColors.pendingOrange : AgriColors.primaryGreen,
                  foregroundColor: Colors.white,
                  tooltip: 'Lacak Lokasi GPS Akurat',
                  onPressed: _isTrackingGPS ? null : () => _trackCurrentLocation(showFeedback: true),
                  child: _isTrackingGPS
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
          ),

          // 4. BOTTOM ADDRESS CARD & CONFIRMATION BUTTON
          Positioned(
            left: 14,
            right: 14,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AgriColors.lightSageBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.pin_drop_rounded,
                          color: AgriColors.primaryGreen,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lokasi Yang Dipilih:',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AgriColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (_isLoadingAddress)
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AgriColors.primaryGreen),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Memuat alamat dari peta...',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              )
                            else
                              Text(
                                _currentLocationResult?.fullFormattedAddress ??
                                    '${_selectedPoint.latitude.toStringAsFixed(4)}, ${_selectedPoint.longitude.toStringAsFixed(4)}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AgriColors.textMain,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Coordinates info badge with live GPS status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AgriColors.badgeGreenBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AgriColors.primaryGreen.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.gps_fixed_rounded, size: 12, color: AgriColors.verifiedGreen),
                        const SizedBox(width: 5),
                        Text(
                          '${_selectedPoint.latitude.toStringAsFixed(5)}, ${_selectedPoint.longitude.toStringAsFixed(5)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AgriColors.verifiedGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Button Konfirmasi
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AgriColors.darkOliveBtn,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final finalResult = _currentLocationResult ??
                            LocationResult(
                              addressName: 'Titik Peta Terpilih',
                              district: 'Lokasi Terpilih',
                              cityOrRegency: 'Indonesia',
                              province: '',
                              latitude: _selectedPoint.latitude,
                              longitude: _selectedPoint.longitude,
                              fullFormattedAddress:
                                  'Koordinat: ${_selectedPoint.latitude.toStringAsFixed(5)}, ${_selectedPoint.longitude.toStringAsFixed(5)}',
                            );
                        Navigator.of(context).pop(finalResult);
                      },
                      child: Text(
                        'GUNAKAN ALAMAT INI',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
