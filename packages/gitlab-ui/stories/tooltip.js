import { storiesOf } from '@storybook/vue';

function makeTooltip(modifier = '') {
  return () => ({
    template: `
      <div class="d-flex align-items-center justify-content-center p-5 m-5">
        <button
          v-gl-tooltip${modifier}
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

storiesOf('tooltip', module)
  .add('defaults to top', makeTooltip())
  .add('to the right', makeTooltip('.right'))
  .add('to the bottom', makeTooltip('.bottom'))
  .add('to the left', makeTooltip('.left'));
