/// Helper class to hold information needed to construct sheet music image URLs.
class SheetMusicInfo {
  /// The base URL path ending with a slash (e.g., "https://.../sheet-music/1985/").
  final String baseDirectoryUrl;
  
  /// The filename prefix without page number or extension (e.g., "PianoSheet_NewHymnal_en_001").
  final String filePrefix;

  SheetMusicInfo({required this.baseDirectoryUrl, required this.filePrefix});

  /// Constructs the full URL for the main/first image file.
  Uri get mainImageUrl => Uri.parse('$baseDirectoryUrl$filePrefix.png');

  /// Constructs the full URL for a specific numbered page image file.
  Uri getPagedImageUrl(int pageNumber) {
    // Ensure pageNumber is positive, although the Swift code started loop from 1
    if (pageNumber <= 0) {
        throw ArgumentError('Page number must be positive.');
    }
    // Note: Added underscore before page number based on Swift code
    return Uri.parse('$baseDirectoryUrl${filePrefix}_$pageNumber.png'); 
  }
} 