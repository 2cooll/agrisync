import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final String addressName;
  final String district;
  final String cityOrRegency;
  final String province;
  final double latitude;
  final double longitude;
  final String fullFormattedAddress;

  const LocationResult({
    required this.addressName,
    required this.district,
    required this.cityOrRegency,
    required this.province,
    required this.latitude,
    required this.longitude,
    required this.fullFormattedAddress,
  });

  LatLng get toLatLng => LatLng(latitude, longitude);

  @override
  String toString() => fullFormattedAddress;
}

class LocationService {
  /// Preset Sentra Pertanian Populer di Indonesia (Offline-ready & instan)
  static final List<LocationResult> agriculturalPresets = [
    const LocationResult(
      addressName: 'Perumahan Permata Hijau',
      district: 'Lowokwaru',
      cityOrRegency: 'Kota Malang',
      province: 'Jawa Timur',
      latitude: -7.9255,
      longitude: 112.5985,
      fullFormattedAddress: 'Perumahan Permata Hijau, Kel. Tlogomas, Kec. Lowokwaru, Kota Malang, Jawa Timur',
    ),
    const LocationResult(
      addressName: 'Sentra Hortikultura Batu',
      district: 'Bumiaji',
      cityOrRegency: 'Kota Batu',
      province: 'Jawa Timur',
      latitude: -7.8712,
      longitude: 112.5271,
      fullFormattedAddress: 'Jl. Raya Selecta, Kec. Bumiaji, Kota Batu, Jawa Timur',
    ),
    const LocationResult(
      addressName: 'Perkebunan Sayur Lembang',
      district: 'Lembang',
      cityOrRegency: 'Kab. Bandung Barat',
      province: 'Jawa Barat',
      latitude: -6.8184,
      longitude: 107.6186,
      fullFormattedAddress: 'Jl. Kolonel Masturi, Kec. Lembang, Kab. Bandung Barat, Jawa Barat',
    ),
    const LocationResult(
      addressName: 'Lahan Sayuran Dataran Tinggi Dieng',
      district: 'Batur',
      cityOrRegency: 'Kab. Banjarnegara / Wonosobo',
      province: 'Jawa Tengah',
      latitude: -7.2062,
      longitude: 109.9042,
      fullFormattedAddress: 'Kawasan Dataran Tinggi Dieng, Kec. Batur, Jawa Tengah',
    ),
    const LocationResult(
      addressName: 'Sentra Jeruk & Sayur Brastagi',
      district: 'Berastagi',
      cityOrRegency: 'Kab. Karo',
      province: 'Sumatera Utara',
      latitude: 3.1895,
      longitude: 98.5085,
      fullFormattedAddress: 'Jl. Jamin Ginting, Kec. Berastagi, Kab. Karo, Sumatera Utara',
    ),
    const LocationResult(
      addressName: 'Sentra Bawang Merah Brebes',
      district: 'Wanasari',
      cityOrRegency: 'Kab. Brebes',
      province: 'Jawa Tengah',
      latitude: -6.8703,
      longitude: 109.0435,
      fullFormattedAddress: 'Kec. Wanasari, Kab. Brebes, Jawa Tengah',
    ),
    const LocationResult(
      addressName: 'Lahan Padi Organik Gianyar',
      district: 'Ubud',
      cityOrRegency: 'Kab. Gianyar',
      province: 'Bali',
      latitude: -8.5069,
      longitude: 115.2625,
      fullFormattedAddress: 'Tegallalang, Kec. Ubud, Kab. Gianyar, Bali',
    ),
    const LocationResult(
      addressName: 'Sentra Cabai & Padi Sleman',
      district: 'Pakem',
      cityOrRegency: 'Kab. Sleman',
      province: 'D.I. Yogyakarta',
      latitude: -7.6622,
      longitude: 110.4208,
      fullFormattedAddress: 'Jl. Kaliurang Km 17, Kec. Pakem, Kab. Sleman, D.I. Yogyakarta',
    ),
    const LocationResult(
      addressName: 'Sentra Padi Pandanwangi Cianjur',
      district: 'Warungkondang',
      cityOrRegency: 'Kab. Cianjur',
      province: 'Jawa Barat',
      latitude: -6.8523,
      longitude: 107.1032,
      fullFormattedAddress: 'Kec. Warungkondang, Kab. Cianjur, Jawa Barat',
    ),
  ];

