import createState from '~/monitoring/stores/state';
import * as types from '~/monitoring/stores/mutation_types';
import mutations from '~/monitoring/stores/mutations/alerts';
import { OPERATORS } from '~/monitoring/constants';

describe('Monitoring alerts mutations', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe(`${types.ADD_ALERT_QUEUE_CREATE}`, () => {
    it('pushes an alert to the alerts array', () => {
      mutations[types.ADD_ALERT_QUEUE_CREATE](state);

      const [curAlert] = state.alertsVuex;

      expect(state.alertsVuex.length).toBe(2);
      expect(curAlert.operator).toBe(OPERATORS.greaterThan);
      expect(curAlert.threshold).toBe(null);
      expect(curAlert.prometheusMetricId).toBe(null);
      expect(curAlert.alert).toStrictEqual({});
    });
  });

  describe(`${types.UPDATE_FORM_ALERT}`, () => {
    it('updates an alert from the array', () => {
      mutations[types.UPDATE_FORM_ALERT](state, {
        index: 0,
        operator: OPERATORS.equalTo,
        threshold: 10,
        prometheusMetricId: '1_response_metrics_nginx_ingress_throughput_status_code',
      });

      const [curAlert] = state.alertsVuex;

      expect(curAlert.operator).toBe(OPERATORS.equalTo);
      expect(curAlert.threshold).toBe(10);
      expect(curAlert.prometheusMetricId).toBe(
        '1_response_metrics_nginx_ingress_throughput_status_code',
      );
    });
  });

  describe(`${types.RESET_ALERT_FORM}`, () => {
    it('resets the alert array', () => {
      mutations[types.RESET_ALERT_FORM](state);

      const [curAlert] = state.alertsVuex;

      expect(state.alertsVuex.length).toBe(1);
      expect(curAlert.operator).toBe(OPERATORS.greaterThan);
      expect(curAlert.threshold).toBe(null);
      expect(curAlert.prometheusMetricId).toBe(null);
      expect(curAlert.alert).toStrictEqual({});
    });
  });

  describe(`${types.ADD_ALERT_TO_DELETE}`, () => {
    it('adds an alert to the alersToDelete array', () => {
      mutations[types.ADD_ALERT_TO_DELETE](state, 0);

      expect(state.alertsVuex.length).toBe(0);
      expect(state.alertsToDelete.length).toBe(1);
    });
  });
});
