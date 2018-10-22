import Vue from 'vue';
import { withKnobs, boolean, number } from '@storybook/addon-knobs/vue';
import documentedStoriesOf from '../utils/documented_stories';
import { variantOptions } from '../utils/constants';
import readme from '../../documentation/skeleton_loading.md';
import { glSkeletonLoading } from '../../index';

const components = {
  glSkeletonLoading,
};

const template = '<gl-skeleton-loading :lines="lines" />';

function generateProps({
} = {}) {
  return {
    lines: {
      type: Number,
      default: number('lines', 3, {
        range: true,
        min: 1,
        max: 3,
        step: 1,
      }),
    }
  };
}

documentedStoriesOf('skeleton-loading', readme)
  .addDecorator(withKnobs)
  .add('default', () => ({
    props: generateProps(),
    components,
    template,
  }));
