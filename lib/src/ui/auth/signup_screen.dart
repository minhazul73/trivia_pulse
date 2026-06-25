
import '../../core/imports/core_imports.dart';
import '../../core/imports/packages_imports.dart';

import 'providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.35),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

    Future<void> handleSignup() async {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      context.read<AuthProvider>().signUp(
            context: context,
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
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
                painter: _SignupBackgroundPainter(
                  t: _floatController.value,
                  isDark: isDark,
                  primary: cs.primary,
                  secondary: cs.secondary,
                  tertiary: cs.tertiary,
                ),
              ),
            ),
          ),

          // Decorative elements
          ..._buildDecorations(cs, isDark),

          // Content
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
                        SizedBox(height: 20.h),
                        AnimatedBuilder(
                          animation: _floatAnimation,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(0, _floatAnimation.value * 0.8),
                            child: child,
                          ),
                          child: _buildHeroSection(cs, tt),
                        ),
                        SizedBox(height: 28.h),
                        _buildFormCard(
                          context: context,
                          cs: cs,
                          tt: tt,
                          isDark: isDark,
                          isLoading: isLoading,
                          onSignup: handleSignup,
                        ),
                        SizedBox(height: 28.h),
                        _buildLoginLink(context, cs, tt),
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

  Widget _buildHeroSection(ColorScheme cs, TextTheme tt) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (_, child) =>
              Transform.scale(scale: _pulseAnimation.value, child: child),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      cs.primary.withValues(alpha: 0),
                      cs.primary.withValues(alpha: 0.35),
                      cs.secondary.withValues(alpha: 0.35),
                      cs.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              // Inner icon container
              Container(
                width: 76.w,
                height: 76.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.secondary, cs.primary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.secondary.withValues(alpha: 0.5),
                      blurRadius: 22,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  color: cs.onSecondary,
                  size: 36.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [cs.secondary, cs.primary, cs.tertiary],
          ).createShader(bounds),
          child: Text(
            'Create Account',
            style: tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Join & start your trivia adventure \u{1F3AE}',
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.65),
            letterSpacing: 0.2,
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
    required VoidCallback onSignup,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: isDark
            ? cs.surface.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.88),
        border: Border.all(
          color: cs.secondary.withValues(alpha: isDark ? 0.3 : 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.secondary.withValues(alpha: isDark ? 0.2 : 0.12),
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
                'Your Details',
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              SizedBox(height: 20.h),

              // Name
              AppTextField(
                controller: _nameController,
                enabled: !isLoading,
                label: 'Full Name',
                prefixIcon: Icon(Icons.person_rounded,
                    color: cs.secondary, size: 20.sp),
                validator: (v) {
                  if (AppUtils.isBlank(v)) return 'Name is required';
                  return null;
                },
              ),
              SizedBox(height: 14.h),

              // Email
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

              // Password
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
              SizedBox(height: 14.h),

              // Confirm Password
              AppTextField(
                controller: _confirmPasswordController,
                enabled: !isLoading,
                label: 'Confirm Password',
                obscureText: _obscureConfirmPassword,
                prefixIcon: Icon(Icons.lock_outline_rounded,
                    color: cs.primary, size: 20.sp),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: cs.onSurfaceVariant,
                    size: 20.sp,
                  ),
                  onPressed: () => setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                validator: (v) {
                  if (AppUtils.isBlank(v)) {
                    return 'Confirm password is required';
                  }
                  if (v != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              SizedBox(height: 28.h),

              // Sign up button with secondary gradient
              _GradientSignupButton(
                label: 'Create Account',
                isLoading: isLoading,
                onPressed: isLoading ? null : onSignup,
                cs: cs,
                tt: tt,
              ),

              SizedBox(height: 16.h),

              // Terms notice
              Center(
                child: Text(
                  'By signing up, you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(
      BuildContext context, ColorScheme cs, TextTheme tt) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.login),
      child: RichText(
        text: TextSpan(
          text: 'Already have an account? ',
          style: tt.bodyMedium
              ?.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
          children: [
            TextSpan(
              text: 'Log In',
              style: TextStyle(
                  color: cs.primary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDecorations(ColorScheme cs, bool isDark) {
    return [
      Positioned(
        top: -30,
        left: -50,
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (_, _) => Transform.translate(
            offset: Offset(_floatAnimation.value * 0.4,
                _floatAnimation.value * 0.6),
            child: Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    cs.secondary
                        .withValues(alpha: isDark ? 0.22 : 0.13),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 60,
        right: -50,
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (_, _) => Transform.translate(
            offset: Offset(-_floatAnimation.value * 0.5,
                -_floatAnimation.value * 0.4),
            child: Container(
              width: 180.w,
              height: 180.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    cs.primary
                        .withValues(alpha: isDark ? 0.18 : 0.11),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        top: 60,
        right: 24,
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (_, _) => Transform.rotate(
            angle: _floatAnimation.value * 0.05,
            child: Icon(Icons.emoji_events_rounded,
                size: 20.sp,
                color: cs.tertiary.withValues(alpha: 0.3)),
          ),
        ),
      ),
      Positioned(
        top: 130,
        left: 18,
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (_, _) => Transform.translate(
            offset: Offset(
                _floatAnimation.value * 0.3, _floatAnimation.value),
            child: Icon(Icons.lightbulb_rounded,
                size: 18.sp,
                color: cs.secondary.withValues(alpha: 0.3)),
          ),
        ),
      ),
    ];
  }
}

// ── Signup background painter (different gradient feel) ───────────────────
class _SignupBackgroundPainter extends CustomPainter {
  const _SignupBackgroundPainter({
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
            const Color(0xFF0E0D1C), const Color(0xFF120E1F), t)!
        : Color.lerp(
            const Color(0xFFF2F0FF), const Color(0xFFF8F0FF), t)!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = baseColor,
    );

    // Top-left blob
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          secondary.withValues(alpha: isDark ? 0.2 : 0.13),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.1, size.height * 0.08),
        radius: size.width * 0.5,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.08),
        size.width * 0.5,
        paint1);

    // Bottom-right blob
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          primary.withValues(alpha: isDark ? 0.15 : 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.9, size.height * 0.92),
        radius: size.width * 0.48,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.92),
        size.width * 0.48,
        paint2);
  }

  @override
  bool shouldRepaint(_SignupBackgroundPainter old) =>
      old.t != t || old.isDark != isDark;
}

// ── Signup gradient button (secondary-primary) ────────────────────────────
class _GradientSignupButton extends StatefulWidget {
  const _GradientSignupButton({
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
  State<_GradientSignupButton> createState() =>
      _GradientSignupButtonState();
}

class _GradientSignupButtonState extends State<_GradientSignupButton>
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
                  widget.cs.secondary,
                  Color.lerp(
                      widget.cs.secondary, widget.cs.primary, 0.55)!,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      widget.cs.secondary.withValues(alpha: 0.45),
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
                          color: widget.cs.onSecondary,
                        ),
                      )
                    : Text(
                        key: const ValueKey('label'),
                        widget.label,
                        style: widget.tt.titleMedium?.copyWith(
                          color: widget.cs.onSecondary,
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
