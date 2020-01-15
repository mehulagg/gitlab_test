import _ from 'underscore';

export const getAlertsForWidget = state => metricIds =>
  _.pick(state.availableAlertsFromQueries, alert => metricIds.includes(alert.metricId));

export const getVisibleAlerts = state => state.alertsVuex.filter(alert => alert.visible);

export default getAlertsForWidget;
