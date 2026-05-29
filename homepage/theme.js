/* Theme mode: system, light, or dark — persists choice and follows OS changes. */
(function () {
  var MODE_KEY = 'equivalence-theme-mode';
  var mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');

  function getMode() {
    return localStorage.getItem(MODE_KEY) || 'system';
  }

  function resolveTheme(mode) {
    if (mode === 'dark') return 'dark';
    if (mode === 'light') return 'light';
    return mediaQuery.matches ? 'dark' : 'light';
  }

  function applyTheme() {
    var mode = getMode();
    var theme = resolveTheme(mode);
    document.documentElement.dataset.theme = theme;
    document.documentElement.dataset.themeMode = mode;

    document.querySelectorAll('.theme-btn').forEach(function (btn) {
      btn.classList.toggle('active', btn.dataset.themeMode === mode);
    });
  }

  function setMode(mode) {
    localStorage.setItem(MODE_KEY, mode);
    applyTheme();
  }

  document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.theme-btn').forEach(function (btn) {
      btn.addEventListener('click', function () {
        setMode(btn.dataset.themeMode);
      });
    });

    applyTheme();
  });

  mediaQuery.addEventListener('change', function () {
    if (getMode() === 'system') {
      applyTheme();
    }
  });
})();
