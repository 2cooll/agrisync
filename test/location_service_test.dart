import 'package:flutter_test/flutter_test.dart';
import 'package:agrisync/data/services/location_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationService & OpenStreetMap Geocoding Tests', () {
    test('Agricultural presets contains essential farming centers in Indonesia', () {
      final presets = LocationService.agriculturalPresets;
      expect(presets.isNotEmpty, true);
      expect(presets.any((p) => p.cityOrRegency.contains('Batu')), true);
      expect(presets.any((p) => p.cityOrRegency.contains('Bandung')), true);
      expect(presets.any((p) => p.cityOrRegency.contains('Wonosobo') || p.cityOrRegency.contains('Banjarnegara')), true);
      expect(presets.any((p) => p.cityOrRegency.contains('Brebes')), true);
    });

    test('Local search matches preset locations by keyword', () async {
      final resultsBatu = await LocationService.searchLocation('Batu');
      expect(resultsBatu.isNotEmpty, true);
      expect(resultsBatu.any((r) => r.fullFormattedAddress.toLowerCase().contains('batu') || r.cityOrRegency.contains('Batu')), true);

      final resultsLembang = await LocationService.searchLocation('Lembang');
      expect(resultsLembang.isNotEmpty, true);
      expect(resultsLembang.any((r) => r.fullFormattedAddress.toLowerCase().contains('lembang') || r.district.contains('Lembang')), true);
    });

    test('Reverse geocode fallback extracts coordinates gracefully', () async {
      final result = await LocationService.reverseGeocode(-7.8712, 112.5271);
      expect(result.latitude, -7.8712);
      expect(result.longitude, 112.5271);
      expect(result.fullFormattedAddress.isNotEmpty, true);
    });

    test('getCurrentUserLocation returns accurate coordinates with safe fallback', () async {
      final loc = await LocationService.getCurrentUserLocation();
      expect(loc.latitude, isNotNull);
      expect(loc.longitude, isNotNull);
      expect(loc.fullFormattedAddress.isNotEmpty, isTrue);
      expect(loc.toLatLng.latitude, equals(loc.latitude));
      expect(loc.toLatLng.longitude, equals(loc.longitude));
    });
  });
}

