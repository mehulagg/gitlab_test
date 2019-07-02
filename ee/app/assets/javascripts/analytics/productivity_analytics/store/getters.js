import { metricTypes } from './../constants';

export const chartLoading = state => chartKey => state.charts[chartKey].isLoading;

export const getChartData = state => chartKey => state.charts[chartKey].data;

export const getSelectedChartData = state => chartKey => state.charts[chartKey].selected;

export const getMetricDropdownLabel = state => chartKey =>
  metricTypes.find(m => m.key === state.charts[chartKey].params.metricType).label;
