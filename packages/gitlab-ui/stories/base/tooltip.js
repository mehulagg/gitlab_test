import { withKnobs, select } from '@storybook/addon-knobs';
import documentedStoriesOf from '../utils/documented_stories';
import readme from '../../components/base/tooltip/tooltip.md';
import { tooltipPlacements } from '../utils/constants';
import { GlTooltip, GlTooltipDirective } from '../../index';

const directives = {
  GlTooltipDirective,
};

const components = {
  GlTooltip,
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
      this.$el.querySelector('button').focus();
    },
  });
}

function generateProps({ placement = tooltipPlacements.top } = {}) {
  return {
    placement: {
      type: String,
      default: select('placement', tooltipPlacements, placement),
    },
  };
}

function generateTooltip() {
  return () => ({
    props: generateProps(),
    components,
    template: `
      <div class="d-flex align-items-center justify-content-center p-5 m-5">
        <button id="btn1">Tooltip</button>
        <gl-tooltip 
          target="btn1"
          triggers="hover focus click"
          :placement="placement"
        >
          Hello <strong>World!</strong>
        </gl-tooltip>
      </div>
    `,
    mounted() {
      this.$nextTick(() => this.$el.querySelector('button').focus());
    },
  });
}

documentedStoriesOf('base|tooltip', readme)
  .addDecorator(withKnobs)
  .add('defaults to top', makeTooltip())
  .add('to the right', makeTooltip('.right'))
  .add('to the bottom', makeTooltip('.bottom'))
  .add('to the left', makeTooltip('.left'))
  .add('with HTML content', generateTooltip());
