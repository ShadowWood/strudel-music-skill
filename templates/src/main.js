// templates/src/main.js
//
// The plumbing that the strudel-music skill owns. The agent MUST NOT edit this
// file (see SKILL.md, Hard rule #1). The agent edits exactly one file:
// templates/src/pattern.js, and this module is what wires the new pattern into
// the embedded strudel.cc REPL iframe.
//
// Responsibilities:
//   1. encodePattern(code) — UTF-8 safe -> base64
//   2. loadPattern(code)   — push the encoded pattern into the iframe as a URL hash
//   3. HMR: every time pattern.js updates, re-encode and reload the iframe

/**
 * Encode a Strudel code string to a base64 string that the strudel.cc REPL
 * will accept as the URL-hash portion of `https://strudel.cc/?autoplay=1#...`.
 *
 * We must go UTF-8 -> bytes -> base64, NOT btoa(code) directly: a user-supplied
 * prompt can include non-Latin-1 characters (emoji, accented characters, copy-
 * pasted lyrics). `btoa` throws on anything outside Latin-1, so we encode the
 * string to a Uint8Array first and then to base64 via a manual byte-to-binary
 * conversion. Using a manual loop (instead of `String.fromCharCode(...bytes)`)
 * avoids the call-stack overflow that `btoa` triggers on inputs larger than
 * roughly 64 KB.
 *
 * @param {string} code The Strudel pattern code (may contain any UTF-8).
 * @returns {string} The base64-encoded pattern, safe for use in a URL hash.
 */
export function encodePattern(code) {
  const bytes = new TextEncoder().encode(String(code ?? ''));
  let binary = '';
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary);
}

/**
 * Push a Strudel pattern into the embedded strudel.cc iframe.
 *
 * Looks up the single iframe in the document (id = "strudel-frame") and sets
 * its `src` to `https://strudel.cc/?autoplay=1#<base64>`. The iframe is
 * deliberately NOT sandboxed (see SKILL.md, Hard rule #5) so that the WebAudio
 * API inside strudel.cc is allowed to start.
 *
 * @param {string} code The Strudel pattern code.
 * @returns {boolean} true if the iframe was found and updated, false otherwise.
 */
export function loadPattern(code) {
  const iframe = typeof document !== 'undefined'
    ? document.getElementById('strudel-frame')
    : null;
  if (!iframe) {
    // No iframe in this document. Either the test harness imported us without
    // a DOM, or the player shell is not loaded. Either way: no-op.
    return false;
  }
  const encoded = encodePattern(code);
  iframe.src = `https://strudel.cc/?autoplay=1#${encoded}`;
  return true;
}

// ---------------------------------------------------------------------------
// HMR wiring
// ---------------------------------------------------------------------------
//
// Vite's HMR API. When pattern.js changes, the dev server reloads the module
// graph rooted at it. We `accept` the pattern module here so Vite does NOT do
// a full page reload, and we manually call `loadPattern` with the new default
// export. The result is a sub-second iframe refresh with no page flash.
//
// `import.meta.hot` is undefined in production builds (no HMR runtime), so we
// guard the registration. In that case the iframe is still loaded once at
// startup by the IIFE below.
if (import.meta.hot) {
  import.meta.hot.accept('./pattern.js', (newModule) => {
    if (newModule && typeof newModule.default === 'string') {
      loadPattern(newModule.default);
    }
  });
}

// ---------------------------------------------------------------------------
// First-load bootstrap
// ---------------------------------------------------------------------------
//
// Import pattern.js once at startup so the iframe is populated with the
// current pattern on the very first page load (not just on subsequent HMR
// updates). The default export of pattern.js is the only top-level statement
// in that file; see SKILL.md, Hard rule #3.
import initialPattern from './pattern.js';
if (typeof initialPattern === 'string') {
  // Defer one microtask so the DOM is fully parsed before we look up the
  // iframe. If `main.js` is loaded with `type="module"`, the DOM is already
  // parsed by the time we get here, but the microtask is cheap insurance.
  queueMicrotask(() => loadPattern(initialPattern));
}
