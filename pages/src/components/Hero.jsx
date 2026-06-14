import { ArrowUpRight } from 'lucide-react';
import { hero } from '../content.js';

export default function Hero() {
  const { badge, title, tagline, cta } = hero;

  return (
    <section className="relative pt-10 pb-12 md:pt-14 md:pb-16" aria-labelledby="hero-heading">
      <div
        className="absolute right-0 top-8 flex h-16 w-16 items-center justify-center rounded-full bg-muted-orange md:top-12 md:h-20 md:w-20"
        aria-hidden="true"
      >
        <span className="font-label text-[0.55rem] font-semibold uppercase leading-tight tracking-wider text-white text-center px-2">
          {badge}
        </span>
      </div>

      <h1
        id="hero-heading"
        className="max-w-3xl font-display text-4xl font-semibold leading-[1.1] tracking-tight text-charcoal md:text-5xl lg:text-6xl text-balance"
      >
        {title.prefix}{' '}
        <span className="text-terracotta">{title.highlight}</span>
        <br className="hidden sm:block" />
        <span className="sm:inline">
          {' '}
          Skill{' '}
          <span className="font-normal italic text-muted-orange">{title.connector}</span>{' '}
          <span className="italic">{title.suffix}</span>
        </span>
      </h1>

      <div className="mt-6 max-w-xl border-t border-divider pt-6">
        <p className="font-body text-lg leading-relaxed text-warm-gray md:text-xl">{tagline}</p>
      </div>

      <div className="mt-8">
        <a
          href={cta.href}
          target="_blank"
          rel="noopener noreferrer"
          className="focus-ring inline-flex cursor-pointer items-center gap-2 rounded-sm bg-terracotta px-6 py-3 font-label text-xs font-semibold uppercase tracking-widest text-white transition-colors duration-200 hover:bg-terracotta/90"
        >
          {cta.label}
          <ArrowUpRight className="h-4 w-4" aria-hidden="true" />
        </a>
      </div>
    </section>
  );
}
