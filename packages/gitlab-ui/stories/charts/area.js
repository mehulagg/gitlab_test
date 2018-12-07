import documentedStoriesOf from '../utils/documented_stories';
import { GlAreaChart } from '../../index';
import readme from '../../components/charts/area/area.md';

const components = {
  GlAreaChart,
};

documentedStoriesOf('area-chart', readme).add('default', () => ({
  props: {},
  components,
  data() {
    return {
      data: {
        Full: {
          Mon: 1220,
          Tue: 932,
          Wed: 901,
          Thu: 934,
          Fri: 1290,
          Sat: 1330,
          Sun: 1320,
        },
      },
      option: {
        xAxis: {
          name: 'Time',
          type: 'category',
        },
      },
    };
  },
  template: `<gl-area-chart
    :data="data"
    :option="option"
  />`,
}));
