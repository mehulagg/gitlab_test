import Vue from 'vue';
import { storiesOf } from '@storybook/vue';

storiesOf('progress-bar', module)
  .add('default', () => ({
    template: '<gl-progress-bar :value="30" />'
  }))
  .add('success variant', () => ({
    template: '<gl-progress-bar :value="30" variant="success" />'
  }));
