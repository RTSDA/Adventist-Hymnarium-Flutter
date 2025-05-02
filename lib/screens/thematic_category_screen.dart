import 'package:flutter/material.dart';
import 'package:adventist_hymnarium/database/database.dart'; // Import the ThematicList model
import 'package:adventist_hymnarium/screens/hymn_detail_screen.dart'; // Import hymn detail screen

class ThematicCategoryScreen extends StatefulWidget {
  final ThematicList category;

  const ThematicCategoryScreen({super.key, required this.category});

  @override
  State<ThematicCategoryScreen> createState() => _ThematicCategoryScreenState();
}

class _ThematicCategoryScreenState extends State<ThematicCategoryScreen> {
  final AppDatabase _db = AppDatabase.instance; // Get DB instance
  List<Hymn> _hymns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHymns();
  }

  Future<void> _loadHymns() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final hymns = await _db.getHymnsByCategory(widget.category);
      if (!mounted) return;
      setState(() {
        _hymns = hymns;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading hymns for category ${widget.category.thematic}: $e");
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
        
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.thematic),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hymns.isEmpty
              ? const Center(child: Text('No hymns found for this category.'))
              : ListView.separated(
                  itemCount: _hymns.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
                  itemBuilder: (context, index) {
                    final hymn = _hymns[index];
                    return ListTile(
                      title: Row(
                        children: [
                          SizedBox(
                            width: 60.0,
                            child: Text(
                              '#${hymn.number}',
                              style: TextStyle(
                                color: numberColor,
                                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              hymn.title ?? 'Untitled Hymn',
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HymnDetailScreen(hymn: hymn),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
} 