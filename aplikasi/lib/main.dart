import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const SnipsterApp());
}

class SnipsterApp extends StatelessWidget {
  const SnipsterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapCat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.outfitTextTheme(),
        useMaterial3: true,
      ),
      home: const RootScreen(),
    );
  }
}

/// RootScreen manages the Stacked Layering:
/// Layer 0 (Bottom): MainAppScreen (always ready underneath)
/// Layer 1 (Top): SplashOverlay Container (fades out smoothly over 2.0 seconds when loading completes)
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  bool _splashVisible = true;
  double _splashOpacity = 1.0;

  void _onLoadingFinished() {
    // Smooth 2.0 Second Fade Out (2000ms) matching index.html prototype
    setState(() {
      _splashOpacity = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // MAIN APP SCREEN - PLACED UNDERNEATH AT ALL TIMES
          const MainAppScreen(),

          // SPLASH SCREEN OVERLAY - PLACED ON TOP FOR SLOW FADE OUT
          if (_splashVisible)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeInOut,
              opacity: _splashOpacity,
              onEnd: () {
                if (_splashOpacity == 0.0) {
                  setState(() {
                    _splashVisible = false;
                  });
                }
              },
              child: SplashOverlay(
                onLoadingFinished: _onLoadingFinished,
              ),
            ),
        ],
      ),
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

class SplashOverlay extends StatefulWidget {
  final VoidCallback onLoadingFinished;

  const SplashOverlay({
    super.key,
    required this.onLoadingFinished,
  });

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay>
    with TickerProviderStateMixin {
  int _currentSlide = 0;

  // Animation States for startAppLoading Sequence
  bool _isFadingOutOnboarding = false;
  bool _hideOnboardingContent = false;
  bool _isSheetFullscreen = false;
  bool _showLoadingScreen = false;
  double _loadingFadeOpacity = 0.0;

  // Progress Bar State
  double _progress = 0.0;
  String _currentLog = "MENYIAPKAN CORE ENGINE...";

  // Controllers
  late AnimationController _entranceController;
  late AnimationController _spinController;
  late AnimationController _slideTextController;
  late VideoPlayerController _videoController;
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
      tag: "SnapCat",
      title: "Unduh apa saja",
      subtitle:
          "Tempel tautan, cari, pilih resolusi, simpan, that simple bro",
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Initial Load Entrance Pop-In Animation (0.8s)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    // Spin Right 360° + Scale Pulse Controller (0.55s)
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    // Slide Body Text Fade-Out Down & Slide-In Up Controller (0.35s)
    _slideTextController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: 1.0,
    );

    // Initialize Video Controller
    _videoController = VideoPlayerController.asset(
      'assets/videos/kucingnew.mp4',
    )..initialize().then((_) {
        _videoController.setLooping(true);
        if (mounted) setState(() {});
      });

