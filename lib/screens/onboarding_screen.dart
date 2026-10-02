import 'package:flutter/material.dart';
import 'package:medisimbio_ui/screens/auth_wrapper.dart';
import 'package:medisimbio_ui/screens/splash_screen.dart';
import 'package:medisimbio_ui/services/preference_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = const [
    OnboardingData(
      title: 'Your Health\nOne Identity',
      description: 'A single Med ID for your complete health journey.',
      buttonText: 'Next',
      image: 'assets/images/onboarding_screen_01.png',
    ),
    OnboardingData(
      title: 'Complete\nHealth Journey',
      description:
          'Appointments, prescriptions, reports and more — all in one place.',
      buttonText: 'Next',
      image: 'assets/images/onboarding_screen_02.png',
    ),
    OnboardingData(
      title: 'You Control\nYour Data',
      description:
          'Choose who can access your health information, what they can access and for how long.',
      buttonText: 'Next',
      image: 'assets/images/onboarding_screen_03.png',
    ),
    OnboardingData(
      title: 'AI Health\nAssistant',
      description:
          'Describe your health concern naturally. Get structured information with few questions.',
      buttonText: 'Get Started',
      image: 'assets/images/onboarding_screen_04.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skip() {
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    // Persist hasSeenOnboarding = true locally
    await PreferenceService.setHasSeenOnboarding(value: true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthWrapper(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F8),
      body: Stack(
        children: [
          // Topographic Wave Decor Background matching Splash Screen
          const Positioned.fill(
            child: CustomPaint(
              painter: SplashWaveBackgroundPainter(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar with Skip Button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _currentPage < 3
                        ? TextButton(
                            onPressed: _skip,
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5A716E),
                              ),
                            ),
                          )
                        : const SizedBox(height: 48),
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final data = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF087F73),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              data.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF5A716E),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 42),
                            // Illustration Image
                            SizedBox(
                              height: 320,
                              child: Image.asset(
                                data.image,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 48,
                                      color: Color(0xFF5A716E),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Controls: Page Indicator + Primary Button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Column(
                    children: [
                      // Carousel Indicator Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF087F73)
                                  : const Color(0xFFC0E0DA),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 28),

                      // Full Width Primary Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF087F73),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _pages[_currentPage].buttonText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DATA MODEL
// ============================================================================

class OnboardingData {
  final String title;
  final String description;
  final String buttonText;
  final String image;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.image,
  });
}
