import documentedStoriesOf from '../utils/documented_stories';
import { GlChart } from '../../charts';
import readme from '../../components/charts/chart/chart.md';

const components = {
  GlChart,
};

documentedStoriesOf('charts|chart', readme).add('default', () => ({
  props: {},
  components,
  data() {
    return {
      options: {
        xAxis: {
          type: 'category',
          data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        },
        yAxis: {
          type: 'value',
        },
        series: [
          {
            data: [820, 932, 901, 934, 1290, 1330, 1320],
            type: 'bar',
          },
        ],
      },
    };
  },
  template: `<gl-chart
      :options="options"
    />`,
}));
