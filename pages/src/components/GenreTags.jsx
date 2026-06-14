import { genres as genresContent } from '../content.js';
import Section from './Section.jsx';

export default function GenreTags() {
  return (
    <Section id={genresContent.id} title={genresContent.title} subtitle={genresContent.subtitle}>
      <div className="flex flex-wrap gap-3">
        {genresContent.tags.map((tag) => (
          <span key={tag} className="genre-tag">
            {tag}
          </span>
        ))}
      </div>
    </Section>
  );
}