  /// Reverse Geocoding: Mengubah koordinat (lat, lng) menjadi nama alamat menggunakan OpenStreetMap (Nominatim API gratis)
  static Future<LocationResult> reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'AgriSyncApp-Flutter/1.0 (agrisync.innovation.dev@gmail.com)',
          'Accept-Language': 'id-ID,id;q=0.9,en;q=0.8',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final road = address['road'] ?? address['pedestrian'] ?? address['village'] ?? address['suburb'] ?? 'Lahan Pertanian';
          final district = address['suburb'] ?? address['municipality'] ?? address['county'] ?? 'Kecamatan';
          final city = address['city'] ?? address['town'] ?? address['regency'] ?? address['county'] ?? 'Kota/Kabupaten';
          final province = address['state'] ?? address['province'] ?? 'Indonesia';
          final displayName = data['display_name'] ?? '$road, $district, $city, $province';

          return LocationResult(
            addressName: road.toString(),
            district: district.toString(),
            cityOrRegency: city.toString(),
            province: province.toString(),
            latitude: lat,
            longitude: lng,
            fullFormattedAddress: displayName.toString(),
          );
        }
      }
    } catch (e) {
      debugPrint('ℹ️ [LocationService] Reverse geocode online notice: $e (Falling back to localized coordinates)');
    }

    // Fallback: Cari preset terdekat jika sangat dekat (< 0.02 deg) atau format koordinat rapi
    for (final preset in agriculturalPresets) {
      final dLat = (preset.latitude - lat).abs();
      final dLng = (preset.longitude - lng).abs();
      if (dLat < 0.02 && dLng < 0.02) {
        return preset;
      }
    }

    return LocationResult(
      addressName: 'Titik Peta (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})',
      district: 'Lokasi Terpilih',
      cityOrRegency: 'Indonesia',
      province: 'Nusantara',
      latitude: lat,
      longitude: lng,
      fullFormattedAddress: 'Titik Koordinat: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
    );
  }

  /// Pencarian Alamat / Wilayah menggunakan OpenStreetMap Nominatim API Gratis
  static Future<List<LocationResult>> searchLocation(String query) async {
    if (query.trim().isEmpty) return agriculturalPresets;

    final normalized = query.trim().toLowerCase();
    final localMatches = agriculturalPresets.where((p) {
      return p.addressName.toLowerCase().contains(normalized) ||
          p.district.toLowerCase().contains(normalized) ||
          p.cityOrRegency.toLowerCase().contains(normalized) ||
          p.province.toLowerCase().contains(normalized) ||
          p.fullFormattedAddress.toLowerCase().contains(normalized);
    }).toList();

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=jsonv2&countrycodes=id&limit=8&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'AgriSyncApp-Flutter/1.0 (agrisync.innovation.dev@gmail.com)',
          'Accept-Language': 'id-ID,id;q=0.9',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        final results = list.map((item) {
          final lat = double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0;
          final lon = double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0;
          final address = item['address'] as Map<String, dynamic>? ?? {};

          final name = item['name'] ?? address['road'] ?? address['suburb'] ?? item['display_name']?.split(',').first ?? query;
          final district = address['suburb'] ?? address['municipality'] ?? address['county'] ?? '';
          final city = address['city'] ?? address['town'] ?? address['regency'] ?? '';
          final state = address['state'] ?? 'Indonesia';

          return LocationResult(
            addressName: name.toString(),
            district: district.toString(),
            cityOrRegency: city.toString(),
            province: state.toString(),
            latitude: lat,
            longitude: lon,
            fullFormattedAddress: item['display_name'] ?? '$name, $city, $state',
          );
        }).toList();

        if (results.isNotEmpty) {
          return results;
        }
      }
    } catch (e) {
      debugPrint('ℹ️ [LocationService] Search API notice: $e (Returning local matching presets)');
    }

    return localMatches.isNotEmpty ? localMatches : agriculturalPresets;
  }

  /// Melacak koordinat GPS pengguna saat ini secara akurat (High Accuracy GPS)
  /// Menggunakan Geolocator dengan multi-level fallback (IP Geocoding & Local Presets)
  static Future<LocationResult> getCurrentUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('⚠️ [LocationService] GPS Service disabled on device.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 6),
        );

        return await reverseGeocode(position.latitude, position.longitude);
      }
    } catch (e) {
      debugPrint('ℹ️ [LocationService] Live GPS tracking notice: $e');
    }

    // Secondary Fallback: IP Geolocation API
    try {
      final ipRes = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 3));
      if (ipRes.statusCode == 200) {
        final data = json.decode(ipRes.body);
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          return await reverseGeocode(lat, lng);
        }
      }
    } catch (_) {}

    // Final Fallback: Default Sentra Hortikultura Batu
    return agriculturalPresets.first;
  }
}

