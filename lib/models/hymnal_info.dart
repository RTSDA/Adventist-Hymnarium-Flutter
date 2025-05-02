/// Represents information about a specific hymnal version.
class HymnalInfo {
  final String key; // e.g., 'en-newVersion'
  final String name; // e.g., 'New Version (1985)'
  final String shortName; // e.g., '1985'
  final int year; // e.g., 1985
  final String copyright; // Copyright string

  const HymnalInfo({
    required this.key,
    required this.name,
    required this.shortName,
    required this.year,
    required this.copyright,
  });
}

/// Map of available hymnals, keyed by their unique identifier.
const Map<String, HymnalInfo> hymnalMap = {
  'en-newVersion': HymnalInfo(
    key: 'en-newVersion',
    name: 'New Version (1985)',
    shortName: '1985',
    year: 1985,
    copyright: '© 1985 Review and Herald® Publishing Association' // Example copyright
  ),
  'en-oldVersion': HymnalInfo(
    key: 'en-oldVersion',
    name: 'Old Version (1941)',
    shortName: '1941',
    year: 1941,
    copyright: '© 1941 Review and Herald® Publishing Association' // Example copyright
  ),
  // Add other hymnals here if needed
}; 