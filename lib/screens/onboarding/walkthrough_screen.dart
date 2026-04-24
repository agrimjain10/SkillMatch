import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {'title': 'DISCOVER TALENT', 'desc': 'FIND THE PERFECT COLLABORATORS FOR YOUR NEXT PROJECT.'},
    {'title': 'SKILL MATCHING', 'desc': 'OUR ALGORITHM CONNECTS YOU BASED ON REAL EXPERTISE.'},
    {'title': 'SECURE CHAT', 'desc': 'COMMUNICATE SAFELY WITHIN OUR PROTECTED ECOSYSTEM.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridBackground(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flash_on, size: 80, color: AppTheme.primaryContainer),
                        const SizedBox(height: 48),
                        Text(_pages[i]['title']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 24),
                        Text(_pages[i]['desc']!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => context.go('/login'), child: const Text('SKIP')),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                      } else {
                        context.go('/login');
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'GET STARTED' : 'NEXT'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