    // Start Initial Entrance Animation
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _spinController.dispose();
    _slideTextController.dispose();
    _videoController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _goToSlide(int index) {
    if (index == _currentSlide || _isFadingOutOnboarding) return;

    // Trigger Spin 360° Animation
    _spinController.forward(from: 0.0);

    // Slide Text Fade-Out Down
    _slideTextController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _currentSlide = index;
        });
        // Slide Text Slide-In Up
        _slideTextController.forward();
      }
    });
  }

  void _handleActionClick() {
    if (_isFadingOutOnboarding) return;

    if (_currentSlide == 3) {
      _startAppLoadingSequence();
    } else {
      _goToSlide(_currentSlide + 1);
    }
  }

  /// Exact 100% Timing & Sequence from index.html prototype `startAppLoading()`:
  /// 1. Logo Box & Onboarding content FADE OUT over 1.0 SECOND (1000ms).
  /// 2. Visible 1-SECOND DELAY (1000ms) before upward glide.
  /// 3. Bottom Sheet glides UP smoothly to top (-34px) in 0.65s (650ms).
  /// 4. Fade in loading screen (0.5s) & start cat video + 5.0s progress bar.
  /// 5. At 100%, wait 400ms delay then call `onLoadingFinished` to trigger 2.0s Fade Out.
  void _startAppLoadingSequence() {
    // Step 1: Fade out logo box and onboarding content over 1.0s
    setState(() {
      _isFadingOutOnboarding = true;
    });

    // Step 2: After 1000ms delay, hide content and glide sheet upwards
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      setState(() {
        _hideOnboardingContent = true;
        _isSheetFullscreen = true;
      });

      // Step 3: After sheet reaches top (650ms delay), fade in loading screen
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;

        setState(() {
          _showLoadingScreen = true;
        });

        // Trigger loading screen fade-in opacity (500ms)
        Future.microtask(() {
          if (mounted) {
            setState(() {
              _loadingFadeOpacity = 1.0;
            });
          }
        });

        // Start playing video at 0.7x speed
        _videoController.seekTo(Duration.zero);
        _videoController.setPlaybackSpeed(0.7);
        _videoController.play();

        // Start 5.0 Second Progress Bar Interval (50ms step = 1% per step)
        const totalDurationMs = 5000;
        const updateIntervalMs = 50;
        final stepIncrement = 100.0 / (totalDurationMs / updateIntervalMs);

        _progressTimer = Timer.periodic(
          const Duration(milliseconds: updateIntervalMs),
          (timer) {
            if (!mounted) return;

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

              if (_progress >= 90) {
                _videoController.setPlaybackSpeed(1.0);
              }

              if (_progress >= 100) {
                timer.cancel();
                _currentLog = "SELESAI 100%";

                // Step 4: After 400ms delay, call onLoadingFinished to trigger 2.0s Fade Out
                Future.delayed(const Duration(milliseconds: 400), () {
                  if (mounted) {
                    widget.onLoadingFinished();
                  }
                });
              }
            });
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final currentSlideData = _slides[_currentSlide];

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: [
          // AMBIENT ROSE-RED BACKGROUND WITH SOFT MESH OVERLAY
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF87171),
                    Color(0xFFEF4444),
                    Color(0xFF991B1B),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Soft Radial Mesh Pattern Overlay
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: screenHeight * 0.6,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.4),
                          radius: 0.85,
                          colors: [
                            Colors.white.withOpacity(0.22),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // PURE WHITE BOTTOM SHEET CONTAINER (Z-INDEX 100)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 650),
            curve: const Cubic(0.16, 1.0, 0.3, 1.0),
            top: _isSheetFullscreen ? -34.0 : (screenHeight - 395.0),
            left: 0,
            right: 0,
            height: _isSheetFullscreen ? (screenHeight + 34.0) : 395.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
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
                  // FLOATING BLACK LOGO BOX WITH SPIN 360° & SCALE PULSE
                  if (!_hideOnboardingContent)
                    Positioned(
                      top: -43,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.ease,
                        opacity: _isFadingOutOnboarding ? 0.0 : 1.0,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.ease,
                          scale: _isFadingOutOnboarding ? 0.5 : 1.0,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _entranceController,
                              _spinController,
                            ]),
                            builder: (context, child) {
                              // Entrance Pop-In Animation (scale 0.3 -> 1.0, rotate -15deg -> 0deg)
                              final entranceVal = CurvedAnimation(
                                parent: _entranceController,
                                curve: const Cubic(0.34, 1.56, 0.64, 1.0),
                              ).value;
                              final entranceScale = 0.3 + (0.7 * entranceVal);
                              final entranceRotate =
                                  -0.26 * (1.0 - entranceVal); // ~ -15deg

                              // Spin Right 360° Animation on Slide Change with Scale Pulse (0.85 -> 1.18 -> 1.0)
                              final spinVal = _spinController.value;
                              final spinRotate = spinVal * 2 * 3.14159265;
                              double spinScale = 1.0;
                              if (spinVal > 0 && spinVal < 0.5) {
                                spinScale = 1.0 - (0.15 * (spinVal / 0.5));
                              } else if (spinVal >= 0.5) {
                                spinScale = 0.85 + (0.15 * ((spinVal - 0.5) / 0.5));
                              }

                              return Transform.scale(
                                scale: entranceScale * spinScale,
                                child: Transform.rotate(
                                  angle: entranceRotate + spinRotate,
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
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                  // ONBOARDING SHEET CONTENT (TAG, TITLE, SUBTITLE, BUTTON, DOTS)
                  if (!_hideOnboardingContent)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.ease,
                      opacity: _isFadingOutOnboarding ? 0.0 : 1.0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 64, 24, 20),
                        child: Column(
                          children: [
                            // Animated Slide Body
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _slideTextController,
                                builder: (context, child) {
                                  final val = _slideTextController.value;
                                  final opacity = val;
                                  // Fade-out down (offset 10), slide-in up (offset -10 to 0)
                                  final dy = (1.0 - val) * 10.0;

                                  return Transform.translate(
                                    offset: Offset(0, dy),
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 6),
                                          // RED PILL TAG
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
                                          // TITLE
                                          Text(
                                            currentSlideData.title,
                                            style: GoogleFonts.outfit(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF111827),
                                              letterSpacing: -0.5,
                                              height: 1.15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // SUBTITLE
                                          SizedBox(
                                            height: 44,
                                            child: Center(
                                              child: Text(
                                                currentSlideData.subtitle,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(0xFF6B7280),
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // DYNAMIC ACTION BUTTON (Morphs from round 56x56 to 220 start button)
                            GestureDetector(
                              onTap: _handleActionClick,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                curve: const Cubic(0.34, 1.56, 0.64, 1.0),
                                height: 56,
                                width: _currentSlide == 3 ? 220 : 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  gradient: _currentSlide == 3
                                      ? const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_currentSlide == 3) ...[
                                      Text(
                                        'Mulai Sekarang',
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 4 CAROUSEL DOTS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (index) {
                                final isActive = index == _currentSlide;
                                return GestureDetector(
                                  onTap: () => _goToSlide(index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 350),
                                    curve: const Cubic(0.34, 1.56, 0.64, 1.0),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    width: isActive ? 22 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),

                  // FULLSCREEN LOADING INTERFACE WITH INTEGRATED PROGRESS BAR
                  if (_showLoadingScreen)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                      opacity: _loadingFadeOpacity,
                      child: Center(
                        child: SizedBox(
                          width: 280,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // VIDEO CAT CONTAINER WITH MASKING PATCH
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 280,
                                    color: Colors.transparent,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        if (_videoController
                                            .value.isInitialized)
                                          AspectRatio(
                                            aspectRatio: _videoController
                                                .value.aspectRatio,
                                            child:
                                                VideoPlayer(_videoController),
                                          )
                                        else
                                          const SizedBox(
                                            height: 180,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: Color(0xFFEF4444),
                                              ),
                                            ),
                                          ),
                                        // Micro White Mask Patch at bottom edge
                                        Container(
                                          height: 7,
                                          width: double.infinity,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // LOADING BAR OVERLAY IN GAP BETWEEN CAT BODY AND TAIL
                                  Positioned(
                                    top: 136,
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
                                          // Red Gradient Progress Fill Track
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

                                          // HIGH CONTRAST CRISP LOG TEXT INSIDE PROGRESS BAR
                                          Text(
                                            '$_currentLog ${_progress.round()}%',
                                            style: GoogleFonts.outfit(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF111827),
                                              letterSpacing: 0.3,
                                              shadows: const [
                                                Shadow(
                                                  color: Colors.white70,
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // IPHONE BOTTOM HOME INDICATOR BAR
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
    );
  }
}

/* ========================================================
   SNAPCAT MAIN APPLICATION SCREEN (MATCHING INDEX.HTML 100%)
   ======================================================== */
class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _activeNavIndex = 0; // 0: Home, 1: Unduhan, 2: Pengaturan
  final TextEditingController _linkController = TextEditingController();

  bool _hasSearched = false;
  bool _isDropdownExpanded = true;
  int _currentSlideIndex = 0;
  late PageController _pageController;

  String _platformType = 'tiktok_video';
  String _platformName = 'TikTok';
  String _creatorHandle = '@reyaramani458';
  String _videoTitle =
      'Aesthetic Sunset Cinematic Vlog #2026 - High Quality Short';
  String _dropdownLabel = 'Pilih Format & Resolusi';
  List<Map<String, String>> _optionsList = [];

  final List<String> _slideImages = const [
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _linkController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _triggerSearch([String? presetUrl]) {
    final text = presetUrl ?? _linkController.text.trim();
    if (presetUrl != null) {
      _linkController.text = presetUrl;
    }
    final val = text.toLowerCase();

    final isTikTokSlide = val.contains('slide') || val.contains('photo');
    final isYoutubeLive = val.contains('youtube') && val.contains('live');
    final isYoutubeShorts = (val.contains('youtube') || val.contains('youtu.be')) &&
        (val.contains('shorts') || val.contains('reels'));
    final isYoutubeStandard =
        (val.contains('youtube') || val.contains('youtu.be')) &&
            !isYoutubeLive &&
            !isYoutubeShorts;

    setState(() {
      _hasSearched = true;
      _isDropdownExpanded = true;
      _currentSlideIndex = 0;

      if (isTikTokSlide) {
        _platformType = 'tiktok_photo';
        _platformName = 'TikTok Photo';
        _creatorHandle = '@nature_vibes';
        _videoTitle = 'Aesthetic Photo Collection #Slide 2026';
        _dropdownLabel = 'Pilih Foto & Format';
        _optionsList = [
          {
            'res': 'Slide 1 Foto',
            'sub': 'JPG • 2.1 MB',
            'format': 'Slide 1 JPG'
          },
          {
            'res': 'Slide 2 Foto',
            'sub': 'JPG • 1.9 MB',
            'format': 'Slide 2 JPG'
          },
          {
            'res': 'Slide 3 Foto',
            'sub': 'JPG • 2.4 MB',
            'format': 'Slide 3 JPG'
          },
          {
            'res': 'Semua Foto (ZIP)',
            'sub': 'Paket Foto • 6.4 MB',
            'format': 'Semua Slide ZIP'
          },
        ];
      } else if (isYoutubeLive) {
        _platformType = 'youtube_live';
        _platformName = 'YouTube Live';
        _creatorHandle = '@LiveGamingHQ';
        _videoTitle =
            '🔴 LIVE STREAM - Esports World Championship Final 2026';
        _dropdownLabel = 'Pilih Format & Resolusi';
        _optionsList = [
          {
            'res': '1080p Full HD',
            'sub': 'MP4 • 450 MB',
            'format': '1080p Full HD'
          },
          {
            'res': '720p HD',
            'sub': 'MP4 • 210 MB',
            'format': '720p HD'
          },
          {
            'res': 'Audio',
            'sub': 'MP3 • 45 MB',
            'format': 'Audio MP3'
          },
        ];
      } else if (isYoutubeShorts) {
        _platformType = 'youtube_shorts';
        _platformName = 'YouTube Shorts';
        _creatorHandle = '@ShortsCreator';
        _videoTitle = 'Amazing Skateboard Trick #Shorts #2026';
        _dropdownLabel = 'Pilih Format & Resolusi';
        _optionsList = [
          {
            'res': '1080p Full HD',
            'sub': 'MP4 • 18.2 MB',
            'format': 'YouTube Shorts 1080p'
          },
          {
            'res': '720p HD',
            'sub': 'MP4 • 10.5 MB',
            'format': 'YouTube Shorts 720p'
          },
          {
            'res': 'Audio',
            'sub': 'MP3 • 2.5 MB',
            'format': 'YouTube Shorts MP3'
          },
        ];
      } else if (isYoutubeStandard) {
        _platformType = 'youtube_standard';
        _platformName = 'YouTube';
        _creatorHandle = '@OfficialChannel';
        _videoTitle = 'Official Music Video 4K 2026 - Mastered Audio';
        _dropdownLabel = 'Pilih Format & Resolusi';
        _optionsList = [
          {
            'res': '1080p Full HD',
            'sub': 'MP4 • 45.5 MB',
            'format': 'YouTube 1080p'
          },
          {'res': '720p HD', 'sub': 'MP4 • 22.1 MB', 'format': 'YouTube 720p'},
          {'res': '480p SD', 'sub': 'MP4 • 12.8 MB', 'format': 'YouTube 480p'},
          {'res': 'Audio', 'sub': 'MP3 • 5.2 MB', 'format': 'YouTube MP3'},
        ];
      } else {
        _platformType = 'tiktok_video';
        _platformName = 'TikTok';
        _creatorHandle = '@reyaramani458';
        _videoTitle =
            'Aesthetic Sunset Cinematic Vlog #2026 - High Quality Short';
        _dropdownLabel = 'Pilih Format & Resolusi';
        _optionsList = [
          {
            'res': '1080p Full HD',
            'sub': 'MP4 • 24.5 MB',
            'format': 'TikTok 1080p'
          },
          {'res': '720p HD', 'sub': 'MP4 • 14.2 MB', 'format': 'TikTok 720p'},
          {'res': '480p SD', 'sub': 'MP4 • 8.1 MB', 'format': 'TikTok 480p'},
          {'res': 'Audio', 'sub': 'MP3 • 3.8 MB', 'format': 'TikTok MP3'},
        ];
      }
    });
  }

  void _handleDownloadAction(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Memulai pengunduhan untuk: $label',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      _linkController.text = data.text!;
      _triggerSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Red Aurora Header Background Glow
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [
                    const Color(0xFFEF4444).withOpacity(0.35),
                    const Color(0xFFF43F5E).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Content View (Home, Unduhan, or Pengaturan)
          SafeArea(
            child: IndexedStack(
              index: _activeNavIndex,
              children: [
                // TAB 0: HOME / DOWNLOADER INTERFACE
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Header Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.share_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SnapCat',
                                    style: GoogleFonts.outfit(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF111827),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.notifications_none_rounded,
                                color: Color(0xFF111827),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Input Bar Card
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFFF3F4F6),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.link_rounded,
                              color: Color(0xFF9CA3AF),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _linkController,
                                onSubmitted: (_) => _triggerSearch(),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF111827),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Tempel tautan disini',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _triggerSearch(),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFEF4444),
                                      Color(0xFFDC2626),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x59EF4444),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.search_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Platform Supported Shortcuts Section
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Platform Yang Di Dukung',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9CA3AF),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // TikTok Shortcut
                          GestureDetector(
                            onTap: () => _triggerSearch(
                                'https://tiktok.com/@user/video/123'),
                            child: Column(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.18),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/tiktok.png',
                                      width: 42,
                                      height: 42,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'TikTok',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48),

                          // YouTube Shortcut
                          GestureDetector(
                            onTap: () => _triggerSearch(
                                'https://youtube.com/watch?v=sample'),
                            child: Column(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/yt.png',
                                      width: 42,
                                      height: 42,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'YouTube',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Result Preview Section Header
                      Text(
                        'Pratinjau Hasil',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Empty State Placeholder (Clean text matching index.html)
                      if (!_hasSearched)
                        CustomPaint(
                          painter: DashedRectPainter(
                            color: const Color(0xFFE5E7EB),
                            strokeWidth: 1.5,
                            gap: 6.0,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 32,
                            ),
                            child: Center(
                              child: Text(
                                'Tempelkan tautan video di atas untuk melihat pratinjau hasil',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF9CA3AF),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        // Dynamic Preview Card (Matching index.html)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF3F4F6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Card Header (Platform Badge + Creator Handle)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _platformType.startsWith('tiktok')
                                          ? Colors.black
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: _platformType.startsWith('youtube')
                                          ? Border.all(
                                              color: const Color(0xFFE5E7EB),
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          _platformType.startsWith('tiktok')
                                              ? 'assets/images/tiktok.png'
                                              : 'assets/images/yt.png',
                                          width: 16,
                                          height: 16,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _platformName,
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _platformType
                                                    .startsWith('tiktok')
                                                ? Colors.white
                                                : const Color(0xFF111827),
                                            height: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _creatorHandle,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Dynamic Media Container
                              if (_platformType == 'tiktok_photo') ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    height: 240,
                                    width: double.infinity,
                                    color: Colors.black,
                                    child: Stack(
                                      children: [
                                        PageView.builder(
                                          controller: _pageController,
                                          onPageChanged: (idx) {
                                            setState(() {
                                              _currentSlideIndex = idx;
                                            });
                                          },
                                          itemCount: _slideImages.length,
                                          itemBuilder: (context, index) {
                                            return Image.network(
                                              _slideImages[index],
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                        Positioned(
                                          top: 12,
                                          left: 0,
                                          right: 0,
                                          child: Center(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.65),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'Slide ${_currentSlideIndex + 1}',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _slideImages.length,
                                    (idx) {
                                      final isActive =
                                          idx == _currentSlideIndex;
                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 3),
                                        width: isActive ? 16 : 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFFD1D5DB),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ] else ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: AspectRatio(
                                    aspectRatio:
                                        (_platformType == 'youtube_live' ||
                                                _platformType ==
                                                    'youtube_standard')
                                            ? 16 / 9
                                            : 9 / 14,
                                    child: Image.network(
                                      _platformType == 'youtube_live'
                                          ? 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800&auto=format&fit=crop&q=80'
                                          : _platformType == 'youtube_shorts'
                                              ? 'https://images.unsplash.com/photo-1520116468816-95b69f847357?w=800&auto=format&fit=crop&q=80'
                                              : 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&auto=format&fit=crop&q=80',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),

                              // Video Title Block
                              Text(
                                _videoTitle,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF111827),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Accordion Dropdown Button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isDropdownExpanded = !_isDropdownExpanded;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _dropdownLabel,
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: _isDropdownExpanded ? 0.5 : 0.0,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Color(0xFF6B7280),
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Accordion Options List
                              if (_isDropdownExpanded) ...[
                                const SizedBox(height: 10),
                                Column(
                                  children: _optionsList.map((item) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFF3F4F6),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['res'] ?? '',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(0xFF111827),
                                                ),
                                              ),
                                              Text(
                                                item['sub'] ?? '',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF6B7280),
                                                ),
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () => _handleDownloadAction(
                                              item['format'] ?? '',
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFEF4444),
                                                    Color(0xFFDC2626),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0x40EF4444),
                                                    blurRadius: 8,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .arrow_downward_rounded,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Unduh',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // TAB 1: UNDUHAN (DOWNLOAD HISTORY)
                Center(
                  child: Text(
                    'Riwayat Unduhan',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),

                // TAB 2: PENGATURAN (SETTINGS)
                Center(
                  child: Text(
                    'Pengaturan Aplikasi',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // FLOATING GLASSMORPHISM BOTTOM NAVIGATION DOCK (FIXED FLOATING)
          Positioned(
            bottom: 18,
            left: 18,
            right: 18,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 310),
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(31),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDockNavItem(0, Icons.home_rounded, 'Home'),
                    _buildDockNavItem(1, Icons.download_rounded, 'Unduhan'),
                    _buildDockNavItem(2, Icons.settings_rounded, 'Pengaturan'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDockNavItem(int index, IconData icon, String label) {
    final isActive = _activeNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeNavIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color:
                  isActive ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashed Border Painter for Empty State Box
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(20),
      ));

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
