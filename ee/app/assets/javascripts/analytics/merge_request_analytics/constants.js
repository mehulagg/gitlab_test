import { __ } from '~/locale';

export const DEFAULT_NUMBER_OF_DAYS = 365;
export const MAX_RECORDS = 100;
export const ASSIGNEES_VISIBLE = 2;
export const AVATAR_SIZE = 24;

export const THROUGHPUT_CHART_STRINGS = {
  CHART_TITLE: __('Throughput'),
  Y_AXIS_TITLE: __('Merge Requests merged'),
  X_AXIS_TITLE: __('Month'),
  CHART_DESCRIPTION: __('The number of merge requests merged by month.'),
  NO_DATA: __('There is no chart data available.'),
  ERROR_FETCHING_DATA: __(
    'There was an error while fetching the chart data. Please refresh the page to try again.',
  ),
};

export const THROUGHPUT_TABLE_STRINGS = {
  NO_DATA: __('There is no table data available.'),
  ERROR_FETCHING_DATA: __(
    'There was an error while fetching the table data. Please refresh the page to try again.',
  ),
};

export const MERGE_REQUEST_ID_PREFIX = '!';

export const LINE_CHANGE_SYMBOLS = {
  ADDITIONS: '+',
  DELETITIONS: '-',
};

export const THROUGHPUT_TABLE_TEST_IDS = {
  TABLE_HEADERS: 'header',
  MERGE_REQUEST_DETAILS: 'detailsCol',
  LABEL_DETAILS: 'labelDetails',
  DATE_MERGED: 'dateMergedCol',
  TIME_TO_MERGE: 'timeToMergeCol',
  MILESTONE: 'milestoneCol',
  PIPELINES: 'pipelinesCol',
  LINE_CHANGES: 'lineChangesCol',
  ASSIGNEES: 'assigneesCol',
  COMMITS: 'commitsCol',
  COMMENT_COUNT: 'commentCount',
};

export const PIPELINE_STATUS_ICON_CLASSES = {
  status_success: 'gl-text-green-500',
  status_failed: 'gl-text-red-500',
  status_pending: 'gl-text-orange-500',
  default: 'gl-text-grey-500',
};
