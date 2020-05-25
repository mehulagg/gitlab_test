import Mousetrap from 'mousetrap';
import $ from 'jquery';
import { updateText } from '~/lib/utils/text_markdown';

function toggleMarkdownPreview(e) {
  // Check if short-cut was triggered while in Write Mode
  const $target = $(e.target);
  const $form = $target.closest('form');

  if ($target.hasClass('js-note-text')) {
    $('.js-md-preview-button', $form).focus();
  }
  $(document).triggerHandler('markdown-preview:toggle', [e]);
}

function insertMarkdownBoldSymbol(e) {
  updateText({
    textArea: $(e.target),
    tag: '**',
    cursorOffset: 0,
    wrap: true,
  });
}

function insertMarkdownItalicSymbol(e) {
  updateText({
    textArea: $(e.target),
    tag: '*',
    cursorOffset: 0,
    wrap: true,
  });
}

function insertMarkdownLinkSymbol(e) {
  updateText({
    textArea: $(e.target),
    tag: '[{text}](url)',
    cursorOffset: 0,
    wrap: true,
    select: 'url',
  });
}

function meta(shortcut) {
  return [`ctrl+${shortcut}`, `command+${shortcut}`];
}

export default function initMarkdownShortcuts() {
  const markdownPreviewShortcut = meta('shift+p');
  const boldTextShortcut = meta('b');
  const italicTextShortcut = meta('i');
  const linkTextShortcut = meta('k');
  
  const textareaShortcuts = [
    ...markdownPreviewShortcut,
    ...boldTextShortcut,
    ...italicTextShortcut,
    ...linkTextShortcut,
  ];

  const defaultStopCallback = Mousetrap.stopCallback;
  Mousetrap.stopCallback = (e, element, combo) => {
    if (textareaShortcuts.includes(combo)) {
      return false;
    }

    return defaultStopCallback(e, element, combo);
  };

  Mousetrap.bind(markdownPreviewShortcut, toggleMarkdownPreview);
  Mousetrap.bind(boldTextShortcut, insertMarkdownBoldSymbol);
  Mousetrap.bind(italicTextShortcut, insertMarkdownItalicSymbol);
  Mousetrap.bind(linkTextShortcut, insertMarkdownLinkSymbol);
}
