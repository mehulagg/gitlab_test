import mutations from 'ee/analytics/code_analytics/store/mutations';
import * as types from 'ee/analytics/code_analytics/store/mutation_types';
import {
  group,
  project,
  endpoint,
  codeHotspotsResponseData,
  codeHotspotsTransformedData,
} from '../mock_data';
import httpStatus from '~/lib/utils/http_status';

describe('Code analytics mutations', () => {
  let state;

  beforeEach(() => {
    state = {};
  });

  afterEach(() => {
    state = {};
  });

  it.each`
    mutation                            | payload       | expectedState
    ${types.SET_SELECTED_GROUP}         | ${group.name} | ${{ selectedGroup: group.name, selectedProject: null }}
    ${types.SET_SELECTED_FILE_QUANTITY} | ${250}        | ${{ selectedFileQuantity: 250 }}
    ${types.SET_ENDPOINT}               | ${endpoint}   | ${{ endpoint }}
  `(
    '$mutation with payload $payload will update state with $expectedState',
    ({ mutation, payload, expectedState }) => {
      mutations[mutation](state, payload);

      expect(state).toMatchObject(expectedState);
    },
  );

  it.each`
    mutation                                  | payload                 | expectedState
    ${types.REQUEST_CODE_HOTSPOTS_DATA}       | ${null}                 | ${{ isLoading: true }}
    ${types.RECEIVE_CODE_HOTSPOTS_DATA_ERROR} | ${httpStatus.FORBIDDEN} | ${{ isLoading: false, codeHotspotsData: [], errorCode: httpStatus.FORBIDDEN }}
  `(
    '$mutation with payload $payload will update state with $expectedState',
    ({ mutation, payload, expectedState }) => {
      mutations[mutation](state, payload);

      expect(state).toMatchObject(expectedState);
    },
  );

  describe(`${types.SET_SELECTED_PROJECT}`, () => {
    beforeEach(() => {
      state = {
        codeHotspotsData: codeHotspotsTransformedData,
      };
    });

    describe('with a project', () => {
      it('sets the selectedProject value', () => {
        mutations[types.SET_SELECTED_PROJECT](state, project);

        expect(state.selectedProject).toEqual(project);
      });

      it('does not alter codeHotspotsData', () => {
        mutations[types.SET_SELECTED_PROJECT](state, project);

        expect(state.codeHotspotsData).toEqual(codeHotspotsTransformedData);
      });
    });

    describe('with no project', () => {
      it('sets the selectedProject value to null', () => {
        mutations[types.SET_SELECTED_PROJECT](state, null);

        expect(state.selectedProject).toEqual(null);
      });

      it('clears codeHotspotsData', () => {
        mutations[types.SET_SELECTED_PROJECT](state, null);

        expect(state.codeHotspotsData).toEqual([]);
      });
    });
  });

  describe(`${types.RECEIVE_CODE_HOTSPOTS_DATA_SUCCESS}`, () => {
    it('will transform and set the code hotspots data', () => {
      const stateWithFilters = {
        selectedGroup: group,
        selectedProject: project,
      };

      mutations[types.RECEIVE_CODE_HOTSPOTS_DATA_SUCCESS](
        stateWithFilters,
        codeHotspotsResponseData,
      );

      expect(stateWithFilters.codeHotspotsData).toEqual(codeHotspotsTransformedData);
      expect(stateWithFilters.isLoading).toBeFalsy();
    });
  });
});
