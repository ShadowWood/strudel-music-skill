export const siteMeta = {
  edition: 'Skill Version 1.0',
  projectName: 'strudel-music',
  pageLabel: 'Page 01 / 01',
};

export const hero = {
  badge: 'Agent Skill',
  title: {
    prefix: 'The',
    highlight: 'Strudel-Music',
    connector: '&',
    suffix: 'Agent Guide',
  },
  tagline:
    'Turn natural language into live, generative music. Describe what you hear — the skill writes the Strudel code, and the browser plays it.',
  cta: {
    label: 'View on GitHub',
    href: 'https://github.com/ShadowWood/strudel-music-skill',
  },
};

export const stats = [
  { value: '6', label: 'Supported Agents' },
  { value: '12+', label: 'Genre Templates' },
  { value: '1', label: 'File the Agent Edits' },
];

export const tableOfContents = [
  { label: 'About the Skill', href: '#about' },
  { label: 'Architecture', href: '#architecture' },
  { label: 'Demo', href: '#demo' },
  { label: 'Features', href: '#features' },
  { label: 'Supported Genres', href: '#genres' },
  { label: 'Quick Start', href: '#quick-start' },
  { label: 'Limitations', href: '#limitations' },
];

export const about = {
  id: 'about',
  title: 'About the Skill',
  subtitle: 'Describe music in plain English — hear it in your browser.',
  paragraphs: [
    'strudel-music is an agent skill that bridges natural-language descriptions and live, generative music. Tell the agent what you want — "a warm lo-fi beat with a dusty vinyl feel" — and it translates your words into executable Strudel code.',
    'Built on the official strudel.cc REPL, every pattern is streamed into the player via a URL hash. The agent edits exactly one file: templates/src/pattern.js. No local synthesis engine, no @strudel/* npm packages — just describe, generate, and play.',
  ],
};

export const architecture = {
  id: 'architecture',
  title: 'How It Works',
  subtitle: 'Three steps from install to playback.',
  steps: [
    {
      number: '01',
      title: 'Install the skill',
      description:
        'Run install.sh to register the skill with your agent — Cursor, Claude Code, Hermes, Windsurf, OpenCode, or Xcode. Global or project-local scope, symlink or copy mode.',
    },
    {
      number: '02',
      title: 'Start the local player',
      description:
        'Run scripts/init.sh to copy templates, install dependencies, and launch the Vite dev server at http://localhost:5173/. Click play inside the iframe once to satisfy browser autoplay policy.',
    },
    {
      number: '03',
      title: 'Describe your music',
      description:
        'Tell the agent what you hear. It writes Strudel code to pattern.js. Vite HMR reads the new export, base64-encodes it, and reloads the iframe hash — changes play in about one second.',
    },
  ],
};

export const demo = {
  id: 'demo',
  title: 'See It In Action',
  subtitle: 'From a single prompt to a full arrangement in your browser.',
  examplePrompt:
    '/strudel-music please make a house music with full parts(intro, build-up, drop, outro).',
  steps: [
    {
      number: '01',
      title: 'Describe your track',
      caption:
        'Invoke the skill with a natural-language prompt. The agent plans the arrangement and checks that the dev server is running.',
      image: '/images/input_step1.png',
      alt: 'Claude Code terminal showing the user invoking /strudel-music with a house music prompt',
    },
    {
      number: '02',
      title: 'Agent writes the pattern',
      caption:
        'The agent edits pattern.js, structures intro, build-up, drop, and outro with arrange(), and summarizes the track before playback.',
      image: '/images/input_step2.png',
      alt: 'Claude Code terminal showing a pattern.js diff and a house track breakdown at 124 BPM',
    },
    {
      number: '03',
      title: 'Hear it in the browser',
      caption:
        'The Strudel REPL loads the generated code via iframe hash. Click play once, then every save reloads in about a second.',
      image: '/images/preview_page.png',
      alt: 'Strudel REPL in the browser showing BUILD-UP, DROP, and OUTRO sections with a play button',
    },
  ],
  resultSummary:
    'Result: a 124 BPM F minor house track — intro, build-up, drop, and outro across 40 bars (~77 seconds).',
};

export const features = {
  id: 'features',
  title: 'Features',
  subtitle: 'Everything you need — nothing you do not.',
  items: [
    {
      icon: 'music',
      title: 'Natural-language music',
      description:
        'Describe mood, tempo, and instrumentation in plain English. The skill maps your words to Strudel mini-notation using reference.md and genres.md.',
    },
    {
      icon: 'code',
      title: 'Official REPL integration',
      description:
        'Patterns run inside strudel.cc via an iframe hash — the only approved architecture. Local @strudel/web lacks setcpm, $:, and working drum prebake.',
    },
    {
      icon: 'monitor',
      title: 'Live browser preview',
      description:
        'Vite HMR reloads the iframe on every save to pattern.js. Hear changes in under a second without restarting the dev server.',
    },
    {
      icon: 'layers',
      title: 'Multi-genre templates',
      description:
        'Curated patterns for house, techno, hip-hop, jazz, ambient, drum and bass, and more. Mix, layer, and iterate from a proven starting point.',
    },
  ],
};

export const proTip = {
  label: 'Pro Tip',
  quote:
    'The first pattern requires one click inside the iframe. After that, every HMR reload plays silently — browser autoplay policy, not a bug.',
  attribution: 'From SKILL.md troubleshooting',
};

export const genres = {
  id: 'genres',
  title: 'Supported Genres',
  subtitle: 'Each genre includes curated rhythm and tonal patterns — mix, layer, and tweak to create something uniquely yours.',
  tags: [
    'House',
    'Techno',
    'Hip-Hop',
    'Jazz',
    'Ambient',
    'Drum & Bass',
    'Reggae',
    'Bossa Nova',
    'Classical',
    'Lo-Fi',
    'Pop / EDM',
  ],
};

export const quickStart = {
  id: 'quick-start',
  title: 'Quick Start',
  subtitle: 'Install, initialize, and listen — three commands.',
  exerciseLabel: 'Exercise',
  exercisePrompt: 'Run these commands, then ask your agent for a beat.',
  commands: `# 1. Install the skill into your agent
bash install.sh

# 2. Initialize the player (copies templates, npm install, starts Vite)
bash scripts/init.sh

# 3. Open http://localhost:5173/ and click play once inside the iframe

# Then tell your agent:
"make a chill lo-fi beat with a warm vinyl feel"`,
  examplePrompt: 'make a chill lo-fi beat with a warm vinyl feel',
};

export const limitations = {
  id: 'limitations',
  title: 'Known Limitations',
  subtitle: 'Honest boundaries — the skill says no when it must.',
  items: [
    'No audio export — the skill plays in the browser only, not to WAV or MP3.',
    'No exact song replicas — same genre and tempo, not a note-for-note copy.',
    'No vocal samples — upstream banks are drum-machine only.',
    'Requires a browser — there is no CLI player or headless server mode.',
    'Requires network access — the REPL loads from strudel.cc on every session.',
  ],
};

export const footer = {
  builtWith: {
    label: 'Built with',
    href: 'https://strudel.cc',
    name: 'strudel.cc',
  },
  github: {
    label: 'GitHub',
    href: 'https://github.com/ShadowWood/strudel-music-skill',
  },
  copyright: 'strudel-music',
  year: '2026',
};
