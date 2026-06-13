// templates/vite.config.js — Vite dev server for the strudel-music player.
// Port is fixed at 5173 so the user can bookmark http://localhost:5173/.
// `open: true` launches the browser automatically on `npm run dev`.
// Keep this file minimal: no headers block, no proxy, no extra plugins.

export default {
  server: {
    port: 5173,
    open: true,
  },
};
