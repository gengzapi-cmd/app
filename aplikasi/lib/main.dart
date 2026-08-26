import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SnipsterApp());
}

class SnipsterApp extends StatelessWidget {
  const SnipsterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snipster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.outfitTextTheme(),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingSlide {
  final IconData icon;
  final String tag;
  final String title;
  final String subtitle;

  const OnboardingSlide({
    required this.icon,
    required this.tag,
    required this.title,
    required this.subtitle,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _currentSlide = 0;
  bool _isFullscreenLoading = false;
  double _loadingOpacity = 1.0;
  double _progress = 0.0;
  String _currentLog = "MENYIAPKAN CORE ENGINE...";

  late VideoPlayerController _videoController;
  late AnimationController _spinController;
  late AnimationController _slideFadeController;
  Timer? _progressTimer;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      icon: Icons.share_rounded,
      tag: "Tutorial",
      title: "Salin Tautan",
      subtitle:
          "Temukan video di platfrom favorit anda, klik bagikan lalu klik salin tautan",
    ),
    OnboardingSlide(
      icon: Icons.content_paste_rounded,
      tag: "Tutorial",
      title: "Tempel Tautan",
      subtitle: "Tempel tautan yang anda salin ke input tautan",
    ),
    OnboardingSlide(
      icon: Icons.search_rounded,
      tag: "Tutorial",
      title: "Cari & Unduh",
      subtitle: "Klik tombol cari, lihat pratinjau, pilih resolusi dan unduh",
    ),
    OnboardingSlide(
      icon: Icons.fast_forward_rounded,
      tag: "Snipster",
      title: "Unduh apa saja",
      subtitle:
          "Tempel tautan, cari, pilih resolusi, simpan, that simple bro",
    ),
  ];

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _slideFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: 1.0,
    );

    _videoController = VideoPlayerController.asset(
      'assets/videos/kucingnew.mp4',
    )..initialize().then((_) {
        _videoController.setLooping(true);
        setState(() {});
      });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _slideFadeController.dispose();
    _videoController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _goToSlide(int index) {
    if (index == _currentSlide) return;

    _spinController.forward(from: 0.0);
    _slideFadeController.reverse().then((_) {
      setState(() {
        _currentSlide = index;
      });
      _slideFadeController.forward();
    });
  }

  void _handleNextAction() {
    if (_currentSlide < 3) {
      _goToSlide(_currentSlide + 1);
    } else {
      _startAppLoading();
    }
  }

