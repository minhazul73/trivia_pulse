import '../../core/imports/imports.dart';
import '../quiz/provider/quiz_provider.dart';

/// Maps category names to fitting icons for visual richness.
IconData _iconForCategory(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('science')) return Icons.science_rounded;
  if (lower.contains('math') || lower.contains('mathemat')) {
    return Icons.calculate_rounded;
  }
  if (lower.contains('history')) return Icons.account_balance_rounded;
  if (lower.contains('geograph')) return Icons.public_rounded;
  if (lower.contains('sport')) return Icons.sports_soccer_rounded;
  if (lower.contains('music')) return Icons.music_note_rounded;
  if (lower.contains('film') || lower.contains('movie')) {
    return Icons.movie_rounded;
  }
  if (lower.contains('art')) return Icons.palette_rounded;
  if (lower.contains('animal')) return Icons.pets_rounded;
  if (lower.contains('politic')) return Icons.how_to_vote_rounded;
  if (lower.contains('computer') || lower.contains('tech')) {
    return Icons.computer_rounded;
  }
  if (lower.contains('book') || lower.contains('literature')) {
    return Icons.menu_book_rounded;
  }
  if (lower.contains('food') || lower.contains('gadgets')) {
    return Icons.fastfood_rounded;
  }
  if (lower.contains('vehicle') || lower.contains('car')) {
    return Icons.directions_car_rounded;
  }
  if (lower.contains('tv') || lower.contains('television')) {
    return Icons.tv_rounded;
  }
  if (lower.contains('video game')) return Icons.videogame_asset_rounded;
  if (lower.contains('comic') || lower.contains('manga')) {
    return Icons.auto_stories_rounded;
  }
  if (lower.contains('anime')) return Icons.theaters_rounded;
  if (lower.contains('celebrity') || lower.contains('people')) {
    return Icons.star_rounded;
  }
  if (lower.contains('myth')) return Icons.flare_rounded;
  return Icons.quiz_rounded;
}

/// Generates a deterministic accent color per category based on its id.
Color _accentForCategory(int id, BuildContext context) {
  final colors = [
    const Color(0xFF6C63FF), // indigo-violet
    const Color(0xFF00BFA5), // teal
    const Color(0xFFFF6B6B), // coral-red
    const Color(0xFFFFD93D), // amber
    const Color(0xFF4ECDC4), // mint
    const Color(0xFFFF8C42), // orange
    const Color(0xFFA259FF), // purple
    const Color(0xFF1CB0F6), // sky blue
  ];
  return colors[id % colors.length];
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final categories = quizProvider.categories;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HeroHeader().animate().fadeIn(
              duration: AppDurations.normal,
            ),
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
                      Text(
                        'Choose a Category',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (quizProvider.isLoading)
                        SizedBox(
                          width: 16.r,
                          height: 16.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.primary,
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.primaryContainer,
                            borderRadius: AppBorders.full,
                          ),
                          child: Text(
                            '${categories.length} topics',
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

          // ── Category grid ────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            sliver: quizProvider.isLoading
                ? _SkeletonGrid()
                : categories.isEmpty
                ? SliverToBoxAdapter(child: _EmptyState())
                : SliverList.separated(
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _CategoryCard(
                        category: category,
                        delay: Duration(milliseconds: 200 + index * 50),
                      );
                    },
                  ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }
}

// ── Hero Header ───────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.xl,
        AppSpacing.pagePadding,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDarkMode
              ? [
                  // In dark mode M3 primary is very light — blend heavily toward
                  // black so white text always stays legible.
                  Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.65),
                    context.colors.primary,
                  ),
                  Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.65),
                    context.colors.tertiary,
                  ),
                ]
              : [context.colors.primary, context.colors.tertiary],
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
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Trivia Pulse',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Test Your\nKnowledge',
              style: context.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Pick a topic and start your quiz adventure. How much do you know?',
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            // Quick stats row
            Row(
              children: [
                const _HeroStat(
                  icon: Icons.category_rounded,
                  label: 'Categories',
                ),
                SizedBox(width: AppSpacing.md),
                const _HeroStat(icon: Icons.timer_rounded, label: '15s per Q'),
                SizedBox(width: AppSpacing.md),
                const _HeroStat(icon: Icons.star_rounded, label: '10 pts each'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 14.r),
        SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Category Card ─────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final dynamic category;
  final Duration delay;

  const _CategoryCard({required this.category, required this.delay});

  @override
  Widget build(BuildContext context) {
    final accent = _accentForCategory(category.id, context);
    final icon = _iconForCategory(category.name);
    final count = category.questionCount?.totalQuestionCount;
    final easy = category.questionCount?.totalEasyQuestionCount ?? 0;
    final medium = category.questionCount?.totalMediumQuestionCount ?? 0;
    final hard = category.questionCount?.totalHardQuestionCount ?? 0;

    return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppBorders.lg,
            onTap: () => context.push(
              AppRoutes.quizCustomization,
              extra: {'category': category},
            ),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLow,
                borderRadius: AppBorders.lg,
                border: Border.all(
                  color: context.colors.outlineVariant,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icon bubble
                  Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: AppBorders.md,
                    ),
                    child: Icon(icon, color: accent, size: 26.r),
                  ),
                  SizedBox(width: AppSpacing.md),

                  // Name + stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        if (count != null)
                          Row(
                            children: [
                              _MiniDiffBadge(
                                label: 'E',
                                count: easy,
                                color: context.appColors.success,
                              ),
                              SizedBox(width: AppSpacing.xs),
                              _MiniDiffBadge(
                                label: 'M',
                                count: medium,
                                color: context.appColors.warning,
                              ),
                              SizedBox(width: AppSpacing.xs),
                              _MiniDiffBadge(
                                label: 'H',
                                count: hard,
                                color: context.colors.error,
                              ),
                              const Spacer(),
                              Text(
                                '$count Qs',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            'Loading counts...',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),

                  // Chevron
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14.r,
                    color: context.colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: delay, duration: AppDurations.normal)
        .slideX(
          begin: 0.08,
          end: 0,
          delay: delay,
          duration: AppDurations.normal,
          curve: AppCurves.emphasized,
        );
  }
}

class _MiniDiffBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _MiniDiffBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 1.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppBorders.xs,
      ),
      child: Text(
        '$label·$count',
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}

// ── Skeleton Grid ─────────────────────────────────────────────────────────────

class _SkeletonGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: 8,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => Skeletonizer(
        enabled: true,
        child: Container(
          height: 72.h,
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLow,
            borderRadius: AppBorders.lg,
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 56.r,
            color: context.colors.onSurfaceVariant,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No categories available',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Check your connection and try again.',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
