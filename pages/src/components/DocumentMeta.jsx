import { siteMeta } from '../content.js';

export default function DocumentMeta() {
  return (
    <header className="flex items-center justify-between border-b border-divider pb-4">
      <div className="flex flex-col gap-1 sm:flex-row sm:items-center sm:gap-6">
        <span className="label-meta">{siteMeta.edition}</span>
        <span className="hidden h-3 w-px bg-divider sm:block" aria-hidden="true" />
        <span className="label-meta text-charcoal">{siteMeta.projectName}</span>
      </div>
      <span className="label-meta">{siteMeta.pageLabel}</span>
    </header>
  );
}
