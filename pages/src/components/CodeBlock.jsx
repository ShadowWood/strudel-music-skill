function highlightCode(code) {
  const lines = code.split('\n');
  return lines.map((line, index) => {
    if (line.startsWith('#')) {
      return (
        <span key={index} className="block text-warm-gray/70">
          {line}
          {index < lines.length - 1 ? '\n' : ''}
        </span>
      );
    }
    if (line.startsWith('"')) {
      return (
        <span key={index} className="block text-terracotta">
          {line}
          {index < lines.length - 1 ? '\n' : ''}
        </span>
      );
    }
    return (
      <span key={index}>
        {line}
        {index < lines.length - 1 ? '\n' : ''}
      </span>
    );
  });
}

export default function CodeBlock({ code }) {
  return (
    <pre className="code-block">
      <code>{highlightCode(code)}</code>
    </pre>
  );
}
