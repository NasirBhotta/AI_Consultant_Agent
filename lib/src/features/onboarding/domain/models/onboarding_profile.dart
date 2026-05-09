enum ApsCertificateStatus { hasCertificate, applying, needsGuidance }

enum TargetDegree { bsc, msc, mba }

class OnboardingProfile {
  const OnboardingProfile({
    this.apsStatus,
    this.fullName = '',
    this.nationality = '',
    this.targetDegree,
    this.intakeSemester = '',
    this.countryOfResidence = '',
    this.isHydrating = false,
    this.hasLoadedDraft = false,
  });

  final ApsCertificateStatus? apsStatus;
  final String fullName;
  final String nationality;
  final TargetDegree? targetDegree;
  final String intakeSemester;
  final String countryOfResidence;
  final bool isHydrating;
  final bool hasLoadedDraft;

  bool get isStepOneComplete => apsStatus != null;

  bool get isStepTwoComplete =>
      fullName.trim().isNotEmpty &&
      nationality.trim().isNotEmpty &&
      targetDegree != null &&
      intakeSemester.trim().isNotEmpty &&
      countryOfResidence.trim().isNotEmpty;

  OnboardingProfile copyWith({
    ApsCertificateStatus? apsStatus,
    bool clearApsStatus = false,
    String? fullName,
    String? nationality,
    TargetDegree? targetDegree,
    bool clearTargetDegree = false,
    String? intakeSemester,
    String? countryOfResidence,
    bool? isHydrating,
    bool? hasLoadedDraft,
  }) {
    return OnboardingProfile(
      apsStatus: clearApsStatus ? null : (apsStatus ?? this.apsStatus),
      fullName: fullName ?? this.fullName,
      nationality: nationality ?? this.nationality,
      targetDegree:
          clearTargetDegree ? null : (targetDegree ?? this.targetDegree),
      intakeSemester: intakeSemester ?? this.intakeSemester,
      countryOfResidence: countryOfResidence ?? this.countryOfResidence,
      isHydrating: isHydrating ?? this.isHydrating,
      hasLoadedDraft: hasLoadedDraft ?? this.hasLoadedDraft,
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
    };
  }

  static OnboardingProfile fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return const OnboardingProfile();
    }

    return OnboardingProfile(
      apsStatus: _apsStatusFromName(data['apsStatus'] as String?),
      fullName: (data['fullName'] as String?) ?? '',
      nationality: (data['nationality'] as String?) ?? '',
      targetDegree: _targetDegreeFromName(data['targetDegree'] as String?),
      intakeSemester: (data['intakeSemester'] as String?) ?? '',
      countryOfResidence: (data['countryOfResidence'] as String?) ?? '',
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
}
