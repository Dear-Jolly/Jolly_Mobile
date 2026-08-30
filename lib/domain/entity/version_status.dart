class VersionStatus {
  final String minSupportedVersion;
  final bool forceUpdate;

  const VersionStatus({
    required this.minSupportedVersion,
    required this.forceUpdate,
  });
}
