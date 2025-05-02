import 'package:flutter/material.dart';
import 'package:adventist_hymnarium/database/database.dart'; // Import Drift DB
import 'package:adventist_hymnarium/screens/responsive_reading_detail_screen.dart'; // Import the detail screen

class ResponsiveReadingsList extends StatefulWidget {
  const ResponsiveReadingsList({super.key});

  @override
  State<ResponsiveReadingsList> createState() => _ResponsiveReadingsListState();
}

class _ResponsiveReadingsListState extends State<ResponsiveReadingsList> {
  final AppDatabase _db = AppDatabase.instance; // Get Drift DB instance
  List<ResponsiveReading> _readings = []; // Use Drift's ResponsiveReading
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      // Use Drift query
      final readings = await _db.getAllReadingsSorted();
      
      if (!mounted) return;
      setState(() {
        _readings = readings;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading responsive readings: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final numberColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.lightBlueAccent
        : Theme.of(context).colorScheme.primary;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_readings.isEmpty) {
      return const Center(child: Text('No responsive readings found.'));
    }

    return ListView.separated(
      itemCount: _readings.length,
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
      itemBuilder: (context, index) {
        final reading = _readings[index];
        return ListTile(
          title: Row(
            children: [
              SizedBox(
                width: 60.0, // Consistent width like hymn list
                child: Text(
                  '#${reading.number}',
                  style: TextStyle(
                    color: numberColor,
                    fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Expanded(
                child: Text(
                  reading.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            // Navigate to ResponsiveReadingDetailScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResponsiveReadingDetailScreen(reading: reading),
              ),
            );
          },
        );
      },
    );
  }
} 