import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/game_content.dart';
import '../data/question_bank.dart';
import '../models/models.dart';
import 'audio_service.dart';

class GameStore extends ChangeNotifier {
  GameStore(this.audio);

  final AudioService audio;
  static const _key = 'mindarena_profile_v1';
  static const _accountsKey = 'mindarena_accounts_v1';

  PlayerProfile player = PlayerProfile(id: 'guest', username: 'Challenger');
  bool ready = false;
  String? lastUnlockedAchievement;
  String? pendingReward;
  List<QuestionDraft> pipelineDrafts = [];
  List<ReviewItem> lastReview = [];
  bool streakProtected = false;
  bool firstWinBonus = false;
  String lastSignature = '';

  final _uuid = const Uuid();
  static const _draftsKey = 'mindarena_pipeline_v1';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        player = PlayerProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }
    audio.apply(player);
    try {
      final rawDrafts = prefs.getString(_draftsKey);
      if (rawDrafts != null) {
        pipelineDrafts = [
          for (final e in jsonDecode(rawDrafts) as List)
            if (e is Map) QuestionDraft.fromJson(Map<String, dynamic>.from(e)),
        ];
      }
    } catch (_) {}
    final needRoll = player.lastMissionDate != todayStamp;
    _rollMissions();
    if (needRoll) await _persist();
    ready = true;
    notifyListeners();
    try {
      await audio.init();
      if (player.music) {
        await audio.startMusic();
      }
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(player.toJson()));
    audio.apply(player);
  }

  String _hash(String s) => s.codeUnits.fold(0, (a, b) => (a * 31 + b) & 0x7fffffff).toString();

  Future<Map<String, Map<String, dynamic>>> _accounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_accountsKey);
    if (raw == null) return {};
    return (jsonDecode(raw) as Map).map((k, v) => MapEntry(k.toString(), Map<String, dynamic>.from(v as Map)));
  }

  Future<void> _saveAccounts(Map<String, Map<String, dynamic>> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountsKey, jsonEncode(map));
  }

  Future<void> enterAsGuest() async {
    if (!player.hasEntered) {
      player = PlayerProfile(id: 'guest_${_uuid.v4().substring(0, 8)}', username: 'Challenger')
        ..hasEntered = true;
    } else {
      player.hasEntered = true;
    }
    await _persist();
    notifyListeners();
  }

  Future<String?> register({
    required String username,
    required String email,
    required String password,
    AuthProviderType provider = AuthProviderType.email,
  }) async {
    if (username.trim().length < 3) return 'Username must be at least 3 characters.';
    if (provider == AuthProviderType.email && !email.contains('@')) return 'Enter a valid email.';
    if (provider == AuthProviderType.email && password.length < 6) return 'Password must be 6+ characters.';
    final accounts = await _accounts();
    final key = email.toLowerCase().trim();
    if (provider == AuthProviderType.email && accounts.containsKey(key)) {
      return 'That email already has an arena identity.';
    }
    final xp = player.xp;
    final snapshot = player.toJson();
    player = PlayerProfile.fromJson(snapshot)
      ..id = _uuid.v4()
      ..username = username.trim()
      ..email = email.trim()
      ..passwordHash = _hash(password)
      ..provider = provider
      ..hasEntered = true
      ..xp = xp;
    if (provider == AuthProviderType.email) {
      accounts[key] = player.toJson();
      await _saveAccounts(accounts);
    }
    await _persist();
    notifyListeners();
    return null;
  }

  Future<String?> login(String email, String password) async {
    final accounts = await _accounts();
    final rec = accounts[email.toLowerCase().trim()];
    if (rec == null) return 'No account found.';
    if (rec['passwordHash'] != _hash(password)) return 'Wrong password.';
    player = PlayerProfile.fromJson(rec)..hasEntered = true;
    await _persist();
    notifyListeners();
    return null;
  }

  Future<void> quickProvider(AuthProviderType provider) async {
    final name = provider == AuthProviderType.google ? 'GoogleChallenger' : 'AppleChallenger';
    await register(
      username: name,
      email: '${provider.name}_${_uuid.v4().substring(0, 6)}@mindarena.local',
      password: _uuid.v4(),
      provider: provider,
    );
  }

  Future<void> updateIdentity({String? country, String? university, String? username}) async {
    if (country != null) player.country = country;
    if (university != null) player.university = university;
    if (username != null && username.trim().length >= 3) player.username = username.trim();
    await _persist();
    notifyListeners();
  }

  Future<void> setAvatar(AvatarConfig cfg) async {
    player.avatar = cfg;
    await _persist();
    notifyListeners();
  }

  Future<void> setAudio({bool? music, bool? sfx}) async {
    if (music != null) player.music = music;
    if (sfx != null) player.sfx = sfx;
    audio.apply(player);
    if (player.music) {
      await audio.startMusic();
    } else {
      await audio.stopMusic();
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setVolumes({int? musicVol, int? sfxVol, bool persist = true}) async {
    if (musicVol != null) player.musicVol = musicVol.clamp(0, 100);
    if (sfxVol != null) player.sfxVol = sfxVol.clamp(0, 100);
    audio.apply(player);
    if (persist) await _persist();
    notifyListeners();
  }

  Future<void> setQuality(GraphicsQuality q) async {
    player.quality = q;
    await _persist();
    notifyListeners();
  }

  Future<void> setAccent(String v) async {
    player.accent = v;
    await _persist();
    notifyListeners();
  }

  Future<void> setHaptics(bool v) async {
    player.haptics = v;
    await _persist();
    notifyListeners();
  }

  Future<void> setReduceMotion(bool v) async {
    player.reduceMotion = v;
    await _persist();
    notifyListeners();
  }

  Future<void> setCpuSkill(int v) async {
    player.cpuSkill = v.clamp(0, 2);
    await _persist();
    notifyListeners();
  }

  Future<void> setSkipCountdown(bool v) async {
    player.skipCountdown = v;
    await _persist();
    notifyListeners();
  }

  Future<void> setColorblind(bool v) async {
    player.colorblind = v;
    await _persist();
    notifyListeners();
  }

  String exportBackup() {
    final map = Map<String, dynamic>.from(player.toJson())..remove('passwordHash');
    return jsonEncode(map);
  }

  Future<String?> importBackup(String raw) async {
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return 'That backup is not valid.';
      final next = PlayerProfile.fromJson(Map<String, dynamic>.from(map));
      if (next.id.isEmpty) return 'That backup is not valid.';
      player = next..hasEntered = true;
      await _persist();
      notifyListeners();
      return null;
    } catch (_) {
      return 'That backup is not valid.';
    }
  }

  Future<void> setPinnedMode(String mode) async {
    player.pinnedMode = mode;
    await _persist();
    notifyListeners();
  }

  Question get questionOfTheDay {
    final i = todayStamp.hashCode.abs() % kQuestionBank.length;
    return kQuestionBank[i];
  }

  bool get canAnswerQotd => player.lastQotd != todayStamp;

  Future<bool> answerQotd(int index) async {
    if (!canAnswerQotd) return false;
    final ok = index == questionOfTheDay.correctIndex;
    player.lastQotd = todayStamp;
    if (ok) {
      player.coins += 20;
      addXp(25);
    }
    await _persist();
    notifyListeners();
    return ok;
  }

  double get cpuHitChance => switch (player.cpuSkill) {
        0 => 0.42,
        2 => 0.78,
        _ => 0.62,
      };

  bool get weekendEvent {
    final d = DateTime.now().weekday;
    return d == DateTime.saturday || d == DateTime.sunday;
  }

  Future<void> dismissTips() async {
    player.seenTips = true;
    await _persist();
    notifyListeners();
  }

  String get weekStamp {
    final n = DateTime.now();
    final monday = n.subtract(Duration(days: n.weekday - 1));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  int get weeklyBestLive {
    if (player.lastWeekly != weekStamp) return 0;
    return player.weeklyBest;
  }

  String get arenaCode {
    final h = player.id.codeUnits.fold(0, (a, b) => (a * 31 + b) & 0x7fffffff);
    return 'MA-${(h % 1000000).toString().padLeft(6, '0')}';
  }

  String codeForName(String name) {
    final h = name.codeUnits.fold(0, (a, b) => (a * 31 + b) & 0x7fffffff);
    return 'MA-${(h % 1000000).toString().padLeft(6, '0')}';
  }

  String get seasonName {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final n = DateTime.now();
    return '${months[n.month - 1]} ${n.year}';
  }

  int get seasonDaysLeft {
    final n = DateTime.now();
    final end = n.month == 12 ? DateTime(n.year + 1, 1, 1) : DateTime(n.year, n.month + 1, 1);
    return end.difference(DateTime(n.year, n.month, n.day)).inDays;
  }

  void _rollMissions() {
    if (player.lastMissionDate == todayStamp) return;
    player.lastMissionDate = todayStamp;
    player.missionRush = 0;
    player.missionCorrect = 0;
    player.missionMini = 0;
    player.missionClaimed = [];
  }

  Future<void> ensureMissions() async {
    if (player.lastMissionDate == todayStamp) return;
    _rollMissions();
    await _persist();
    notifyListeners();
  }

  List<ArenaMission> get todayMissions {
    final fresh = player.lastMissionDate == todayStamp;
    return [
      ArenaMission(id: 'rush', title: 'Finish 1 ranked rush', need: 1, have: fresh ? player.missionRush : 0, xp: 40, coins: 15),
      ArenaMission(id: 'correct', title: 'Land 8 correct answers', need: 8, have: fresh ? player.missionCorrect : 0, xp: 50, coins: 20),
      ArenaMission(id: 'mini', title: 'Complete a mini-game', need: 1, have: fresh ? player.missionMini : 0, xp: 40, coins: 15),
    ];
  }

  int get missionsReady => todayMissions.where((m) => m.done && !player.missionClaimed.contains(m.id)).length;

  Future<String?> claimMission(String id) async {
    _rollMissions();
    final m = todayMissions.where((e) => e.id == id);
    if (m.isEmpty) return 'Unknown mission.';
    if (!m.first.done) return 'Not complete yet.';
    if (player.missionClaimed.contains(id)) return 'Already claimed.';
    player.missionClaimed = [...player.missionClaimed, id];
    addXp(m.first.xp);
    player.coins += m.first.coins;
    await _persist();
    notifyListeners();
    return null;
  }

  int lastScoreFor(String mode) {
    for (final m in player.history) {
      if (m.mode == mode) return m.score;
    }
    return 0;
  }

  List<Question> notebookDrill() {
    final prompts = player.notebook.map((e) => e.prompt.toLowerCase()).toSet();
    if (prompts.isEmpty) return const [];
    return kQuestionBank.where((q) => prompts.contains(q.prompt.toLowerCase())).toList();
  }

  Future<void> clearNotebook() async {
    player.notebook = [];
    await _persist();
    notifyListeners();
  }

  Future<String?> addFriend(String raw) async {
    final typed = raw.trim();
    if (typed.length < 3) return 'Enter a rival code or name.';
    final code = typed.toUpperCase().replaceAll(' ', '');
    if (code == arenaCode) return 'That is your own arena code.';
    String name = typed;
    var resolved = code;
    for (final n in kBotNames) {
      if (codeForName(n) == code || n.toLowerCase() == typed.toLowerCase()) {
        name = n;
        resolved = codeForName(n);
        break;
      }
    }
    if (RegExp(r'^MA-\d{6}$').hasMatch(code) && name == typed) {
      name = 'Challenger ${code.substring(3)}';
      resolved = code;
    }
    if (player.friends.any((f) => f.code == resolved || f.name.toLowerCase() == name.toLowerCase())) {
      return 'Already in your rival list.';
    }
    player.friends = [
      FriendRecord(name: name, code: resolved, country: kCountries[name.hashCode.abs() % kCountries.length]),
      ...player.friends,
    ];
    await _persist();
    notifyListeners();
    return null;
  }

  Future<void> removeFriend(String code) async {
    player.friends = player.friends.where((f) => f.code != code).toList();
    await _persist();
    notifyListeners();
  }

  Future<String?> claimSeason(int points) async {
    final hit = kSeasonTrack.where((t) => t.points == points);
    if (hit.isEmpty) return 'Unknown tier.';
    final tier = hit.first;
    if (player.seasonPoints < tier.points) return 'Score more this season.';
    final key = '${tier.points}';
    if (player.seasonClaimed.contains(key)) return 'Already claimed.';
    player.seasonClaimed = [...player.seasonClaimed, key];
    player.coins += tier.coins;
    if (tier.item != null) _unlock(tier.item!);
    await _persist();
    notifyListeners();
    return null;
  }

  List<int> addXp(int amount) {
    final before = player.level;
    if (player.xpDay != todayStamp) {
      player.xpDay = todayStamp;
      player.xpToday = 0;
    }
    player.xp += amount;
    player.xpToday += amount;
    if (player.xpToday >= 400) _tryAchievement('daily_grind');
    while (player.level < 50 && player.xp >= _totalXpFor(player.level + 1)) {
      player.level++;
      player.coins += 25;
      if (player.level == 5) _unlock('cyber_jacket');
      if (player.level == 8) _unlock('neon_visor');
      if (player.level == 15) _unlock('champion_crown');
      if (player.level == 25) _unlock('void_cloak');
    }
    if (player.level >= 10) _tryAchievement('level_10');
    return [before, player.level];
  }

  int _totalXpFor(int level) {
    var t = 0;
    for (var i = 1; i < level; i++) {
      t += player.xpForLevel(i);
    }
    return t;
  }

  void _unlock(String id) {
    if (!player.unlocked.contains(id)) {
      player.unlocked = [...player.unlocked, id];
      pendingReward = id;
    }
  }

  void _tryAchievement(String id) {
    if (player.achievements.contains(id)) return;
    final def = kAchievements.where((e) => e.id == id);
    if (def.isEmpty) return;
    player.achievements = [...player.achievements, id];
    player.xp += def.first.xp;
    lastUnlockedAchievement = id;
  }

  String get todayStamp {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  void _touchStreak() {
    final today = todayStamp;
    if (player.lastPlayDate == today) return;
    if (player.lastPlayDate.isEmpty) {
      player.streak = 1;
    } else {
      final last = DateTime.tryParse(player.lastPlayDate);
      final diff = last == null ? 99 : DateTime.now().difference(DateTime(last.year, last.month, last.day)).inDays;
      if (diff == 1) {
        player.streak = player.streak + 1;
      } else if (diff > 1 && player.streakSavers > 0 && player.streak >= 2) {
        player.streakSavers--;
        player.streak = player.streak + 1;
        streakProtected = true;
      } else {
        player.streak = 1;
      }
    }
    player.lastPlayDate = today;
    if (player.streak >= 7) _tryAchievement('streak_7');
    if (player.streak >= 30) _tryAchievement('unstoppable');
  }

  bool get canClaimDaily => player.lastDailyClaim != todayStamp;
  bool get canDailyChallenge => player.lastDailyChallenge != todayStamp;
  bool get canTournament => player.lastTournament != todayStamp;

  Future<DailyReward?> claimDaily() async {
    if (!canClaimDaily) return null;
    _touchStreak();
    final idx = ((player.streak - 1) % 7);
    final reward = kDailyRewards[idx];
    addXp(reward.xp);
    if (reward.item != null) _unlock(reward.item!);
    if (idx == 6 && player.streakSavers < 2) player.streakSavers++;
    player.coins += 10 + idx * 5;
    player.lastDailyClaim = todayStamp;
    await _persist();
    notifyListeners();
    return reward;
  }

  MatchResult applyMatch({
    required String mode,
    required GameCategory? category,
    required int score,
    required int correct,
    required int wrong,
    required int answered,
    required int bestStreak,
    required List<int> answerTimesMs,
    required bool won,
    List<ReviewItem>? review,
  }) {
    lastUnlockedAchievement = null;
    pendingReward = null;
    streakProtected = false;
    lastReview = review ?? [];
    firstWinBonus = false;
    final practice = mode == 'practice';
    final levelBefore = player.level;
    if (!practice) _touchStreak();
    final fairCap = answered * 220 + 80;
    final fairScore = min(score, fairCap);
    final personalBest = !practice && fairScore > player.bestScore;
    player.totalGames++;
    player.totalCorrect += correct;
    player.totalWrong += wrong;
    if (!practice && won) player.wins++;
    if (!practice) {
      if (won) {
        player.matchWinStreak++;
        if (player.matchWinStreak > player.bestWinStreak) {
          player.bestWinStreak = player.matchWinStreak;
        }
      } else {
        player.matchWinStreak = 0;
      }
    }
    if (personalBest) player.bestScore = fairScore;
    if (!practice && bestStreak > player.bestStreak) player.bestStreak = bestStreak;
    final fast = answerTimesMs.where((t) => t > 0 && t <= 1800).length;
    if (!practice) player.fastAnswers += fast;
    if (!practice) player.universityPoints += max(0, score ~/ 10);
    player.lastMode = mode;
    player.lastCategory = category?.name ?? '';
    if (player.playDay != todayStamp) {
      player.playDay = todayStamp;
      player.playSecondsToday = 0;
    }
    player.playSecondsToday += switch (mode) {
      'reaction' => 40,
      'memory' => 80,
      'accuracy' => 30,
      'duel' => 50,
      'practice' => 45,
      _ => 60,
    };
    _rollMissions();
    if (!practice) {
      if (mode.contains('rush') || mode == 'daily' || mode == 'weekly' || mode == 'tournament') {
        player.missionRush++;
      }
      player.missionCorrect += correct;
      if (mode == 'reaction' || mode == 'memory' || mode == 'accuracy') player.missionMini++;
      if (category != null && fairScore > (player.categoryBest[category.name] ?? 0)) {
        player.categoryBest = {...player.categoryBest, category.name: fairScore};
      }
    }

    final avg = answerTimesMs.isEmpty
        ? 0
        : answerTimesMs.reduce((a, b) => a + b) ~/ answerTimesMs.length;
    final acc = answered == 0 ? 0 : ((correct / answered) * 100).round();
    if (!practice && answered >= 6 && acc > player.bestAccuracy) player.bestAccuracy = acc;
    if (mode == 'reaction' && answerTimesMs.isNotEmpty) {
      final best = answerTimesMs.reduce(min);
      if (player.bestReactionMs == 0 || best < player.bestReactionMs) player.bestReactionMs = best;
    }
    if (mode == 'memory' && answerTimesMs.isNotEmpty) {
      final ms = answerTimesMs.reduce(min);
      if (player.bestMemoryMs == 0 || ms < player.bestMemoryMs) player.bestMemoryMs = ms;
      if (ms <= 40000 && correct >= 8) _tryAchievement('memory_flash');
    }
    final speed = avg == 0 ? 50 : (100 - ((avg.clamp(400, 8000) - 400) / 76)).round().clamp(20, 99);

    var xp = 40 + correct * 18 + (won ? 40 : 0) + (bestStreak >= 5 ? 25 : 0);
    if (mode == 'daily') xp += 60;
    if (mode == 'tournament') xp += 80;
    if (practice) xp = max(10, xp ~/ 2);
    if (player.isPremium && !practice) xp = (xp * 1.15).round();
    if (player.doubleXpLive && !practice) xp *= 2;
    if (!practice && won && player.lastFirstWin != todayStamp) {
      player.lastFirstWin = todayStamp;
      xp += 40;
      firstWinBonus = true;
    }
    if (!practice) player.seasonPoints += max(0, fairScore);
    if (!practice) {
      if (player.lastWeekly != weekStamp) {
        player.weeklyBest = 0;
        player.lastWeekly = weekStamp;
      }
      if (fairScore > player.weeklyBest) player.weeklyBest = fairScore;
    }
    final signature = _hash('$fairScore|$answered|$correct|${player.id}');
    lastSignature = signature;
    final levels = addXp(xp);
    player.coins += correct * 2;
    if (firstWinBonus) player.coins += 30;
    if (!practice && weekendEvent) player.coins += 12 + correct;
    if (lastReview.isNotEmpty) {
      final misses = lastReview.where((e) => !e.correct).toList();
      player.notebook = [...misses, ...player.notebook].take(20).toList();
    }

    if (category != null) {
      final key = category.name;
      player.categoryXp[key] = (player.categoryXp[key] ?? 0) + 1;
      if (category == GameCategory.world && (player.categoryXp[key] ?? 0) >= 15) {
        _tryAchievement('world_master');
      }
      if ((player.categoryXp[key] ?? 0) >= 25) _tryAchievement('specialist');
    }

    if (!practice && (mode.contains('rush') || mode == 'daily' || mode == 'weekly')) _tryAchievement('first_rush');
    if (!practice && player.wins >= 1) _tryAchievement('first_victory');
    if (player.wins >= 100) _tryAchievement('arena_champion');
    if (player.fastAnswers >= 20) _tryAchievement('speed_demon');
    if (acc >= 95 && answered >= 8) _tryAchievement('genius');
    if (acc == 100 && answered >= 10) _tryAchievement('perfect_run');
    if (!practice && player.matchWinStreak >= 5) _tryAchievement('win_streak_5');
    if (bestStreak >= 12) _tryAchievement('combo_12');
    if (player.unlocked.length >= 4) _tryAchievement('collector');

    if (mode == 'daily') player.lastDailyChallenge = todayStamp;
    if (mode == 'tournament') player.lastTournament = todayStamp;

    var placement = 0;
    var fieldSize = 0;
    if (mode == 'tournament') {
      final field = tournamentField(fairScore);
      fieldSize = field.length;
      placement = field.indexWhere((e) => e.isPlayer) + 1;
      if (placement > 0 && placement <= 10) {
        player.coins += 80;
        _unlock('champion_crown');
      }
    }

    final rank = globalRankFor(player.bestScore);
    final prevScore = lastScoreFor(mode);
    final result = MatchResult(
      mode: mode,
      score: fairScore,
      correct: correct,
      wrong: wrong,
      answered: answered,
      bestStreak: bestStreak,
      avgAnswerMs: avg,
      xpGained: xp,
      speedPct: speed,
      accuracyPct: acc,
      rank: rank,
      personalBest: personalBest && score > 0,
      won: won,
      rewardId: pendingReward,
      levelBefore: levelBefore,
      levelAfter: levels.last,
      placement: placement,
      fieldSize: fieldSize,
      prevScore: prevScore,
      scoreDelta: prevScore == 0 ? 0 : fairScore - prevScore,
    );
    player.history = [
      MatchRecord(
        mode: mode,
        score: fairScore,
        xp: xp,
        at: todayStamp,
        won: won,
        signature: signature,
      ),
      ...player.history,
    ].take(25).toList();
    _persist();
    notifyListeners();
    return result;
  }

  int globalRankFor(int score) {
    final board = leaderboard();
    final idx = board.indexWhere((e) => e.isPlayer);
    return idx < 0 ? 240 : idx + 1;
  }

  List<LeaderboardEntry> leaderboard({String? country, String? university}) {
    final bots = <LeaderboardEntry>[];
    for (var i = 0; i < kBotNames.length; i++) {
      final seed = Random(i * 97 + 13);
      bots.add(LeaderboardEntry(
        name: kBotNames[i],
        score: 4200 - i * 160 + seed.nextInt(90),
        country: kCountries[i % kCountries.length],
        university: kUniversities[i % kUniversities.length],
      ));
    }
    final mine = LeaderboardEntry(
      name: player.username,
      score: player.bestScore,
      country: player.country,
      university: player.university,
      isPlayer: true,
    );
    var all = [...bots, mine];
    if (country != null) all = all.where((e) => e.country == country).toList();
    if (university != null) all = all.where((e) => e.university == university).toList();
    all.sort((a, b) => b.score.compareTo(a.score));
    return all;
  }

  Map<String, int> universityTotals() {
    final map = <String, int>{};
    for (final e in leaderboard()) {
      map[e.university] = (map[e.university] ?? 0) + e.score;
    }
    map[player.university] = (map[player.university] ?? 0) + player.universityPoints;
    return map;
  }

  Future<String?> buyItem(ShopItem item) async {
    if (player.unlocked.contains(item.id)) return 'Already owned.';
    if (item.plusOnly && !player.isPremium) return 'MindArena Plus exclusive.';
    if (!player.isPremium && item.cost > 0 && player.coins < item.cost) {
      return 'Not enough coins. Win matches — never buy power.';
    }
    if (!player.isPremium && item.cost > 0) player.coins -= item.cost;
    _unlock(item.id);
    if (player.unlocked.length >= 4) _tryAchievement('collector');
    await _persist();
    notifyListeners();
    return null;
  }

  Future<void> activatePlus() async {
    player.isPremium = true;
    _unlock('gold_ace');
    await _persist();
    notifyListeners();
  }

  Future<void> grantRewardedBoost() async {
    if (player.isPremium) return;
    addXp(80);
    player.coins += 15;
    player.doubleXpUntil = DateTime.now().add(const Duration(minutes: 20)).millisecondsSinceEpoch;
    await _persist();
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    player = PlayerProfile(id: 'guest', username: 'Challenger');
    await audio.stopMusic();
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    final accounts = await _accounts();
    accounts.remove(player.email.toLowerCase().trim());
    await _saveAccounts(accounts);
    await logout();
  }

  GameCategory get dailyCategory {
    const order = [
      GameCategory.brain,
      GameCategory.science,
      GameCategory.world,
      GameCategory.tech,
      GameCategory.math,
      GameCategory.entertainment,
      GameCategory.word,
    ];
    return order[DateTime.now().weekday % 7];
  }

  int get lifetimeAccuracy {
    final t = player.totalCorrect + player.totalWrong;
    if (t == 0) return 0;
    return ((player.totalCorrect / t) * 100).round();
  }

  String get favoriteArena {
    if (player.categoryXp.isEmpty) return '60-Second Rush';
    final top = player.categoryXp.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return GameCategory.values.firstWhere((e) => e.name == top.key, orElse: () => GameCategory.brain).title;
  }

  int get xpTodayLive => player.xpDay == todayStamp ? player.xpToday : 0;

  List<Question> get flaggedQuestions {
    final ids = player.flagged.toSet();
    if (ids.isEmpty) return const [];
    return kQuestionBank.where((q) => ids.contains(q.id)).toList();
  }

  List<LeaderboardEntry> seasonBoard() {
    final bots = <LeaderboardEntry>[];
    for (var i = 0; i < 40; i++) {
      final seed = Random(i * 41 + 9);
      bots.add(LeaderboardEntry(
        name: '${kBotNames[i % kBotNames.length]}${i > 19 ? i : ''}',
        score: 9000 - i * 140 + seed.nextInt(70),
        country: kCountries[i % kCountries.length],
        university: kUniversities[i % kUniversities.length],
      ));
    }
    final mine = LeaderboardEntry(
      name: player.username,
      score: player.seasonPoints,
      country: player.country,
      university: player.university,
      isPlayer: true,
    );
    final all = [...bots, mine]..sort((a, b) => b.score.compareTo(a.score));
    return all;
  }

  List<LeaderboardEntry> weeklyBoard() {
    final bots = <LeaderboardEntry>[];
    for (var i = 0; i < 40; i++) {
      final seed = Random(i * 23 + weekStamp.hashCode);
      bots.add(LeaderboardEntry(
        name: '${kBotNames[i % kBotNames.length]}${i > 19 ? i : ''}',
        score: 6200 - i * 110 + seed.nextInt(80),
        country: kCountries[i % kCountries.length],
        university: kUniversities[i % kUniversities.length],
      ));
    }
    final mine = LeaderboardEntry(
      name: player.username,
      score: weeklyBestLive,
      country: player.country,
      university: player.university,
      isPlayer: true,
    );
    final all = [...bots, mine]..sort((a, b) => b.score.compareTo(a.score));
    return all;
  }

  String? pipelineDuplicateOf(String prompt) {
    final n = _normPrompt(prompt);
    if (n.length < 6) return null;
    for (final q in kQuestionBank) {
      if (_normPrompt(q.prompt) == n) return q.id;
    }
    for (final d in pipelineDrafts) {
      if (_normPrompt(d.prompt) == n) return d.id;
    }
    return null;
  }

  static String _normPrompt(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

  Future<String?> savePipelineDraft(QuestionDraft draft) async {
    if (draft.prompt.trim().length < 8) return 'Prompt must be at least 8 characters.';
    if (draft.options.length != 4 || draft.options.any((e) => e.trim().isEmpty)) {
      return 'Need four non-empty options.';
    }
    if (draft.correctIndex < 0 || draft.correctIndex > 3) return 'Mark the correct option.';
    final dup = pipelineDuplicateOf(draft.prompt);
    final saved = QuestionDraft(
      id: draft.id,
      prompt: draft.prompt.trim(),
      options: [for (final o in draft.options) o.trim()],
      correctIndex: draft.correctIndex,
      explanation: draft.explanation.trim(),
      category: draft.category,
      difficulty: draft.difficulty,
      status: dup == null ? 'queued' : 'flagged_duplicate',
    );
    final prefs = await SharedPreferences.getInstance();
    pipelineDrafts = [saved, ...pipelineDrafts].take(40).toList();
    await prefs.setString(_draftsKey, jsonEncode(pipelineDrafts.map((e) => e.toJson()).toList()));
    notifyListeners();
    if (dup != null) return 'Duplicate of $dup. Flagged — never auto-published.';
    return null;
  }

  List<LeaderboardEntry> tournamentField(int score) {
    final field = <LeaderboardEntry>[
      for (var i = 0; i < 99; i++)
        LeaderboardEntry(
          name: '${kBotNames[i % kBotNames.length]}${10 + i}',
          score: 350 + Random(i * 17 + score).nextInt(7800),
          country: kCountries[i % kCountries.length],
          university: kUniversities[i % kUniversities.length],
        ),
      LeaderboardEntry(
        name: player.username,
        score: score,
        country: player.country,
        university: player.university,
        isPlayer: true,
      ),
    ]..sort((a, b) => b.score.compareTo(a.score));
    return field;
  }

  Future<void> equipItem(ShopItem item) async {
    final owned = player.unlocked.contains(item.id) || (item.plusOnly && player.isPremium);
    if (!owned && item.cost > 0) return;
    if (!player.unlocked.contains(item.id) && item.cost == 0) _unlock(item.id);
    final a = player.avatar;
    player.avatar = switch (item.slot) {
      'glasses' => a.copyWith(glasses: item.value),
      'hat' => a.copyWith(hat: item.value),
      'accessory' => a.copyWith(accessory: item.value),
      'shoes' => a.copyWith(shoes: item.value),
      'hair' => a.copyWith(hairColor: item.value),
      _ => a.copyWith(outfit: item.value),
    };
    await _persist();
    notifyListeners();
  }

  Future<void> flagQuestion(String id) async {
    if (id.isEmpty || player.flagged.contains(id)) return;
    player.flagged = [...player.flagged, id];
    await _persist();
    notifyListeners();
  }
}
