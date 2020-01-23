const cachedData = new Map();

export const getAllPreviousElements = el => {
  let node = el.previousSibling;
  const previousEls = [];

  while (node) {
    previousEls.push(node);
    node = node.previousSibling;
  }

  return previousEls;
};
export const getCharacterIndex = el => {
  if (!cachedData.has(el)) {
    cachedData.set(
      el,
      getAllPreviousElements(el).reduce((acc, { textContent }) => acc + textContent.length, 0),
    );
  }

  return cachedData.get(el);
};

export const getLines = () => {
  if (!cachedData.has('lines')) {
    cachedData.set('lines', [...document.querySelectorAll('.blob-viewer .line')]);
  }

  return cachedData.get('lines');
};
export const getLineIndex = lineEl => getLines().indexOf(lineEl);

export const getCurrentHoverElement = () => cachedData.get('current');
export const setCurrentHoverElement = el => cachedData.set('current', el);
