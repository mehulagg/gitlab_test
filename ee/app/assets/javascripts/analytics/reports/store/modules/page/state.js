import { s__ } from '~/locale';

export default () => ({
  isLoading: false,

  configEndpoint: '',
  seriesEndpoint: '',
  reportId: null,

  groupName: null,
  groupPath: null,

  config: {
    title: s__('GenericReports|Report'),
    chart: {
      series: [
        {
          id: null,
          title: null,
        },
      ],
      type: null,
    },
    id: null,
  },
});
