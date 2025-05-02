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

  @override
  void initState() {
    super.initState();
    _loadSheetMusic();
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

    // Use PhotoViewGallery for swipeable, zoomable images
    return PhotoViewGallery.builder(
      itemCount: _imageData.length,
      builder: (context, index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: MemoryImage(_imageData[index]),
          initialScale: PhotoViewComputedScale.contained * 0.95, // Start slightly zoomed out
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 4.0, // Allow zooming in significantly
          heroAttributes: PhotoViewHeroAttributes(tag: "sheet_music_$index"),
        );
      },
      scrollPhysics: const BouncingScrollPhysics(),
      backgroundDecoration: BoxDecoration(
        color: Theme.of(context).canvasColor, // Use theme background
      ),
      pageController: PageController(initialPage: _currentPage), // Control current page
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      loadingBuilder: (context, event) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} 