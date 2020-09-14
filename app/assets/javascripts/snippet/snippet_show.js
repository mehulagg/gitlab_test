import LineHighlighter from '~/line_highlighter';
import BlobViewer from '~/blob/viewer';
import ZenMode from '~/zen_mode';
import initNotes from '~/init_notes';
import snippetEmbed from '~/snippet/snippet_embed';
import { SnippetShowInit } from '~/snippets';
import loadAwardsHandler from '~/awards_handler';

document.addEventListener('DOMContentLoaded', () => {
  if (!gon.features.snippetsVue) {
    new LineHighlighter(); // eslint-disable-line no-new
    new BlobViewer(); // eslint-disable-line no-new
    initNotes();
    new ZenMode(); // eslint-disable-line no-new
    snippetEmbed();
  } else {
    SnippetShowInit();
    initNotes();
  }
  loadAwardsHandler();
});
