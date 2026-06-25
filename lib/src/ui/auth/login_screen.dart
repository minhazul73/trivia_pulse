
import '../../core/imports/core_imports.dart';
import '../../core/imports/packages_imports.dart';

import 'providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((AuthProvider p) => p.isLoading);
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isDark = context.isDarkMode;

    Future<void> handleLogin() async {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      context.read<AuthProvider>().login(
            context: context,
            email: _emailController.text,
            password: _passwordController.text,
          );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (_, _) => CustomPaint(
                painter: _AuthBackgroundPainter(
                  t: _floatController.value,
                  isDark: isDark,
                  primary: cs.primary,
                  secondary: cs.secondary,
                  tertiary: cs.tertiary,
                ),
              ),
            ),
          ),

          // Floating decorative orbs
          ..._buildFloatingOrbs(cs, isDark),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 24.h),
                        AnimatedBuilder(
                          animation: _floatAnimation,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: child,
                          ),
                          child: _buildLogoSection(cs, tt),
                        ),
                        SizedBox(height: 32.h),
                        _buildGlassCard(
                          context: context,
                          cs: cs,
                          tt: tt,
                          isDark: isDark,
                          isLoading: isLoading,
                          onLogin: handleLogin,
                        ),
                        SizedBox(height: 24.h),
                        _buildSocialSection(context, cs, tt, isDark, isLoading),
                        SizedBox(height: 28.h),
                        _buildSignupLink(context, cs, tt),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection(ColorScheme cs, TextTheme tt) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (_, child) =>
              Transform.scale(scale: _pulseAnimation.value, child: child),
          child: Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cs.primary, cs.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.5),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.psychology_rounded,
              color: cs.onPrimary,
              size: 40.sp,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        ShaderMask(
          shaderCallback: (bounds) =>
              LinearGradient(colors: [cs.primary, cs.tertiary])
                  .createShader(bounds),
          child: Text(
            'Welcome Back!',
            style: tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Continue your trivia journey \u{1F9E0}',
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.65),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({
    required BuildContext context,
    required ColorScheme cs,
    required TextTheme tt,
    required bool isDark,
    required bool isLoading,
    required VoidCallback onLogin,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: isDark
            ? cs.surface.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.88),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign In',
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              SizedBox(height: 20.h),
              AppTextField(
                controller: _emailController,
                enabled: !isLoading,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(Icons.email_rounded,
                    color: cs.primary, size: 20.sp),
                validator: (v) {
                  if (AppUtils.isBlank(v)) return 'Email is required';
                  if (!AppUtils.isValidEmail(v!)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 14.h),
              AppTextField(
                controller: _passwordController,
                enabled: !isLoading,
                label: 'Password',
                obscureText: _obscurePassword,
                prefixIcon: Icon(Icons.lock_rounded,
                    color: cs.primary, size: 20.sp),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: cs.onSurfaceVariant,
                    size: 20.sp,
                  ),
                  onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) {
                  if (AppUtils.isBlank(v)) return 'Password is required';
                  if (v!.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () =>
                        setState(() => _rememberMe = !_rememberMe),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: _rememberMe
                                ? cs.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: _rememberMe
                                  ? cs.primary
                                  : cs.outlineVariant,
                              width: 1.5,
                            ),
                          ),
                          child: _rememberMe
                              ? Icon(Icons.check_rounded,
                                  color: cs.onPrimary, size: 14.sp)
                              : null,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Remember Me',
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () =>
                        context.push(AppRoutes.forgotPassword),
                    child: Text(
                      'Forgot Password?',
                      style: tt.bodySmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _GradientButton(
                label: 'Sign In',
                isLoading: isLoading,
                onPressed: isLoading ? null : onLogin,
                cs: cs,
                tt: tt,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialSection(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
    bool isDark,
    bool isLoading,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: AppDivider(color: cs.outlineVariant)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                'or continue with',
                style:
                    tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            Expanded(child: AppDivider(color: cs.outlineVariant)),
          ],
        ),
        SizedBox(height: 16.h),
        _GoogleSignInButton(
          isDark: isDark,
          isLoading: isLoading,
          cs: cs,
          tt: tt,
          onPressed: isLoading
              ? null
              : () => context
                  .read<AuthProvider>()
                  .loginWithGoogle(context: context),
        ),
      ],
    );
  }

  Widget _buildSignupLink(
      BuildContext context, ColorScheme cs, TextTheme tt) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.signup),
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: tt.bodyMedium
              ?.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
          children: [
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                  color: cs.primary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingOrbs(ColorScheme cs, bool isDark) {
    return [
      Positioned(
        top: -40,
        right: -40,
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (_, _) => Transform.translate(
            offset: Offset(0, _floatAnimation.value * 0.5),
            child: Container(
              width: 180.w,
              height: 180.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    cs.primary
                        .withValues(alpha: isDark ? 0.25 : 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 100,
        left: -60,
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (_, _) => Transform.translate(
            offset: Offset(0, -_floatAnimation.value * 0.7),
            child: Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    cs.secondary
                        .withValues(alpha: isDark ? 0.2 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        top: 80,
        left: 20,
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (_, _) => Transform.translate(
            offset: Offset(
                _floatAnimation.value * 0.3, _floatAnimation.value),
            child: Icon(Icons.quiz_rounded,
                size: 22.sp,
                color: cs.primary.withValues(alpha: 0.3)),
          ),
        ),
      ),
      Positioned(
        top: 140,
        right: 28,
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (_, _) => Transform.translate(
            offset: Offset(-_floatAnimation.value * 0.4,
                -_floatAnimation.value),
            child: Icon(Icons.stars_rounded,
                size: 18.sp,
                color: cs.tertiary.withValues(alpha: 0.35)),
          ),
        ),
      ),
    ];
  }
}

// ── Background painter ─────────────────────────────────────────────────────
class _AuthBackgroundPainter extends CustomPainter {
  const _AuthBackgroundPainter({
    required this.t,
    required this.isDark,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  final double t;
  final bool isDark;
  final Color primary;
  final Color secondary;
  final Color tertiary;

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isDark
        ? Color.lerp(
            const Color(0xFF0D0D1A), const Color(0xFF111128), t)!
        : Color.lerp(
            const Color(0xFFF0F2FF), const Color(0xFFF5F0FF), t)!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = baseColor,
    );

    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          primary.withValues(alpha: isDark ? 0.18 : 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.1),
        radius: size.width * 0.55,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.1),
        size.width * 0.55,
        paint1);

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          secondary.withValues(alpha: isDark ? 0.15 : 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.15, size.height * 0.85),
        radius: size.width * 0.5,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.85),
        size.width * 0.5,
        paint2);
  }

  @override
  bool shouldRepaint(_AuthBackgroundPainter old) =>
      old.t != t || old.isDark != isDark;
}

