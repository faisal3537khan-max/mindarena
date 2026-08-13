import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../models/models.dart';
import '../services/game_store.dart';
import 'rush_screen.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key, this.items});

  final List<ReviewItem>? items;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final rows = items ?? store.lastReview;
    return Scaffold(
      body: ArenaBackground(
        quality: store.player.quality,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: ArenaPalette.cyan)),
                  const Expanded(child: GlowText('ANSWER REVIEW', size: 16)),
                ],
              ),
              if (rows.isEmpty)
                const HoloPanel(child: Text('No questions to review from the last run.', style: TextStyle(color: ArenaPalette.mute)))
              else
                for (final r in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: HoloPanel(
                      accent: r.correct ? ArenaPalette.lime : ArenaPalette.danger,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.prompt, style: const TextStyle(fontWeight: FontWeight.w800, height: 1.35)),
                          const SizedBox(height: 8),
                          Text('You: ${r.picked}', style: TextStyle(color: r.correct ? ArenaPalette.lime : ArenaPalette.danger)),
                          if (!r.correct) Text('Answer: ${r.answer}', style: const TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text(r.why, style: const TextStyle(color: ArenaPalette.mute, height: 1.35, fontSize: 13)),
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

class NotebookScreen extends StatefulWidget {
  const NotebookScreen({super.key});

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final rows = store.player.notebook.where((e) => _q.isEmpty || e.prompt.toLowerCase().contains(_q) || e.answer.toLowerCase().contains(_q)).toList();
    return Scaffold(
      body: ArenaBackground(
        quality: store.player.quality,
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: ArenaPalette.cyan)),
                  const Expanded(child: GlowText('MISS NOTEBOOK', size: 16)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  decoration: const InputDecoration(hintText: 'Search misses', prefixIcon: Icon(Icons.search, color: ArenaPalette.mute)),
                  onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? const Center(child: Text('No misses stored yet.', style: TextStyle(color: ArenaPalette.mute)))
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          NeonButton(
                            label: 'DRILL IN A PRACTICE RUSH',
                            color: ArenaPalette.cyan,
                            icon: Icons.fitness_center,
                            onTap: () {
                              final drill = store.notebookDrill();
                              if (drill.length < 4) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Need 4 matching bank questions. Keep playing — misses stack here.')),
                                );
                                return;
                              }
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RushScreen(mode: 'practice', title: 'MISS DRILL', seed: drill),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          NeonButton(
                            label: 'CLEAR NOTEBOOK',
                            color: ArenaPalette.danger,
                            icon: Icons.delete_outline,
                            onTap: () => store.clearNotebook(),
                          ),
                          const SizedBox(height: 16),
                          for (final r in rows)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: HoloPanel(
                                accent: ArenaPalette.danger,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.prompt, style: const TextStyle(fontWeight: FontWeight.w800, height: 1.35)),
                                    const SizedBox(height: 8),
                                    Text('You: ${r.picked}', style: const TextStyle(color: ArenaPalette.danger)),
                                    Text('Answer: ${r.answer}', style: const TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 6),
                                    Text(r.why, style: const TextStyle(color: ArenaPalette.mute, height: 1.35, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
