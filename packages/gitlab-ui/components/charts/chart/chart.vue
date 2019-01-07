<script>
import echarts from 'echarts';

const validRenderers = ['canvas', 'svg'];
const defaultHeight = 400;

export default {
  props: {
    options: {
      type: Object,
      required: true,
    },
    width: {
      type: Number,
      required: false,
      default: null,
    },
    height: {
      type: Number,
      required: false,
      default: null,
    },
    groupId: {
      type: String,
      required: false,
      default: '',
    },
    renderer: {
      type: String,
      required: false,
      default: 'svg',
      validator(renderer) {
        return validRenderers.includes(renderer);
      },
    },
  },
  data() {
    return {
      chart: null,
    };
  },
  watch: {
    options() {
      this.draw();
    },
    width() {
      this.setChartSize();
    },
    height() {
      this.setChartSize();
    },
  },
  mounted() {
    this.chart = echarts.init(this.$refs.chart, null, { renderer: this.renderer });
    if (this.groupId.length) {
      this.chart.group = this.groupId;
      echarts.connect(this.groupId);
    }
    this.$emit('created', this.chart);
    this.draw();
    this.setChartSize();
  },
  methods: {
    draw() {
      this.chart.setOption(this.options);
      this.$emit('updated', this.chart);
    },
    setChartSize() {
      this.chart.resize({
        width: this.width || 'auto',
        height: this.height || defaultHeight,
      });
    },
  },
};
</script>

<template>
  <div ref="chart"></div>
</template>
