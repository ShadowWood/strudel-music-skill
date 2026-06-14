import { stats } from '../content.js';

export default function StatsRow() {
  return (
    <section aria-label="Key statistics" className="section-divider py-10 md:py-12">
      <div className="grid grid-cols-1 gap-8 sm:grid-cols-3 sm:gap-6">
        {stats.map((stat) => (
          <div key={stat.label} className="text-center sm:text-left">
            <p className="font-display text-4xl font-semibold text-terracotta md:text-5xl">{stat.value}</p>
            <p className="mt-2 font-label text-[0.65rem] font-medium uppercase tracking-[0.18em] text-warm-gray">
              {stat.label}
            </p>
          </div>
        ))}
      </div>
    </section>
  );
}
