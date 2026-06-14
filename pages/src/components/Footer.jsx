import { footer } from '../content.js';

export default function Footer() {
  return (
    <footer className="section-divider py-10 text-center md:py-12">
      <p className="font-body text-sm text-warm-gray">
        {footer.builtWith.label}{' '}
        <a
          href={footer.builtWith.href}
          target="_blank"
          rel="noopener noreferrer"
          className="focus-ring cursor-pointer text-terracotta underline decoration-terracotta/30 underline-offset-4 transition-colors duration-200 hover:decoration-terracotta"
        >
          {footer.builtWith.name}
        </a>
        <span className="mx-2 text-divider" aria-hidden="true">
          |
        </span>
        <a
          href={footer.github.href}
          target="_blank"
          rel="noopener noreferrer"
          className="focus-ring cursor-pointer text-terracotta underline decoration-terracotta/30 underline-offset-4 transition-colors duration-200 hover:decoration-terracotta"
        >
          {footer.github.label}
        </a>
      </p>
      <p className="mt-3 font-label text-[0.65rem] uppercase tracking-wider text-warm-gray/70">
        {footer.copyright} &copy; {footer.year}
      </p>
    </footer>
  );
}
