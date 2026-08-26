<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Snipster - Onboarding & System Setup</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
  
  <style>
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      -webkit-font-smoothing: antialiased;
    }

    /* Ambient Rose-Red Background Backdrop */
    body {
      font-family: 'Outfit', 'Inter', -apple-system, sans-serif;
      background: linear-gradient(135deg, #FFE4E6 0%, #FFF1F2 50%, #FECDD3 100%);
      min-height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
      padding: 20px;
    }

    /* Mobile Device Frame Mockup */
    .phone-frame {
      width: 360px;
      height: 740px;
      background: #000;
      border-radius: 46px;
      border: 8px solid #1C1B22;
      box-shadow: 0 25px 60px -15px rgba(220, 38, 38, 0.35),
                  0 0 0 2px rgba(239, 68, 68, 0.4);
      position: relative;
      overflow: hidden;
      display: flex;
      flex-direction: column;
    }

    /* Screen with Vibrant Crimson-Red Gradient */
    .phone-screen {
      width: 100%;
      height: 100%;
      background: linear-gradient(155deg, #F87171 0%, #EF4444 45%, #991B1B 100%);
      position: relative;
      overflow: hidden;
      display: flex;
      flex-direction: column;
    }

    /* Soft Mesh Overlay */
    .mesh-pattern-overlay {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 60%;
      background-image: 
        radial-gradient(circle at 50% 30%, rgba(255, 255, 255, 0.22) 0%, transparent 65%),
        linear-gradient(45deg, rgba(255, 255, 255, 0.08) 25%, transparent 25%, transparent 75%, rgba(255, 255, 255, 0.08) 75%),
        linear-gradient(-45deg, rgba(255, 255, 255, 0.08) 25%, transparent 25%, transparent 75%, rgba(255, 255, 255, 0.08) 75%);
      background-size: 100% 100%, 40px 40px, 40px 40px;
      background-position: 0 0, 0 0, 20px 20px;
      pointer-events: none;
    }

    .upper-spacer {
      flex: 1;
      width: 100%;
    }

    /* Pure White Bottom Sheet Container */
    .splash-bottom-sheet {
      position: absolute;
      bottom: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: #FFFFFF;
      border-top-left-radius: 50% 34px;
      border-top-right-radius: 50% 34px;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 64px 24px 20px;
      z-index: 10;
      box-shadow: 0 -12px 40px rgba(0, 0, 0, 0.12);
      transform: translateY(calc(100% - 395px));
      transition: transform 0.65s cubic-bezier(0.16, 1, 0.3, 1), border-radius 0.65s ease;
    }

    /* Fullscreen Mode State - Negative top offset (-34px) to push curve past top edge */
    .splash-bottom-sheet.fullscreen-mode {
      transform: translateY(-34px) !important;
      border-top-left-radius: 50% 34px !important;
      border-top-right-radius: 50% 34px !important;
    }

    /* FLOATING BLACK LOGO BOX */
    .logo-box {
      position: absolute;
      top: -43px;
      left: 50%;
      transform: translateX(-50%);
      width: 86px;
      height: 86px;
      background: #000000;
      border-radius: 24px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      box-shadow: 0 14px 32px rgba(0, 0, 0, 0.4);
      z-index: 20;
      transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.4s ease;
    }

    /* SPIN RIGHT 360-DEGREE ROTATION ANIMATION */
    .logo-box.animate-spin-right {
      animation: spinRight 0.55s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
    }

    @keyframes spinRight {
      0% {
        transform: translateX(-50%) rotate(0deg) scale(0.85);
      }
      50% {
        transform: translateX(-50%) rotate(180deg) scale(1.18);
      }
      100% {
        transform: translateX(-50%) rotate(360deg) scale(1);
      }
    }

    .sheet-content {
      display: flex;
      flex-direction: column;
      align-items: center;
      text-align: center;
      width: 100%;
      height: 100%;
    }

    /* Animated Slide Body */
    .slide-body {
      display: flex;
      flex-direction: column;
      align-items: center;
      text-align: center;
      width: 100%;
      margin-top: 6px;
      opacity: 1;
      transform: translateY(0);
      transition: opacity 0.35s ease, transform 0.35s cubic-bezier(0.16, 1, 0.3, 1);
    }

    .slide-body.fade-out {
      opacity: 0;
      transform: translateY(10px);
    }

    .slide-body.fade-in {
      animation: slideInUp 0.35s cubic-bezier(0.16, 1, 0.3, 1) forwards;
    }

    @keyframes slideInUp {
      from {
        opacity: 0;
        transform: translateY(-10px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    /* RED PILL TAG */
    .app-tag-pill {
      background: #FEE2E2;
      padding: 6px 20px;
      border-radius: 14px;
      margin-bottom: 10px;
    }

    .app-tag-pill span {
      font-size: 14px;
      font-weight: 700;
      color: #DC2626;
      letter-spacing: 0.3px;
    }

    /* TITLE FONT (28px) WITH MEPET MARGIN */
    .splash-title {
      font-size: 28px;
      font-weight: 800;
      color: #111827;
      margin-bottom: 4px;
      letter-spacing: -0.5px;
      line-height: 1.15;
    }

    /* SUBTITLE FONT (15px) MEPET CLOSE TO TITLE */
    .splash-subtitle {
      font-size: 15px;
      color: #6B7280;
      font-weight: 500;
      line-height: 1.4;
      max-width: 300px;
      margin-bottom: 20px;
      min-height: 44px;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    /* Dynamic Action Button */
    .splash-action-btn {
      height: 56px;
      background: #EF4444;
      color: white;
      border: none;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      box-shadow: 0 10px 24px rgba(239, 68, 68, 0.4);
      transition: all 0.35s cubic-bezier(0.34, 1.56, 0.64, 1);
      font-family: inherit;
      font-weight: 700;
      font-size: 16px;
    }

    .splash-action-btn.round-btn {
      width: 56px;
      border-radius: 16px;
      padding: 0;
    }

    .splash-action-btn.start-btn {
      width: 220px;
      border-radius: 18px;
      padding: 0 24px;
      gap: 8px;
      letter-spacing: 0.2px;
      background: linear-gradient(135deg, #EF4444 0%, #DC2626 100%);
    }

    .splash-action-btn:hover {
      transform: scale(1.06);
      background: #DC2626;
    }

    .splash-action-btn:active {
      transform: scale(0.95);
    }

    /* 4 Carousel Dots */
    .carousel-dots {
      display: flex;
      align-items: center;
      gap: 6px;
      margin-top: auto;
      margin-bottom: 10px;
    }

    .carousel-dots .dot {
      width: 6px;
      height: 6px;
      border-radius: 50%;
      background: #E5E7EB;
      transition: all 0.35s cubic-bezier(0.34, 1.56, 0.64, 1);
      cursor: pointer;
    }

    .carousel-dots .dot.active {
      width: 22px;
      height: 6px;
      border-radius: 3px;
      background: #EF4444;
    }

    /* FULLSCREEN LOADING INTERFACE WITH INTEGRATED PROGRESS BAR */
    .loading-container {
      display: none;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: 100%;
      opacity: 0;
      transition: opacity 0.5s ease;
    }

    .loading-container.active {
      display: flex;
      opacity: 1;
    }

    /* CONTAINER HOLDING THE VIDEO AND OVERLAY LOADING BAR */
    .video-cat-container {
      position: relative;
      width: 280px;
      display: flex;
      align-items: center;
      justify-content: center;
      background: transparent;
      box-shadow: none;
    }

    /* Micro White Mask Patch at the extreme bottom edge */
    .video-cat-container::after {
      content: '';
      position: absolute;
      bottom: 0;
      left: 0;
      width: 100%;
      height: 7px;
      background: #FFFFFF;
      pointer-events: none;
      z-index: 5;
    }

    .video-cat-element {
      width: 100%;
      height: auto;
      display: block;
      background: transparent;
    }

    /* LOADING BAR OVERLAY PLACED EXACTLY IN THE GAP BETWEEN CAT BODY AND TAIL */
    .cat-gap-loading-track {
      position: absolute;
      top: 61%;
      left: 50%;
      transform: translate(-50%, -50%);
      width: 260px;
      height: 22px;
      background: #E5E7EB;
      border-radius: 11px;
      overflow: hidden;
      z-index: 10;
      box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.12);
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .cat-gap-loading-fill {
      position: absolute;
      left: 0;
      top: 0;
      width: 0%;
      height: 100%;
      background: linear-gradient(90deg, #EF4444 0%, #DC2626 100%);
      border-radius: 11px;
      transition: width 0.1s linear;
      z-index: 11;
    }

    /* LOG TEXT PLACED CLEANLY INSIDE THE LOADING BAR */
    .cat-bar-log-text {
      position: relative;
      z-index: 15;
      font-size: 10.5px;
      font-weight: 800;
      color: #111827;
      mix-blend-mode: difference;
      filter: invert(1) grayscale(1) contrast(9);
      letter-spacing: 0.3px;
      white-space: nowrap;
      pointer-events: none;
      text-transform: uppercase;
    }

    /* iPhone Bottom Line Indicator */
    .home-indicator {
      position: absolute;
      bottom: 8px;
      left: 50%;
      transform: translateX(-50%);
      width: 120px;
      height: 4px;
      background: #111827;
      border-radius: 2px;
      z-index: 30;
      opacity: 0.8;
    }
  </style>
</head>
<body>

  <!-- Mobile Frame Container -->
  <div class="phone-frame">
    <div class="phone-screen">
      
      <!-- Mesh Pattern Background -->
      <div class="mesh-pattern-overlay"></div>

      <!-- Upper Spacer -->
      <div class="upper-spacer"></div>

      <!-- Pure White Bottom Sheet Container -->
      <div class="splash-bottom-sheet" id="bottomSheet">
        
        <!-- Floating Logo Box -->
        <div class="logo-box" id="logoBox">
          <svg id="logoIcon" width="42" height="42" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="18" cy="5" r="3"/>
            <circle cx="6" cy="12" r="3"/>
            <circle cx="18" cy="19" r="3"/>
            <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/>
            <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>
          </svg>
        </div>

        <div class="sheet-content" id="sheetContent">
          <!-- Onboarding Carousel View -->
          <div class="slide-body" id="slideBody">
            <div class="app-tag-pill">
              <span id="slideTag">Tutorial</span>
            </div>

            <h2 class="splash-title" id="slideTitle">Salin Tautan</h2>
            <p class="splash-subtitle" id="slideSubtitle">Temukan video di platfrom favorit anda, klik bagikan lalu klik salin tautan</p>
          </div>

          <!-- Dynamic Action Button -->
          <button class="splash-action-btn round-btn" id="actionBtn" onclick="handleActionClick()">
            <svg id="btnIcon" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <line x1="5" y1="12" x2="19" y2="12"></line>
              <polyline points="12 5 19 12 12 19"></polyline>
            </svg>
            <span id="btnText" style="display:none;">Mulai Sekarang</span>
          </button>

          <!-- 4 Carousel Dots -->
          <div class="carousel-dots" id="carouselDots">
            <span class="dot active" onclick="goToSlide(0)"></span>
            <span class="dot" onclick="goToSlide(1)"></span>
            <span class="dot" onclick="goToSlide(2)"></span>
            <span class="dot" onclick="goToSlide(3)"></span>
          </div>
        </div>

        <!-- FULLSCREEN LOADING INTERFACE WITH EXACT-FIT OVERLAY PROGRESS BAR -->
        <div class="loading-container" id="loadingScreen">
          <div class="video-cat-container">
            <video class="video-cat-element" id="catVideo" src="kucingnew.mp4" loop muted playsinline></video>
            
            <!-- PROGRESS BAR WITH LOG TEXT INSIDE IT -->
            <div class="cat-gap-loading-track">
              <div class="cat-gap-loading-fill" id="catGapProgress"></div>
              <span class="cat-bar-log-text" id="barLogText">MENYIAPKAN... 0%</span>
            </div>
          </div>
        </div>

      </div>

      <div class="home-indicator"></div>

    </div>
  </div>

  <script>
    const slides = [
      {
        icon: `<svg width="42" height="42" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="18" cy="5" r="3"/>
                <circle cx="6" cy="12" r="3"/>
                <circle cx="18" cy="19" r="3"/>
                <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/>
                <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>
               </svg>`,
        tag: "Tutorial",
        title: "Salin Tautan",
        subtitle: "Temukan video di platfrom favorit anda, klik bagikan lalu klik salin tautan"
      },
      {
        icon: `<svg width="42" height="42" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/>
                <rect x="8" y="2" width="8" height="4" rx="1" ry="1"/>
               </svg>`,
        tag: "Tutorial",
        title: "Tempel Tautan",
        subtitle: "Tempel tautan yang anda salin ke input tautan"
      },
      {
        icon: `<svg width="42" height="42" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="11" cy="11" r="8"/>
                <line x1="21" y1="21" x2="16.65" y2="16.65"/>
               </svg>`,
        tag: "Tutorial",
        title: "Cari & Unduh",
        subtitle: "Klik tombol cari, lihat pratinjau, pilih resolusi dan unduh"
      },
      {
        icon: `<svg width="46" height="46" viewBox="0 0 24 24" fill="white">
                <path d="M4 6L12 12L4 18V6Z"/>
                <path d="M20 6L12 12L20 18V6Z"/>
               </svg>`,
        tag: "Snipster",
        title: "Unduh apa saja",
        subtitle: "Tempel tautan, cari, pilih resolusi, simpan, that simple bro"
      }
    ];

    let currentSlide = 0;

    function renderSlide(index) {
      const logoBox = document.getElementById('logoBox');
      const logoIcon = document.getElementById('logoIcon');
      const slideBody = document.getElementById('slideBody');
      const slideTag = document.getElementById('slideTag');
      const slideTitle = document.getElementById('slideTitle');
      const slideSubtitle = document.getElementById('slideSubtitle');
      const actionBtn = document.getElementById('actionBtn');
      const btnIcon = document.getElementById('btnIcon');
      const btnText = document.getElementById('btnText');
      const dots = document.querySelectorAll('.carousel-dots .dot');

      logoBox.classList.remove('animate-spin-right');
      void logoBox.offsetWidth;
      logoBox.classList.add('animate-spin-right');

      slideBody.classList.remove('fade-in');
      slideBody.classList.add('fade-out');

      setTimeout(() => {
        logoIcon.outerHTML = `<div id="logoIcon" style="display:flex;align-items:center;justify-content:center;">${slides[index].icon}</div>`;
        slideTag.innerText = slides[index].tag;
        slideTitle.innerText = slides[index].title;
        slideSubtitle.innerText = slides[index].subtitle;

        if (index === 3) {
          actionBtn.className = "splash-action-btn start-btn";
          btnText.style.display = "inline";
          btnIcon.style.order = "2";
        } else {
          actionBtn.className = "splash-action-btn round-btn";
          btnText.style.display = "none";
          btnIcon.style.order = "1";
        }

        dots.forEach((dot, idx) => {
          dot.classList.toggle('active', idx === index);
        });

        slideBody.classList.remove('fade-out');
        slideBody.classList.add('fade-in');
      }, 200);

      setTimeout(() => {
        logoBox.classList.remove('animate-spin-right');
      }, 550);
    }

    function handleActionClick() {
      if (currentSlide === 3) {
        startAppLoading();
      } else {
        currentSlide++;
        renderSlide(currentSlide);
      }
    }

    function goToSlide(index) {
      currentSlide = index;
      renderSlide(currentSlide);
    }

    // FRAMELESS MP4 VIDEO CAT LOADING ENGINE WITH SLOW-MOTION & SYNCHRONIZED 90% WAKE-UP
    function startAppLoading() {
      const bottomSheet = document.getElementById('bottomSheet');
      const logoBox = document.getElementById('logoBox');
      const sheetContent = document.getElementById('sheetContent');
      const loadingScreen = document.getElementById('loadingScreen');
      const catVideo = document.getElementById('catVideo');
      const progressFill = document.getElementById('catGapProgress');
      const barLogText = document.getElementById('barLogText');

      // 1. Instantly hide logo box and slide text
      logoBox.style.opacity = '0';
      logoBox.style.transform = 'translateX(-50%) scale(0.5)';
      sheetContent.style.opacity = '0';
      sheetContent.style.transition = 'opacity 0.2s ease';

      setTimeout(() => {
        sheetContent.style.display = 'none';
      }, 200);

      // 2. Pure white sheet glides UP smoothly to full screen (0.65s)
      bottomSheet.classList.add('fullscreen-mode');

      // 3. AFTER bottom sheet reaches full screen (650ms), FADE IN loading screen gracefully
      setTimeout(() => {
        loadingScreen.style.display = 'flex';
        
        requestAnimationFrame(() => {
          loadingScreen.classList.add('active');
        });

        if (catVideo) {
          catVideo.currentTime = 0;
          catVideo.playbackRate = 0.7; // SLOW-MOTION PLAYBACK SET TO 0.7X
          catVideo.play();
        }

        let progress = 0;
        const totalDurationMs = 5000;
        const updateIntervalMs = 50;
        const stepIncrement = 100 / (totalDurationMs / updateIntervalMs);

        const progressTimer = setInterval(() => {
          progress += stepIncrement;

          if (progress > 100) progress = 100;
          if (progressFill) progressFill.style.width = progress + '%';

          const pct = Math.round(progress);
          let logMsg = "MENYIAPKAN CORE ENGINE...";
          if (pct > 20 && pct <= 40) logMsg = "MENGINSTALL LIBRARY MEDIA...";
          else if (pct > 40 && pct <= 65) logMsg = "MENGINSTALL FFMPEG DECODER...";
          else if (pct > 65 && pct <= 85) logMsg = "MENGHUBUNGKAN AKSELERASI...";
          else if (pct > 85 && pct < 100) logMsg = "MEMVERIFIKASI SISTEM...";
          else if (pct >= 100) logMsg = "SELESAI";

          if (barLogText) barLogText.innerText = `${logMsg} ${pct}%`;

          // WHEN LOADING REACHES 90%, SYNCHRONIZE VIDEO TO WAKE UP SMOOTHLY
          if (progress >= 90 && catVideo) {
            catVideo.playbackRate = 1.0; // Return to normal speed as cat wakes up at 90%
          }

          if (progress >= 100) {
            clearInterval(progressTimer);
            if (barLogText) barLogText.innerText = "SELESAI 100%";

            // FADE OUT LOADING SCREEN SMOOTHLY ONCE COMPLETED
            setTimeout(() => {
              loadingScreen.style.transition = "opacity 0.6s ease";
              loadingScreen.style.opacity = "0";
              bottomSheet.style.transition = "opacity 0.6s ease";
              bottomSheet.style.opacity = "0";
            }, 600);
          }
        }, updateIntervalMs);
      }, 650);
    }
  </script>
</body>
</html>
