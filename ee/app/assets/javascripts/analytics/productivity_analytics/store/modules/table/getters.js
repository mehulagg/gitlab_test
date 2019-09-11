import { chartKeys, tableSortOrder } from './../../../constants';

export const sortIcon = state => tableSortOrder[state.sortOrder].icon;

export const sortTooltipTitle = state => tableSortOrder[state.sortOrder].title;

export const sortFieldDropdownLabel = (state, _, rootState) =>
  rootState.metricTypes.find(metric => metric.key === state.sortField).label;

/**
 * Returns an array of metrics which can be selected by the user to be displayed in the last column of the MR table.
 * It takes the available metricTypes for the MR table filters out the 'time_to_merge' metric
 * since this metric is already being displayed in a different column.
 */
export const getColumnOptions = (_state, _getters, _rootState, rootGetters) =>
  rootGetters
    .getMetricTypes(chartKeys.mergeRequestTable)
    .filter(metric => metric.key !== 'time_to_merge');

export const columnMetricLabel = (state, getters) =>
  getters.getColumnOptions.find(metric => metric.key === state.columnMetric).label;

export const isSelectedSortField = state => sortField => state.sortField === sortField;

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
