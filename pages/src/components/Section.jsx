export default function Section({ id, title, subtitle, children, className = '' }) {
  return (
    <section id={id} aria-labelledby={`${id}-heading`} className={`section-divider py-10 md:py-14 ${className}`}>
      <div className="mb-8">
        <h2
          id={`${id}-heading`}
          className="font-display text-2xl font-semibold text-charcoal md:text-3xl"
        >
          {title}
        </h2>
        {subtitle && (
          <p className="mt-3 font-display text-lg italic text-warm-gray md:text-xl">{subtitle}</p>
        )}
      </div>
      {children}
    </section>
  );
}
