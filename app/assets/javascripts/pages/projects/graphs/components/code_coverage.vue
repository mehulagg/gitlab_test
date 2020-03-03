<script>
import { GlDropdown, GlDropdownItem, GlIcon } from '@gitlab/ui';
import { GlAreaChart } from '@gitlab/ui/dist/charts';
import { __ } from '~/locale';

export default {
  components: {
    GlAreaChart,
    GlDropdown,
    GlDropdownItem,
    GlIcon,
  },
  props: {
    languages: {
      type: Array,
      required: true,
    },
    chartData: {
      type: Array,
      default: () => []
    },
  },
  data() {
    return {
      selectedLanguageId: 0,
    };
  },
  computed: {
    dates(){
      return ['2020-01-01', '2020-01-08', '2020-01-15', '2020-01-22', '2020-01-29', '2020-02-04', '2020-01-11']
    },
    selected() {
      return this.languages[this.selectedLanguageId];
    },
    selectedLabel() {
      return this.selected.label;
    },
    chartStyle() {
      return { color: this.selected.color };
    },
    dateRange() {
    // TODO: Take the first and last date entry to make a range
      return "May 3rd to June 5th"
    },
    downloadCsv() {
      const data = new Blob([this.csvText], { type: 'text/plain' });
      return window.URL.createObjectURL(data);
    },
  },
  methods: {
    getChartData() {
      return [
        {
          name: this.selectedLabel,
          // TODO: pass the data from the API
          data: [[0, 50], [1, 55], [2, 60], [3, 40], [4, 35], [5, 34], [6, 50]],
          type: 'line',
          areaStyle: this.chartStyle,
          lineStyle: this.chartStyle,
          itemStyle: this.chartStyle,
          smooth: true,
        },
      ];
    },
    getChartOptions() {
      return {
        yAxis: {
          name: __('Bi-weekly code coverage'),
          type: 'value',
          min: 0,
          max: 100,
        },
        xAxis: {
          name: '',
          type: 'category',
          data: this.dates,
        },
      };
    },
    formatTooltipText(){

    }
  },
};
</script>

<template>
  <div>
    <div class="d-flex justify-content-between align-items-center">
      <h4 class="sub-header">{{ __(`Code coverage statistics for master ${dateRange}`) }}</h4>
      <button class="btn btn-light h-100 pl-2 pr-2 pt-0 pb-0" style="font-size: 11px;">
        {{ __('Download raw data (.csv)') }}
      </button>
    </div>
    <div class="d-flex justify-content-end mr-5 mt-3">
      <gl-dropdown :text="selectedLabel">
        <gl-dropdown-item
          v-for="(lang, index) in languages"
          :key="lang.label"
          @click="selectedLanguageId = index"
        >
          <div class="d-flex">
            <gl-icon
              v-if="index === selectedLanguageId"
              name="mobile-issue-close"
              class="position-absolute"
            />
            <span class="d-flex align-items-center ml-4">
              <span class="mr-2" :style="{ color: lang.color }">
                <gl-icon name="stop"/>
                </span>{{ lang.label }}
              </span>
          </div>
        </gl-dropdown-item>
      </gl-dropdown>
    </div>
    <gl-area-chart :height="250" :data="getChartData()" :option="getChartOptions()" :formatTooltipText="formatTooltipText" />
  </div>
</template>
