import '../../../core/imports/imports.dart';
import '../../../data/models/result_model.dart';
import '../../../ui/auth/providers/session_provider.dart';
import '../../../ui/profile/provider/result_history_provider.dart';
import '../../auth/providers/auth_provider.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dt.day}/${dt.month}/${dt.year}';
}

Color _difficultyColor(String d, BuildContext context) => switch (d) {
  'easy' => context.appColors.success,
  'medium' => context.appColors.warning,
  'hard' => context.colors.error,
  _ => context.colors.primary,
};

IconData _difficultyIcon(String d) => switch (d) {
  'easy' => Icons.sentiment_satisfied_rounded,
  'medium' => Icons.sentiment_neutral_rounded,
  'hard' => Icons.whatshot_rounded,
  _ => Icons.shuffle_rounded,
};

// ── Profile Tab ───────────────────────────────────────────────────────────────

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initProvider();
    _scrollController.addListener(_onScroll);
  }

  void _initProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final session = context.read<SessionProvider>();
      final uid = session.user?.id;
      if (uid != null) {
        await context.read<ResultHistoryProvider>().init(
          uid: uid,
          displayName: session.user?.name,
          photoUrl: session.user?.photoUrl,
        );
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ResultHistoryProvider>().loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final provider = context.watch<ResultHistoryProvider>();
    final user = session.user;

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () => context.read<ResultHistoryProvider>().loadFirstPage(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _ProfileHeader(
                name: user?.name ?? 'Player',
                email: user?.email ?? '',
                photoUrl: user?.photoUrl,
                results: provider.results,
              ).animate().fadeIn(duration: AppDurations.normal),
            ),

            // ── Section label ────────────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.lg,
                AppSpacing.pagePadding,
                AppSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child:
                    Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 18.r,
                          color: context.colors.primary,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Quiz History',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (provider.results.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2.r,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.primaryContainer,
                              borderRadius: AppBorders.full,
                            ),
                            child: Text(
                              '${provider.results.length} games',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colors.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ).animate().fadeIn(
                      delay: const Duration(milliseconds: 150),
                      duration: AppDurations.normal,
                    ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────────────
            if (provider.isLoading && provider.results.isEmpty)
              SliverPadding(
                padding: EdgeInsets.all(AppSpacing.pagePadding),
                sliver: SliverList.separated(
                  itemCount: 5,
                  separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, _) => Skeletonizer(
                    enabled: true,
                    child: _ResultCard(result: _dummyResult, index: 0),
                  ),
                ),
              )
            else if (provider.results.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyHistory().animate().fadeIn(
                  duration: AppDurations.normal,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                ),
                sliver: SliverList.separated(
                  itemCount: provider.results.length,
                  separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) =>
                      _ResultCard(
                        result: provider.results[index],
                        index: index,
                      ).animate().fadeIn(
                        delay: Duration(milliseconds: index.clamp(0, 5) * 60),
                        duration: AppDurations.normal,
                      ),
                ),
              ),

            // ── Load more ────────────────────────────────────────────────────
            if (provider.results.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.all(AppSpacing.pagePadding),
                sliver: SliverToBoxAdapter(
                  child: provider.hasMore
                      ? _LoadMoreButton(
                          isLoading: provider.isLoading,
                          onTap: () => context
                              .read<ResultHistoryProvider>()
                              .loadNextPage(),
                        )
                      : Center(
                          child: Text(
                            'All caught up ✓',
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

// ── Dummy result for skeleton ─────────────────────────────────────────────────

final _dummyResult = ResultModel(
  totalQuestions: 10,
  correctCount: 7,
  score: 70,
  selectedAnswers: List.filled(10, 'answer'),
  categoryName: 'General Knowledge',
  difficulty: 'medium',
  questionType: 'any',
  timestamp: DateTime.now(),
);

// ── Profile Header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final List<ResultModel> results;

  const _ProfileHeader({
    required this.name,
    required this.email,
    this.photoUrl,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    // Aggregate stats from loaded results.
    final totalScore = results.fold<int>(0, (sum, r) => sum + r.score);
    final bestScore = results.isEmpty
        ? 0
        : results.map((r) => r.score).reduce((a, b) => a > b ? a : b);
    final avgAccuracy = results.isEmpty
        ? 0.0
        : results.fold<double>(0, (sum, r) => sum + r.accuracy) /
              results.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDarkMode
              ? [
                  Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.65),
                    context.colors.primary,
                  ),
                  Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.65),
                    context.colors.secondary,
                  ),
                ]
              : [context.colors.primary, context.colors.secondary],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            children: [
              // Avatar + name + Logout icon
              Row(
                children: [
                  _Avatar(photoUrl: photoUrl, name: name),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: context.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.r),
                        Text(
                          email,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: .centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.logout_rounded,
                        color: context.colors.error,
                      ),
                      onPressed: () =>
                          context.read<AuthProvider>().logout(context: context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),

              // Stats row
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: AppBorders.lg,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _HeaderStat(
                      label: 'Games',
                      value: '${results.length}',
                      icon: Icons.sports_esports_rounded,
                    ),
                    _VerticalDivider(),
                    _HeaderStat(
                      label: 'Total Score',
                      value: '$totalScore',
                      icon: Icons.star_rounded,
                    ),
                    _VerticalDivider(),
                    _HeaderStat(
                      label: 'Best',
                      value: '$bestScore',
                      icon: Icons.emoji_events_rounded,
                    ),
                    _VerticalDivider(),
                    _HeaderStat(
                      label: 'Accuracy',
                      value: '${avgAccuracy.toStringAsFixed(0)}%',
                      icon: Icons.track_changes_rounded,
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

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final String name;

  const _Avatar({this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.r,
      height: 64.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: photoUrl != null
            ? CachedNetworkImage(
                imageUrl: photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => _InitialAvatar(name: name),
                errorWidget: (_, _, _) => _InitialAvatar(name: name),
              )
            : _InitialAvatar(name: name),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String name;
  const _InitialAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: context.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeaderStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 18.r),
        SizedBox(height: 4.r),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36.h,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}

// ── Result Card ───────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final ResultModel result;
  final int index;

  const _ResultCard({required this.result, required this.index});

  @override
  Widget build(BuildContext context) {
    final accuracy = result.accuracy;
    final scoreColor = accuracy >= 70
        ? context.appColors.success
        : accuracy >= 50
        ? context.appColors.warning
        : context.colors.error;

    final diffColor = _difficultyColor(result.difficulty, context);
    final diffIcon = _difficultyIcon(result.difficulty);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: AppBorders.lg,
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: category + score ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  result.categoryName,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              // Score gradient pill
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3.r,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scoreColor, scoreColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: AppBorders.full,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, color: Colors.white, size: 12.r),
                    SizedBox(width: 2.r),
                    Text(
                      '${result.score} pts',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // ── Middle row: correct / wrong / skipped badges ───────────────
          Row(
            children: [
              _StatBadge(
                label: '${result.correctCount} correct',
                color: context.appColors.success,
              ),
              SizedBox(width: AppSpacing.xs),
              _StatBadge(
                label: '${result.wrongCount} wrong',
                color: context.colors.error,
              ),
              if (result.skippedCount > 0) ...[
                SizedBox(width: AppSpacing.xs),
                _StatBadge(
                  label: '${result.skippedCount} skipped',
                  color: context.colors.onSurfaceVariant,
                ),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.sm),

          // ── Bottom row: difficulty + type + time ───────────────────────
          Row(
            children: [
              // Difficulty badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2.r,
                ),
                decoration: BoxDecoration(
                  color: diffColor.withValues(alpha: 0.12),
                  borderRadius: AppBorders.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(diffIcon, size: 10.r, color: diffColor),
                    SizedBox(width: 3.r),
                    Text(
                      result.difficulty.toUpperCase(),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: diffColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              // Type badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2.r,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHigh,
                  borderRadius: AppBorders.xs,
                ),
                child: Text(
                  result.questionType == 'boolean'
                      ? 'T/F'
                      : result.questionType.toUpperCase(),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 9.sp,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.access_time_rounded,
                size: 12.r,
                color: context.colors.onSurfaceVariant,
              ),
              SizedBox(width: 4.r),
              Text(
                _relativeTime(result.timestamp),
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

class _StatBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppBorders.xs,
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Load More Button ──────────────────────────────────────────────────────────

class _LoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _LoadMoreButton({required this.isLoading, required this.onTap});

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

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
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
                color: context.colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.quiz_outlined,
                size: 40.r,
                color: context.colors.onPrimaryContainer,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'No games yet',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Complete a quiz to see your history here.',
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
