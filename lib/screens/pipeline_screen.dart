import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../models/models.dart';
import '../services/game_store.dart';

class PipelineScreen extends StatefulWidget {
  const PipelineScreen({super.key});

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  final _prompt = TextEditingController();
  final _why = TextEditingController();
  final _opts = List.generate(4, (_) => TextEditingController());
  int _correct = 0;
  String _category = 'brain';
  String _difficulty = 'medium';
  String? _dupNote;

  @override
  void dispose() {
    _prompt.dispose();
    _why.dispose();
    for (final c in _opts) {
      c.dispose();
    }
    super.dispose();
  }

  void _check(GameStore store) {
    final dup = store.pipelineDuplicateOf(_prompt.text);
    setState(() {
      _dupNote = dup == null ? 'No duplicate in the live bank or draft queue.' : 'Matches existing item: $dup';
    });
  }

  Future<void> _save(GameStore store) async {
    final draft = QuestionDraft(
      id: 'draft-${DateTime.now().millisecondsSinceEpoch}',
      prompt: _prompt.text,
      options: [for (final c in _opts) c.text],
      correctIndex: _correct,
      explanation: _why.text,
      category: _category,
      difficulty: _difficulty,
    );
    final err = await store.savePipelineDraft(draft);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(err ?? 'Queued as draft. Never auto-published to the live bank.')),
    );
    if (err == null || err.startsWith('Duplicate')) {
      _prompt.clear();
      _why.clear();
      for (final c in _opts) {
        c.clear();
      }
      setState(() => _dupNote = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
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
                  const Expanded(child: GlowText('QUESTION PIPELINE', size: 16)),
                ],
              ),
              const HoloPanel(
                child: Text(
                  'Generate → validate → queue. Drafts stay local. Nothing here publishes into the live question bank automatically. Connect Firebase later for a real review queue.',
                  style: TextStyle(color: ArenaPalette.mute, height: 1.4, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _prompt,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Prompt'),
                onChanged: (_) => _dupNote = null,
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < 4; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _correct = i),
                        icon: Icon(
                          _correct == i ? Icons.check_circle : Icons.circle_outlined,
                          color: _correct == i ? ArenaPalette.lime : ArenaPalette.mute,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _opts[i],
                          decoration: InputDecoration(labelText: 'Option ${i + 1}${i == _correct ? '  (correct)' : ''}'),
                        ),
                      ),
                    ],
                  ),
                ),
              TextField(
                controller: _why,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Did you know? explanation'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final c in const ['brain', 'math', 'tech', 'world', 'science', 'word', 'entertainment'])
                    ChoiceChip(
                      label: Text(c.toUpperCase()),
                      selected: _category == c,
                      selectedColor: ArenaPalette.cyan.withValues(alpha: 0.3),
                      onSelected: (_) => setState(() => _category = c),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final d in const ['easy', 'medium', 'hard'])
                    ChoiceChip(
                      label: Text(d.toUpperCase()),
                      selected: _difficulty == d,
                      selectedColor: ArenaPalette.magenta.withValues(alpha: 0.3),
                      onSelected: (_) => setState(() => _difficulty = d),
                    ),
                ],
              ),
              if (_dupNote != null) ...[
                const SizedBox(height: 8),
                Text(_dupNote!, style: TextStyle(color: _dupNote!.startsWith('No') ? ArenaPalette.lime : ArenaPalette.gold)),
              ],
              const SizedBox(height: 12),
              NeonButton(label: 'CHECK DUPLICATES', color: ArenaPalette.electric, onTap: () => _check(store)),
              const SizedBox(height: 10),
              NeonButton(label: 'QUEUE DRAFT', color: ArenaPalette.gold, onTap: () => _save(store)),
              const SizedBox(height: 18),
              const Text('FLAGGED FROM PLAY', style: TextStyle(letterSpacing: 2, color: ArenaPalette.mute, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (store.flaggedQuestions.isEmpty)
                const Text('No live flags yet. Tap the flag on a rush question to queue it here.', style: TextStyle(color: ArenaPalette.mute))
              else
                for (final q in store.flaggedQuestions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: HoloPanel(
                      accent: ArenaPalette.gold,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q.prompt, style: const TextStyle(fontWeight: FontWeight.w800, height: 1.35)),
                          const SizedBox(height: 4),
                          Text('${q.id}  •  ${q.category.name}  •  ${q.difficulty}', style: const TextStyle(color: ArenaPalette.mute, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 18),
              const Text('QUEUED DRAFTS', style: TextStyle(letterSpacing: 2, color: ArenaPalette.mute, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (store.pipelineDrafts.isEmpty)
                const Text('No drafts yet.', style: TextStyle(color: ArenaPalette.mute))
              else
                for (final d in store.pipelineDrafts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: HoloPanel(
                      accent: d.status == 'flagged_duplicate' ? ArenaPalette.gold : ArenaPalette.cyan,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.prompt, style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(
                            '${d.category} • ${d.difficulty} • ${d.status.replaceAll('_', ' ')}',
                            style: const TextStyle(color: ArenaPalette.mute, fontSize: 12),
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
