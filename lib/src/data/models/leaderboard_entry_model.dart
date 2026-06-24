import 'package:equatable/equatable.dart';

/// A single entry in the global Firestore leaderboard collection.
/// Document ID == uid, one doc per user, upserted after every quiz.
class LeaderboardEntry extends Equatable {
  final String uid;
  final String displayName;
  final String? photoUrl;
  final int totalScore;
  final int gamesPlayed;
  final int bestScore;
  final DateTime lastPlayedAt;

  /// Rank injected client-side from the list index (1-based).
  final int? rank;

  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    required this.totalScore,
    required this.gamesPlayed,
    required this.bestScore,
    required this.lastPlayedAt,
    this.rank,
  });

  double get averageScore =>
      gamesPlayed == 0 ? 0 : totalScore / gamesPlayed;

  LeaderboardEntry copyWith({
    String? uid,
    String? displayName,
    String? photoUrl,
    int? totalScore,
    int? gamesPlayed,
    int? bestScore,
    DateTime? lastPlayedAt,
    int? rank,
  }) {
    return LeaderboardEntry(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      totalScore: totalScore ?? this.totalScore,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      bestScore: bestScore ?? this.bestScore,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      rank: rank ?? this.rank,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'totalScore': totalScore,
    'gamesPlayed': gamesPlayed,
    'bestScore': bestScore,
    'lastPlayedAt': lastPlayedAt,
  };

  /// Caller must convert Timestamp → DateTime before calling.
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, {int? rank}) {
    return LeaderboardEntry(
      uid: json['uid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Anonymous',
      photoUrl: json['photoUrl'] as String?,
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
      gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
      bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
      lastPlayedAt: json['lastPlayedAt'] as DateTime? ?? DateTime.now(),
      rank: rank,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    displayName,
    photoUrl,
    totalScore,
    gamesPlayed,
    bestScore,
    lastPlayedAt,
    rank,
  ];
}
