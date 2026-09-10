import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../data/models/user_model.dart';
import '../../../state/app_state.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/welcome_screen.dart';
import '../pebisnis/pebisnis_home_screen.dart';
import '../petani/petani_home_screen.dart';

class SplashScreen extends StatefulWidget {
  final Duration duration;
  final bool autoNavigate;

  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 2600),
    this.autoNavigate = true,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _footerFade;
  late Animation<double> _pulseGlow;

  Timer? _navigationTimer;
  String _loadingMessage = 'Menginisialisasi layanan pertanian...';
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // 1. Intro entrance animation
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeIn),
      ),
    );

    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
      ),
    );

    // 2. Ambient subtle pulsing glow around the logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseGlow = Tween<double>(begin: 0.88, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. Dynamic progress controller
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _progressController.addListener(() {
      final val = _progressController.value;
      if (!mounted) return;
      if (val < 0.4) {
        if (_loadingMessage != 'Menginisialisasi sistem pertanian...') {
          setState(() => _loadingMessage = 'Menginisialisasi sistem pertanian...');
        }
      } else if (val < 0.8) {
        if (_loadingMessage != 'Menghubungkan rantai pasok digital...') {
          setState(() => _loadingMessage = 'Menghubungkan rantai pasok digital...');
        }
      } else {
        if (_loadingMessage != 'Selamat Datang di AgriSync!') {
          setState(() => _loadingMessage = 'Selamat Datang di AgriSync!');
        }
      }
    });

    _introController.forward();
    _progressController.forward();

    if (widget.autoNavigate) {
      _navigationTimer = Timer(widget.duration, () {
        _navigateToTarget();
      });
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _introController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _navigateToTarget() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    final appState = Provider.of<AppState>(context, listen: false);

    Widget targetScreen;
    if (!appState.isLoggedIn) {
      targetScreen = const WelcomeScreen();
    } else {
      switch (appState.currentUser.role) {
        case UserRole.pebisnis:
          targetScreen = const  PebisnisHomeScreen();
          break;
        case UserRole.petani:
          targetScreen = const PetaniHomeScreen();
          break;
        case UserRole.admin:
          targetScreen = const AdminDashboardScreen();
          break;
      }
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 650),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: InkWell(
        onTap: () {
          // Allow instant skip on tap
          _navigationTimer?.cancel();
          _navigateToTarget();
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1B3813), // Deep forest botanical green
                Color(0xFF2D571C), // Rich agricultural green
                Color(0xFF457E24), // Vibrant emerald olive
                Color(0xFF1E3812), // Grounded dark green
              ],
              stops: [0.0, 0.35, 0.72, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Ambient Decorative Background Circles
              Positioned(
                top: -size.width * 0.25,
                right: -size.width * 0.25,
                child: Container(
                  width: size.width * 0.85,
                  height: size.width * 0.85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7BCA38).withOpacity(0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -size.width * 0.3,
                left: -size.width * 0.3,
                child: Container(
                  width: size.width * 0.9,
                  height: size.width * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF5BA626).withOpacity(0.16),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main Content
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),

                        // Animated Glowing Logo Emblem
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _introController,
                            _pulseController,
                          ]),
                          builder: (context, child) {
                            return Opacity(
                              opacity: _logoFade.value,
                              child: Transform.scale(
                                scale: _logoScale.value,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outer Ripple Glow Rings
                                    Transform.scale(
                                      scale: _pulseGlow.value,
                                      child: Container(
                                        width: 146,
                                        height: 146,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF86E342).withOpacity(0.25),
                                            width: 2.0,
                                          ),
                                          gradient: RadialGradient(
                                            colors: [
                                              const Color(0xFF72C330).withOpacity(0.25),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Secondary Pulse Ring
                                    Transform.scale(
                                      scale: (_pulseGlow.value * 1.12).clamp(0.8, 1.3),
                                      child: Container(
                                        width: 170,
                                        height: 170,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFFB5F47E).withOpacity(0.12),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Core White Circular Emblem with Sprout & Shadow
                                    Container(
                                      width: 118,
                                      height: 118,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color(0xFF82DC39),
                                          width: 3.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 28,
                                            offset: const Offset(0, 10),
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFF67B72A).withOpacity(0.4),
                                            blurRadius: 22,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: CustomPaint(
                                          size: const Size(68, 68),
                                          painter: _SplashSproutPainter(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        // Animated Title & Taglines
                        AnimatedBuilder(
                          animation: _introController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _textFade.value,
                              child: Transform.translate(
                                offset: Offset(0, _textSlide.value),
                                child: Column(
                                  children: [
                                    // Brand Name
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Agri',
                                          style: GoogleFonts.merriweather(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: -0.8,
                                          ),
                                        ),
                                        Text(
                                          'Sync',
                                          style: GoogleFonts.merriweather(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFFA5F46A),
                                            letterSpacing: -0.8,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    // Pill Tagline
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Rantai Pasok Pertanian Digital',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFE5F9D7),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Subtitle
                                    Text(
                                      'Menghubungkan Petani & Pebisnis Indonesia',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.78),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const Spacer(flex: 3),

                        // Progress bar & Loading status text
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _introController,
                            _progressController,
                          ]),
                          builder: (context, child) {
                            return Opacity(
                              opacity: _footerFade.value,
                              child: Column(
                                children: [
                                  // Animated smooth progress bar
                                  Container(
                                    width: 180,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return Container(
                                          width: constraints.maxWidth *
                                              _progressController.value,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF86E342),
                                                Color(0xFFC7FCA2),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF86E342)
                                                    .withOpacity(0.7),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Status message text
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      _loadingMessage,
                                      key: ValueKey(_loadingMessage),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.85),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Footer Version Tag
                        AnimatedBuilder(
                          animation: _introController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _footerFade.value,
                              child: Text(
                                'AgriSync v2.4 • Smart Agricultural Ecosystem',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.5),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Sprout Painter for high-fidelity botanical splash emblem
class _SplashSproutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF5BA626),
          Color(0xFF387216),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = const Color(0xFF1E3A12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Center sprout bud
    final pathBud = Path();
    pathBud.moveTo(w * 0.5, h * 0.12);
    pathBud.quadraticBezierTo(w * 0.68, h * 0.35, w * 0.5, h * 0.58);
    pathBud.quadraticBezierTo(w * 0.32, h * 0.35, w * 0.5, h * 0.12);
    canvas.drawPath(pathBud, paintFill);
    canvas.drawPath(pathBud, paintStroke);

    // Left leaf
    final pathLeft = Path();
    pathLeft.moveTo(w * 0.46, h * 0.54);
    pathLeft.cubicTo(w * 0.12, h * 0.52, w * 0.08, h * 0.88, w * 0.46, h * 0.88);
    pathLeft.cubicTo(w * 0.46, h * 0.72, w * 0.34, h * 0.62, w * 0.46, h * 0.54);
    canvas.drawPath(pathLeft, paintFill);
    canvas.drawPath(pathLeft, paintStroke);

    // Right leaf
    final pathRight = Path();
    pathRight.moveTo(w * 0.54, h * 0.54);
    pathRight.cubicTo(w * 0.88, h * 0.52, w * 0.92, h * 0.88, w * 0.54, h * 0.88);
    pathRight.cubicTo(w * 0.54, h * 0.72, w * 0.66, h * 0.62, w * 0.54, h * 0.54);
    canvas.drawPath(pathRight, paintFill);
    canvas.drawPath(pathRight, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
