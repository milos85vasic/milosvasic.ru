/* milosvasic.ru — theme toggle, language switcher, scroll reveal.
   Progressive enhancement: page is fully readable (English) with JS disabled. */
(function () {
  'use strict';
  var root = document.documentElement;

  /* ---------- Theme ---------- */
  var themeBtn = document.getElementById('theme-btn');
  function applyTheme(t) {
    root.setAttribute('data-theme', t);
    try { localStorage.setItem('mv-theme', t); } catch (e) {}
    if (themeBtn) {
      themeBtn.textContent = t === 'dark' ? '☀' : '◐';
      themeBtn.setAttribute('aria-pressed', String(t === 'dark'));
    }
  }
  if (themeBtn) {
    applyTheme(root.getAttribute('data-theme') || 'light');
    themeBtn.addEventListener('click', function () {
      applyTheme(root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
    });
  }

  /* ---------- i18n ---------- */
  var dict = window.MV_I18N || {};
  var langs = window.MV_LANGS || [{ code: 'en', name: 'English' }];
  var langBtn = document.getElementById('lang-btn');
  var langMenu = document.getElementById('lang-menu');

  function translate(code) {
    var table = dict[code] || dict.en;
    document.querySelectorAll('[data-i18n]').forEach(function (el) {
      var key = el.getAttribute('data-i18n');
      if (table && table[key] != null) el.innerHTML = table[key];
    });
    root.setAttribute('lang', code);
    root.setAttribute('dir', (code === 'ar' || code === 'fa' || code === 'he') ? 'rtl' : 'ltr');
    if (langBtn) langBtn.textContent = code.toUpperCase();
    try { localStorage.setItem('mv-lang', code); } catch (e) {}
    if (langMenu) {
      langMenu.querySelectorAll('button').forEach(function (b) {
        b.setAttribute('aria-current', String(b.dataset.code === code));
      });
    }
  }

  if (langMenu) {
    langs.forEach(function (l) {
      var b = document.createElement('button');
      b.type = 'button'; b.dataset.code = l.code; b.setAttribute('role', 'menuitem');
      b.innerHTML = '<span>' + l.name + '</span><span class="mono" style="margin-left:auto;opacity:.6">' + l.code.toUpperCase() + '</span>';
      b.addEventListener('click', function () { translate(l.code); closeMenu(); });
      langMenu.appendChild(b);
    });
  }
  function openMenu() { if (langMenu) { langMenu.classList.add('open'); langBtn.setAttribute('aria-expanded', 'true'); } }
  function closeMenu() { if (langMenu) { langMenu.classList.remove('open'); langBtn.setAttribute('aria-expanded', 'false'); } }
  if (langBtn) {
    langBtn.addEventListener('click', function (e) {
      e.stopPropagation();
      langMenu.classList.contains('open') ? closeMenu() : openMenu();
    });
    document.addEventListener('click', closeMenu);
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') closeMenu(); });
  }

  // Initial language: stored > browser > en
  var initial = 'en';
  try {
    var stored = localStorage.getItem('mv-lang');
    var supported = langs.map(function (l) { return l.code; });
    if (stored && supported.indexOf(stored) > -1) initial = stored;
    else { var nav = (navigator.language || 'en').slice(0, 2); if (supported.indexOf(nav) > -1) initial = nav; }
  } catch (e) {}
  translate(initial);

  /* ---------- Scroll reveal ---------- */
  var reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  var items = document.querySelectorAll('.reveal');
  if (reduce || !('IntersectionObserver' in window)) {
    items.forEach(function (el) { el.classList.add('in'); });
  } else {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) { if (en.isIntersecting) { en.target.classList.add('in'); io.unobserve(en.target); } });
    }, { threshold: 0.12 });
    items.forEach(function (el) { io.observe(el); });
  }
})();
