import 'package:flutter/material.dart';

enum GameCategory {
  brain,
  math,
  tech,
  world,
  science,
  word,
  reaction,
  memory,
  accuracy,
  entertainment,
}

extension GameCategoryX on GameCategory {
  String get title => switch (this) {
        GameCategory.brain => 'Brain Arena',
        GameCategory.math => 'Math Rush',
        GameCategory.tech => 'Tech Battle',
        GameCategory.world => 'World Challenge',
        GameCategory.science => 'Science Lab',
        GameCategory.word => 'Word Master',
        GameCategory.reaction => 'Reaction Arena',
        GameCategory.memory => 'Memory Arena',
        GameCategory.accuracy => 'Accuracy Arena',
        GameCategory.entertainment => 'Entertainment Arena',
      };

  String get tagline => switch (this) {
        GameCategory.brain => 'Knowledge. Logic. Instinct.',
        GameCategory.math => 'Fast numbers. Faster mind.',
        GameCategory.tech => 'Code, systems, the future.',
        GameCategory.world => 'Flags, capitals, landmarks.',
        GameCategory.science => 'Physics, chem, biology.',
        GameCategory.word => 'Vocabulary under fire.',
        GameCategory.reaction => 'Tap the moment. No delay.',
        GameCategory.memory => 'Hold the pattern. Win.',
        GameCategory.accuracy => 'Aim. Precision. Control.',
        GameCategory.entertainment => 'Movies, music, pop culture.',
      };

  IconData get icon => switch (this) {
        GameCategory.brain => Icons.psychology_alt,
        GameCategory.math => Icons.functions,
        GameCategory.tech => Icons.terminal,
        GameCategory.world => Icons.public,
        GameCategory.science => Icons.science,
        GameCategory.word => Icons.spellcheck,
        GameCategory.reaction => Icons.bolt,
        GameCategory.memory => Icons.grid_view,
        GameCategory.accuracy => Icons.gps_fixed,
        GameCategory.entertainment => Icons.movie_filter,
      };

  Color get accent => switch (this) {
        GameCategory.brain => const Color(0xFF7A5CFF),
        GameCategory.math => const Color(0xFF00F0FF),
        GameCategory.tech => const Color(0xFF7CFF6B),
        GameCategory.world => const Color(0xFF00B4FF),
        GameCategory.science => const Color(0xFF7CFF6B),
        GameCategory.word => const Color(0xFFFFD166),
        GameCategory.reaction => const Color(0xFFFF2BD6),
        GameCategory.memory => const Color(0xFF00F0FF),
        GameCategory.accuracy => const Color(0xFFFF4D6D),
        GameCategory.entertainment => const Color(0xFFFF2BD6),
      };

  bool get isQuiz => switch (this) {
        GameCategory.reaction ||
        GameCategory.memory ||
        GameCategory.accuracy =>
          false,
        _ => true,
      };
}

enum GraphicsQuality { low, medium, high, ultra }

enum AuthProviderType { guest, email, google, apple }

