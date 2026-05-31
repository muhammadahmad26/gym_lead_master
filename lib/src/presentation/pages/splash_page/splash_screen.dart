import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/admin_main_page.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_home_page/member_home_page.dart';
import 'package:gym_lead_master/src/presentation/pages/splash_page/initial_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ==========================================
  // ANIMATION CONTROLLERS
  // ==========================================
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loaderController;

  // ANIMATIONS
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _taglineFadeAnimation;
  late Animation<double> _bottomFadeAnimation;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _initializeApp();
  }

  // ==========================================
  // SETUP STAGGERED ANIMATIONS
  // ==========================================
  void _setupAnimations() {
    // LOGO: Scale + Fade (0ms - 1200ms)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // TEXT: Fade + Slide (600ms - 1800ms)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _textSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );

    // BOTTOM: Fade (1000ms - 2000ms)
    _bottomFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // LOADER: Spinning
    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  void _startAnimations() async {
    // Staggered start
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();
    _loaderController.repeat();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  // ==========================================
  // AUTH CHECK + NAVIGATION
  // ==========================================
  Future<void> _initializeApp() async {
    try {
      // Minimum splash display time (3 seconds)
      await Future.delayed(const Duration(seconds: 3));

      // Check auth state
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User is logged in — determine role
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String role = userDoc.data() is Map<String, dynamic>
              ? (userDoc.data() as Map<String, dynamic>)['role'] ?? 'member'
              : 'member';

          // Save gymId to SharedPreferences for quick access
          String gymId =
              (userDoc.data() as Map<String, dynamic>)['gymId'] ?? '';
          if (gymId.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('gymId', gymId);
          }

          if (!_navigated) {
            _navigated = true;
            _navigateToScreen(
              role == 'admin'
                  ? const adminHomePage()
                  : const MemeberHomePage(),
            );
          }
        } else {
          // User exists in Auth but not Firestore — go to login
          if (!_navigated) {
            _navigated = true;
            _navigateToScreen(const InitialPages());
          }
        }
      } else {
        // Not logged in — go to initial page
        if (!_navigated) {
          _navigated = true;
          _navigateToScreen(const InitialPages());
        }
      }
    } catch (e) {
      print("Splash auth error: $e");
      // On error, go to login screen
      if (!_navigated) {
        _navigated = true;
        _navigateToScreen(const InitialPages());
      }
    }
  }

  // Smooth fade transition to next screen
  void _navigateToScreen(Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }

  // ==========================================
  // UI BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A), // Dark Blue
              Color(0xFF1E293B), // Mid Dark
              Color(0xFF2563EB), // Royal Blue
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ==========================================
            // BACKGROUND GLOW EFFECTS (Premium touch)
            // ==========================================
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF97316).withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981).withOpacity(0.06),
                ),
              ),
            ),

            // ==========================================
            // MAIN CONTENT
            // ==========================================
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // LOGO SECTION (Scale + Fade)
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoFadeAnimation.value,
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: size.width * 0.35,
                      height: size.width * 0.35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            'assets/images/app_main_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // APP NAME (Fade + Slide)
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textFadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, _textSlideAnimation.value),
                          child: child,
                        ),
                      );
                    },
                    child: const Text(
                      "Gym Lead Master",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // TAGLINE (Fade)
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _taglineFadeAnimation.value,
                        child: child,
                      );
                    },
                    child: const Text(
                      "Smart Gym Management Solution",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFFF97316),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // LOADING INDICATOR (Spinning)
                  AnimatedBuilder(
                    animation: _loaderController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _loaderController.value * 6.28, // Full rotation
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CustomPaint(
                        painter: _LoaderPainter(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // BOTTOM SECTION (Fade)
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _bottomFadeAnimation.value,
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          "Version 1.0.0",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.4),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "© 2026 Gym Lead Master",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// CUSTOM PREMIUM LOADER PAINTER
// ==========================================
class _LoaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 3.0;
    final Paint paint = Paint()
      ..color = const Color(0xFFF97316) // Orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Rect rect = Offset.zero & size;
    const double startAngle = 0.0;
    const double sweepAngle = 4.7; // ~270 degrees

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

    // Secondary dim arc
    final Paint dimPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, sweepAngle, 1.57, false, dimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}