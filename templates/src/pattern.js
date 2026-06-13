// templates/src/pattern.js
// The agent's only edit target. Its default export is a template-literal
// string of Strudel code that Vite HMR pushes into the strudel.cc iframe
// via templates/src/main.js. Keep this file as a plain ESM string source:
// exactly one `export default` statement, no other bindings, no imports.

export default `setcpm(90/4)
$: note("c e g").sound("square")
`;