class Question {
  const Question({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final GameCategory category;
  final String difficulty;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

class AvatarConfig {
  const AvatarConfig({
    this.preset = 2,
    this.hair = 1,
    this.hairColor = 0,
    this.outfit = 0,
    this.shoes = 0,
    this.glasses = 0,
    this.hat = 0,
    this.accessory = 0,
    this.pose = 0,
  });

  final int preset;
  final int hair;
  final int hairColor;
  final int outfit;
  final int shoes;
  final int glasses;
  final int hat;
  final int accessory;
  final int pose;

  AvatarConfig copyWith({
    int? preset,
    int? hair,
    int? hairColor,
    int? outfit,
    int? shoes,
    int? glasses,
    int? hat,
    int? accessory,
    int? pose,
  }) {
    return AvatarConfig(
      preset: preset ?? this.preset,
      hair: hair ?? this.hair,
      hairColor: hairColor ?? this.hairColor,
      outfit: outfit ?? this.outfit,
      shoes: shoes ?? this.shoes,
      glasses: glasses ?? this.glasses,
      hat: hat ?? this.hat,
      accessory: accessory ?? this.accessory,
      pose: pose ?? this.pose,
    );
  }

  Map<String, dynamic> toJson() => {
        'preset': preset,
        'hair': hair,
        'hairColor': hairColor,
        'outfit': outfit,
        'shoes': shoes,
        'glasses': glasses,
        'hat': hat,
        'accessory': accessory,
        'pose': pose,
      };

  factory AvatarConfig.fromJson(Map<String, dynamic> json) => AvatarConfig(
        preset: json['preset'] as int? ?? 2,
        hair: json['hair'] as int? ?? 1,
        hairColor: json['hairColor'] as int? ?? 0,
        outfit: json['outfit'] as int? ?? 0,
        shoes: json['shoes'] as int? ?? 0,
        glasses: json['glasses'] as int? ?? 0,
        hat: json['hat'] as int? ?? 0,
        accessory: json['accessory'] as int? ?? 0,
        pose: json['pose'] as int? ?? 0,
      );
}

class MatchResult {
  const MatchResult({
    required this.mode,
    required this.score,
    required this.correct,
    required this.wrong,
    required this.answered,
    required this.bestStreak,
    required this.avgAnswerMs,
    required this.xpGained,
    required this.speedPct,
    required this.accuracyPct,
    required this.rank,
    required this.personalBest,
    required this.won,
    this.rewardId,
    this.levelBefore = 1,
    this.levelAfter = 1,
    this.placement = 0,
    this.fieldSize = 0,
    this.prevScore = 0,
    this.scoreDelta = 0,
  });

  final String mode;
  final int score;
  final int correct;
  final int wrong;
  final int answered;
  final int bestStreak;
  final int avgAnswerMs;
  final int xpGained;
  final int speedPct;
  final int accuracyPct;
  final int rank;
  final bool personalBest;
  final bool won;
  final String? rewardId;
  final int levelBefore;
  final int levelAfter;
  final int placement;
  final int fieldSize;
  final int prevScore;
  final int scoreDelta;
}

class AchievementDef {
  const AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xp,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int xp;
}

class DailyReward {
  const DailyReward({required this.day, required this.label, this.xp = 0, this.item});

  final int day;
  final String label;
  final int xp;
  final String? item;
}

class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.cost,
    required this.blurb,
    this.plusOnly = false,
    this.slot = 'outfit',
    this.value = 0,
  });

  final String id;
  final String name;
  final int cost;
  final String blurb;
  final bool plusOnly;
  final String slot;
  final int value;
}

class MatchRecord {
  const MatchRecord({
    required this.mode,
    required this.score,
    required this.xp,
    required this.at,
    required this.won,
    this.signature = '',
  });

  final String mode;
  final int score;
  final int xp;
  final String at;
  final bool won;
  final String signature;

  Map<String, dynamic> toJson() => {
        'mode': mode,
        'score': score,
        'xp': xp,
        'at': at,
        'won': won,
        'signature': signature,
      };

  factory MatchRecord.fromJson(Map<String, dynamic> j) => MatchRecord(
        mode: j['mode'] as String? ?? 'rush',
        score: j['score'] as int? ?? 0,
        xp: j['xp'] as int? ?? 0,
        at: j['at'] as String? ?? '',
        won: j['won'] as bool? ?? false,
        signature: j['signature'] as String? ?? '',
      );
}

class PlayerProfile {
  PlayerProfile({
    required this.id,
    required this.username,
    this.email = '',
    this.passwordHash = '',
    this.provider = AuthProviderType.guest,
    this.country = 'Pakistan',
    this.university = 'Independent',
    this.level = 1,
    this.xp = 0,
    this.coins = 0,
    this.streak = 0,
    this.lastPlayDate = '',
    this.lastDailyClaim = '',
    this.lastDailyChallenge = '',
    this.lastTournament = '',
    this.totalGames = 0,
    this.wins = 0,
    this.bestScore = 0,
    this.bestStreak = 0,
    this.totalCorrect = 0,
    this.totalWrong = 0,
    this.fastAnswers = 0,
    this.universityPoints = 0,
    this.hasEntered = false,
    this.music = true,
    this.sfx = true,
    this.musicVol = 70,
    this.sfxVol = 80,
    this.accent = 'cyan',
    this.quality = GraphicsQuality.high,
    this.unlocked = const ['starter_jacket'],
    this.achievements = const [],
    this.categoryXp = const {},
    this.isPremium = false,
    this.doubleXpUntil = 0,
    this.seasonPoints = 0,
    this.weeklyBest = 0,
    this.lastWeekly = '',
    this.seenTips = false,
    this.haptics = true,
    this.reduceMotion = false,
    this.streakSavers = 0,
    this.lastMode = '',
    this.lastCategory = '',
    this.bestReactionMs = 0,
    this.bestMemoryMs = 0,
    this.bestAccuracy = 0,
    this.cpuSkill = 1,
    this.skipCountdown = false,
    this.lastQotd = '',
    this.lastFirstWin = '',
    this.pinnedMode = '',
    this.colorblind = false,
    this.playSecondsToday = 0,
    this.playDay = '',
    this.matchWinStreak = 0,
    this.bestWinStreak = 0,
    this.xpToday = 0,
    this.xpDay = '',
    this.lastMissionDate = '',
    this.missionRush = 0,
    this.missionCorrect = 0,
    this.missionMini = 0,
    List<String>? seasonClaimed,
    List<ReviewItem>? notebook,
    List<String>? flagged,
    List<String>? missionClaimed,
    Map<String, int>? categoryBest,
    List<FriendRecord>? friends,
    List<MatchRecord>? history,
    AvatarConfig? avatar,
  })  : avatar = avatar ?? const AvatarConfig(),
        history = history ?? [],
        missionClaimed = missionClaimed ?? [],
        categoryBest = categoryBest ?? {},
        friends = friends ?? [],
        seasonClaimed = seasonClaimed ?? [],
        notebook = notebook ?? [],
        flagged = flagged ?? [];

