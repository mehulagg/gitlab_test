import { withKnobs, number } from '@storybook/addon-knobs/vue';
import documentedStoriesOf from '../utils/documented_stories';
import readme from '../../components/base/skeleton_loading/skeleton_loading.md';
import { GlSkeletonLoading } from '../../index';

const components = {
  GlSkeletonLoading,
};

const template = '<gl-skeleton-loading :lines="lines" />';

function generateProps() {
  return {
    lines: {
      type: Number,
      default: number('lines', 3, {
        range: true,
        min: 1,
        max: 3,
        step: 1,
      }),
    },
  };
}

documentedStoriesOf('base|skeleton-loading', readme)
  .addDecorator(withKnobs)
  .add('default', () => ({
    props: generateProps(),
    components,
    template,
  }));
