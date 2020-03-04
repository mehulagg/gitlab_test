import createState from 'ee/threat_monitoring/store/modules/threat_monitoring/state';
import * as getters from 'ee/threat_monitoring/store/modules/threat_monitoring/getters';
import { INVALID_CURRENT_ENVIRONMENT_NAME } from 'ee/threat_monitoring/constants';

describe('threatMonitoring module getters', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('currentEnvironmentName', () => {
    describe.each`
      context                            | currentEnvironmentId | environments                | expectedName
      ${'no environments'}               | ${1}                 | ${[]}                       | ${INVALID_CURRENT_ENVIRONMENT_NAME}
      ${'a non-existent environment id'} | ${2}                 | ${[{ id: 1 }]}              | ${INVALID_CURRENT_ENVIRONMENT_NAME}
      ${'an existing environment id'}    | ${3}                 | ${[{ id: 3, name: 'foo' }]} | ${'foo'}
    `('given $context', ({ currentEnvironmentId, environments, expectedName }) => {
      beforeEach(() => {
        state.currentEnvironmentId = currentEnvironmentId;
        state.environments = environments;
      });

      it('returns the expected name', () => {
        expect(getters.currentEnvironmentName(state)).toBe(expectedName);
      });
    });
  });

  describe('hasHistory', () => {
    it.each(['nominal', 'anomalous'])('returns true if there is any %s history data', type => {
      state.wafStatistics.history[type] = ['foo'];
      expect(getters.hasHistory(state)).toBe(true);
    });

    it('returns false if there is no history', () => {
      state.wafStatistics.history.nominal = [];
      state.wafStatistics.history.anomalous = [];
      expect(getters.hasHistory(state)).toBe(false);
    });
  });
});
