import { limitations as limitationsContent } from '../content.js';
import Section from './Section.jsx';

export default function Limitations() {
  return (
    <Section
      id={limitationsContent.id}
      title={limitationsContent.title}
      subtitle={limitationsContent.subtitle}
    >
      <ul className="space-y-4">
        {limitationsContent.items.map((item) => (
          <li key={item} className="flex gap-4 font-body text-base leading-relaxed text-warm-gray md:text-lg">
            <span className="mt-2 h-1.5 w-1.5 shrink-0 rounded-full bg-terracotta" aria-hidden="true" />
            {item}
          </li>
        ))}
      </ul>
    </Section>
  );
}
