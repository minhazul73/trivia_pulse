import 'dart:math' as math;

import '../../core/imports/core_imports.dart';
import '../../core/imports/packages_imports.dart';

import 'providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _orbitController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _orbitAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _orbitAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _orbitController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((AuthProvider p) => p.isLoading);
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isDark = context.isDarkMode;

    Future<void> handleForgotPassword() async {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      context.read<AuthProvider>().forgotPassword(
        context: context,
        email: _emailController.text,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (_, _) => CustomPaint(
                painter: _ForgotBgPainter(
                  t: _floatController.value,
                  isDark: isDark,
                  primary: cs.primary,
                  secondary: cs.secondary,
                  tertiary: cs.tertiary,
                ),
              ),
            ),
          ),

          // Decorative floating elements
          ..._buildDecorativeElements(cs, isDark),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom back button bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    children: [_BackButton(cs: cs, isDark: isDark)],
                  ),
                ),

                // Scrollable body
                Expanded(
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
                              SizedBox(height: 8.h),
                              _buildHeroSection(cs, tt),
                              SizedBox(height: 36.h),
                              _buildFormCard(
                                context: context,
                                cs: cs,
                                tt: tt,
                                isDark: isDark,
                                isLoading: isLoading,
                                onSubmit: handleForgotPassword,
                              ),
                              SizedBox(height: 28.h),
                              _buildBackLink(context, cs, tt),
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
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(ColorScheme cs, TextTheme tt) {
    return Column(
      children: [
        // Orbiting icon animation
        SizedBox(
          width: 110.w,
          height: 110.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing outer ring
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, _) => Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              // Orbiting dot
              AnimatedBuilder(
                animation: _orbitAnimation,
                builder: (_, _) => Transform.translate(
                  offset: Offset(
                    42.w * math.cos(_orbitAnimation.value),
                    42.w * math.sin(_orbitAnimation.value),
                  ),
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.tertiary,
                      boxShadow: [
                        BoxShadow(
                          color: cs.tertiary.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Center icon
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, _floatAnimation.value * 0.5),
                  child: child,
                ),
                child: Container(
                  width: 76.w,
                  height: 76.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cs.tertiary, cs.primary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.tertiary.withValues(alpha: 0.45),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    color: cs.onTertiary,
                    size: 36.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [cs.tertiary, cs.primary],
          ).createShader(bounds),
          child: Text(
            'Reset Password',
            style: tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'No worries! Enter your email and we\'ll send you a reset link \u{1F4E7}',
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.65),
              height: 1.5,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard({
    required BuildContext context,
    required ColorScheme cs,
    required TextTheme tt,
    required bool isDark,
    required bool isLoading,
    required VoidCallback onSubmit,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: isDark
            ? cs.surface.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.88),
        border: Border.all(
          color: cs.tertiary.withValues(alpha: isDark ? 0.3 : 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.tertiary.withValues(alpha: isDark ? 0.2 : 0.1),
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
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: cs.tertiaryContainer,
                    ),
                    child: Icon(
                      Icons.mark_email_unread_rounded,
                      color: cs.onTertiaryContainer,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Enter Your Email',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              AppTextField(
                controller: _emailController,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                label: 'Email Address',
                prefixIcon: Icon(
                  Icons.email_rounded,
                  color: cs.tertiary,
                  size: 20.sp,
                ),
                validator: (v) {
                  if (AppUtils.isBlank(v)) return 'Email is required';
                  if (!AppUtils.isValidEmail(v!)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 28.h),
              _GradientResetButton(
                label: 'Send Reset Link',
                isLoading: isLoading,
                onPressed: isLoading ? null : onSubmit,
                cs: cs,
                tt: tt,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackLink(BuildContext context, ColorScheme cs, TextTheme tt) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 14.sp,
            color: cs.primary,
          ),
          SizedBox(width: 6.w),
          Text(
            'Back to Login',
            style: tt.bodyMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDecorativeElements(ColorScheme cs, bool isDark) {
    return [
      Positioned(
        top: -20,
        right: -30,
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (_, _) => Transform.translate(
            offset: Offset(0, _floatAnimation.value * 0.6),
            child: Container(
              width: 170.w,
              height: 170.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    cs.tertiary.withValues(alpha: isDark ? 0.2 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 80,
        left: -40,
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (_, _) => Transform.translate(
            offset: Offset(0, -_floatAnimation.value * 0.5),
            child: Container(
              width: 160.w,
              height: 160.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    cs.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        top: 200,
        right: 16,
        child: AnimatedBuilder(
          animation: _orbitAnimation,
          builder: (_, _) => Transform.rotate(
            angle: _orbitAnimation.value,
            child: Icon(
              Icons.key_rounded,
              size: 20.sp,
              color: cs.primary.withValues(alpha: 0.22),
            ),
          ),
        ),
      ),
    ];
  }
}

// ── Custom back button widget ──────────────────────────────────────────────
class _BackButton extends StatefulWidget {
  const _BackButton({required this.cs, required this.isDark});
  final ColorScheme cs;
  final bool isDark;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        Navigator.pop(context);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.isDark
                ? widget.cs.surfaceContainerHighest
                : Colors.white.withValues(alpha: 0.9),
            border: Border.all(color: widget.cs.outlineVariant, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: widget.cs.onSurface,
          ),
        ),
      ),
    );
  }
}

// ── Forgot password background painter ─────────────────────────────────────
class _ForgotBgPainter extends CustomPainter {
  const _ForgotBgPainter({
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
        ? Color.lerp(const Color(0xFF0F0E1D), const Color(0xFF130F20), t)!
        : Color.lerp(const Color(0xFFF3F0FF), const Color(0xFFF8F5FF), t)!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = baseColor,
    );

    final paint1 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              tertiary.withValues(alpha: isDark ? 0.18 : 0.12),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.8, size.height * 0.12),
              radius: size.width * 0.52,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.12),
      size.width * 0.52,
      paint1,
    );

    final paint2 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              primary.withValues(alpha: isDark ? 0.14 : 0.09),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.2, size.height * 0.88),
              radius: size.width * 0.45,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.88),
      size.width * 0.45,
      paint2,
    );
  }

  @override
  bool shouldRepaint(_ForgotBgPainter old) =>
      old.t != t || old.isDark != isDark;
}

// ── Reset link gradient button (tertiary-primary) ─────────────────────────
class _GradientResetButton extends StatefulWidget {
  const _GradientResetButton({
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
  State<_GradientResetButton> createState() => _GradientResetButtonState();
}

class _GradientResetButtonState extends State<_GradientResetButton>
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
                  widget.cs.tertiary,
                  Color.lerp(widget.cs.tertiary, widget.cs.primary, 0.5)!,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.cs.tertiary.withValues(alpha: 0.45),
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
                          color: widget.cs.onTertiary,
                        ),
                      )
                    : Row(
                        key: const ValueKey('label'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            color: widget.cs.onTertiary,
                            size: 18.sp,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            widget.label,
                            style: widget.tt.titleMedium?.copyWith(
                              color: widget.cs.onTertiary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
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