  String id;
  String username;
  String email;
  String passwordHash;
  AuthProviderType provider;
  String country;
  String university;
  int level;
  int xp;
  int coins;
  int streak;
  String lastPlayDate;
  String lastDailyClaim;
  String lastDailyChallenge;
  String lastTournament;
  int totalGames;
  int wins;
  int bestScore;
  int bestStreak;
  int totalCorrect;
  int totalWrong;
  int fastAnswers;
  int universityPoints;
  bool hasEntered;
  bool music;
  bool sfx;
  int musicVol;
  int sfxVol;
  String accent;
  GraphicsQuality quality;
  List<String> unlocked;
  List<String> achievements;
  Map<String, int> categoryXp;
  bool isPremium;
  int doubleXpUntil;
  int seasonPoints;
  int weeklyBest;
  String lastWeekly;
  bool seenTips;
  bool haptics;
  bool reduceMotion;
  int streakSavers;
  String lastMode;
  String lastCategory;
  int bestReactionMs;
  int bestMemoryMs;
  int bestAccuracy;
  int cpuSkill;
  bool skipCountdown;
  String lastQotd;
  String lastFirstWin;
  String pinnedMode;
  bool colorblind;
  int playSecondsToday;
  String playDay;
  int matchWinStreak;
  int bestWinStreak;
  int xpToday;
  String xpDay;
  List<String> seasonClaimed;
  List<ReviewItem> notebook;
  List<String> flagged;
  String lastMissionDate;
  int missionRush;
  int missionCorrect;
  int missionMini;
  List<String> missionClaimed;
  Map<String, int> categoryBest;
  List<FriendRecord> friends;
  List<MatchRecord> history;
  AvatarConfig avatar;

  bool get doubleXpLive => DateTime.now().millisecondsSinceEpoch < doubleXpUntil;

  int xpForLevel(int lvl) => 200 + (lvl - 1) * 150;

  int get xpIntoLevel {
    var remaining = xp;
    for (var i = 1; i < level; i++) {
      remaining -= xpForLevel(i);
    }
    return remaining.clamp(0, xpForLevel(level));
  }

  double get levelProgress {
    if (level >= 50) return 1;
    return xpIntoLevel / xpForLevel(level);
  }

