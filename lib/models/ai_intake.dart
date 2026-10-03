class AiQuestion {
  final String id;
  final String questionText;
  final String subtitle;
  final List<String> options;
  final bool isRequired;

  AiQuestion({
    required this.id,
    required this.questionText,
    required this.subtitle,
    required this.options,
    this.isRequired = true,
  });
}

class AiIntakeRecord {
  final String id;
  final String uid;
  final String chiefComplaint;
  final String duration;
  final String associatedSymptoms;
  final String severity;
  final String additionalNotes;
  final DateTime createdAt;
  final String status; // 'AI Structured - Pending Verification'

  AiIntakeRecord({
    required this.id,
    required this.uid,
    required this.chiefComplaint,
    required this.duration,
    required this.associatedSymptoms,
    required this.severity,
    this.additionalNotes = '',
    required this.createdAt,
    this.status = 'AI Structured - Pending Verification',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'chiefComplaint': chiefComplaint,
      'duration': duration,
      'associatedSymptoms': associatedSymptoms,
      'severity': severity,
      'additionalNotes': additionalNotes,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory AiIntakeRecord.fromJson(Map<String, dynamic> json) {
    return AiIntakeRecord(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      chiefComplaint: json['chiefComplaint'] ?? '',
      duration: json['duration'] ?? '',
      associatedSymptoms: json['associatedSymptoms'] ?? '',
      severity: json['severity'] ?? '',
      additionalNotes: json['additionalNotes'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      status: json['status'] ?? 'AI Structured - Pending Verification',
    );
  }
}
