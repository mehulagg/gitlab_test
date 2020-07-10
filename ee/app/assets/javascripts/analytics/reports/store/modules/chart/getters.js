import { SERIES_LABEL_COLORS, SERIES_LABEL_STYLE } from 'ee/analytics/reports/constants';

export const displayChart = state => Boolean(!state.isLoading && !state.error);

export const columnChartData = state => {
  const {
    data: { datasets, labels },
  } = state;
  const { data: series, label: seriesName } = datasets[0];

  return { [seriesName]: series.map((value, index) => [labels[index], value]) };
};

export const seriesInfo = state => [
  {
    type: SERIES_LABEL_STYLE,
    name: state?.data?.datasets[0]?.label,
    color: SERIES_LABEL_COLORS[0],
  },
];
