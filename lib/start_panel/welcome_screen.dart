import 'package:flutter/material.dart';
import '../login/user_manual.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _colorAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _colorAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));
    
    _colorAnimation = ColorTween(
      begin: const Color(0xFF6A5AE0),
      end: const Color(0xFFE91E63),
    ).animate(_colorAnimationController);

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FF),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Logo with animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6A5AE0).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Welcome text with animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF6A5AE0), Color(0xFFE91E63)],
                          ).createShader(bounds),
                          child: const Text(
                            'Welcome to\nBizconnect!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        const Text(
                          'The Entrepreneur Chat App',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B7ED8),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        const Text(
                          'Together, We Build Business',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // Get Started button with animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedBuilder(
                      animation: _colorAnimation,
                      builder: (context, child) {
                        return Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_colorAnimation.value!, _colorAnimation.value!.withValues(alpha: 0.8)],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: _colorAnimation.value!.withValues(alpha: 0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserManual(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _colorAnimationController.dispose();
    super.dispose();
  }
}