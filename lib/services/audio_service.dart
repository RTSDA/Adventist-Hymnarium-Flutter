import 'dart:async'; // For StreamSubscription & Timer
import 'dart:io'; // For File operations
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:path_provider/path_provider.dart'; // To get cache directory
import 'package:path/path.dart' as p; // For joining paths
import 'package:http/http.dart' as http; // For downloading
import 'package:adventist_hymnarium/locator.dart'; // To get MediaService
import 'package:adventist_hymnarium/services/media_service.dart'; // To get URLs
import 'package:adventist_hymnarium/database/database.dart'; // Import for Hymn type

class AudioService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final MediaService _mediaService = locator<MediaService>(); // Get MediaService

  Hymn? _currentlyPlayingHymn;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false; // Add loading state
  String? _loadingError;

  // Cache directory name
  static const String _audioCacheDir = "audio_cache";

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  // Cache path future
  Future<String>? _cachePathFuture;

  AudioService() {
    _cachePathFuture = _getCacheDirectory(); // Initialize cache path
    // Listen to player state changes
    _playerStateChangeSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      _playerState = state;
      
      // Reset position internally when playback naturally finishes or is stopped
      if (state == PlayerState.stopped || state == PlayerState.completed) {
          _position = Duration.zero;
      }

      print("AudioPlayer State: $state");
      notifyListeners(); 
    });

    // Listen to duration changes
    _durationSubscription = _audioPlayer.onDurationChanged.listen((newDuration) {
        print("AudioPlayer Duration Changed: $newDuration");
        if (newDuration > Duration.zero) {
          _duration = newDuration;
          notifyListeners();
        } 
    });

    // Listen to position changes
    _positionSubscription = _audioPlayer.onPositionChanged.listen((newPosition) {
        print("AudioPlayer Position Changed: $newPosition"); 
        // Only notify if the position has changed meaningfully
        if ((newPosition - _position).abs() > const Duration(milliseconds: 20)) { 
          _position = newPosition;
          notifyListeners();
        }
    });
    
    // Listen for completion
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
        print("AudioPlayer Completed");
        _currentlyPlayingHymn = null; // Clear current hymn on completion
        _position = Duration.zero; // Reset position
        _duration = Duration.zero; // Reset duration
        notifyListeners();
    });
  }

  Hymn? get currentlyPlayingHymn => _currentlyPlayingHymn;
  PlayerState get playerState => _playerState;
  bool get isPlaying => _playerState == PlayerState.playing;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get isLoading => _isLoading; // Expose loading state
  String? get loadingError => _loadingError;

  // Helper to get cache directory path
  Future<String> _getCacheDirectory() async {
    final tempDir = await getTemporaryDirectory(); // Or getApplicationSupportDirectory()
    final cachePath = p.join(tempDir.path, _audioCacheDir);
    final cacheDir = Directory(cachePath);
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
      print("Created audio cache directory: $cachePath");
    }
    return cachePath;
  }

  // Helper to get the expected local path for a hymn
  Future<String> _getLocalPath(Hymn hymn) async {
    final cacheDir = await (_cachePathFuture ??= _getCacheDirectory());
    final type = hymn.hymnalType; // Get potentially null type
    if (type == null) {
       throw Exception("Cannot determine cache key for hymn #${hymn.number} due to null hymnalType");
    }
    // Use cache key logic similar to iOS reference
    final numberString = hymn.number.toString().padLeft(3, '0');
    final cacheKey = type == 'en-oldVersion' 
        ? "1941_$numberString.mp3"
        : "1985_$numberString.mp3";
    return p.join(cacheDir, cacheKey);
  }

  Future<void> play(Uri url, Hymn hymn) async {
    // Reset position/duration for new track
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners(); // Update UI immediately

    if (isPlaying || _playerState == PlayerState.paused) {
      await stop(); // Stop previous before starting new
    }
    
    print("Playing: ${url.toString()} for Hymn #${hymn.number}");
    try {
      // Set release mode to stop - important for resource management
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.play(UrlSource(url.toString()));
      _currentlyPlayingHymn = hymn;
      // Duration might take a moment to load, listener will update it
      notifyListeners(); 
    } catch (e) {
      print("Error playing audio: $e");
      _currentlyPlayingHymn = null;
      _playerState = PlayerState.stopped; 
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    // State change handled by listener
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
    // State change handled by listener
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    // State changes handled by listeners (state -> stopped, position -> 0)
    _currentlyPlayingHymn = null;
    _duration = Duration.zero;
    _position = Duration.zero;
    _isLoading = false; // Ensure loading stops
    _loadingError = null;
    notifyListeners(); 
  }
  
  // Seek to a specific position
  Future<void> seek(Duration position) async {
      await _audioPlayer.seek(position);
      // Position state updated by listener
  }

  Future<void> togglePlayPause(Hymn hymn) async {
      // Use number for comparison as it's the primary key in Drift table
      if (isPlaying && _currentlyPlayingHymn?.number == hymn.number) {
          await pause();
      } else if (_playerState == PlayerState.paused && _currentlyPlayingHymn?.number == hymn.number) {
          await resume();
      } else {
          // If different hymn or stopped/completed, start playing new one (downloads if needed)
          await _playHymn(hymn);
      }
  }

  // Refactored Play Logic (called by toggle)
  Future<void> _playHymn(Hymn hymn) async {
     // Stop current playback before starting new actions
    if (isPlaying || _playerState == PlayerState.paused) {
      await stop();
    }
    
    _currentlyPlayingHymn = hymn; // Set current hymn immediately
    _isLoading = true;
    _loadingError = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();

    try {
      final localPath = await _getLocalPath(hymn);
      final localFile = File(localPath);
      String sourcePath;

      if (await localFile.exists()) {
        print("Playing from cache: $localPath");
        sourcePath = localPath;
      } else {
        print("Downloading to cache: $localPath");
        final remoteUrl = _mediaService.getAudioUrl(hymn);
        
        try {
           // Use http to download
           final response = await http.get(remoteUrl).timeout(const Duration(seconds: 30)); // Add timeout
           if (response.statusCode == 200) {
             await localFile.writeAsBytes(response.bodyBytes);
             print("Download complete.");
             sourcePath = localPath;
           } else {
             throw Exception('Download failed: Status code ${response.statusCode}');
           }
        } catch (e) {
          print("Download error: $e");
          // Attempt to delete potentially corrupted partial file
          if (await localFile.exists()) { await localFile.delete(); }
          throw Exception('Failed to download audio: $e');
        }
      }
      
      // Play from the determined source path (local cache)
      print("Setting source: $sourcePath");
      await _audioPlayer.setSourceDeviceFile(sourcePath); // Use DeviceFileSource
      print("Source set successfully.");

      // --- Added: Explicitly fetch duration after setting source ---
      try {
        final fetchedDuration = await _audioPlayer.getDuration();
        if (fetchedDuration != null && fetchedDuration > Duration.zero) {
          _duration = fetchedDuration;
          print("Explicitly fetched duration: $_duration");
          notifyListeners(); // Update UI with fetched duration
        } else {
            print("getDuration() returned null or zero after setting source.");
        }
      } catch (e) {
          print("Error calling getDuration(): $e");
          // Optionally handle this error, maybe fallback or log
      }
      // -------------------------------------------------------------

      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      print("Attempting to resume/play...");
      await _audioPlayer.resume(); // Start playing
      print("Resume called successfully.");
      
    } catch (e) {
        print("Error preparing/playing audio: $e");
        _loadingError = e.toString();
        _currentlyPlayingHymn = null;
        _playerState = PlayerState.stopped;
    } finally {
        _isLoading = false;
        notifyListeners();
    }
  }

  @override
  void dispose() {
    // Cancel all stream subscriptions
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    _audioPlayer.dispose(); 
    super.dispose();
  }
} 