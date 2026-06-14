import { Music, Code2, Monitor, Layers } from 'lucide-react';
import { features as featuresContent } from '../content.js';
import Section from './Section.jsx';

const iconMap = {
  music: Music,
  code: Code2,
  monitor: Monitor,
  layers: Layers,
};

export default function Features() {
  return (
    <Section id={featuresContent.id} title={featuresContent.title} subtitle={featuresContent.subtitle}>
      <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
        {featuresContent.items.map((item) => {
          const Icon = iconMap[item.icon];
          return (
            <article key={item.title} className="feature-card">
              <Icon className="mb-4 h-6 w-6 text-terracotta" aria-hidden="true" />
              <h3 className="font-display text-lg font-semibold text-charcoal">{item.title}</h3>
              <p className="mt-2 font-body text-sm leading-relaxed text-warm-gray md:text-base">
                {item.description}
              </p>
            </article>
          );
        })}
      </div>
    </Section>
  );
}
