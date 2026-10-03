class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String hospitalName;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final double consultationFee;
  final String imageUrl;
  final String about;
  final List<String> availableDates;
  final List<String> availableSlots;
  final String consultationMode; // 'In-Person', 'Video', 'Both'

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospitalName,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.consultationFee,
    required this.imageUrl,
    required this.about,
    required this.availableDates,
    required this.availableSlots,
    this.consultationMode = 'In-Person & Video',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'hospitalName': hospitalName,
      'rating': rating,
      'reviewCount': reviewCount,
      'experienceYears': experienceYears,
      'consultationFee': consultationFee,
      'imageUrl': imageUrl,
      'about': about,
      'availableDates': availableDates,
      'availableSlots': availableSlots,
      'consultationMode': consultationMode,
    };
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      hospitalName: json['hospitalName'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
      consultationFee: (json['consultationFee'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      about: json['about'] ?? '',
      availableDates: List<String>.from(json['availableDates'] ?? []),
      availableSlots: List<String>.from(json['availableSlots'] ?? []),
      consultationMode: json['consultationMode'] ?? 'In-Person & Video',
    );
  }
}
