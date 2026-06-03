enum ApsCertificateStatus { hasCertificate, applying, needsGuidance }

enum TargetDegree { bsc, msc, mba }

enum AcademicTrack { matricInter, oLevelALevel }

enum OnboardingDocumentType {
  matricCertificate,
  matricMarksheet,
  interCertificate,
  interMarksheet,
  oLevelCertificate,
  oLevelMarksheet,
  aLevelCertificate,
  aLevelMarksheet,
  profilePhoto,
  previousCv,
  recommendationLetterOne,
  recommendationLetterTwo,
}

class OnboardingDocumentRecord {
  const OnboardingDocumentRecord({
    required this.fileName,
    required this.downloadUrl,
    required this.storagePath,
    this.uploadedAtIso,
  });

  final String fileName;
  final String downloadUrl;
  final String storagePath;
  final String? uploadedAtIso;

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'downloadUrl': downloadUrl,
      'storagePath': storagePath,
      'uploadedAtIso': uploadedAtIso,
    };
  }

  static OnboardingDocumentRecord? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    return OnboardingDocumentRecord(
      fileName: (map['fileName'] as String?) ?? '',
      downloadUrl: (map['downloadUrl'] as String?) ?? '',
      storagePath: (map['storagePath'] as String?) ?? '',
      uploadedAtIso: map['uploadedAtIso'] as String?,
    );
  }
}

class OnboardingProfile {
  const OnboardingProfile({
    this.apsStatus,
    this.fullName = '',
    this.nationality = '',
    this.targetDegree,
    this.intakeSemester = '',
    this.countryOfResidence = '',
    this.academicTrack,
    this.documents = const {},
    this.isHydrating = false,
    this.hasLoadedDraft = false,
    this.uploadingDocument,
  });

  final ApsCertificateStatus? apsStatus;
  final String fullName;
  final String nationality;
  final TargetDegree? targetDegree;
  final String intakeSemester;
  final String countryOfResidence;
  final AcademicTrack? academicTrack;
  final Map<OnboardingDocumentType, OnboardingDocumentRecord> documents;
  final bool isHydrating;
  final bool hasLoadedDraft;
  final OnboardingDocumentType? uploadingDocument;

  bool get isStepOneComplete => apsStatus != null;

  bool get isStepTwoComplete =>
      fullName.trim().isNotEmpty &&
      nationality.trim().isNotEmpty &&
      targetDegree != null &&
      intakeSemester.trim().isNotEmpty &&
      countryOfResidence.trim().isNotEmpty;

  bool get isStepThreeComplete {
    if (academicTrack == null) {
      return false;
    }

    final requiredDocuments =
        academicTrack == AcademicTrack.matricInter
            ? const [
              OnboardingDocumentType.matricCertificate,
              OnboardingDocumentType.matricMarksheet,
              OnboardingDocumentType.interCertificate,
              OnboardingDocumentType.interMarksheet,
            ]
            : const [
              OnboardingDocumentType.oLevelCertificate,
              OnboardingDocumentType.oLevelMarksheet,
              OnboardingDocumentType.aLevelCertificate,
              OnboardingDocumentType.aLevelMarksheet,
            ];

    for (final documentType in requiredDocuments) {
      if (!documents.containsKey(documentType)) {
        return false;
      }
    }

    return true;
  }

  OnboardingProfile copyWith({
    ApsCertificateStatus? apsStatus,
    bool clearApsStatus = false,
    String? fullName,
    String? nationality,
    TargetDegree? targetDegree,
    bool clearTargetDegree = false,
    String? intakeSemester,
    String? countryOfResidence,
    AcademicTrack? academicTrack,
    bool clearAcademicTrack = false,
    Map<OnboardingDocumentType, OnboardingDocumentRecord>? documents,
    bool? isHydrating,
    bool? hasLoadedDraft,
    OnboardingDocumentType? uploadingDocument,
    bool clearUploadingDocument = false,
  }) {
    return OnboardingProfile(
      apsStatus: clearApsStatus ? null : (apsStatus ?? this.apsStatus),
      fullName: fullName ?? this.fullName,
      nationality: nationality ?? this.nationality,
      targetDegree:
          clearTargetDegree ? null : (targetDegree ?? this.targetDegree),
      intakeSemester: intakeSemester ?? this.intakeSemester,
      countryOfResidence: countryOfResidence ?? this.countryOfResidence,
      academicTrack:
          clearAcademicTrack ? null : (academicTrack ?? this.academicTrack),
      documents: documents ?? this.documents,
      isHydrating: isHydrating ?? this.isHydrating,
      hasLoadedDraft: hasLoadedDraft ?? this.hasLoadedDraft,
      uploadingDocument:
          clearUploadingDocument
              ? null
              : (uploadingDocument ?? this.uploadingDocument),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'apsStatus': apsStatus?.name,
      'fullName': fullName.trim(),
      'nationality': nationality.trim(),
      'targetDegree': targetDegree?.name,
      'intakeSemester': intakeSemester.trim(),
      'countryOfResidence': countryOfResidence.trim(),
      'academicTrack': academicTrack?.name,
      'documents': {
        for (final entry in documents.entries) entry.key.name: entry.value.toMap(),
      },
    };
  }

  static OnboardingProfile fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return const OnboardingProfile();
    }

    final rawDocuments =
        data['documents'] is Map
            ? Map<String, dynamic>.from(data['documents'] as Map)
            : null;
    final parsedDocuments = <OnboardingDocumentType, OnboardingDocumentRecord>{};

    if (rawDocuments != null) {
      for (final entry in rawDocuments.entries) {
        final documentType = _documentTypeFromName(entry.key);
        final record = OnboardingDocumentRecord.fromMap(
          entry.value is Map
              ? Map<String, dynamic>.from(entry.value as Map)
              : null,
        );
        if (documentType != null && record != null) {
          parsedDocuments[documentType] = record;
        }
      }
    }

    return OnboardingProfile(
      apsStatus: _apsStatusFromName(data['apsStatus'] as String?),
      fullName: (data['fullName'] as String?) ?? '',
      nationality: (data['nationality'] as String?) ?? '',
      targetDegree: _targetDegreeFromName(data['targetDegree'] as String?),
      intakeSemester: (data['intakeSemester'] as String?) ?? '',
      countryOfResidence: (data['countryOfResidence'] as String?) ?? '',
      academicTrack: _academicTrackFromName(data['academicTrack'] as String?),
      documents: parsedDocuments,
      hasLoadedDraft: true,
    );
  }

  static ApsCertificateStatus? _apsStatusFromName(String? value) {
    if (value == null) {
      return null;
    }

    for (final status in ApsCertificateStatus.values) {
      if (status.name == value) {
        return status;
      }
    }

    return null;
  }

  static TargetDegree? _targetDegreeFromName(String? value) {
    if (value == null) {
      return null;
    }

    for (final degree in TargetDegree.values) {
      if (degree.name == value) {
        return degree;
      }
    }

    return null;
  }

  static AcademicTrack? _academicTrackFromName(String? value) {
    if (value == null) {
      return null;
    }

    for (final track in AcademicTrack.values) {
      if (track.name == value) {
        return track;
      }
    }

    return null;
  }

  static OnboardingDocumentType? _documentTypeFromName(String? value) {
    if (value == null) {
      return null;
    }

    for (final type in OnboardingDocumentType.values) {
      if (type.name == value) {
        return type;
      }
    }

    return null;
  }
}
