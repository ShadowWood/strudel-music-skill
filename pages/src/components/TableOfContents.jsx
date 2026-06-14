import { tableOfContents } from '../content.js';

export default function TableOfContents() {
  return (
    <nav aria-label="Table of contents" className="section-divider py-10 md:py-12">
      <h2 className="label-meta mb-6">Contents</h2>
      <ol className="space-y-3">
        {tableOfContents.map((item, index) => (
          <li key={item.href}>
            <a
              href={item.href}
              className="focus-ring toc-leader group cursor-pointer font-body text-base text-charcoal transition-colors duration-200 hover:text-terracotta md:text-lg"
            >
              <span className="font-label mr-2 text-[0.65rem] text-warm-gray">
                {String(index + 1).padStart(2, '0')}
              </span>
              <span className="group-hover:underline">{item.label}</span>
              <span className="font-label text-[0.65rem] text-warm-gray">
                {String(index + 1).padStart(2, '0')}
              </span>
            </a>
          </li>
        ))}
      </ol>
    </nav>
  );
}
