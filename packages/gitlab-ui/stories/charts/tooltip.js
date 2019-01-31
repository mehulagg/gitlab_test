import documentedStoriesOf from '../utils/documented_stories';
import { GlChart, GlChartTooltip } from '../../charts';
import readme from '../../components/charts/tooltip/tooltip.md';

const components = {
  GlChart,
  GlChartTooltip,
};

documentedStoriesOf('charts|chart-tooltip', readme).add('default', () => ({
  props: {},
  components,
  data() {
    return {
      chart: null,
      options: {},
      showTooltip: true,
      top: '50%',
      left: '0px',
    };
  },
  methods: {
    onCreated(chart) {
      this.chart = chart;
    },
  },
  template: `<div class="position-relative">
    <gl-chart
      :options="options"
      :height="100"
      @created="onCreated"
    />
    <gl-chart-tooltip
      v-if="chart"
      :chart="chart"
      :show="showTooltip"
      :top="top"
      :left="left"
    >
      <div slot="title">
        Example Title
      </div>
      Example Content
    </gl-chart-tooltip>
  </div>`,
}));
