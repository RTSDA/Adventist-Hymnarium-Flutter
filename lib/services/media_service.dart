import 'package:flutter/foundation.dart';
import 'package:adventist_hymnarium/database/database.dart'; // Correct: Import for Hymn
import 'package:adventist_hymnarium/models/sheet_music_info.dart';
import 'package:intl/intl.dart'; // For number formatting

class MediaService {
  // Base URL found in the reference iOS project
  static const String _baseURL = "https://adventisthymnarium.rockvilletollandsda.church";

  // Formatter to ensure hymn numbers are 3 digits with leading zeros (e.g., 001, 012, 123)
  final NumberFormat _hymnNumberFormat = NumberFormat("000");

  /// Constructs the URL for the audio file (.mp3) of a given hymn,
  /// based on the logic observed in the reference iOS app.
  Uri getAudioUrl(Hymn hymn) {
    final formattedNumber = _hymnNumberFormat.format(hymn.number);
    String path;
    final type = hymn.hymnalType; // Get potentially null type

    if (type == null) {
        print('Error: Hymn #${hymn.number} has null hymnalType. Cannot determine audio URL.');
        // Return a dummy/error URI or throw?
        return Uri.parse('error:null_hymnal_type'); 
    }

    if (type == 'en-oldVersion') {
      path = '/audio/1941/$formattedNumber.mp3';
    } else if (type == 'en-newVersion') {
      path = '/audio/1985/en_$formattedNumber.mp3';
    } else {
      print('Warning: Unexpected hymnalType for audio URL: $type');
      path = '/audio/1985/en_$formattedNumber.mp3'; 
    }
    
    return Uri.parse(_baseURL + path);
  }

  /// Returns information needed to construct URLs for sheet music images (.png),
  /// or null if sheet music is not available for the given hymn's type.
  /// Based on Swift code: loads multiple PNGs like PianoSheet_NewHymnal_en_001.png, ..._1.png, ..._2.png
  SheetMusicInfo? getSheetMusicInfo(Hymn hymn) {
    final formattedNumber = _hymnNumberFormat.format(hymn.number);
    final type = hymn.hymnalType; // Get potentially null type
    
    if (type == 'en-newVersion') { // Only proceed if type is known and matches
      final String baseDirectoryUrl = '$_baseURL/sheet-music/1985/';
      final String filePrefix = 'PianoSheet_NewHymnal_en_$formattedNumber';
      return SheetMusicInfo(baseDirectoryUrl: baseDirectoryUrl, filePrefix: filePrefix);
    } else {
      // No sheet music available for old version or unknown/null types
      if (type == null) print('Info: Hymn #${hymn.number} has null hymnalType. Cannot determine sheet music.');
      return null; 
    }
  }

  // TODO: Add methods for actually fetching/downloading audio/images using http/dio
  // TODO: Implement caching logic based on cacheKey pattern: "1941_{number}.mp3" or "1985_{number}.mp3" for audio
  //       and "{number}.png", "{number}_1.png", etc. for sheet music images.
} 