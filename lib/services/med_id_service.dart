import 'dart:math';

class MedIdService {
  /// Generates a unique Med ID in format MD-XXXX-XXXX
  static String generateMedId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String part1 =
        List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
    String part2 =
        List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
    return 'MD-$part1-$part2';
  }

  /// Default fallback Med ID matching reference image
  static const String defaultMedId = 'MD-S3AK-9Q8P';
}
