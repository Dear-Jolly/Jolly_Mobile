import '../../../domain/entity/version_status.dart';

class VersionDto {
  final String minSupportedVersion;
  final bool forceUpdate;

  const VersionDto({
    required this.minSupportedVersion,
    required this.forceUpdate,
  });

  factory VersionDto.fromJson(Map<String, dynamic> json) {
    return VersionDto(
      minSupportedVersion: json['minSupportedVersion'] as String? ?? '',
      forceUpdate: json['forceUpdate'] as bool? ?? false,
    );
  }

  VersionStatus toEntity() {
    return VersionStatus(
      minSupportedVersion: minSupportedVersion,
      forceUpdate: forceUpdate,
    );
  }
}
