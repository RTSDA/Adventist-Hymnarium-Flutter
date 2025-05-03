import 'dart:io'; // Import for Platform check
import 'package:flutter/foundation.dart' show kIsWeb; // For platform detection
import 'dart:typed_data';
import 'package:adventist_hymnarium/database/database.dart';
import 'package:adventist_hymnarium/locator.dart';
import 'package:adventist_hymnarium/models/sheet_music_info.dart';
import 'package:adventist_hymnarium/services/media_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class SheetMusicScreen extends StatefulWidget {
  final Hymn hymn;
  const SheetMusicScreen({super.key, required this.hymn});

  @override
  State<SheetMusicScreen> createState() => _SheetMusicScreenState();
}

class _SheetMusicScreenState extends State<SheetMusicScreen> {
  final MediaService _mediaService = locator<MediaService>();
  
  // State to hold fetched image data
  List<Uint8List> _imageData = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 0;
  late PageController _pageController;
  late PhotoViewController _photoViewController;

  // Define reasonable absolute min/max scale bounds
  static const double _minScale = 0.5;
  static const double _maxScale = 5.0;

  // Determine if we are on a desktop platform
  bool get _isDesktop => !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _photoViewController = PhotoViewController();
    _loadSheetMusic();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _photoViewController.dispose();
    super.dispose();
  }

  Future<void> _loadSheetMusic() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _imageData = [];
    });

    final sheetInfo = _mediaService.getSheetMusicInfo(widget.hymn);
    if (sheetInfo == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Sheet music not available for this hymnal.';
      });
      return;
    }

    List<Uint8List> loadedImages = [];
    try {
      // Try loading the main image first (without _pageNumber)
      try {
        final response = await http.get(sheetInfo.mainImageUrl);
        if (response.statusCode == 200) {
          loadedImages.add(response.bodyBytes);
          print('Loaded main sheet music image.');
        } else {
           print('Main sheet music image not found (Status: ${response.statusCode}).');
        }
      } catch (e) {
         print('Error loading main sheet music image: $e');
      }

      // Then try loading subsequent pages (_1, _2, etc.)
      int pageNumber = 1;
      int consecutiveFailures = 0;
      while (consecutiveFailures < 2) { // Stop after 2 failures like iOS app
        try {
          final pageUrl = sheetInfo.getPagedImageUrl(pageNumber);
          print('Attempting to load page: ${pageUrl.toString()}');
          final response = await http.get(pageUrl).timeout(const Duration(seconds: 10)); // Add timeout

          if (response.statusCode == 200) {
            loadedImages.add(response.bodyBytes);
            print('Loaded sheet music page $pageNumber.');
            consecutiveFailures = 0; // Reset on success
          } else {
            print('Sheet music page $pageNumber not found (Status: ${response.statusCode}).');
            consecutiveFailures++;
          }
        } catch (e) {
          print('Error loading sheet music page $pageNumber: $e');
          consecutiveFailures++;
        }
        pageNumber++;
      }
      
      if (loadedImages.isEmpty && _errorMessage == null) {
         // If main image and all pages failed, set error
         _errorMessage = 'Could not load any sheet music pages.';
      }

    } catch (e) {
      // Catch any broader errors during the process
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
    }

    if (mounted) { // Check if widget is still mounted before calling setState
        setState(() {
            _imageData = loadedImages;
            _isLoading = false;
        });
    }
  }

  void _goToPage(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sheet Music: #${widget.hymn.number}'),
        // Show page number in AppBar
        actions: _imageData.isNotEmpty ? [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(child: Text('Page ${_currentPage + 1} of ${_imageData.length}')),
          )
        ] : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }
    if (_imageData.isEmpty) {
      // Should be caught by errorMessage, but as a fallback
      return const Center(child: Text('No sheet music images found.'));
    }

    bool canGoBack = _currentPage > 0;
    bool canGoForward = _currentPage < _imageData.length - 1;

    // Use PhotoViewGallery for swipeable, zoomable images
    return Stack(
      children: [
        PhotoViewGallery.builder(
          itemCount: _imageData.length,
          builder: (context, index) {
            // Wrap MemoryImage in Image.memory and set filterQuality
            final imageWidget = Image.memory(
              _imageData[index],
              filterQuality: FilterQuality.medium, // Or FilterQuality.high
              gaplessPlayback: true, // Prevents flicker during zoom/pan
            );
            
            return PhotoViewGalleryPageOptions.customChild(
              child: imageWidget, // Use the Image widget
              controller: _photoViewController,
              // Keep other existing options like scales and heroAttributes
              initialScale: PhotoViewComputedScale.contained * 0.95, 
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 4.0, 
              heroAttributes: PhotoViewHeroAttributes(tag: "sheet_music_$index"),
            );
          },
          scrollPhysics: const BouncingScrollPhysics(),
          backgroundDecoration: BoxDecoration(
            color: Theme.of(context).canvasColor, // Use theme background
          ),
          pageController: _pageController, // Use the state's controller
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
              _photoViewController.scale = null;
            });
          },
          loadingBuilder: (context, event) => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        // --- Navigation Buttons ---
        // Conditionally build buttons only if there's more than one page
        if (_imageData.length > 1) ...[
          // Left Button
          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4), // Semi-transparent background
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new), // Use _new variant for potentially better centering
                  color: Colors.white, // White icon for contrast
                  iconSize: _isDesktop ? 30 : 24, // Adjusted size for background
                  tooltip: 'Previous Page',
                  onPressed: canGoBack ? () => _goToPage(_currentPage - 1) : null,
                ),
              ),
            ),
          ),
          // Right Button
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios), 
                  color: Colors.white,
                  iconSize: _isDesktop ? 30 : 24, // Adjusted size for background
                  tooltip: 'Next Page',
                  onPressed: canGoForward ? () => _goToPage(_currentPage + 1) : null,
                ),
              ),
            ),
          ),
        ],
        // --- End Navigation Buttons ---

        // --- Zoom Buttons ---
        Positioned(
          bottom: 20,
          right: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                mini: true,
                heroTag: 'zoom_in_button', // Unique heroTag
                tooltip: 'Zoom In',
                onPressed: () {
                  // Use ?.toDouble() for safe casting and ?? for default
                  double currentScale = (_photoViewController.scale?.toDouble() ?? 1.0);
                  double newScale = currentScale * 1.2; // Increase scale by 20%
                  // Clamp using defined constants and cast result to double
                  _photoViewController.scale = newScale.clamp(_minScale, _maxScale).toDouble();
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: true,
                heroTag: 'zoom_out_button', // Unique heroTag
                tooltip: 'Zoom Out',
                onPressed: () {
                   // Use ?.toDouble() for safe casting and ?? for default
                  double currentScale = (_photoViewController.scale?.toDouble() ?? 1.0);
                  double newScale = currentScale / 1.2; // Decrease scale by 20% (approx)
                  // Clamp using defined constants and cast result to double
                   _photoViewController.scale = newScale.clamp(_minScale, _maxScale).toDouble();
                },
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
        // --- End Zoom Buttons ---
      ],
    );
  }
} 