import { SERIES_LABEL_STYLE, SERIES_LABEL_COLORS } from 'ee/analytics/reports/constants';

export const initialState = {
  configEndpoint: '',
  seriesEndpoint: '',
  reportId: null,
  groupName: null,
  groupPath: null,
  config: {
    title: 'Report',
  },
};

export const pageData = {
  configEndpoint: 'foo_bar_endpoint',
  seriesEndpoint: 'bar_foo_endpoint',
  reportId: 'foo_bar_id',
  groupName: 'Foo Bar',
  groupPath: 'foo_bar',
};

export const configData = {
  title: 'Foo Bar Report',
  chart: {
    series: [
      {
        id: 'series_one_id',
        title: 'Series 1',
      },
    ],
    type: 'bar',
  },
  id: 'chart_id',
};

export const seriesData = {
  datasets: [
    {
      data: [1, 2, 3],
      label: 'Series 1',
    },
  ],
  labels: ['label1', 'label2', 'label3'],
};

export const formattedColumnChartData = {
  'Series 1': [['label1', 1], ['label2', 2], ['label3', 3]],
};

export const seriesInfo = [
  {
    type: SERIES_LABEL_STYLE,
    name: 'Series 1',
    color: SERIES_LABEL_COLORS[0],
  },
];
