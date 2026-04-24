import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final List<String> _filters = ['DESIGN', 'DEVELOPMENT', 'BLOCKCHAIN', 'AI', 'ROBOTICS'];
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEEP SEARCH', style: TextStyle(letterSpacing: 4)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GridBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'ENTER QUERY...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: const BorderSide(width: 2)),
                ),
              ),
              const SizedBox(height: 32),
              const Text('CATEGORICAL FILTERS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _filters.map((f) {
                  final isSelected = _selected.contains(f);
                  return GestureDetector(
                    onTap: () => setState(() => isSelected ? _selected.remove(f) : _selected.add(f)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: AppTheme.brutalistDecoration(
                        color: isSelected ? AppTheme.primaryContainer : Colors.white,
                      ),
                      child: Text(f, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('SEARCHING ${_selected.isEmpty ? 'ALL CATEGORIES' : _selected.join(', ')}')),
                ),
                child: const Text('EXECUTE SEARCH'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
