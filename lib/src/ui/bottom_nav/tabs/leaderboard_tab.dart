import '../../../core/imports/imports.dart';
import '../../../data/models/leaderboard_entry_model.dart';
import '../../../ui/auth/providers/session_provider.dart';
import '../../../ui/leaderboard/provider/leaderboard_provider.dart';

// ── Medal helpers ─────────────────────────────────────────────────────────────

Color _medalColor(int rank, BuildContext context) => switch (rank) {
  1 => const Color(0xFFFFD700), // gold
  2 => const Color(0xFFC0C0C0), // silver
  3 => const Color(0xFFCD7F32), // bronze
  _ => context.colors.outlineVariant,
};

String _medalEmoji(int rank) => switch (rank) {
  1 => '🥇',
  2 => '🥈',
  3 => '🥉',
  _ => '#$rank',
};

// ── Leaderboard Tab ───────────────────────────────────────────────────────────

class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({super.key});

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardProvider>().loadFirstPage();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<LeaderboardProvider>().loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();
    final session = context.watch<SessionProvider>();
    final currentUid = session.user?.id;

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () => context.read<LeaderboardProvider>().refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Hero Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _LeaderboardHeader()
                  .animate()
                  .fadeIn(duration: AppDurations.normal),
            ),

            // ── Podium (top 3) ───────────────────────────────────────────────
            if (!provider.isLoading || provider.entries.isNotEmpty)
              SliverToBoxAdapter(
                child: _Podium(
                  entries: provider.entries.take(3).toList(),
                  currentUid: currentUid,
                ).animate().fadeIn(
                      delay: const Duration(milliseconds: 150),
                      duration: AppDurations.normal,
                    ),
              ),

            // ── Rank list (4+) ───────────────────────────────────────────────
            if (provider.isLoading && provider.entries.isEmpty)
              SliverPadding(
                padding: EdgeInsets.all(AppSpacing.pagePadding),
                sliver: SliverList.separated(
                  itemCount: 8,
                  separatorBuilder: (_, _) =>
                      SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) => Skeletonizer(
                    enabled: true,
                    child: _RankCard(
                      entry: _dummyEntry(i + 4),
                      isCurrentUser: false,
                    ),
                  ),
                ),
              )
            else if (provider.entries.isEmpty && provider.error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(
                  onRetry: () =>
                      context.read<LeaderboardProvider>().loadFirstPage(),
                ),
              )
            else if (provider.entries.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(),
              )
            else if (provider.entries.length > 3)
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                ),
                sliver: SliverList.separated(
                  itemCount: provider.entries.length - 3,
                  separatorBuilder: (_, _) =>
                      SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final entry = provider.entries[index + 3];
                    return _RankCard(
                      entry: entry,
                      isCurrentUser: entry.uid == currentUid,
                    ).animate().fadeIn(
                          delay: Duration(
                            milliseconds: index.clamp(0, 6) * 50,
                          ),
                          duration: AppDurations.normal,
                        );
                  },
                ),
              ),

            // ── Load more ────────────────────────────────────────────────────
            if (provider.entries.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.all(AppSpacing.pagePadding),
                sliver: SliverToBoxAdapter(
                  child: provider.hasMore
                      ? _LoadMoreIndicator(
                          isLoading: provider.isLoading,
                          onTap: () =>
                              context.read<LeaderboardProvider>().loadNextPage(),
                        )
                      : Center(
                          child: Text(
                            '— End of leaderboard —',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                ),
              ),

            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}

LeaderboardEntry _dummyEntry(int rank) => LeaderboardEntry(
  uid: 'dummy_$rank',
  displayName: 'Player $rank',
  totalScore: 100 - (rank * 5),
  gamesPlayed: 10,
  bestScore: 50,
  lastPlayedAt: DateTime.now(),
  rank: rank,
);

// ── Leaderboard Header ────────────────────────────────────────────────────────

class _LeaderboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.xl,
        AppSpacing.pagePadding,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDarkMode
              ? [
                  Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.65),
                    context.colors.tertiary,
                  ),
                  Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.65),
                    context.colors.primary,
                  ),
                ]
              : [
                  context.colors.tertiary,
                  context.colors.primary,
                ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: AppBorders.md,
                  ),
                  child: Icon(
                    Icons.leaderboard_rounded,
                    color: Colors.white,
                    size: 22.r,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Leaderboard',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Compete globally. Climb the ranks.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Podium (top 3) ────────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String? currentUid;

  const _Podium({required this.entries, this.currentUid});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    // Order: 2nd on left, 1st in center (raised), 3rd on right.
    final first = entries.isNotEmpty ? entries[0] : null;
    final second = entries.length > 1 ? entries[1] : null;
    final third = entries.length > 2 ? entries[2] : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.lg,
        AppSpacing.pagePadding,
        AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (second != null)
            Expanded(
              child: _PodiumCard(
                entry: second,
                height: 120.h,
                isCurrentUser: second.uid == currentUid,
              ),
            ),
          SizedBox(width: AppSpacing.sm),
          // 1st place — raised
          if (first != null)
            Expanded(
              flex: 3,
              child: _PodiumCard(
                entry: first,
                height: 150.h,
                isCurrentUser: first.uid == currentUid,
              ),
            ),
          SizedBox(width: AppSpacing.sm),
          // 3rd place
          if (third != null)
            Expanded(
              child: _PodiumCard(
                entry: third,
                height: 100.h,
                isCurrentUser: third.uid == currentUid,
              ),
            ),
        ],
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final double height;
  final bool isCurrentUser;

  const _PodiumCard({
    required this.entry,
    required this.height,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final rank = entry.rank ?? 1;
    final medal = _medalColor(rank, context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Medal emoji
        Text(
          _medalEmoji(rank),
          style: TextStyle(fontSize: 22.sp),
        ),
        SizedBox(height: AppSpacing.xs),

        // Avatar
        Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: medal, width: 2.5),
            color: context.colors.surfaceContainerHigh,
          ),
          child: ClipOval(
            child: entry.photoUrl != null
                ? CachedNetworkImage(
                    imageUrl: entry.photoUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => _NameCircle(entry.displayName),
                  )
                : _NameCircle(entry.displayName),
          ),
        ),
        SizedBox(height: AppSpacing.xs),

        // Name
        Text(
          entry.displayName.split(' ').first,
          style: context.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isCurrentUser ? context.colors.primary : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xs),

        // Podium bar
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: isCurrentUser
                ? context.colors.primaryContainer
                : context.colors.surfaceContainerHigh,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppBorders.md.topLeft.x),
            ),
            border: Border.all(
              color: isCurrentUser ? context.colors.primary : medal,
              width: isCurrentUser ? 2 : 1.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xs),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bolt_rounded,
                  size: 16.r,
                  color: isCurrentUser
                      ? context.colors.primary
                      : context.colors.onSurfaceVariant,
                ),
                Text(
                  '${entry.totalScore}',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? context.colors.primary : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${entry.gamesPlayed} games',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 9.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NameCircle extends StatelessWidget {
  final String name;
  const _NameCircle(this.name);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.primaryContainer,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colors.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ── Rank Card (4+) ────────────────────────────────────────────────────────────

class _RankCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _RankCard({required this.entry, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    final rank = entry.rank ?? 0;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? context.colors.primaryContainer.withValues(alpha: 0.5)
            : context.colors.surfaceContainerLow,
        borderRadius: AppBorders.lg,
        border: Border.all(
          color: isCurrentUser
              ? context.colors.primary.withValues(alpha: 0.5)
              : context.colors.outlineVariant,
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHigh,
              borderRadius: AppBorders.sm,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),

          // Avatar
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.surfaceContainerHigh,
            ),
            child: ClipOval(
              child: entry.photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: entry.photoUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) =>
                          _NameCircle(entry.displayName),
                    )
                  : _NameCircle(entry.displayName),
            ),
          ),
          SizedBox(width: AppSpacing.sm),

          // Name + games
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.displayName,
                        style: context.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCurrentUser
                              ? context.colors.primary
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 1.r,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primary,
                          borderRadius: AppBorders.full,
                        ),
                        child: Text(
                          'You',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onPrimary,
                            fontSize: 9.sp,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${entry.gamesPlayed} games · best ${entry.bestScore}pts',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Total score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.totalScore}',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser
                      ? context.colors.primary
                      : context.colors.onSurface,
                ),
              ),
              Text(
                'pts',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Load More Indicator ───────────────────────────────────────────────────────

class _LoadMoreIndicator extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _LoadMoreIndicator({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? SizedBox(
              width: 24.r,
              height: 24.r,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.primary,
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(Icons.expand_more_rounded, size: 18.r),
              label: const Text('Load more'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.primary,
                side: BorderSide(color: context.colors.outlineVariant),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppBorders.full,
                ),
              ),
            ),
    );
  }
}

// ── Empty / Error States ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: context.colors.tertiaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.leaderboard_outlined,
                size: 40.r,
                color: context.colors.onTertiaryContainer,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'No scores yet',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Be the first to complete a quiz and claim the top spot!',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56.r,
              color: context.colors.error,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Couldn\'t load leaderboard',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Check your internet connection and try again.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
