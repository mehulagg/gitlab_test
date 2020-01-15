import _ from 'underscore';

export const getAlertsForWidget = state => metricIds =>
  _.pick(state.availableAlertsFromQueries, alert => metricIds.includes(alert.metricId));

export default getAlertsForWidget;
