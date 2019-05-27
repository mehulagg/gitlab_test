import { REPORT_STATUS, SORT_FIELDS, SORT_ORDER } from './constants';

export default () => ({
  endpoint: '',
  dependenciesDownloadEndpoint: '',
  initialized: false,
  isLoading: false,
  errorLoading: false,
  dependencies: [],
  pageInfo: {},
  reportInfo: {
    status: REPORT_STATUS.ok,
    job_path: '',
  },
  sortField: 'name',
  sortFields: SORT_FIELDS,
  sortOrder: SORT_ORDER.ascending,
});
