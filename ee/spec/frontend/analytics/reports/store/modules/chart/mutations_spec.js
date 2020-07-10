import * as types from 'ee/analytics/reports/store/modules/chart/mutation_types';
import mutations from 'ee/analytics/reports/store/modules/chart/mutations';
import { initialState, seriesData } from 'ee_jest/analytics/reports/mock_data';

describe('Reports chart mutations', () => {
  let state;

  beforeEach(() => {
    state = initialState;
  });

  afterEach(() => {
    state = null;
  });

  it.each`
    mutation                                 | expectedState
    ${types.REQUEST_CHART_SERIES_DATA}       | ${{ isLoading: true, error: false }}
    ${types.RECEIVE_CHART_SERIES_DATA_ERROR} | ${{ isLoading: false, error: true }}
  `('$mutation will set $stateKey=$value', ({ mutation, expectedState }) => {
    mutations[mutation](state);

    expect(state).toMatchObject(expectedState);
  });

  it.each`
    mutation                                   | payload       | expectedState
    ${types.RECEIVE_CHART_SERIES_DATA_SUCCESS} | ${seriesData} | ${{ isLoading: false, error: false, data: seriesData }}
  `(
    '$mutation with payload $payload will update state with $expectedState',
    ({ mutation, payload, expectedState }) => {
      mutations[mutation](state, payload);

      expect(state).toMatchObject(expectedState);
    },
  );
});
