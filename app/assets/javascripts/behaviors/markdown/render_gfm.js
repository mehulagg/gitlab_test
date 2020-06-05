import $ from 'jquery';
import syntaxHighlight from '~/syntax_highlight';
import renderMath from './render_math';
import renderMermaid from './render_mermaid';
import renderMetrics from './render_metrics';
import highlightCurrentUser from './highlight_current_user';
import initUserPopovers from '../../user_popovers';
import initMRPopovers from '../../mr_popover';

function initCommentPopovers() {
  const links = Array.from(document.querySelectorAll(`a[href*="${window.location.pathname}"`));
  links.map(link => {
    const { hash } = new URL(link.href);

    if (hash.startsWith('#note_')) {
      const noteId = hash;
      const noteEl = document.querySelector(noteId);

      if (noteEl) {
        let noteContent = noteEl.querySelector('.note-text').textContent;

        const maxLength = 100;
        if (noteContent.length > maxLength) {
          noteContent = `${noteContent.slice(0, maxLength).replace(/\s+$/, '')}...`;
        }

        link.setAttribute('data-original-title', noteContent);
        link.removeAttribute('title');
      }
    }
  });
}

// Render GitLab flavoured Markdown
//
// Delegates to syntax highlight and render math & mermaid diagrams.
//
$.fn.renderGFM = function renderGFM() {
  syntaxHighlight(this.find('.js-syntax-highlight'));
  renderMath(this.find('.js-render-math'));
  renderMermaid(this.find('.js-render-mermaid'));
  highlightCurrentUser(this.find('.gfm-project_member').get());
  initUserPopovers(this.find('.js-user-link').get());
  initMRPopovers(this.find('.gfm-merge_request').get());
  initCommentPopovers();
  renderMetrics(this.find('.js-render-metrics').get());
  return this;
};

$(() => $('body').renderGFM());
