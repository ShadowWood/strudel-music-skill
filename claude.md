---
name: project-standards
description: Standards for the strudel-music-skill project. Read this before making any change.
---

# Project Standards

## Project
A re-implementation of the `strudel-music` skill. The skill lets a user describe music in natural language, and a Vite-based local player embeds the official `strudel.cc` REPL inside an `<iframe>`. The agent's only writable artifact is `templates/src/pattern.js`.

## Working rules
- The agent NEVER installs or imports `@strudel/*` npm packages. The iframe hash approach is the only approved architecture.
- The agent NEVER adds `sandbox` to the iframe. The WebAudio API breaks otherwise.
- The agent NEVER uses top-level `let pattern = ...` bindings inside `pattern.js` when composing with `arrange()`. Inline all pattern fragments.
- All text (code, comments, docs, scripts, user-facing strings) MUST be English. No Chinese, Japanese, or other non-Latin scripts.
- The agent edits ONLY `templates/src/pattern.js` to change the music. Everything else is plumbing.

## Layout
```
.
├── SKILL.md                 # Agent-facing contract
├── reference.md             # Mini-notation + NL mapping
├── genres.md                # Genre templates
├── examples.md              # Paired NL -> code examples
├── install.sh               # Skill installer for Cursor/Claude/Hermes/Windsurf/OpenCode/Xcode
├── scripts/
│   ├── init.sh              # Player initializer (Node check, copy, npm install, dev server)
│   └── download-samples.sh  # Offline sample prep
├── templates/
│   ├── index.html           # Player shell
│   ├── vite.config.js       # Vite dev server config
│   ├── package.json         # Only vite + vitest
│   └── src/
│       ├── main.js          # encodePattern + loadPattern + HMR hook
│       ├── pattern.js       # The ONLY file the agent edits
│       └── encodePattern.test.js  # vitest unit test
└── templates/test-cdn.html  # 7-case debug page for any future @strudel/web work
```

## Validation
- `bash -n` syntax check on every shell script before commit.
- `grep -rP '[\x{4e00}-\x{9fff}]' . --include='*.md' --include='*.js' --include='*.sh' --include='*.html' --include='*.json' --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.humanize` must return nothing.
- `node --input-type=module -e "import('./templates/src/pattern.js').then(m => console.log(typeof m.default))"` must print `string`.

## Iteration discipline
- One AC at a time.
- Run only the narrowest meaningful verification for the slice just changed.
- A downstream Reviewer runs detailed validation; do not duplicate it here.
