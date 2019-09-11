export const getMetricTypes = state => component =>
  state.metricTypes.filter(m => m.components.indexOf(component) !== -1);

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
