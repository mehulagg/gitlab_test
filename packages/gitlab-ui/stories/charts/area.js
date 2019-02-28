import { withKnobs, object } from '@storybook/addon-knobs';
import documentedStoriesOf from '../utils/documented_stories';
import { GlAreaChart } from '../../charts';
import readme from '../../components/charts/area/area.md';

const components = {
  GlAreaChart,
};

function generateProps({
  data = {
    Full: [
      ['Mon', 1220],
      ['Tue', 932],
      ['Wed', 901],
      ['Thu', 934],
      ['Fri', 1290],
      ['Sat', 1330],
      ['Sun', 1320],
    ],
  },
  option = {
    xAxis: {
      name: 'Time',
      type: 'category',
    },
  },
  thresholds = {
    'too-high': { threshold: 1200, operator: '>' },
  },
} = {}) {
  return {
    data: {
      type: Object,
      default: object('Chart Data', data),
    },
    option: {
      type: Object,
      default: object('EChart Options', option),
    },
    thresholds: {
      type: Object,
      default: object('Thresholds', thresholds),
    },
  };
}

documentedStoriesOf('charts|area-chart', readme)
  .addDecorator(withKnobs)
  .add('default', () => ({
    props: generateProps(),
    components,
    template: `<gl-area-chart
      :data="data"
      :option="option"
      :thresholds="thresholds"
    />`,
  }));
