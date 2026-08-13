import 'package:flutter/material.dart';

import '../models/models.dart';

const kCountries = [
  'Pakistan',
  'India',
  'UAE',
  'UK',
  'USA',
  'Canada',
  'Saudi Arabia',
  'Germany',
  'Australia',
  'Turkey',
];

const kUniversities = [
  'Independent',
  'NUST',
  'FAST-NUCES',
  'LUMS',
  'University of Punjab',
  'COMSATS',
  'IBA Karachi',
  'GIKI',
  'UET',
  'Other',
];

const kDailyRewards = [
  DailyReward(day: 1, label: '50 XP', xp: 50),
  DailyReward(day: 2, label: '75 XP', xp: 75),
  DailyReward(day: 3, label: 'Avatar item', xp: 40, item: 'neon_visor'),
  DailyReward(day: 4, label: '100 XP', xp: 100),
  DailyReward(day: 5, label: 'Mystery box', xp: 80, item: 'void_gloves'),
  DailyReward(day: 6, label: '200 XP', xp: 200),
  DailyReward(day: 7, label: 'Rare reward', xp: 150, item: 'champion_crown'),
];

const kAchievements = [
  AchievementDef(id: 'first_victory', title: 'First Victory', description: 'Win your first match.', icon: Icons.emoji_events, xp: 80),
  AchievementDef(id: 'speed_demon', title: 'Speed Demon', description: 'Answer 20 questions extremely quickly.', icon: Icons.bolt, xp: 120),
  AchievementDef(id: 'genius', title: 'Genius', description: 'Hit 95% accuracy in a match (8+ answers).', icon: Icons.psychology, xp: 150),
  AchievementDef(id: 'unstoppable', title: 'Unstoppable', description: 'Maintain a 30-day streak.', icon: Icons.local_fire_department, xp: 300),
  AchievementDef(id: 'arena_champion', title: 'Arena Champion', description: 'Win 100 matches.', icon: Icons.workspace_premium, xp: 400),
  AchievementDef(id: 'world_master', title: 'World Master', description: 'Play World Challenge 15 times.', icon: Icons.public, xp: 180),
  AchievementDef(id: 'first_rush', title: 'Enter the Arena', description: 'Finish a 60-Second Rush.', icon: Icons.timer, xp: 50),
  AchievementDef(id: 'streak_7', title: 'Week Warrior', description: 'Keep a 7-day streak.', icon: Icons.whatshot, xp: 100),
  AchievementDef(id: 'level_10', title: 'Challenger Rank', description: 'Reach level 10.', icon: Icons.military_tech, xp: 120),
  AchievementDef(id: 'collector', title: 'Style Icon', description: 'Unlock 4 avatar items.', icon: Icons.checkroom, xp: 90),
  AchievementDef(id: 'combo_12', title: 'On Fire', description: 'Chain 12 correct answers in one rush.', icon: Icons.whatshot, xp: 160),
  AchievementDef(id: 'perfect_run', title: 'Flawless', description: 'Answer 10+ questions at 100% accuracy.', icon: Icons.verified, xp: 200),
  AchievementDef(id: 'win_streak_5', title: 'Hot Hand', description: 'Win 5 matches in a row.', icon: Icons.whatshot, xp: 180),
  AchievementDef(id: 'memory_flash', title: 'Total Recall', description: 'Clear Memory Arena in under 40 seconds.', icon: Icons.grid_view, xp: 140),
  AchievementDef(id: 'daily_grind', title: 'Daily Grind', description: 'Earn 400 XP in a single day.', icon: Icons.trending_up, xp: 120),
  AchievementDef(id: 'specialist', title: 'Specialist', description: 'Play one category 25 times.', icon: Icons.military_tech, xp: 160),
];

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.name,
    required this.score,
    required this.country,
    required this.university,
    this.isPlayer = false,
  });

  final String name;
  final int score;
  final String country;
  final String university;
  final bool isPlayer;
}

const kSeasonTrack = [
  SeasonTier(points: 400, label: 'Warm-up crate', coins: 40),
  SeasonTier(points: 1200, label: 'Hover Kicks', item: 'pulse_kicks'),
  SeasonTier(points: 3000, label: 'Void Gloves + coins', coins: 80, item: 'void_gloves'),
  SeasonTier(points: 6000, label: 'Champion flare', coins: 120, item: 'champion_crown'),
];

const kShop = [
  ShopItem(id: 'starter_jacket', name: 'Arena Tee', cost: 0, blurb: 'Every challenger starts here.', slot: 'outfit', value: 0),
  ShopItem(id: 'cyber_jacket', name: 'Cyber Jacket', cost: 180, blurb: 'Neon plates. Zero pay-to-win.', slot: 'outfit', value: 2),
  ShopItem(id: 'neon_visor', name: 'Neon Visor', cost: 120, blurb: 'See the arena in cyan.', slot: 'glasses', value: 1),
  ShopItem(id: 'void_gloves', name: 'Void Gloves', cost: 90, blurb: 'Mystery-box classic.', slot: 'accessory', value: 1),
  ShopItem(id: 'champion_crown', name: 'Champion Crown', cost: 320, blurb: 'For the board climbers.', slot: 'hat', value: 2),
  ShopItem(id: 'void_cloak', name: 'Void Cloak', cost: 400, blurb: 'Rare silhouette. Cosmetic only.', slot: 'outfit', value: 4),
  ShopItem(id: 'pulse_kicks', name: 'Hover Kicks', cost: 140, blurb: 'They do not make you faster. Promise.', slot: 'shoes', value: 1),
  ShopItem(id: 'gold_ace', name: 'Gold Ace Skin', cost: 0, blurb: 'Plus exclusive. Looks expensive. Is not power.', plusOnly: true, slot: 'outfit', value: 4),
];

const kBotNames = [
  'NovaBlade',
  'PixelSage',
  'AetherKid',
  'LogicFox',
  'CyberMira',
  'Quark',
  'Nimble',
  'Vanta',
  'IonPulse',
  'RogueByte',
  'Lumen',
  'Kairo',
  'Sable',
  'Nex',
  'OrionX',
  'ZaraVolt',
  'Hexa',
  'Drift',
  'EchoMind',
  'TitanQ',
];
