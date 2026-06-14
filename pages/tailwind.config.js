/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        cream: '#F5F2ED',
        charcoal: '#1A1A1A',
        terracotta: '#C05E4E',
        'muted-orange': '#E8A87C',
        'warm-gray': '#6B6560',
        divider: '#D4CFC7',
      },
      fontFamily: {
        display: ['"Playfair Display"', 'Georgia', 'serif'],
        body: ['Lora', 'Georgia', 'serif'],
        label: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['ui-monospace', 'SFMono-Regular', 'Menlo', 'monospace'],
      },
      boxShadow: {
        paper: '0 4px 24px rgba(26, 26, 26, 0.06), 0 1px 3px rgba(26, 26, 26, 0.04)',
        float: '0 8px 32px rgba(26, 26, 26, 0.1), 0 2px 8px rgba(26, 26, 26, 0.06)',
      },
      maxWidth: {
        editorial: '72rem',
      },
    },
  },
  plugins: [],
};
