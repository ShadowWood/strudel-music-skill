import { quickStart } from '../content.js';
import Section from './Section.jsx';
import CodeBlock from './CodeBlock.jsx';

export default function ExerciseBox() {
  return (
    <Section id={quickStart.id} title={quickStart.title} subtitle={quickStart.subtitle}>
      <div className="exercise-box">
        <div className="mb-4 inline-block rounded-sm border border-terracotta px-3 py-1">
          <span className="label-meta text-terracotta">{quickStart.exerciseLabel}</span>
        </div>
        <p className="mb-5 font-body text-base text-warm-gray">{quickStart.exercisePrompt}</p>
        <CodeBlock code={quickStart.commands} />
      </div>
    </Section>
  );
}
