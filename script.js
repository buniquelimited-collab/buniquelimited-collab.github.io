(function () {
  'use strict';
  // helper
  function byId(id) { return document.getElementById(id); }

  try {
    var openBtn = byId('openPopupBtn');
    var popup = byId('popup');
    var popupBox = byId('popupBox');
    var moreBtn = byId('moreBtn');
    var lessBtn = byId('lessBtn');

    if (!openBtn) {
      console.warn('openPopupBtn not present — popup disabled.');
      return;
    }

    function openPopup() {
      if (!popup) return;
      popup.style.display = 'flex';
      popup.setAttribute('aria-hidden', 'false');
      document.body.style.overflow = 'hidden';
      if (moreBtn && moreBtn.focus) moreBtn.focus();
    }

    function closePopup() {
      if (!popup) return;
      popup.style.display = 'none';
      popup.setAttribute('aria-hidden', 'true');
      document.body.style.overflow = '';
      try { openBtn.focus(); } catch (e) { }
    }

    openBtn.addEventListener('click', function (e) { e.preventDefault(); openPopup(); });

    if (moreBtn) moreBtn.addEventListener('click', function () { window.open('https://t.me/+pB-NjhJnCdhhN2M9', '_blank', 'noopener'); });
    if (lessBtn) lessBtn.addEventListener('click', function () { window.open('https://t.me/+qjO9hqLoWm8xNzk1', '_blank', 'noopener'); });

    if (popup) popup.addEventListener('click', function (evt) { if (evt.target === popup) closePopup(); });
    if (popupBox) popupBox.addEventListener('click', function (evt) { evt.stopPropagation(); });

    document.addEventListener('keydown', function (evt) {
      var k = evt.key || evt.keyCode;
      if ((k === 'Escape' || k === 'Esc' || k === 27) && popup && popup.style.display === 'flex') closePopup();
    });

  } catch (err) {
    console.error('Popup init error:', err);
  }
})();
