import 'package:flutter_test/flutter_test.dart';
import 'package:medisimbio_ui/screens/emergency_screens.dart';

void main() {
  group('Phase 1R — Emergency Facility Discovery Unit Tests', () {
    test('Haversine distance calculation produces correct distance in kilometers', () {
      // Coordinates for London Eye (51.5033, -0.1195) to Big Ben (51.5007, -0.1246) ~0.46 km
      final dist = EmergencyFacility.calculateHaversineDistance(
        lat1: 51.5033,
        lon1: -0.1195,
        lat2: 51.5007,
        lon2: -0.1246,
      );

      expect(dist, isNotNull);
      expect(dist!, greaterThan(0.4));
      expect(dist, lessThan(0.6));
    });

    test('Haversine distance calculation returns null if any coordinate is missing', () {
      final dist = EmergencyFacility.calculateHaversineDistance(
        lat1: null,
        lon1: -0.1195,
        lat2: 51.5007,
        lon2: -0.1246,
      );

      expect(dist, isNull);
    });

    test('EmergencyFacility object constructor retains all fields correctly', () {
      final facility = EmergencyFacility(
        id: 'fac_101',
        name: 'City General Hospital',
        type: 'Hospital',
        address: '123 Health Ave, Metro City',
        phone: '+1234567890',
        latitude: 12.9716,
        longitude: 77.5946,
        distanceKm: 2.4,
        etaText: '8 mins',
        emergencyAvailabilityStatus: 'AVAILABLE',
        emergencyService: '24-hour Emergency Department',
      );

      expect(facility.id, equals('fac_101'));
      expect(facility.name, equals('City General Hospital'));
      expect(facility.type, equals('Hospital'));
      expect(facility.phone, equals('+1234567890'));
      expect(facility.distanceKm, equals(2.4));
      expect(facility.etaText, equals('8 mins'));
      expect(facility.emergencyAvailabilityStatus, equals('AVAILABLE'));
    });

    test('Category filtering logic separates Hospitals from Clinics', () {
      final facilities = [
        EmergencyFacility(id: '1', name: 'Apex Hospital', type: 'Hospital'),
        EmergencyFacility(id: '2', name: 'Care Clinic', type: 'Clinic'),
        EmergencyFacility(id: '3', name: 'Metro Trauma Center', type: 'Hospital'),
      ];

      final hospitalsOnly = facilities
          .where((f) => f.type.toLowerCase().contains('hospital'))
          .toList();
      final clinicsOnly = facilities
          .where((f) => f.type.toLowerCase().contains('clinic'))
          .toList();

      expect(hospitalsOnly.length, equals(2));
      expect(clinicsOnly.length, equals(1));
      expect(clinicsOnly.first.name, equals('Care Clinic'));
    });

    test('Availability status text evaluation', () {
      final availableFac = EmergencyFacility(
        id: '1',
        name: 'Fac 1',
        emergencyAvailabilityStatus: 'AVAILABLE',
      );

      final unavailableFac = EmergencyFacility(
        id: '2',
        name: 'Fac 2',
        emergencyAvailabilityStatus: 'UNAVAILABLE',
      );

      final unconfirmedFac = EmergencyFacility(
        id: '3',
        name: 'Fac 3',
        emergencyAvailabilityStatus: null,
      );

      expect(availableFac.emergencyAvailabilityStatus, equals('AVAILABLE'));
      expect(unavailableFac.emergencyAvailabilityStatus, equals('UNAVAILABLE'));
      expect(unconfirmedFac.emergencyAvailabilityStatus, isNull);
    });
  });
}
