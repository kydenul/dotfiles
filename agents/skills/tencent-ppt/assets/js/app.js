/**
 * Tencent PPT Slideshow Engine v3.3
 *
 * Static asset — hard-linked into every presentation project.
 * DO NOT edit per-presentation. All customization lives in index.html + styles.css.
 *
 * Features:
 *   - Viewport scaling (transform: scale) for 1920×1080 canvas
 *   - Keyboard & button navigation (←→↑↓ Space Home End)
 *   - Fullscreen toggle (F)
 *   - Gallery / overview mode (G) — thumbnail grid for quick navigation
 *   - Progress bar & slide counter
 *   - PDF export via html2canvas + jsPDF (P key or button) — HTTP mode only
 *   - Auto-hide control bar
 */

(function () {
  "use strict";

  // ── Protocol detection ─────────────────────────────────────────
  var isFileProtocol = location.protocol === "file:";

  // ── Slide discovery ──────────────────────────────────────────────
  var slides = document.querySelectorAll(".slide");
  var total = slides.length;
  if (!total) return;

  var current = 0;
  var galleryOpen = false;

  // ── Inject navigation UI ────────────────────────────────────────
  // Hide export button under file:// protocol
  var exportBtn = isFileProtocol
    ? ""
    : '<button id="pptExport" title="Export PDF (P)">📄</button>';

  var controlsHTML =
    '<div class="ppt-progress"><div class="ppt-progress-fill" id="pptProgress"></div></div>' +
    '<div class="ppt-controls" id="pptControls">' +
    '<button id="pptPrev" title="Previous (←)">◀</button>' +
    '<span class="ppt-counter" id="pptCounter">1 / ' +
    total +
    "</span>" +
    '<button id="pptNext" title="Next (→)">▶</button>' +
    '<button id="pptGallery" title="Gallery (G)">▦</button>' +
    '<button id="pptFS" title="Fullscreen (F)">⛶</button>' +
    exportBtn +
    "</div>" +
    '<div class="ppt-export-overlay" id="pptExportOverlay">' +
    "<h2>Exporting PDF…</h2>" +
    '<div class="ppt-export-progress" id="pptExportProgress">Preparing…</div>' +
    '<div class="ppt-export-bar-bg"><div class="ppt-export-bar-fill" id="pptExportBar"></div></div>' +
    "</div>";

  // Gallery overlay
  var galleryHTML =
    '<div class="ppt-gallery" id="pptGalleryOverlay">' +
    '<div class="ppt-gallery-header">' +
    '<h2 class="ppt-gallery-title">Slide Overview</h2>' +
    '<button class="ppt-gallery-close" id="pptGalleryClose">✕</button>' +
    "</div>" +
    '<div class="ppt-gallery-grid" id="pptGalleryGrid"></div>' +
    "</div>";

  // file:// tip overlay
  var tipHTML =
    '<div class="ppt-tip-overlay" id="pptTipOverlay">' +
    '<div class="ppt-tip-box">' +
    "<h2>导出 PDF 需要启动预览服务</h2>" +
    "<p>当前以本地文件方式打开，无法导出 PDF。</p>" +
    "<p>请在 CodeBuddy / AI 助手中输入：</p>" +
    '<div class="ppt-tip-cmd">"帮我启动 PPT 预览"</div>' +
    '<p class="ppt-tip-sub">启动后即可正常导出 PDF、并获得更好的预览体验。</p>' +
    '<button class="ppt-tip-close" id="pptTipClose">我知道了</button>' +
    "</div>" +
    "</div>";

  var wrapper = document.createElement("div");
  wrapper.innerHTML = controlsHTML + galleryHTML + tipHTML;
  while (wrapper.firstChild) document.body.appendChild(wrapper.firstChild);

  // Inject styles (self-contained)
  var style = document.createElement("style");
  style.textContent =
    /* Progress bar */
    ".ppt-progress{position:fixed;top:0;left:0;right:0;height:4px;background:rgba(255,255,255,.1);z-index:9000}" +
    ".ppt-progress-fill{height:100%;background:#0052D9;transition:width .3s}" +
    /* Control bar */
    ".ppt-controls{position:fixed;bottom:0;left:0;right:0;height:56px;" +
    "background:linear-gradient(transparent,rgba(0,0,0,.6));display:flex;align-items:center;" +
    "justify-content:center;gap:20px;z-index:9000;opacity:0;transition:opacity .3s}" +
    "body:hover .ppt-controls,.ppt-controls:hover{opacity:1}" +
    ".ppt-controls button{background:rgba(255,255,255,.15);border:none;color:#fff;" +
    "width:40px;height:40px;border-radius:50%;cursor:pointer;font-size:18px;" +
    "display:flex;align-items:center;justify-content:center;transition:background .2s}" +
    ".ppt-controls button:hover{background:rgba(255,255,255,.3)}" +
    ".ppt-counter{color:rgba(255,255,255,.8);font-size:14px;min-width:60px;text-align:center}" +
    /* Export overlay */
    ".ppt-export-overlay{position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,.85);" +
    "display:none;flex-direction:column;align-items:center;justify-content:center;gap:20px}" +
    ".ppt-export-overlay.active{display:flex}" +
    ".ppt-export-overlay h2{color:#fff;font-size:24px;font-family:inherit}" +
    ".ppt-export-progress{color:rgba(255,255,255,.7);font-size:16px}" +
    ".ppt-export-bar-bg{width:320px;height:6px;background:rgba(255,255,255,.15);border-radius:3px;overflow:hidden}" +
    ".ppt-export-bar-fill{height:100%;background:#0052D9;border-radius:3px;transition:width .3s;width:0}" +
    /* Tip overlay (file:// PDF hint) */
    ".ppt-tip-overlay{position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,.75);" +
    "display:none;align-items:center;justify-content:center}" +
    ".ppt-tip-overlay.active{display:flex}" +
    ".ppt-tip-box{background:#fff;border-radius:12px;padding:40px 48px;max-width:480px;text-align:center;" +
    "font-family:inherit;box-shadow:0 20px 60px rgba(0,0,0,.3)}" +
    ".ppt-tip-box h2{font-size:22px;color:#1a1a2e;margin:0 0 16px;font-weight:700}" +
    ".ppt-tip-box p{font-size:15px;color:#555;line-height:1.6;margin:0 0 12px}" +
    ".ppt-tip-cmd{background:#F0F4FF;border:1px solid #D0DFFF;border-radius:8px;padding:12px 20px;" +
    "font-size:16px;color:#0052D9;font-weight:700;margin:16px 0;user-select:all}" +
    ".ppt-tip-sub{font-size:13px;color:#999;margin:12px 0 20px}" +
    ".ppt-tip-close{background:#0052D9;color:#fff;border:none;border-radius:8px;" +
    "padding:10px 32px;font-size:15px;cursor:pointer;transition:background .2s}" +
    ".ppt-tip-close:hover{background:#0040B0}" +
    /* Gallery overlay */
    ".ppt-gallery{position:fixed;inset:0;z-index:9500;background:rgba(10,10,30,.95);" +
    "display:none;flex-direction:column;overflow:hidden}" +
    ".ppt-gallery.active{display:flex}" +
    ".ppt-gallery-header{display:flex;align-items:center;justify-content:space-between;" +
    "padding:20px 32px;flex-shrink:0}" +
    ".ppt-gallery-title{color:#fff;font-size:20px;font-weight:700;font-family:inherit;margin:0}" +
    ".ppt-gallery-close{background:rgba(255,255,255,.15);border:none;color:#fff;" +
    "width:36px;height:36px;border-radius:50%;cursor:pointer;font-size:18px;" +
    "display:flex;align-items:center;justify-content:center;transition:background .2s}" +
    ".ppt-gallery-close:hover{background:rgba(255,255,255,.3)}" +
    ".ppt-gallery-grid{flex:1;overflow-y:auto;padding:0 32px 32px;" +
    "display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:20px;" +
    "align-content:start}" +
    ".ppt-gallery-item{position:relative;cursor:pointer;border-radius:6px;overflow:hidden;" +
    "border:3px solid transparent;transition:border-color .2s,transform .2s;aspect-ratio:16/9;background:#222}" +
    ".ppt-gallery-item:hover{border-color:rgba(255,255,255,.4);transform:scale(1.03)}" +
    ".ppt-gallery-item.current{border-color:#0052D9}" +
    ".ppt-gallery-thumb{width:1920px;height:1080px;transform-origin:0 0;pointer-events:none;" +
    "position:absolute;top:0;left:0;overflow:hidden}" +
    ".ppt-gallery-label{position:absolute;bottom:0;left:0;right:0;padding:6px 10px;" +
    "background:linear-gradient(transparent,rgba(0,0,0,.7));color:rgba(255,255,255,.9);" +
    "font-size:13px;font-family:inherit;text-align:center;z-index:2}";
  document.head.appendChild(style);

  // ── DOM refs ─────────────────────────────────────────────────────
  var progressBar = document.getElementById("pptProgress");
  var counter = document.getElementById("pptCounter");

  // ── Viewport scaling ─────────────────────────────────────────────
  function fitSlide() {
    var vw = window.innerWidth || document.documentElement.clientWidth;
    var vh = window.innerHeight || document.documentElement.clientHeight;
    var scale = Math.min(vw / 1920, vh / 1080);
    var left = (vw - 1920 * scale) / 2;
    var top = (vh - 1080 * scale) / 2;
    for (var i = 0; i < total; i++) {
      slides[i].style.left = left + "px";
      slides[i].style.top = top + "px";
      slides[i].style.transform = "scale(" + scale + ")";
    }
  }

  window.addEventListener("resize", fitSlide);
  window.addEventListener("DOMContentLoaded", fitSlide);
  document.addEventListener("fullscreenchange", function () {
    setTimeout(fitSlide, 100);
    setTimeout(fitSlide, 300);
  });
  document.addEventListener("webkitfullscreenchange", function () {
    setTimeout(fitSlide, 100);
    setTimeout(fitSlide, 300);
  });
  // Polling fallback (catches edge cases like devtools open/close)
  (function () {
    var lastW = 0,
      lastH = 0;
    setInterval(function () {
      var w = window.innerWidth || document.documentElement.clientWidth;
      var h = window.innerHeight || document.documentElement.clientHeight;
      if (w !== lastW || h !== lastH) {
        lastW = w;
        lastH = h;
        fitSlide();
      }
    }, 300);
  })();
  fitSlide();

  // ── Navigation ───────────────────────────────────────────────────
  function updateUI() {
    counter.textContent = current + 1 + " / " + total;
    progressBar.style.width = ((current + 1) / total) * 100 + "%";
  }

  function goTo(idx) {
    if (idx < 0 || idx >= total) return;
    slides[current].classList.remove("active");
    current = idx;
    slides[current].classList.add("active");
    updateUI();
  }
  function next() {
    goTo(current + 1);
  }
  function prev() {
    goTo(current - 1);
  }

  function toggleFullscreen() {
    if (!document.fullscreenElement && !document.webkitFullscreenElement) {
      var el = document.documentElement;
      (el.requestFullscreen || el.webkitRequestFullscreen).call(el);
    } else {
      (document.exitFullscreen || document.webkitExitFullscreen).call(document);
    }
  }

  // ── Gallery / Overview ──────────────────────────────────────────
  var galleryOverlay = document.getElementById("pptGalleryOverlay");
  var galleryGrid = document.getElementById("pptGalleryGrid");

  function openGallery() {
    if (galleryOpen) return;
    galleryOpen = true;

    // Build thumbnails
    galleryGrid.innerHTML = "";
    for (var i = 0; i < total; i++) {
      var item = document.createElement("div");
      item.className = "ppt-gallery-item" + (i === current ? " current" : "");
      item.setAttribute("data-index", i);

      // Clone slide content for thumbnail — preserve ALL original classes
      var inner = slides[i].cloneNode(true);
      inner.classList.add("ppt-gallery-thumb");
      // Force visible (original .slide has display:none unless .active)
      inner.style.display = "block";
      inner.style.position = "absolute";
      inner.style.left = "0";
      inner.style.top = "0";
      inner.style.transform = "";
      inner.style.transformOrigin = "0 0";

      var label = document.createElement("div");
      label.className = "ppt-gallery-label";
      // Extract slide title from heading elements
      var titleEl = slides[i].querySelector(
        ".cover-title, .content-heading, .section-title, .center-title, .thanks-text",
      );
      var slideTitle = titleEl ? titleEl.textContent.trim() : "";
      label.textContent =
        i + 1 + (slideTitle ? " · " + slideTitle.substring(0, 40) : "");

      item.appendChild(inner);
      item.appendChild(label);
      galleryGrid.appendChild(item);

      // Scale the cloned slide to fit the thumbnail container
      (function (el, itemEl) {
        requestAnimationFrame(function () {
          var w = itemEl.offsetWidth;
          if (w > 0) {
            el.style.transform = "scale(" + w / 1920 + ")";
          }
        });
      })(inner, item);
    }

    galleryOverlay.classList.add("active");

    // Scroll current slide into view
    var currentItem = galleryGrid.querySelector(".current");
    if (currentItem) {
      currentItem.scrollIntoView({ behavior: "smooth", block: "center" });
    }
  }

  function closeGallery() {
    if (!galleryOpen) return;
    galleryOpen = false;
    galleryOverlay.classList.remove("active");
    galleryGrid.innerHTML = ""; // free cloned DOM
  }

  function toggleGallery() {
    if (galleryOpen) closeGallery();
    else openGallery();
  }

  // Gallery click handler (event delegation)
  galleryGrid.addEventListener("click", function (e) {
    var item = e.target.closest(".ppt-gallery-item");
    if (!item) return;
    var idx = parseInt(item.getAttribute("data-index"), 10);
    if (!isNaN(idx)) {
      goTo(idx);
      closeGallery();
    }
  });

  document
    .getElementById("pptGalleryClose")
    .addEventListener("click", function () {
      closeGallery();
      this.blur();
    });

  // Resize gallery thumbnails on window resize
  window.addEventListener("resize", function () {
    if (!galleryOpen) return;
    var items = galleryGrid.querySelectorAll(".ppt-gallery-item");
    for (var i = 0; i < items.length; i++) {
      var inner = items[i].querySelector(".ppt-gallery-thumb");
      if (inner) {
        var w = items[i].offsetWidth;
        if (w > 0) inner.style.transform = "scale(" + w / 1920 + ")";
      }
    }
  });

  // ── file:// PDF tip ────────────────────────────────────────────
  var tipOverlay = document.getElementById("pptTipOverlay");
  document.getElementById("pptTipClose").addEventListener("click", function () {
    tipOverlay.classList.remove("active");
  });

  function showFileTip() {
    tipOverlay.classList.add("active");
  }

  // Button bindings
  document.getElementById("pptPrev").addEventListener("click", function () {
    prev();
    this.blur();
  });
  document.getElementById("pptNext").addEventListener("click", function () {
    next();
    this.blur();
  });
  document.getElementById("pptGallery").addEventListener("click", function () {
    toggleGallery();
    this.blur();
  });
  document.getElementById("pptFS").addEventListener("click", function () {
    toggleFullscreen();
    this.blur();
  });
  if (!isFileProtocol) {
    document.getElementById("pptExport").addEventListener("click", function () {
      exportPDF();
      this.blur();
    });
  }

  // Keyboard
  document.addEventListener("keydown", function (e) {
    // When gallery is open, only handle gallery-specific keys
    if (galleryOpen) {
      if (e.key === "Escape" || e.key === "g" || e.key === "G") {
        e.preventDefault();
        closeGallery();
      }
      return;
    }

    // When tip overlay is open
    if (tipOverlay.classList.contains("active")) {
      if (e.key === "Escape" || e.key === "Enter") {
        e.preventDefault();
        tipOverlay.classList.remove("active");
      }
      return;
    }

    switch (e.key) {
      case "ArrowRight":
      case "ArrowDown":
      case " ":
        e.preventDefault();
        next();
        break;
      case "ArrowLeft":
      case "ArrowUp":
        e.preventDefault();
        prev();
        break;
      case "Home":
        e.preventDefault();
        goTo(0);
        break;
      case "End":
        e.preventDefault();
        goTo(total - 1);
        break;
      case "f":
      case "F":
        e.preventDefault();
        toggleFullscreen();
        break;
      case "g":
      case "G":
        e.preventDefault();
        openGallery();
        break;
      case "p":
      case "P":
        e.preventDefault();
        if (isFileProtocol) showFileTip();
        else exportPDF();
        break;
      case "Escape":
        if (document.fullscreenElement) document.exitFullscreen();
        break;
    }
  });

  // Ensure first slide is active on load
  goTo(0);

  // ── PDF Export (HTTP mode only) ────────────────────────────────
  var exportBusy = false;

  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      if (document.querySelector('script[src="' + src + '"]')) {
        resolve();
        return;
      }
      var s = document.createElement("script");
      s.src = src;
      s.onload = resolve;
      s.onerror = reject;
      document.head.appendChild(s);
    });
  }

  function exportPDF() {
    if (exportBusy || isFileProtocol) return;
    exportBusy = true;

    var overlay = document.getElementById("pptExportOverlay");
    var progress = document.getElementById("pptExportProgress");
    var bar = document.getElementById("pptExportBar");
    overlay.classList.add("active");
    progress.textContent = "Loading libraries…";
    bar.style.width = "0%";

    (async function () {
      try {
        await loadScript(
          "https://cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js",
        );
        await loadScript(
          "https://cdn.jsdelivr.net/npm/jspdf@2.5.2/dist/jspdf.umd.min.js",
        );

        var jsPDF = window.jspdf.jsPDF;
        var pdf = new jsPDF({
          orientation: "landscape",
          unit: "px",
          format: [1920, 1080],
          compress: true,
        });
        var savedCurrent = current;

        for (var i = 0; i < total; i++) {
          progress.textContent = "Slide " + (i + 1) + " / " + total;
          bar.style.width = (i / total) * 100 + "%";

          slides[i].classList.add("active");
          slides[i].style.display = "block";
          var origT = slides[i].style.transform;
          var origL = slides[i].style.left;
          var origTop = slides[i].style.top;
          slides[i].style.transform = "none";
          slides[i].style.left = "0px";
          slides[i].style.top = "0px";

          await new Promise(function (r) {
            setTimeout(r, 100);
          });
          var canvas = await html2canvas(slides[i], {
            scale: 2,
            useCORS: true,
            width: 1920,
            height: 1080,
          });

          slides[i].style.transform = origT;
          slides[i].style.left = origL;
          slides[i].style.top = origTop;
          if (i !== savedCurrent) {
            slides[i].classList.remove("active");
            slides[i].style.display = "";
          }

          var imgData = canvas.toDataURL("image/jpeg", 0.92);
          if (i > 0) pdf.addPage([1920, 1080], "landscape");
          pdf.addImage(imgData, "JPEG", 0, 0, 1920, 1080);
        }

        bar.style.width = "100%";
        progress.textContent = "Saving…";
        goTo(savedCurrent);

        var title = (document.title || "slides").replace(/[\\/:*?"<>|]/g, "");
        pdf.save(title + ".pdf");
      } catch (e) {
        alert("PDF export failed: " + e.message);
        console.error(e);
      } finally {
        overlay.classList.remove("active");
        exportBusy = false;
      }
    })();
  }
})();
