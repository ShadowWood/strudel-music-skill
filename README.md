# strudel-music-skill

A re-implementation of the `strudel-music` skill. Users describe music in natural language, and the system produces a running Strudel REPL in a browser with one command. The agent edits only `templates/src/pattern.js`.

## What is in the box

- A Vite-based local player that embeds the official `strudel.cc` REPL inside an `<iframe>`. Pattern code lives in `templates/src/pattern.js`, is base64-encoded with `TextEncoder`, and pushed into the iframe as a URL hash. Vite HMR triggers a reload whenever the file changes.
- Agent-facing documentation (`SKILL.md`, `reference.md`, `genres.md`, `examples.md`) that teaches the agent how to map natural language into Strudel code.
- Installer scripts (`install.sh`, `scripts/init.sh`, `scripts/download-samples.sh`) for one-command setup.

## Project layout

```
.
├── SKILL.md                 # Agent-facing contract
├── reference.md             # Mini-notation + natural-language mapping
├── genres.md                # Genre templates
├── examples.md              # Paired natural-language -> code examples
├── install.sh               # Skill installer for supported agents
├── scripts/
│   ├── init.sh              # Player initializer
│   └── download-samples.sh  # Offline sample prep
└── templates/
    ├── index.html           # Player shell
    ├── vite.config.js       # Vite dev server config
    ├── package.json         # Dev dependencies: vite + vitest
    └── src/
        ├── main.js          # encodePattern + loadPattern + HMR hook
        ├── pattern.js       # The ONLY file the agent edits
        └── encodePattern.test.js
```

## Quick start

```bash
# 1. Install the skill into a supported agent
bash install.sh

# 2. Initialize the player (copies templates, runs npm install, starts Vite)
bash scripts/init.sh

# 3. Open http://localhost:5173/ and click the play button once
```

After the first load, the agent edits `templates/src/pattern.js`. The iframe reloads within roughly one second on every save.

## Supported agents

`install.sh` detects and supports: Cursor, Claude Code, Hermes, Windsurf, OpenCode, Xcode. Both global (`~/.{agent}/skills/`) and project-local (`.claude/skills/`, etc.) scopes are supported, in either symlink or copy mode.

## How music is produced

The agent translates a natural-language request into Strudel code and writes it to `templates/src/pattern.js`. The skill enforces that the file's only top-level statement is `export default \`...strudel code...\``. The Vite HMR hook in `templates/src/main.js` reads the new default export, encodes it, and updates the iframe's `src` to `https://strudel.cc/?autoplay=1#<base64>`. The official strudel.cc REPL plays the pattern.

## Known limitations

- The first pattern requires one user click inside the iframe (browser autoplay policy).
- The skill does not use `@strudel/*` npm packages. The iframe hash approach is the only approved architecture because the `evalScope` exposed by `evaluate()` is not equivalent to the strudel.cc REPL context.
- All text in the project is English only.

## License

TBD.