  void _startAppLoading() {
    setState(() {
      _isFullscreenLoading = true;
    });

    _videoController.seekTo(Duration.zero);
    _videoController.setPlaybackSpeed(0.7); // SLOW-MOTION AT 0.7X
    _videoController.play();

    const totalDurationMs = 5000;
    const updateIntervalMs = 50;
    final stepIncrement = 100.0 / (totalDurationMs / updateIntervalMs);

    _progressTimer = Timer.periodic(
      const Duration(milliseconds: updateIntervalMs),
      (timer) {
        setState(() {
          _progress += stepIncrement;
          if (_progress > 100) _progress = 100;

          final pct = _progress.round();
          if (pct <= 20) {
            _currentLog = "MENYIAPKAN CORE ENGINE...";
          } else if (pct <= 40) {
            _currentLog = "MENGINSTALL LIBRARY MEDIA...";
          } else if (pct <= 65) {
            _currentLog = "MENGINSTALL FFMPEG DECODER...";
          } else if (pct <= 85) {
            _currentLog = "MENGHUBUNGKAN AKSELERASI...";
          } else if (pct < 100) {
            _currentLog = "MEMVERIFIKASI SISTEM...";
          } else {
            _currentLog = "SELESAI";
          }

          // AT 90% LOADING, CAT WAKES UP IN SMOOTH SPEED
          if (_progress >= 90) {
            _videoController.setPlaybackSpeed(1.0);
          }

          if (_progress >= 100) {
            timer.cancel();
            _currentLog = "SELESAI 100%";

            // FADE OUT LOADING SCREEN SMOOTHLY
            Future.delayed(const Duration(milliseconds: 600), () {
              if (mounted) {
                setState(() {
                  _loadingOpacity = 0.0;
                });
              }
            });
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentSlideData = _slides[_currentSlide];

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: Center(
        child: Container(
          width: size.width > 420 ? 360 : size.width,
          height: size.height > 800 ? 740 : size.height,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(size.width > 420 ? 46 : 0),
            border: size.width > 420
                ? Border.all(color: const Color(0xFF1C1B22), width: 8)
                : null,
            boxShadow: size.width > 420
                ? [
                    BoxShadow(
                      color: const Color(0xFFDC2626).withOpacity(0.35),
                      blurRadius: 60,
                      offset: const Offset(0, 25),
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Vibrant Crimson Background Gradient
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF87171),
                      Color(0xFFEF4444),
                      Color(0xFF991B1B),
                    ],
                  ),
                ),
              ),

              // Soft Mesh Backdrop
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size.height * 0.6,
                child: Opacity(
                  opacity: 0.15,
                  child: Container(
                    decoration: BoxDecoration(
                      radialGradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        radius: 0.8,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Sheet Container
              AnimatedPositioned(
                duration: const Duration(milliseconds: 650),
                curve: const Cubic(0.16, 1.0, 0.3, 1.0),
                bottom: 0,
                left: 0,
                right: 0,
                height: _isFullscreenLoading ? (size.height > 800 ? 740 : size.height) : 395,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: _loadingOpacity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: _isFullscreenLoading
                          ? BorderRadius.zero
                          : const BorderRadius.only(
                              topLeft: Radius.elliptical(180, 34),
                              topRight: Radius.elliptical(180, 34),
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 40,
                          offset: const Offset(0, -12),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        // Floating Black Logo Box
                        if (!_isFullscreenLoading)
                          Positioned(
                            top: -43,
                            child: RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: _spinController,
                                  curve: Curves.easeInOutBack,
                                ),
                              ),
                              child: Container(
                                width: 86,
                                height: 86,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 32,
                                      offset: const Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    currentSlideData.icon,
                                    color: Colors.white,
                                    size: 42,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Onboarding Content
                        if (!_isFullscreenLoading)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 64, 24, 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FadeTransition(
                                  opacity: _slideFadeController,
                                  child: Column(
                                    children: [
                                      // Red Pill Tag
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEE2E2),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Text(
                                          currentSlideData.tag,
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFDC2626),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Title
                                      Text(
                                        currentSlideData.title,
                                        style: GoogleFonts.outfit(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF111827),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      // Subtitle
                                      Text(
                                        currentSlideData.subtitle,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF6B7280),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Action Button
                                GestureDetector(
                                  onTap: _handleNextAction,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeOutBack,
                                    height: 56,
                                    width: _currentSlide == 3 ? 220 : 56,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      gradient: _currentSlide == 3
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFFEF4444),
                                                Color(0xFFDC2626),
                                              ],
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(
                                        _currentSlide == 3 ? 18 : 16,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFEF4444)
                                              .withOpacity(0.4),
                                          blurRadius: 24,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (_currentSlide == 3) ...[
                                          Text(
                                            'Mulai Sekarang',
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Dots Indicator
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(4, (index) {
                                    final isActive = index == _currentSlide;
                                    return GestureDetector(
                                      onTap: () => _goToSlide(index),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 350,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        width: isActive ? 22 : 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFFE5E7EB),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),

                        // Fullscreen Loading View
                        if (_isFullscreenLoading)
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Video Player Stack
                                SizedBox(
                                  width: 280,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      if (_videoController.value.isInitialized)
                                        AspectRatio(
                                          aspectRatio: _videoController
                                              .value.aspectRatio,
                                          child: VideoPlayer(_videoController),
                                        ),

                                      // White Bottom Mask Patch (7px height)
                                      Container(
                                        height: 7,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),

                                // Loading Bar Overlay Positioned Exactly at 61% Gap
                                Positioned(
                                  top: (size.height > 800 ? 740 : size.height) * 0.61 - 11,
                                  child: Container(
                                    width: 260,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(11),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 3,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Dynamic Progress Fill
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          bottom: 0,
                                          width: 260 * (_progress / 100.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFFEF4444),
                                                  Color(0xFFDC2626),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                            ),
                                          ),
                                        ),

                                        // Dynamic Tech Log Text inside bar
                                        Text(
                                          '$_currentLog ${_progress.round()}%',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            shadows: const [
                                              Shadow(
                                                color: Colors.black54,
                                                blurRadius: 2,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                            letterSpacing: 0.3,
                                          ),
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
                ),
              ),

              // Home Bar Indicator
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 120,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(2),
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
