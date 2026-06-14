export default function ScreenshotFigure({ number, title, caption, src, alt }) {
  return (
    <figure className="screenshot-frame">
      <div className="mb-4 flex items-baseline gap-4">
        <span
          className="shrink-0 font-display text-2xl font-semibold text-terracotta md:text-3xl"
          aria-hidden="true"
        >
          {number}
        </span>
        <h3 className="font-display text-lg font-semibold text-charcoal md:text-xl">{title}</h3>
      </div>
      <div className="overflow-hidden rounded-sm border border-divider bg-white shadow-paper">
        <img
          src={src}
          alt={alt}
          loading="lazy"
          decoding="async"
          className="block w-full"
        />
      </div>
      <figcaption className="mt-4 font-body text-sm leading-relaxed text-warm-gray md:text-base">
        {caption}
      </figcaption>
    </figure>
  );
}
