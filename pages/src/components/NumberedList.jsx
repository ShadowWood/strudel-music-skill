export default function NumberedList({ items }) {
  return (
    <ol className="space-y-8">
      {items.map((item) => (
        <li key={item.number} className="flex gap-5 md:gap-8">
          <span
            className="shrink-0 font-display text-2xl font-semibold text-terracotta md:text-3xl"
            aria-hidden="true"
          >
            {item.number}
          </span>
          <div>
            <h3 className="font-display text-lg font-semibold text-charcoal md:text-xl">{item.title}</h3>
            <p className="mt-2 font-body text-base leading-relaxed text-warm-gray">{item.description}</p>
          </div>
        </li>
      ))}
    </ol>
  );
}
