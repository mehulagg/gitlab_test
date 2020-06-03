import Vue from 'vue';
import { __ } from '~/locale';
import { GlColumnChart } from '@gitlab/ui/dist/charts';

export default () => {
	const containers = document.querySelectorAll('.js-project-analytics-chart');

	if (!containers) {
		return false;
	}  

	return containers.forEach(container => {
		return new Vue({
			el: container,
			components: {
				GlColumnChart,
			},
			data() {
				return {
					chartData: JSON.parse(container.dataset.chartData),
				};
			},
			computed: {
				seriesData() {
					return { full: this.chartData.keys.map((val, idx) => [val, this.chartData.values[idx]]) };
				},
			},
			render(h) {
				return h(GlColumnChart, {
					props: {
						data: this.seriesData,
						xAxisTitle: __('Value'),
						yAxisTitle: __('Number of events'),
						xAxisType: 'category',
					},
				});
			},
		});
	});
};
