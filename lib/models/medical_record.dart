class PrescriptionMedicine {
  final String medicineName;
  final String? dosage;
  final String? frequency;
  final String? duration;
  final String? timing;
  final String? notes;

  PrescriptionMedicine({
    required this.medicineName,
    this.dosage,
    this.frequency,
    this.duration,
    this.timing,
    this.notes,
  });

  factory PrescriptionMedicine.fromJson(Map<String, dynamic> json) {
    return PrescriptionMedicine(
      medicineName: json['medicineName'] ?? json['name'] ?? 'Unspecified Medicine',
      dosage: json['dosage']?.toString(),
      frequency: json['frequency']?.toString(),
      duration: json['duration']?.toString(),
      timing: json['timing']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineName': medicineName,
      if (dosage != null) 'dosage': dosage,
      if (frequency != null) 'frequency': frequency,
      if (duration != null) 'duration': duration,
      if (timing != null) 'timing': timing,
      if (notes != null) 'notes': notes,
    };
  }
}

class PrescriptionRecord {
  final String id;
  final String userId;
  final String? doctorId;
  final String? doctorName;
  final String? clinicName;
  final DateTime? prescriptionDate;
  final List<PrescriptionMedicine> medicines;
  final String? duration;
  final String? status;
  final String? provenance;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PrescriptionRecord({
    required this.id,
    required this.userId,
    this.doctorId,
    this.doctorName,
    this.clinicName,
    this.prescriptionDate,
    required this.medicines,
    this.duration,
    this.status,
    this.provenance,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  // Backward compatibility getters
  String get medicineName => medicines.isNotEmpty ? medicines.first.medicineName : 'Unspecified Medicine';
  String? get dosage => medicines.isNotEmpty ? medicines.first.dosage : null;
  String? get frequency => medicines.isNotEmpty ? medicines.first.frequency : null;
  String? get prescribedBy => doctorName;
  DateTime? get date => prescriptionDate;

  factory PrescriptionRecord.fromJson(Map<String, dynamic> json, String id) {
    List<PrescriptionMedicine> parsedMedicines = [];
    if (json['medicines'] != null && json['medicines'] is List) {
      parsedMedicines = (json['medicines'] as List)
          .whereType<Map<String, dynamic>>()
          .map((m) => PrescriptionMedicine.fromJson(m))
          .toList();
    } else if (json['medicineName'] != null) {
      parsedMedicines = [
        PrescriptionMedicine(
          medicineName: json['medicineName'].toString(),
          dosage: json['dosage']?.toString(),
          frequency: json['frequency']?.toString(),
          duration: json['duration']?.toString(),
          timing: json['timing']?.toString(),
          notes: json['notes']?.toString(),
        )
      ];
    }

    return PrescriptionRecord(
      id: id,
      userId: json['userId'] ?? json['patientId'] ?? '',
      doctorId: json['doctorId'] ?? json['providerId'],
      doctorName: json['doctorName'] ?? json['prescribedBy'],
      clinicName: json['clinicName'] ?? json['clinic'] ?? json['hospital'] ?? json['facility'],
      prescriptionDate: json['prescriptionDate'] != null
          ? DateTime.tryParse(json['prescriptionDate'].toString())
          : (json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null),
      medicines: parsedMedicines,
      duration: json['duration']?.toString(),
      status: json['status']?.toString(),
      provenance: json['provenance']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      if (doctorId != null) 'doctorId': doctorId,
      if (doctorName != null) 'doctorName': doctorName,
      if (clinicName != null) 'clinicName': clinicName,
      if (prescriptionDate != null) 'prescriptionDate': prescriptionDate?.toIso8601String(),
      'medicines': medicines.map((m) => m.toJson()).toList(),
      if (duration != null) 'duration': duration,
      if (status != null) 'status': status,
      if (provenance != null) 'provenance': provenance,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class LabReportRecord {
  final String id;
  final String userId;
  final String testName;
  final String? testCode;
  final String? laboratory;
  final String? laboratoryId;
  final String? orderingProvider;
  final String? providerId;
  final DateTime? orderDate;
  final DateTime? sampleCollectionDate;
  final DateTime? processingDate;
  final DateTime? reportAvailableDate;
  final DateTime? date;
  final String? status;
  final String? reportUrl;
  final String? summary;
  final String? provenance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LabReportRecord({
    required this.id,
    required this.userId,
    required this.testName,
    this.testCode,
    this.laboratory,
    this.laboratoryId,
    this.orderingProvider,
    this.providerId,
    this.orderDate,
    this.sampleCollectionDate,
    this.processingDate,
    this.reportAvailableDate,
    this.date,
    this.status,
    this.reportUrl,
    this.summary,
    this.provenance,
    this.createdAt,
    this.updatedAt,
  });

  factory LabReportRecord.fromJson(Map<String, dynamic> json, String id) {
    return LabReportRecord(
      id: id,
      userId: json['userId'] ?? json['patientId'] ?? '',
      testName: json['testName'] ?? 'Laboratory Test',
      testCode: json['testCode']?.toString(),
      laboratory: json['laboratory'] ?? json['laboratoryName'] ?? json['facility'],
      laboratoryId: json['laboratoryId']?.toString(),
      orderingProvider: json['orderingProvider'] ?? json['doctorName'] ?? json['prescribedBy'],
      providerId: json['providerId'] ?? json['doctorId'],
      orderDate: json['orderDate'] != null
          ? DateTime.tryParse(json['orderDate'].toString())
          : (json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null),
      sampleCollectionDate: json['sampleCollectionDate'] != null
          ? DateTime.tryParse(json['sampleCollectionDate'].toString())
          : null,
      processingDate: json['processingDate'] != null
          ? DateTime.tryParse(json['processingDate'].toString())
          : null,
      reportAvailableDate: json['reportAvailableDate'] != null
          ? DateTime.tryParse(json['reportAvailableDate'].toString())
          : null,
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      status: json['status']?.toString(),
      reportUrl: json['reportUrl'] ?? json['documentUrl'] ?? json['reportDocumentReference'],
      summary: json['summary'] ?? json['notes'],
      provenance: json['provenance']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'testName': testName,
      if (testCode != null) 'testCode': testCode,
      if (laboratory != null) 'laboratory': laboratory,
      if (laboratoryId != null) 'laboratoryId': laboratoryId,
      if (orderingProvider != null) 'orderingProvider': orderingProvider,
      if (providerId != null) 'providerId': providerId,
      if (orderDate != null) 'orderDate': orderDate?.toIso8601String(),
      if (sampleCollectionDate != null)
        'sampleCollectionDate': sampleCollectionDate?.toIso8601String(),
      if (processingDate != null) 'processingDate': processingDate?.toIso8601String(),
      if (reportAvailableDate != null)
        'reportAvailableDate': reportAvailableDate?.toIso8601String(),
      if (date != null) 'date': date?.toIso8601String(),
      if (status != null) 'status': status,
      if (reportUrl != null) 'reportUrl': reportUrl,
      if (summary != null) 'summary': summary,
      if (provenance != null) 'provenance': provenance,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
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

class PharmacyRecord {
  final String id;
  final String userId;
  final String prescriptionId;
  final String? pharmacyId;
  final String? pharmacyName;
  final String? doctorName;
  final String status;
  final List<PrescriptionMedicine> medicines;
  final DateTime? verificationDate;
  final DateTime? dispensedDate;
  final DateTime? orderDate;
  final String? notes;
  final String? provenance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PharmacyRecord({
    required this.id,
    required this.userId,
    required this.prescriptionId,
    this.pharmacyId,
    this.pharmacyName,
    this.doctorName,
    required this.status,
    required this.medicines,
    this.verificationDate,
    this.dispensedDate,
    this.orderDate,
    this.notes,
    this.provenance,
    this.createdAt,
    this.updatedAt,
  });

  factory PharmacyRecord.fromJson(Map<String, dynamic> json, String id) {
    List<PrescriptionMedicine> parsedMedicines = [];
    if (json['medicines'] != null && json['medicines'] is List) {
      parsedMedicines = (json['medicines'] as List)
          .whereType<Map<String, dynamic>>()
          .map((m) => PrescriptionMedicine.fromJson(m))
          .toList();
    } else if (json['medicineName'] != null) {
      parsedMedicines = [
        PrescriptionMedicine(
          medicineName: json['medicineName'].toString(),
          dosage: json['dosage']?.toString(),
          frequency: json['frequency']?.toString(),
          duration: json['duration']?.toString(),
        )
      ];
    }

    return PharmacyRecord(
      id: id,
      userId: json['userId'] ?? json['patientId'] ?? '',
      prescriptionId: json['prescriptionId'] ?? '',
      pharmacyId: json['pharmacyId']?.toString(),
      pharmacyName: json['pharmacyName'] ?? json['pharmacy']?.toString(),
      doctorName: json['doctorName'] ?? json['prescribedBy']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      medicines: parsedMedicines,
      verificationDate: json['verificationDate'] != null
          ? DateTime.tryParse(json['verificationDate'].toString())
          : null,
      dispensedDate: json['dispensedDate'] != null
          ? DateTime.tryParse(json['dispensedDate'].toString())
          : null,
      orderDate: json['orderDate'] != null
          ? DateTime.tryParse(json['orderDate'].toString())
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null),
      notes: json['notes']?.toString(),
      provenance: json['provenance']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'prescriptionId': prescriptionId,
      if (pharmacyId != null) 'pharmacyId': pharmacyId,
      if (pharmacyName != null) 'pharmacyName': pharmacyName,
      if (doctorName != null) 'doctorName': doctorName,
      'status': status,
      'medicines': medicines.map((m) => m.toJson()).toList(),
      if (verificationDate != null)
        'verificationDate': verificationDate?.toIso8601String(),
      if (dispensedDate != null)
        'dispensedDate': dispensedDate?.toIso8601String(),
      if (orderDate != null) 'orderDate': orderDate?.toIso8601String(),
      if (notes != null) 'notes': notes,
      if (provenance != null) 'provenance': provenance,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