  String get rankTitle {
    if (level >= 50) return 'MASTER';
    if (level >= 35) return 'ARENA LEGEND';
    if (level >= 20) return 'CHAMPION';
    if (level >= 10) return 'CHALLENGER';
    if (level >= 5) return 'RISING';
    return 'ROOKIE';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'passwordHash': passwordHash,
        'provider': provider.name,
        'country': country,
        'university': university,
        'level': level,
        'xp': xp,
        'coins': coins,
        'streak': streak,
        'lastPlayDate': lastPlayDate,
        'lastDailyClaim': lastDailyClaim,
        'lastDailyChallenge': lastDailyChallenge,
        'lastTournament': lastTournament,
        'totalGames': totalGames,
        'wins': wins,
        'bestScore': bestScore,
        'bestStreak': bestStreak,
        'totalCorrect': totalCorrect,
        'totalWrong': totalWrong,
        'fastAnswers': fastAnswers,
        'universityPoints': universityPoints,
        'hasEntered': hasEntered,
        'music': music,
        'sfx': sfx,
        'musicVol': musicVol,
        'sfxVol': sfxVol,
        'accent': accent,
        'quality': quality.name,
        'unlocked': unlocked,
        'achievements': achievements,
        'categoryXp': categoryXp,
        'isPremium': isPremium,
        'doubleXpUntil': doubleXpUntil,
        'seasonPoints': seasonPoints,
        'weeklyBest': weeklyBest,
        'lastWeekly': lastWeekly,
        'seenTips': seenTips,
        'haptics': haptics,
        'reduceMotion': reduceMotion,
        'streakSavers': streakSavers,
        'lastMode': lastMode,
        'lastCategory': lastCategory,
        'bestReactionMs': bestReactionMs,
        'bestMemoryMs': bestMemoryMs,
        'bestAccuracy': bestAccuracy,
        'cpuSkill': cpuSkill,
        'skipCountdown': skipCountdown,
        'lastQotd': lastQotd,
        'lastFirstWin': lastFirstWin,
        'pinnedMode': pinnedMode,
        'colorblind': colorblind,
        'playSecondsToday': playSecondsToday,
        'playDay': playDay,
        'matchWinStreak': matchWinStreak,
        'bestWinStreak': bestWinStreak,
        'xpToday': xpToday,
        'xpDay': xpDay,
        'seasonClaimed': seasonClaimed,
        'notebook': notebook.map((e) => e.toJson()).toList(),
        'flagged': flagged,
        'lastMissionDate': lastMissionDate,
        'missionRush': missionRush,
        'missionCorrect': missionCorrect,
        'missionMini': missionMini,
        'missionClaimed': missionClaimed,
        'categoryBest': categoryBest,
        'friends': friends.map((e) => e.toJson()).toList(),
        'history': history.map((e) => e.toJson()).toList(),
        'avatar': avatar.toJson(),
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      id: json['id'] as String? ?? 'guest',
      username: json['username'] as String? ?? 'Challenger',
      email: json['email'] as String? ?? '',
      passwordHash: json['passwordHash'] as String? ?? '',
      provider: AuthProviderType.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => AuthProviderType.guest,
      ),
      country: json['country'] as String? ?? 'Pakistan',
      university: json['university'] as String? ?? 'Independent',
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      lastPlayDate: json['lastPlayDate'] as String? ?? '',
      lastDailyClaim: json['lastDailyClaim'] as String? ?? '',
      lastDailyChallenge: json['lastDailyChallenge'] as String? ?? '',
      lastTournament: json['lastTournament'] as String? ?? '',
      totalGames: json['totalGames'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalCorrect: json['totalCorrect'] as int? ?? 0,
      totalWrong: json['totalWrong'] as int? ?? 0,
      fastAnswers: json['fastAnswers'] as int? ?? 0,
      universityPoints: json['universityPoints'] as int? ?? 0,
      hasEntered: json['hasEntered'] as bool? ?? false,
      music: json['music'] as bool? ?? true,
      sfx: json['sfx'] as bool? ?? true,
      musicVol: json['musicVol'] as int? ?? 70,
      sfxVol: json['sfxVol'] as int? ?? 80,
      accent: json['accent'] as String? ?? 'cyan',
      quality: GraphicsQuality.values.firstWhere(
        (e) => e.name == json['quality'],
        orElse: () => GraphicsQuality.high,
      ),
      unlocked: List<String>.from(json['unlocked'] as List? ?? ['starter_jacket']),
      achievements: List<String>.from(json['achievements'] as List? ?? []),
      categoryXp: Map<String, int>.from(json['categoryXp'] as Map? ?? {}),
      isPremium: json['isPremium'] as bool? ?? false,
      doubleXpUntil: json['doubleXpUntil'] as int? ?? 0,
      seasonPoints: json['seasonPoints'] as int? ?? 0,
      weeklyBest: json['weeklyBest'] as int? ?? 0,
      lastWeekly: json['lastWeekly'] as String? ?? '',
      seenTips: json['seenTips'] as bool? ?? false,
      haptics: json['haptics'] as bool? ?? true,
      reduceMotion: json['reduceMotion'] as bool? ?? false,
      streakSavers: json['streakSavers'] as int? ?? 0,
      lastMode: json['lastMode'] as String? ?? '',
      lastCategory: json['lastCategory'] as String? ?? '',
      bestReactionMs: json['bestReactionMs'] as int? ?? 0,
      bestMemoryMs: json['bestMemoryMs'] as int? ?? 0,
      bestAccuracy: json['bestAccuracy'] as int? ?? 0,
      cpuSkill: json['cpuSkill'] as int? ?? 1,
      skipCountdown: json['skipCountdown'] as bool? ?? false,
      lastQotd: json['lastQotd'] as String? ?? '',
      lastFirstWin: json['lastFirstWin'] as String? ?? '',
      pinnedMode: json['pinnedMode'] as String? ?? '',
      colorblind: json['colorblind'] as bool? ?? false,
      playSecondsToday: json['playSecondsToday'] as int? ?? 0,
      playDay: json['playDay'] as String? ?? '',
      matchWinStreak: json['matchWinStreak'] as int? ?? 0,
      bestWinStreak: json['bestWinStreak'] as int? ?? 0,
      xpToday: json['xpToday'] as int? ?? 0,
      xpDay: json['xpDay'] as String? ?? '',
      seasonClaimed: List<String>.from(json['seasonClaimed'] as List? ?? const []),
      notebook: [
        for (final e in (json['notebook'] as List? ?? const []))
          if (e is Map) ReviewItem.fromJson(Map<String, dynamic>.from(e)),
      ],
      flagged: List<String>.from(json['flagged'] as List? ?? const []),
      lastMissionDate: json['lastMissionDate'] as String? ?? '',
      missionRush: json['missionRush'] as int? ?? 0,
      missionCorrect: json['missionCorrect'] as int? ?? 0,
      missionMini: json['missionMini'] as int? ?? 0,
      missionClaimed: List<String>.from(json['missionClaimed'] as List? ?? const []),
      categoryBest: Map<String, int>.from(json['categoryBest'] as Map? ?? {}),
      friends: [
        for (final e in (json['friends'] as List? ?? const []))
          if (e is Map) FriendRecord.fromJson(Map<String, dynamic>.from(e)),
      ],
      history: [
        for (final e in (json['history'] as List? ?? const []))
          if (e is Map) MatchRecord.fromJson(Map<String, dynamic>.from(e)),
      ],
      avatar: json['avatar'] is Map
          ? AvatarConfig.fromJson(Map<String, dynamic>.from(json['avatar'] as Map))
          : const AvatarConfig(),
    );
  }
}