// ── Gradient CTA button ────────────────────────────────────────────────────
class _GradientButton extends StatefulWidget {
  const _GradientButton({
    required this.label,
    required this.cs,
    required this.tt,
    this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final ColorScheme cs;
  final TextTheme tt;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.65 : 1.0,
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          if (!isDisabled) widget.onPressed?.call();
        },
        onTapCancel: () => _pressController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (_, child) =>
              Transform.scale(scale: _scaleAnim.value, child: child),
          child: Container(
            width: double.infinity,
            height: 54.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.cs.primary,
                  Color.lerp(
                      widget.cs.primary, widget.cs.secondary, 0.6)!,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.cs.primary.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: widget.isLoading
                    ? SizedBox(
                        key: const ValueKey('loader'),
                        width: 22.w,
                        height: 22.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: widget.cs.onPrimary,
                        ),
                      )
                    : Text(
                        key: const ValueKey('label'),
                        widget.label,
                        style: widget.tt.titleMedium?.copyWith(
                          color: widget.cs.onPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Google Sign-In button ──────────────────────────────────────────────────
class _GoogleSignInButton extends StatefulWidget {
  const _GoogleSignInButton({
    required this.isDark,
    required this.isLoading,
    required this.cs,
    required this.tt,
    this.onPressed,
  });

  final bool isDark;
  final bool isLoading;
  final ColorScheme cs;
  final TextTheme tt;
  final VoidCallback? onPressed;

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton>
    with SingleTickerProviderStateMixin {
  static const _googleRed = Color(0xFFEA4335);

  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scaleAnim = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.6 : 1.0,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          if (!isDisabled) widget.onPressed?.call();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (_, child) =>
              Transform.scale(scale: _scaleAnim.value, child: child),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            height: 52.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: widget.isDark
                  ? widget.cs.surfaceContainerHighest
                  : Colors.white,
              border: Border.all(
                color: widget.cs.outlineVariant,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _googleRed.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(
                      alpha: widget.isDark ? 0.25 : 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: widget.isLoading
                    ? SizedBox(
                        key: const ValueKey('loader'),
                        width: 22.w,
                        height: 22.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: _googleRed,
                        ),
                      )
                    : Row(
                        key: const ValueKey('content'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppAssets.googleIcon,
                            width: 22.w,
                            height: 22.h,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Continue with Google',
                            style: widget.tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: widget.cs.onSurface,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
