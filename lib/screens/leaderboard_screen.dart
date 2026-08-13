import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../services/game_store.dart';
import 'duel_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final p = store.player;
    return Scaffold(
      body: ArenaBackground(
        quality: p.quality,
        accent: ArenaPalette.gold,
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: ArenaPalette.gold)),
                  const Expanded(child: GlowText('LEADERBOARD', size: 18, color: ArenaPalette.gold)),
                ],
              ),
              TabBar(
                controller: _tabs,
                indicatorColor: ArenaPalette.cyan,
                labelColor: ArenaPalette.cyan,
                unselectedLabelColor: ArenaPalette.mute,
                isScrollable: true,
                tabs: const [Tab(text: 'GLOBAL'), Tab(text: 'COUNTRY'), Tab(text: 'UNIVERSITY'), Tab(text: 'SEASON'), Tab(text: 'WEEKLY')],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: TextField(
                  decoration: const InputDecoration(hintText: 'Search a rival', prefixIcon: Icon(Icons.search, color: ArenaPalette.mute)),
                  onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _query = p.username.toLowerCase()),
                  child: const Text('FIND ME', style: TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _list(store.leaderboard()),
                    _list(store.leaderboard(country: p.country)),
                    _unis(store),
                    _list(store.seasonBoard()),
                    _list(store.weeklyBoard()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(List entries) {
    final filtered = _query.isEmpty
        ? entries
        : entries.where((e) => e.name.toString().toLowerCase().contains(_query)).toList();
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final e = filtered[i];
        final rank = entries.indexOf(e) + 1;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: e.isPlayer ? ArenaPalette.cyan.withValues(alpha: 0.12) : ArenaPalette.panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: e.isPlayer ? ArenaPalette.cyan : Colors.white10),
          ),
          child: Row(
            children: [
              SizedBox(width: 36, child: Text('#$rank', style: TextStyle(color: rank <= 3 ? ArenaPalette.gold : ArenaPalette.mute, fontWeight: FontWeight.w800))),
              Expanded(child: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700))),
              Text(e.country, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ArenaPalette.mute, fontSize: 11)),
              const SizedBox(width: 8),
              Text('${e.score}', style: const TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w800)),
              if (!e.isPlayer)
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DuelScreen(rival: e.name.toString()))),
                  child: const Text('DUEL', style: TextStyle(color: ArenaPalette.magenta, fontWeight: FontWeight.w900, fontSize: 11)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _unis(GameStore store) {
    final map = store.universityTotals().entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: map.length,
      itemBuilder: (_, i) {
        final e = map[i];
        final mine = e.key == store.player.university;
        return ListTile(
          tileColor: mine ? ArenaPalette.cyan.withValues(alpha: 0.12) : ArenaPalette.panel,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          leading: Text('#${i + 1}', style: const TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w800)),
          title: Text(e.key),
          trailing: Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w800)),
        );
      },
    );
  }
}
