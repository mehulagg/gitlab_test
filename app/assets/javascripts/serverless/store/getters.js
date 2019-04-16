import { translate } from '../utils';

export default {
  hasPrometheusMissingData: state => state.hasPrometheus && !state.hasPrometheusData,

  // Convert the function list into a k/v grouping based on the environment scope

  getFunctions: state => translate(state.functions),
};
