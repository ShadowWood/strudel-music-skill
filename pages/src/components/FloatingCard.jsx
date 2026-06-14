import { Lightbulb } from 'lucide-react';
import { proTip } from '../content.js';

export default function FloatingCard() {
  return (
    <aside aria-label="Pro tip" className="floating-card lg:sticky lg:top-8 lg:self-start">
      <div className="mb-4 flex items-center gap-2">
        <Lightbulb className="h-4 w-4 text-muted-orange" aria-hidden="true" />
        <span className="label-meta text-terracotta">{proTip.label}</span>
      </div>
      <blockquote className="font-display text-lg italic leading-relaxed text-charcoal md:text-xl">
        &ldquo;{proTip.quote}&rdquo;
      </blockquote>
      <p className="mt-4 font-label text-[0.65rem] uppercase tracking-wider text-warm-gray">
        {proTip.attribution}
      </p>
    </aside>
  );
}
