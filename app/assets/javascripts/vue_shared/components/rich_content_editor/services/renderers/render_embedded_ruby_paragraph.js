import {
  buildTextToken,
  buildOpenToken,
  buildCloseToken,
  buildUneditableOpenToken,
} from './build_uneditable_token';

const embeddedRubyRegex = /(^<%.+%>$)/;

const isEmbeddedRuby = literal => {
  return embeddedRubyRegex.test(literal);
};

const canRender = (node, context) => {
  return isEmbeddedRuby(context.getChildrenText(node)) && context.entering;
};

const render = (node, context) => {
  const [[fromLine], [toLine]] = node.sourcepos;

  const rawErb = context
    .sourceContent()
    .split(context.options.softbreak)
    .slice(fromLine - 1, toLine)
    .join(context.options.softbreak);

  context.skipChildren();

  const tokens = [
    buildUneditableOpenToken('pre', { attributes: { 'data-sse-erb': true } }),
    buildOpenToken('code'),
    buildTextToken(rawErb),
    buildCloseToken('code'),
    buildCloseToken('pre'),
  ];

  return tokens;
};

export default { canRender, render };
