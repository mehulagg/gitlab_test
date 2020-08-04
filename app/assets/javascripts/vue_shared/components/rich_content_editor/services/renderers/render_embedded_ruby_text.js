const embeddedRubyRegex = /(^<%.+%>$)/;

const canRender = (node, context) => {
  return embeddedRubyRegex.test(context.getChildrenText(node));
};

const render = (node, context) => {
  const [[fromLine], [toLine]] = node.sourcepos;
  const rawErb = context.sourceContent
    .split('\n')
    .slice(fromLine - 1, toLine)
    .join('\n');

  context.skipChildren();

  return {
    type: 'html',
    content: ```<pre>${rawErb}</pre>```,
  };
};

export default { canRender, render };
