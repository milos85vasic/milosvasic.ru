/* milosvasic.ru — download language chooser popup.
   Triggers: any element with data-dl="cv" | "cl".
   Builds links to /downloads/Milos_Vasic_{CV|Cover_Letter}_{EN|SR|RU}.pdf.
   Accessible: Esc + backdrop close, focus restore, scroll lock. */
(function () {
  'use strict';
  var modal = document.getElementById('dl-modal');
  if (!modal) return;
  var base = modal.getAttribute('data-base') || '/downloads/';
  var nameEl = modal.querySelector('.dl-doc-name');
  var links = modal.querySelectorAll('.dl-lang');
  var FILES = { cv: 'Milos_Vasic_CV', cl: 'Milos_Vasic_Cover_Letter' };
  var lastFocus = null;

  function t(key, fallback) {
    var d = window.MV_I18N || {};
    var code = document.documentElement.getAttribute('lang') || 'en';
    var tab = d[code] || d.en || {};
    return tab[key] || fallback;
  }
  function open(doc) {
    var fbase = FILES[doc] || FILES.cv;
    nameEl.textContent = doc === 'cl' ? t('dl.cl', 'Cover Letter') : t('dl.cv', 'Curriculum Vitae (CV)');
    links.forEach(function (a) { a.setAttribute('href', base + fbase + '_' + a.dataset.lang + '.pdf'); });
    lastFocus = document.activeElement;
    modal.hidden = false;
    document.body.classList.add('mv-article-lock');
    requestAnimationFrame(function () { modal.classList.add('open'); });
    var x = modal.querySelector('.dl-x'); if (x) x.focus();
    document.addEventListener('keydown', onKey);
  }
  function close() {
    modal.classList.remove('open');
    document.body.classList.remove('mv-article-lock');
    document.removeEventListener('keydown', onKey);
    setTimeout(function () { modal.hidden = true; }, 200);
    if (lastFocus && lastFocus.focus) lastFocus.focus();
  }
  function onKey(e) { if (e.key === 'Escape') close(); }

  document.addEventListener('click', function (e) {
    var trig = e.target.closest('[data-dl]');
    if (trig) { e.preventDefault(); open(trig.getAttribute('data-dl')); return; }
    if (e.target.closest('[data-dl-close]')) { e.preventDefault(); close(); }
  });
  window.MVDownloads = { open: open, close: close };
})();
