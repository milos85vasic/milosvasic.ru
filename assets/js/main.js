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
    document.querySelectorAll('[data-i18n-aria]').forEach(function (el) {
      var key = el.getAttribute('data-i18n-aria');
      if (table && table[key] != null) el.setAttribute('aria-label', table[key]);
    });
    document.querySelectorAll('[data-i18n-title]').forEach(function (el) {
      var key = el.getAttribute('data-i18n-title');
      if (table && table[key] != null) el.setAttribute('title', table[key]);
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

  // On pages with real per-language static routes (the home: window.MV_PAGE.paths
  // = { en:'/', ru:'/ru/', … }) choosing a language NAVIGATES to the localized
  // page so its fully-translated BODY loads — not just a client-side chrome swap.
  // The current page's server lang is read once, before translate() mutates it.
  var pageHomeLang = (root.getAttribute('lang') || 'en').slice(0, 2);
  function chooseLang(code) {
    var page = window.MV_PAGE;
    var url = page && page.paths && page.paths[code];
    if (url && code !== pageHomeLang) {
      try { localStorage.setItem('mv-lang', code); } catch (e) {}
      window.location.href = url;
      return;
    }
    translate(code);
    closeMenu();
  }

  if (langMenu) {
    langs.forEach(function (l) {
      var b = document.createElement('button');
      b.type = 'button'; b.dataset.code = l.code; b.setAttribute('role', 'menuitem');
      b.innerHTML = '<span>' + l.name + '</span><span class="mono" style="margin-left:auto;opacity:.6">' + l.code.toUpperCase() + '</span>';
      b.addEventListener('click', function () { chooseLang(l.code); });
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

  // Initial language: explicit stored choice > this page's own <html lang> >
  // browser > en. The page lang is the server-rendered default so a static
  // localized page (e.g. /products/ru/ with <html lang="ru">) shows its native
  // chrome immediately on load; a previously-stored user choice still wins.
  var initial = 'en';
  var supported = langs.map(function (l) { return l.code; });
  var pageLang = (root.getAttribute('lang') || '').slice(0, 2);
  try {
    var stored = localStorage.getItem('mv-lang');
    if (stored && supported.indexOf(stored) > -1) initial = stored;
    else if (pageLang && pageLang !== 'en' && supported.indexOf(pageLang) > -1) initial = pageLang;
    else { var nav = (navigator.language || 'en').slice(0, 2); if (supported.indexOf(nav) > -1) initial = nav; }
  } catch (e) {
    // localStorage blocked (private mode): still honor the page's own lang.
    if (pageLang && pageLang !== 'en' && supported.indexOf(pageLang) > -1) initial = pageLang;
  }
  translate(initial);

  /* ---------- Mobile primary nav (hamburger) ---------- */
  var navToggle = document.getElementById('nav-toggle');
  var navLinks = document.getElementById('nav-links');
  if (navToggle && navLinks) {
    var isNavOpen = function () { return navLinks.classList.contains('open'); };
    var openNav = function () {
      navLinks.classList.add('open');
      navToggle.setAttribute('aria-expanded', 'true');
    };
    var closeNav = function () {
      navLinks.classList.remove('open');
      navToggle.setAttribute('aria-expanded', 'false');
    };
    navToggle.addEventListener('click', function (e) {
      e.stopPropagation();
      isNavOpen() ? closeNav() : openNav();
    });
    // Choosing a link navigates (default) AND closes the menu.
    navLinks.querySelectorAll('a').forEach(function (a) {
      a.addEventListener('click', closeNav);
    });
    // Click outside the menu/toggle closes it.
    document.addEventListener('click', function (e) {
      if (isNavOpen() && !navLinks.contains(e.target) && !navToggle.contains(e.target)) closeNav();
    });
    // Escape closes and restores focus to the toggle (keyboard operable).
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && isNavOpen()) { closeNav(); navToggle.focus(); }
    });
  }

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