class QuestionDraft {
  const QuestionDraft({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.category = 'brain',
    this.difficulty = 'medium',
    this.status = 'draft',
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String category;
  final String difficulty;
  final String status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
        'category': category,
        'difficulty': difficulty,
        'status': status,
      };

  factory QuestionDraft.fromJson(Map<String, dynamic> json) {
    return QuestionDraft(
      id: json['id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      options: List<String>.from(json['options'] as List? ?? const []),
      correctIndex: json['correctIndex'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
      category: json['category'] as String? ?? 'brain',
      difficulty: json['difficulty'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'draft',
    );
  }
}

class FriendRecord {
  const FriendRecord({required this.name, required this.code, this.country = 'Pakistan'});

  final String name;
  final String code;
  final String country;

  Map<String, dynamic> toJson() => {'name': name, 'code': code, 'country': country};

  factory FriendRecord.fromJson(Map<String, dynamic> json) => FriendRecord(
        name: json['name'] as String? ?? 'Rival',
        code: json['code'] as String? ?? '',
        country: json['country'] as String? ?? 'Pakistan',
      );
}

class ArenaMission {
  const ArenaMission({
    required this.id,
    required this.title,
    required this.need,
    required this.have,
    required this.xp,
    required this.coins,
  });

  final String id;
  final String title;
  final int need;
  final int have;
  final int xp;
  final int coins;

  bool get done => have >= need;
}

class ReviewItem {
  const ReviewItem({
    required this.prompt,
    required this.picked,
    required this.answer,
    required this.why,
    required this.correct,
  });

  final String prompt;
  final String picked;
  final String answer;
  final String why;
  final bool correct;

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        'picked': picked,
        'answer': answer,
        'why': why,
        'correct': correct,
      };

  factory ReviewItem.fromJson(Map<String, dynamic> json) => ReviewItem(
        prompt: json['prompt'] as String? ?? '',
        picked: json['picked'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
        why: json['why'] as String? ?? '',
        correct: json['correct'] as bool? ?? false,
      );
}

class SeasonTier {
  const SeasonTier({required this.points, required this.label, this.coins = 0, this.item});

  final int points;
  final String label;
  final int coins;
  final String? item;
}
