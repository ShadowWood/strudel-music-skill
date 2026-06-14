export default function DropCapParagraph({ children, className = '' }) {
  return (
    <p className={`drop-cap font-body text-base leading-relaxed text-warm-gray md:text-lg ${className}`}>
      {children}
    </p>
  );
}
