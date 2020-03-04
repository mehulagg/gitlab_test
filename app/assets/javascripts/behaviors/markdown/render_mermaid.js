import flash from '~/flash';
import $ from 'jquery';
import { sprintf, __ } from '../../locale';
import { once } from 'lodash';

// Renders diagrams and flowcharts from text using Mermaid in any element with the
// `js-render-mermaid` class.
//
// Example markup:
//
// <pre class="js-render-mermaid">
//  graph TD;
//    A-- > B;
//    A-- > C;
//    B-- > D;
//    C-- > D;
// </pre>
//

// This is an arbitrary number; Can be iterated upon when suitable.
const MAX_CHAR_LIMIT = 50;
let mermaidModule = {};

function importMermaidModule() {
  return import(/* webpackChunkName: 'mermaid' */ 'mermaid')
    .then(mermaid => {
      mermaid.initialize({
        // mermaid core options
        mermaid: {
          startOnLoad: false,
        },
        // mermaidAPI options
        theme: 'neutral',
        flowchart: {
          htmlLabels: false,
        },
        securityLevel: 'strict',
      });

      mermaidModule = mermaid;

      return mermaid;
    })
    .catch(err => {
      flash(`Can't load mermaid module: ${err}`);
    });
}

function fixElementSource(el) {
  // Mermaid doesn't like `<br />` tags, so collapse all like tags into `<br>`, which is parsed correctly.
  const source = el.textContent.replace(/<br\s*\/>/g, '<br>');

  // Remove any extra spans added by the backend syntax highlighting.
  Object.assign(el, { textContent: source });

  return { source };
}

function renderMermaidEl(el) {
  mermaidModule.init(undefined, el, id => {
    const source = el.textContent;
    const svg = document.getElementById(id);

    // As of https://github.com/knsv/mermaid/commit/57b780a0d,
    // Mermaid will make two init callbacks:one to initialize the
    // flow charts, and another to initialize the Gannt charts.
    // Guard against an error caused by double initialization.
    if (svg.classList.contains('mermaid')) {
      return;
    }

    svg.classList.add('mermaid');

    // pre > code > svg
    svg.closest('pre').replaceWith(svg);

    // We need to add the original source into the DOM to allow Copy-as-GFM
    // to access it.
    const sourceEl = document.createElement('text');
    sourceEl.classList.add('source');
    sourceEl.setAttribute('display', 'none');
    sourceEl.textContent = source;

    svg.appendChild(sourceEl);
  });
}

function renderMermaids($els) {
  if (!$els.length) return;

  // A diagram may have been truncated in search results which will cause errors, so abort the render.
  if (document.querySelector('body').dataset.page === 'search:show') return;

  importMermaidModule()
    .then(() => {
      let renderedChars = 0;

      $els.each((i, el) => {
        const { source } = fixElementSource(el);
        /**
         * Restrict the rendering to a certain amount of character to
         * prevent mermaidjs from hanging up the entire thread and
         * causing a DoS.
         */
        if ((source && source.length > MAX_CHAR_LIMIT) || renderedChars > MAX_CHAR_LIMIT) {
          const errorText = sprintf(
            __(
              'Cannot render the image. Maximum character count (%{charLimit}) has been exceeded.',
            ),
            { charLimit: MAX_CHAR_LIMIT },
          );

          const html = `
              <div class="js-lazy-render-mermaid-container d-flex-center">
                <span class="margin-right-small mr-2">${errorText}</span>
                <button class="btn btn-link js-lazy-render-mermaid">Render</button>
              </div>
          `;

          const $parent = $(el).parent();

          if (!$parent.find('.js-lazy-render-mermaid-container').length) {
            $parent.find('.js-render-mermaid').hide();
            $parent.append(html);
          }

          return;
        }

        renderedChars += source.length;

        renderMermaidEl(el);
      });
    })
    .catch(err => {
      flash(`Encountered an error while rendering: ${err}`);
    });
}

const hookLazyRenderMermaidEvent = once(() => {
  $(document.body).on('click', '.js-lazy-render-mermaid', function eventHandler() {
    const el = $(this)
      .closest('.mermaid')
      .find('.js-render-mermaid');

    $(el).show();

    $(this)
      .parent()
      .remove();

    renderMermaidEl(el);
  });
});

export default function renderMermaid($els) {
  if (!$els.length) return;

  const visibleMermaids = $els.filter(function filter() {
    return $(this).closest('details').length === 0;
  });

  renderMermaids(visibleMermaids);

  $els.closest('details').one('toggle', function toggle() {
    if (this.open) {
      renderMermaids($(this).find('.js-render-mermaid'));
    }
  });

  hookLazyRenderMermaidEvent();
}
