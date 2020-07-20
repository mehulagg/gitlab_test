// TODO: Move into file shared with similar method in stores/getters.js
const metricsIdsInPanel = panel =>
  panel.metrics.filter(metric => metric.metricId && metric.result).map(metric => metric.metricId);

// TODO: Remove this?
export const metricsWithData = (state, getters, rootState, rootGetters) =>
  state.modules.map(module => rootGetters[`${module}/metricsWithData`]().length);

export const panelsWithData = (state, getters, rootState) => {
  const res = [];

  state.modules.forEach(module => {
    const groups = rootState[module].dashboard.panelGroups;

    groups.forEach(group => {
      group.panels.forEach(panel => {
        const results = metricsIdsInPanel(panel);
        if (results.length) {
          res.push(1);
        }
      });
    });
  });

  return res;
};

export default () => {};
