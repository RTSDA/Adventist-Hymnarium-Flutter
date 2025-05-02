import 'dart:async';
import 'package:adventist_hymnarium/database/database.dart';
import 'package:adventist_hymnarium/screens/hymn_detail_screen.dart';
import 'package:adventist_hymnarium/screens/responsive_reading_detail_screen.dart'; // Import reading detail screen
import 'package:adventist_hymnarium/screens/search_screen.dart'; // Import SearchScreen
import 'package:adventist_hymnarium/screens/history_screen.dart'; // Import HistoryScreen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:adventist_hymnarium/locator.dart';
import 'package:adventist_hymnarium/services/settings_service.dart'; // Import SettingsService
import 'package:adventist_hymnarium/services/hymnal_service.dart'; // Import HymnalService

// --- Placeholder Detail Screens --- 
// TODO: Move these to their own files later
// class HymnDetailScreen extends StatelessWidget { ... } // REMOVED

class ResponsiveReadingScreen extends StatelessWidget {
  final ResponsiveReading reading;
  const ResponsiveReadingScreen({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(reading.title)),
      body: Center(child: Text('Details for Reading ${reading.number} - Coming Soon!')),
    );
  }
}
// --- End Placeholder Detail Screens ---

class NumberPadScreen extends StatefulWidget {
  const NumberPadScreen({Key? key}) : super(key: key);

  @override
  _NumberPadScreenState createState() => _NumberPadScreenState();
}

class _NumberPadScreenState extends State<NumberPadScreen> {
  String _enteredNumber = '';
  bool _isLoading = false; 
  String? _errorMessage;

  final SettingsService _settingsService = locator<SettingsService>(); // Get SettingsService instance

  @override
  void dispose() {
    super.dispose();
  }

  void _onNumberPressed(String number) {
    setState(() {
      _enteredNumber += number;
      _errorMessage = null; // Clear error on new input
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (_enteredNumber.isNotEmpty) {
        _enteredNumber = _enteredNumber.substring(0, _enteredNumber.length - 1);
      }
      _errorMessage = null; // Clear error on delete
    });
  }

  Future<void> _searchNumber() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final number = int.tryParse(_enteredNumber);
    if (number == null || number <= 0) {
      setState(() {
         _isLoading = false;
         _errorMessage = "Invalid number"; 
      });
      return;
    }
    
    final currentHymnalType = _settingsService.selectedHymnalType;
    final bool isOldVersion = currentHymnalType == 'en-oldVersion';

    final HymnalService hymnalService = locator<HymnalService>();

    try {
      // 1. Check for Reading *only* if not Old Version
      ResponsiveReading? reading;
      if (!isOldVersion) {
          reading = await hymnalService.getReading(number);
      }
      
      if (reading != null) {
        // Reading found (and not old version)
        if (!mounted) return;
        final enteredNumBeforeNav = _enteredNumber; // Store before clearing
        _enteredNumber = ''; // Clear on success
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResponsiveReadingDetailScreen(reading: reading!),
          ),
        );
        // If user comes back and number hasn't changed, clear message
        if (mounted && _enteredNumber == enteredNumBeforeNav) {
          setState(() => _errorMessage = null);
        }
      } else {
        // 2. Check for Hymn (always check this)
        final Hymn? hymn = await hymnalService.getHymn(number, currentHymnalType);

        if (hymn != null) {
           // Hymn found
           if (!mounted) return;
           final enteredNumBeforeNav = _enteredNumber; // Store before clearing
           _enteredNumber = ''; // Clear on success
           await Navigator.push(
             context, 
             MaterialPageRoute(
               builder: (context) => HymnDetailScreen(hymn: hymn),
             ),
           );
            // If user comes back and number hasn't changed, clear message
           if (mounted && _enteredNumber == enteredNumBeforeNav) {
             setState(() => _errorMessage = null);
           }
        } else {
          // 3. If neither found, show error (adjust message based on version)
          if (!mounted) return;
          setState(() {
             if (isOldVersion) {
                _errorMessage = "Hymn #$number not found in this version.";
             } else {
                _errorMessage = "Hymn/Reading #$number not found."; // Keep generic for new version
             }
          });
        }
      }

    } catch (e) {
       print("Error searching for #$number: $e");
       if (mounted) {
         setState(() {
           _errorMessage = "Error during search: $e"; // Show error details
         });
       }
    } finally {
       if (mounted) {
         setState(() {
            _isLoading = false; 
         });
       }
    }
  }

  Widget _buildNumberButton(String number, {bool isDelete = false, bool isEmpty = false}) {
    return Expanded( // Make button expand horizontally within the row cell
      child: Padding(
        // Reduce padding around buttons
        padding: const EdgeInsets.all(4.0),
        child: AspectRatio(
          aspectRatio: 1.0, // Make it square
          child: isEmpty
              ? const SizedBox.shrink() // Render nothing for the empty slot
              : MaterialButton(
                  onPressed: isDelete ? _onDeletePressed : () => _onNumberPressed(number),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  shape: const CircleBorder(),
                  elevation: 1.0,
                  child: isDelete
                      ? const Icon(Icons.backspace_outlined, size: 28) // Adjust icon size as needed
                      : FittedBox( // Ensure text fits within the button
                          fit: BoxFit.scaleDown,
                          child: Text(
                             number,
                             style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
                          ),
                        ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canGo = _enteredNumber.isNotEmpty && int.tryParse(_enteredNumber)! > 0;
    const double maxPadWidth = 400.0; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Number'), // Static title
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
          child: Column(
            children: <Widget>[
               Center(
                 child: ConstrainedBox( 
                   constraints: const BoxConstraints(maxWidth: maxPadWidth),
                   child: Column(
                      mainAxisSize: MainAxisSize.min, 
                      children: <Widget>[
                        Container(
                          height: 60,
                          alignment: Alignment.center,
                          child: _errorMessage != null
                              ? Text( // Display error message if present
                                  _errorMessage!,
                                  style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.error),
                                  textAlign: TextAlign.center,
                                )
                              : Text( // Display entered number otherwise
                                  _enteredNumber.isEmpty ? " " : _enteredNumber,
                                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                        const SizedBox(height: 15),
                      ],
                   ),
                 ),
               ),
               Center(
                 child: ConstrainedBox( 
                   constraints: const BoxConstraints(maxWidth: maxPadWidth),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Row(
                         children: [_buildNumberButton('1'), _buildNumberButton('2'), _buildNumberButton('3')],
                       ),
                       Row(
                         children: [_buildNumberButton('4'), _buildNumberButton('5'), _buildNumberButton('6')],
                       ),
                       Row(
                         children: [_buildNumberButton('7'), _buildNumberButton('8'), _buildNumberButton('9')],
                       ),
                       Row(
                         children: [_buildNumberButton('', isEmpty: true), _buildNumberButton('0'), _buildNumberButton('', isDelete: true)],
                       ),
                       const SizedBox(height: 10),
                       SizedBox(
                          width: maxPadWidth * 0.6, // Make Go button wider
                          height: 50,
                         child: ElevatedButton(
                           onPressed: canGo && !_isLoading ? _searchNumber : null, // Disable if invalid or loading
                           style: ElevatedButton.styleFrom(
                             backgroundColor: Theme.of(context).colorScheme.primary,
                             foregroundColor: Theme.of(context).colorScheme.onPrimary,
                           ),
                           child: _isLoading 
                               ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                               : const Text('Go', style: TextStyle(fontSize: 20)),
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
} 