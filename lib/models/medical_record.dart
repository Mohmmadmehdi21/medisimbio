class PrescriptionRecord {
  final String id;
  final String userId;
  final String medicineName;
  final String? dosage;
  final String? frequency;
  final String? duration;
  final String? prescribedBy;
  final DateTime? date;
  final String? provenance;

  PrescriptionRecord({
    required this.id,
    required this.userId,
    required this.medicineName,
    this.dosage,
    this.frequency,
    this.duration,
    this.prescribedBy,
    this.date,
    this.provenance,
  });

  factory PrescriptionRecord.fromJson(Map<String, dynamic> json, String id) {
    return PrescriptionRecord(
      id: id,
      userId: json['userId'] ?? '',
      medicineName: json['medicineName'] ?? 'Unspecified Medicine',
      dosage: json['dosage'],
      frequency: json['frequency'],
      duration: json['duration'],
      prescribedBy: json['prescribedBy'],
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      provenance: json['provenance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'medicineName': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'prescribedBy': prescribedBy,
      'date': date?.toIso8601String(),
      'provenance': provenance,
    };
  }
}

class LabReportRecord {
  final String id;
  final String userId;
  final String testName;
  final String? laboratory;
  final DateTime? date;
  final String? status;
  final String? reportUrl;
  final String? summary;
  final String? provenance;

  LabReportRecord({
    required this.id,
    required this.userId,
    required this.testName,
    this.laboratory,
    this.date,
    this.status,
    this.reportUrl,
    this.summary,
    this.provenance,
  });

  factory LabReportRecord.fromJson(Map<String, dynamic> json, String id) {
    return LabReportRecord(
      id: id,
      userId: json['userId'] ?? '',
      testName: json['testName'] ?? 'Laboratory Test',
      laboratory: json['laboratory'],
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      status: json['status'],
      reportUrl: json['reportUrl'],
      summary: json['summary'],
      provenance: json['provenance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'testName': testName,
      'laboratory': laboratory,
      'date': date?.toIso8601String(),
      'status': status,
      'reportUrl': reportUrl,
      'summary': summary,
      'provenance': provenance,
    };
  }
}

class ConsultationRecord {
  final String id;
  final String userId;
  final String doctorName;
  final String? specialization;
  final String? facility;
  final DateTime? consultationDate;
  final String? appointmentId;
  final String? status;
  final String? provenance;

  ConsultationRecord({
    required this.id,
    required this.userId,
    required this.doctorName,
    this.specialization,
    this.facility,
    this.consultationDate,
    this.appointmentId,
    this.status,
    this.provenance,
  });

  factory ConsultationRecord.fromJson(Map<String, dynamic> json, String id) {
    return ConsultationRecord(
      id: id,
      userId: json['userId'] ?? '',
      doctorName: json['doctorName'] ?? 'Doctor Consultation',
      specialization: json['specialization'],
      facility: json['facility'],
      consultationDate: json['consultationDate'] != null
          ? DateTime.tryParse(json['consultationDate'].toString())
          : null,
      appointmentId: json['appointmentId'],
      status: json['status'],
      provenance: json['provenance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'doctorName': doctorName,
      'specialization': specialization,
      'facility': facility,
      'consultationDate': consultationDate?.toIso8601String(),
      'appointmentId': appointmentId,
      'status': status,
      'provenance': provenance,
    };
  }
}

class ClinicalNoteRecord {
  final String id;
  final String userId;
  final String title;
  final String? author;
  final DateTime? date;
  final String? noteText;
  final String? provenance;

  ClinicalNoteRecord({
    required this.id,
    required this.userId,
    required this.title,
    this.author,
    this.date,
    this.noteText,
    this.provenance,
  });

  factory ClinicalNoteRecord.fromJson(Map<String, dynamic> json, String id) {
    return ClinicalNoteRecord(
      id: id,
      userId: json['userId'] ?? '',
      title: json['title'] ?? 'Clinical Note',
      author: json['author'],
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      noteText: json['noteText'],
      provenance: json['provenance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'author': author,
      'date': date?.toIso8601String(),
      'noteText': noteText,
      'provenance': provenance,
    };
  }
}

class DocumentRecord {
  final String id;
  final String userId;
  final String documentName;
  final String? category;
  final DateTime? uploadDate;
  final String? fileUrl;
  final String? provenance;

  DocumentRecord({
    required this.id,
    required this.userId,
    required this.documentName,
    this.category,
    this.uploadDate,
    this.fileUrl,
    this.provenance,
  });

  factory DocumentRecord.fromJson(Map<String, dynamic> json, String id) {
    return DocumentRecord(
      id: id,
      userId: json['userId'] ?? '',
      documentName: json['documentName'] ?? 'Medical Document',
      category: json['category'],
      uploadDate: json['uploadDate'] != null
          ? DateTime.tryParse(json['uploadDate'].toString())
          : null,
      fileUrl: json['fileUrl'],
      provenance: json['provenance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'documentName': documentName,
      'category': category,
      'uploadDate': uploadDate?.toIso8601String(),
      'fileUrl': fileUrl,
      'provenance': provenance,
    };
  }
}
