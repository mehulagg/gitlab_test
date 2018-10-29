import documentedStoriesOf from './utils/documented_stories';
import readme from '../documentation/tooltip.md';
import { GlTooltipDirective } from '../index';

const directives = {
  GlTooltipDirective,
};

function makeTooltip(modifier = '') {
  return () => ({
    directives,
    template: `
      <div class="d-flex align-items-center justify-content-center p-5 m-5">
        <button
          v-gl-tooltip-directive${modifier}
          title="some tooltip text"
        >
            Tooltip
        </button>
      </div>
    `,
    mounted() {
      this.$el.querySelector('button').focus()
    }
  });
}

documentedStoriesOf('tooltip', readme)
  .add('defaults to top', makeTooltip())
  .add('to the right', makeTooltip('.right'))
  .add('to the bottom', makeTooltip('.bottom'))
  .add('to the left', makeTooltip('.left'));
