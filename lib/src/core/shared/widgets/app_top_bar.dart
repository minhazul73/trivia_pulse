import '../../imports/imports.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.centerTitle = true,
    this.onPressed,
    this.isTransparent = false,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final VoidCallback? onPressed;
  final bool? centerTitle;
  final bool isTransparent;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bool canPop = context.canPop();

    void handleBack() {
      if (onPressed != null) {
        onPressed!();
      } else if (canPop) {
        context.pop();
      } else {
        context.go(AppRoutes.bottomNav);
      }
    }

    final titleContent = titleWidget ??
        (title == null
            ? null
            : Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ));

    return AppBar(
      centerTitle: centerTitle,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isTransparent
          ? Colors.transparent
          : theme.colorScheme.surface.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      title: titleContent,
      leadingWidth: 56.w,
      leading: !canPop
          ? null
          : Padding(
              padding: EdgeInsets.only(left: AppSpacing.sm),
              child: GestureDetector(
                onTap: handleBack,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: AppBorders.md,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 18.r,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
      actions: [
        ...?actions,
        SizedBox(width: AppSpacing.xs),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
