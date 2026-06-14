import { demo } from '../content.js';
import Section from './Section.jsx';
import ScreenshotFigure from './ScreenshotFigure.jsx';

export default function DemoWalkthrough() {
  return (
    <Section id={demo.id} title={demo.title} subtitle={demo.subtitle}>
      <div className="mb-10 rounded-sm border border-divider bg-white/60 p-5 md:p-6">
        <p className="label-meta mb-3">Example prompt</p>
        <p className="font-mono text-sm leading-relaxed text-charcoal md:text-base">{demo.examplePrompt}</p>
      </div>

      <div className="space-y-12 md:space-y-16">
        {demo.steps.map((step) => (
          <ScreenshotFigure
            key={step.number}
            number={step.number}
            title={step.title}
            caption={step.caption}
            src={step.image}
            alt={step.alt}
          />
        ))}
      </div>

      <p className="mt-10 border-t border-divider pt-6 font-body text-base italic text-warm-gray md:text-lg">
        {demo.resultSummary}
      </p>
    </Section>
  );
}
