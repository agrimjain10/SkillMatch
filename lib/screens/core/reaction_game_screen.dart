import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/gamification_provider.dart';
import '../../theme/app_theme.dart';

class ReactionGameScreen extends ConsumerStatefulWidget {
  const ReactionGameScreen({super.key});

  @override
  ConsumerState<ReactionGameScreen> createState() => _ReactionGameScreenState();
}

class _ReactionGameScreenState extends ConsumerState<ReactionGameScreen> {
  final _random = Random();
  Timer? _timer;
  int _target = 0;
  int _score = 0;
  int _seconds = 15;
  bool _running = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    setState(() {
      _running = true;
      _score = 0;
      _seconds = 15;
      _target = _random.nextInt(9);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_seconds <= 1) {
        _timer?.cancel();
        setState(() => _running = false);
        await ref
            .read(gamificationServiceProvider)
            .addPoints(50 + (_score * 5));
        await ref
            .read(gamificationServiceProvider)
            .awardBadge(
              'REACTION GRID GAME',
              'Scored $_score in the reaction grid.',
              60,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('GAME COMPLETE: $_score HITS + BADGE')),
          );
        }
      } else {
        setState(() => _seconds -= 1);
      }
    });
  }

  void _tapCell(int index) {
    if (!_running) return;
    if (index == _target) {
      setState(() {
        _score += 1;
        _target = _random.nextInt(9);
      });
    } else {
      setState(() => _score = max(0, _score - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REACTION GRID', style: TextStyle(letterSpacing: 4)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridBackground(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.brutalistDecoration(
                color: AppTheme.tertiaryContainer,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SCORE $_score',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    '$_seconds SEC',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                final active = _running && index == _target;
                return InkWell(
                  onTap: () => _tapCell(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 90),
                    decoration: AppTheme.brutalistDecoration(
                      color: active ? AppTheme.primaryContainer : Colors.white,
                      radius: 8,
                    ),
                    child: Icon(
                      active ? Icons.bolt : Icons.grid_view,
                      size: 34,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _running ? null : _start,
              child: Text(_running ? 'RUNNING' : 'START GAME'),
            ),
          ],
        ),
      ),
    );
  }
}
