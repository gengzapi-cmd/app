import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  bool _isLoadingStarted = false;
  bool _showLoadingContent = false;
  double _loadingFadeOpacity = 0.0;
  double _screenOpacity = 1.0;
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
          "Temukan video di platform favorit anda, klik bagikan lalu klik salin tautan",
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
        if (mounted) setState(() {});
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
      if (mounted) {
        setState(() {
          _currentSlide = index;
        });
        _slideFadeController.forward();
      }
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
      _isLoadingStarted = true;
    });

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;

      setState(() {
        _showLoadingContent = true;
      });

      Future.microtask(() {
        if (!mounted) return;
        setState(() {
          _loadingFadeOpacity = 1.0;
        });
      });

      _videoController.seekTo(Duration.zero);
      _videoController.setPlaybackSpeed(0.7);
      _videoController.play();

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

              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  setState(() {
                    _screenOpacity = 0.0;
                  });
                  Future.delayed(const Duration(milliseconds: 400), () {
                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const MainAppScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration:
                              const Duration(milliseconds: 800),
                        ),
                      );
                    }
                  });
                }
              });
            }
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final currentSlideData = _slides[_currentSlide];

    return Scaffold(
      backgroundColor: const Color(0xFF991B1B),
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: _screenOpacity,
        child: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            children: [
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

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: screenHeight * 0.6,
                child: Opacity(
                  opacity: 0.15,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
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

              AnimatedPositioned(
                duration: const Duration(milliseconds: 650),
                curve: const Cubic(0.16, 1.0, 0.3, 1.0),
                top: _isLoadingStarted ? -34.0 : (screenHeight - 395.0),
                left: 0,
                right: 0,
                height: _isLoadingStarted ? (screenHeight + 34.0) : 395.0,
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
                      if (!_isLoadingStarted)
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

                      if (!_isLoadingStarted)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 48, 24, 28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FadeTransition(
                                opacity: _slideFadeController,
                                child: Column(
                                  children: [
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
                                    const SizedBox(height: 12),
                                    Text(
                                      currentSlideData.title,
                                      style: GoogleFonts.outfit(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF111827),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
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

                      if (_showLoadingContent)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: _loadingFadeOpacity,
                          child: Center(
                            child: SizedBox(
                              width: screenWidth > 340
                                  ? 320
                                  : screenWidth * 0.9,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      if (_videoController.value.isInitialized)
                                        AspectRatio(
                                          aspectRatio:
                                              _videoController.value.aspectRatio,
                                          child: VideoPlayer(_videoController),
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
                                      Container(
                                        height: 7,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
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
                          ),
                        ),
                    ],
                  ),
                ),
              ),

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
            'res': 'Unduh Semua Foto (ZIP)',
            'sub': '3 Foto • HD • 8.4 MB',
            'format': 'ZIP'
          },
          {
            'res': 'Slide 1 (Foto HD)',
            'sub': 'JPG • 2.8 MB',
            'format': 'Foto 1'
          },
          {
            'res': 'Slide 2 (Foto HD)',
            'sub': 'JPG • 3.1 MB',
            'format': 'Foto 2'
          },
          {
            'res': 'Slide 3 (Foto HD)',
            'sub': 'JPG • 2.5 MB',
            'format': 'Foto 3'
          },
          {
            'res': 'Audio Musik (MP3)',
            'sub': 'MP3 • 3.2 MB',
            'format': 'Audio'
          },
        ];
      } else if (isYoutubeLive) {
        _platformType = 'youtube_live';
        _platformName = 'YouTube Live';
        _creatorHandle = '@GamingChannel';
        _videoTitle = '🔴 LIVE: Gaming Championship 2026 Final Stream';
        _dropdownLabel = 'Pilih Format & Resolusi';
        _optionsList = [
          {
            'res': '1080p60 Full HD Live',
            'sub': 'MP4 • 1.2 GB',
            'format': 'Live 1080p'
          },
          {
            'res': '720p60 HD Live',
            'sub': 'MP4 • 650 MB',
            'format': 'Live 720p'
          },
          {
            'res': '480p SD Live',
            'sub': 'MP4 • 320 MB',
            'format': 'Live 480p'
          },
          {
            'res': 'Audio Stream (MP3)',
            'sub': 'MP3 • 45.0 MB',
            'format': 'Live MP3'
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
            'res': '1080p Shorts HD',
            'sub': 'MP4 • 18.5 MB',
            'format': 'Shorts 1080p'
          },
          {
            'res': '720p Shorts',
            'sub': 'MP4 • 9.8 MB',
            'format': 'Shorts 720p'
          },
          {
            'res': 'Audio Shorts (MP3)',
            'sub': 'MP3 • 2.1 MB',
            'format': 'Shorts MP3'
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
    final mediaQuery = MediaQuery.of(context);

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
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFEF4444)
                                        .withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selamat Datang 👋',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  Text(
                                    'SnapCat',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: 38,
                            height: 38,
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
                                color: Color(0xFF374151),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Input Bar Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withOpacity(0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.link_rounded,
                              color: Color(0xFF9CA3AF),
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _linkController,
                                onSubmitted: (_) => _triggerSearch(),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF111827),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Tempelkan tautan video di sini...',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _pasteFromClipboard,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Tempel',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF4B5563),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _triggerSearch(),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFEF4444),
                                      Color(0xFFDC2626),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFEF4444)
                                          .withOpacity(0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.search_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Platform Supported Shortcuts
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
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9CA3AF),
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
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // TikTok Shortcut
                          GestureDetector(
                            onTap: () =>
                                _triggerSearch('https://tiktok.com/@user/video/123'),
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
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/tiktok.png',
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'TikTok',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 36),

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
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/yt.png',
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'YouTube',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Result Preview Section
                      Text(
                        'Pratinjau Hasil',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Empty State Placeholder (No icon, clean text as requested!)
                      if (!_hasSearched)
                        CustomPaint(
                          painter: DashedRectPainter(
                            color: const Color(0xFFD1D5DB),
                            strokeWidth: 1.5,
                            gap: 6.0,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 36,
                            ),
                            child: Center(
                              child: Text(
                                'Tempelkan tautan video di atas untuk melihat pratinjau hasil',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        // Dynamic Preview Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Card Header (Platform Badge + Creator)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Platform Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _platformType.startsWith('tiktok')
                                          ? Colors.black
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: _platformType.startsWith('youtube')
                                          ? Border.all(
                                              color: const Color(0xFFE5E7EB),
                                              width: 1.2,
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
                                        const SizedBox(width: 4),
                                        Text(
                                          _platformName,
                                          style: GoogleFonts.outfit(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
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

                                  // Creator Handle
                                  Text(
                                    _creatorHandle,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Dynamic Media View
                              if (_platformType == 'tiktok_photo') ...[
                                // TikTok Photo Slide Carousel
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    height: 220,
                                    width: double.infinity,
                                    color: const Color(0xFFF3F4F6),
                                    child: Stack(
                                      children: [
                                        PageView.builder(
                                          controller: _pageController,
                                          onPageChanged: (index) {
                                            setState(() {
                                              _currentSlideIndex = index;
                                            });
                                          },
                                          itemCount: _slideImages.length,
                                          itemBuilder: (context, index) {
                                            return Image.network(
                                              _slideImages[index],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            );
                                          },
                                        ),
                                        // Slide Counter Badge
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                        // Dots Indicator
                                        Positioned(
                                          bottom: 10,
                                          left: 0,
                                          right: 0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List.generate(
                                              _slideImages.length,
                                              (idx) {
                                                final isActive =
                                                    idx == _currentSlideIndex;
                                                return AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 250),
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 3),
                                                  width: isActive ? 18 : 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: isActive
                                                        ? const Color(0xFFEF4444)
                                                        : Colors.white
                                                            .withOpacity(0.7),
                                                    borderRadius:
                                                        BorderRadius.circular(3),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ] else ...[
                                // Video Thumbnail (Landscape / Portrait)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: AspectRatio(
                                    aspectRatio:
                                        (_platformType == 'youtube_live' ||
                                                _platformType ==
                                                    'youtube_standard')
                                            ? 16 / 9
                                            : 9 / 12,
                                    child: Image.network(
                                      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&auto=format&fit=crop&q=80',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),

                              // Video Title
                              Text(
                                _videoTitle,
                                style: GoogleFonts.outfit(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF111827),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Dropdown Trigger Accordion Button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isDropdownExpanded = !_isDropdownExpanded;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(14),
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
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF374151),
                                        ),
                                      ),
                                      Icon(
                                        _isDropdownExpanded
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        color: const Color(0xFF6B7280),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Options List
                              if (_isDropdownExpanded) ...[
                                const SizedBox(height: 10),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _optionsList.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, idx) {
                                    final opt = _optionsList[idx];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        border: Border.all(
                                          color: const Color(0xFFF3F4F6),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.03),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
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
                                                opt['res']!,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      const Color(0xFF111827),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                opt['sub']!,
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      const Color(0xFF6B7280),
                                                ),
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () => _handleDownloadAction(
                                                opt['format']!),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 8,
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
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                            0xFFEF4444)
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset:
                                                        const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.download_rounded,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Unduh',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 12,
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
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // TAB 1: UNDUHAN (RIWAYAT UNDUHAN)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.file_download_rounded,
                            color: Color(0xFFEF4444),
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Riwayat Unduhan',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Belum ada file yang diunduh',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                // TAB 2: PENGATURAN
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.settings_rounded,
                            color: Color(0xFF4B5563),
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pengaturan',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Versi Aplikasi SnapCat 1.0.0',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Glassmorphism Bottom Navigation Dock (Fixed at bottom)
          Positioned(
            bottom: 18,
            left: 18,
            right: 18,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 310),
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(31),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
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
                    _buildNavItem(0, 'Home', svgAsset: 'assets/icons/home.svg'),
                    _buildNavItem(1, 'Unduhan', iconData: Icons.file_download_rounded),
                    _buildNavItem(2, 'Pengaturan', svgAsset: 'assets/icons/seting.svg'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, {String? svgAsset, IconData? iconData}) {
    final isActive = _activeNavIndex == index;
    final color =
        isActive ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeNavIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svgAsset != null)
              SvgPicture.asset(
                svgAsset,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              )
            else if (iconData != null)
              Icon(iconData, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* Custom Painter for Empty State Dashed Border Placeholder */
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
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(20),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
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
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap;
  }
}
