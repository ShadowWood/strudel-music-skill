// templates/src/main.js (placeholder)
// Full encodePattern + loadPattern + HMR hook is added in a later iteration (AC-3).

export function encodePattern(code) {
  return btoa(String.fromCharCode(...new TextEncoder().encode(code)));
}

export function loadPattern(code) {
  const iframe = document.getElementById('strudel-frame');
  if (iframe) iframe.src = `https://strudel.cc/?autoplay=1#${encodePattern(code)}`;
}

if (import.meta.hot) {
  import.meta.hot.accept('./pattern.js', (newModule) => {
    if (newModule && typeof newModule.default === 'string') {
      loadPattern(newModule.default);
    }
  });
}
