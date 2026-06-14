import {
  about,
  architecture,
} from './content.js';
import DocumentMeta from './components/DocumentMeta.jsx';
import Hero from './components/Hero.jsx';
import StatsRow from './components/StatsRow.jsx';
import TableOfContents from './components/TableOfContents.jsx';
import Section from './components/Section.jsx';
import DropCapParagraph from './components/DropCapParagraph.jsx';
import NumberedList from './components/NumberedList.jsx';
import FloatingCard from './components/FloatingCard.jsx';
import DemoWalkthrough from './components/DemoWalkthrough.jsx';
import Features from './components/Features.jsx';
import GenreTags from './components/GenreTags.jsx';
import ExerciseBox from './components/ExerciseBox.jsx';
import Limitations from './components/Limitations.jsx';
import Footer from './components/Footer.jsx';

export default function App() {
  return (
    <div className="min-h-screen bg-cream">
      <div className="editorial-page editorial-paper relative mx-4 my-6 md:mx-8 md:my-10 lg:mx-auto">
        <DocumentMeta />
        <Hero />
        <StatsRow />
        <TableOfContents />

        <Section id={about.id} title={about.title} subtitle={about.subtitle}>
          <div className="space-y-6">
            <DropCapParagraph>{about.paragraphs[0]}</DropCapParagraph>
            <p className="font-body text-base leading-relaxed text-warm-gray md:text-lg">
              {about.paragraphs[1]}
            </p>
          </div>
        </Section>

        <Section id={architecture.id} title={architecture.title} subtitle={architecture.subtitle}>
          <NumberedList items={architecture.steps} />
        </Section>

        <DemoWalkthrough />

        <div className="grid grid-cols-1 gap-8 lg:grid-cols-[minmax(0,1fr)_18rem] lg:gap-10 xl:grid-cols-[minmax(0,1fr)_20rem]">
          <Features />
          <FloatingCard />
        </div>

        <GenreTags />
        <ExerciseBox />
        <Limitations />
        <Footer />
      </div>
    </div>
  );
}
