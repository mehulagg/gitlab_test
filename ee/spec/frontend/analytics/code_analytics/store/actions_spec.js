import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import testAction from 'helpers/vuex_action_helper';
import httpStatus from '~/lib/utils/http_status';
import createFlash from '~/flash';
import * as actions from 'ee/analytics/code_analytics/store/actions';
import * as types from 'ee/analytics/code_analytics/store/mutation_types';
import { group, project, endpoint, codeHotspotsResponseData } from '../mock_data';

const error = new Error('Request failed with status code 404');
const flashErrorMessage = 'There was an error while fetching code analytics data.';

describe('Code analytics actions', () => {
  let state;
  let mock;

  beforeEach(() => {
    state = { endpoint };
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
  });

  it.each`
    action                       | type                                | stateKey                  | payload
    ${'setSelectedGroup'}        | ${types.SET_SELECTED_GROUP}         | ${'selectedGroup'}        | ${group.name}
    ${'setSelectedProject'}      | ${types.SET_SELECTED_PROJECT}       | ${'selectedProject'}      | ${project}
    ${'setSelectedFileQuantity'} | ${types.SET_SELECTED_FILE_QUANTITY} | ${'selectedFileQuantity'} | ${250}
    ${'setEndpoint'}             | ${types.SET_ENDPOINT}               | ${'endpoint'}             | ${endpoint}
  `('$action should set $stateKey with $payload and type $type', ({ action, type, payload }) => {
    testAction(
      actions[action],
      payload,
      state,
      [
        {
          type,
          payload,
        },
      ],
      [],
    );
  });

  it.each`
    action                       | type
    ${'requestCodeHotspotsData'} | ${types.REQUEST_CODE_HOTSPOTS_DATA}
  `('$action should commit mutation with $type', ({ action, type }) => {
    testAction(
      actions[action],
      state,
      null,
      [
        {
          type,
        },
      ],
      [],
    );
  });

  describe('receiveCodeHotspotsDataSuccess', () => {
    beforeEach(() => {
      setFixtures('<div class="flash-container"></div>');
    });

    it(`commits ${types.RECEIVE_CODE_HOTSPOTS_DATA_SUCCESS} mutation with the response data`, () => {
      testAction(
        actions.receiveCodeHotspotsDataSuccess,
        codeHotspotsResponseData,
        state,
        [
          {
            type: types.RECEIVE_CODE_HOTSPOTS_DATA_SUCCESS,
            payload: codeHotspotsResponseData,
          },
        ],
        [],
      );
    });

    it('removes an existing flash error if present', () => {
      const commit = jest.fn();
      const dispatch = jest.fn();

      createFlash(flashErrorMessage);

      const flashAlert = document.querySelector('.flash-alert');

      expect(flashAlert).toBeVisible();

      actions.receiveCodeHotspotsDataSuccess({ commit, dispatch, state });

      expect(flashAlert.style.opacity).toBe('0');
    });
  });

  describe('receiveCodeHotspotsDataError', () => {
    beforeEach(() => {
      setFixtures('<div class="flash-container"></div>');
    });

    it(`commits ${types.RECEIVE_CODE_HOTSPOTS_DATA_ERROR} mutation with the response data`, () => {
      testAction(
        actions.receiveCodeHotspotsDataError,
        { response: { status: httpStatus.FORBIDDEN } },
        state,
        [
          {
            type: types.RECEIVE_CODE_HOTSPOTS_DATA_ERROR,
            payload: httpStatus.FORBIDDEN,
          },
        ],
        [],
      );
    });

    it(`flashes an error when the errorCode is not ${httpStatus.FORBIDDEN}`, () => {
      testAction(
        actions.receiveCodeHotspotsDataError,
        { response: { status: httpStatus.NOT_FOUND } },
        state,
        [
          {
            type: types.RECEIVE_CODE_HOTSPOTS_DATA_ERROR,
            payload: httpStatus.NOT_FOUND,
          },
        ],
        [],
      );

      expect(document.querySelector('.flash-container .flash-text').innerText.trim()).toBe(
        flashErrorMessage,
      );
    });
  });

  describe('fetchCodeHotspotsData', () => {
    beforeEach(() => {
      mock.onGet(state.endpoint).replyOnce(200, { codeHotspotsResponseData });
    });

    describe('with no error', () => {
      it('dispatches receiveCodeHotspotsDataSuccess with received data', () => {
        const stateWithFilters = {
          ...state,
          selectedGroup: group,
          selectedProject: project,
        };

        testAction(
          actions.fetchCodeHotspotsData,
          null,
          stateWithFilters,
          [],
          [
            { type: 'requestCodeHotspotsData' },
            {
              type: 'receiveCodeHotspotsDataSuccess',
              payload: { codeHotspotsResponseData },
            },
          ],
        );
      });
    });

    describe('with error', () => {
      it('dispatches receiveCodeHotspotsDataError', () => {
        const stateWithFilters = {
          endpoint: 'this will break',
          selectedGroup: group,
          selectedProject: project,
        };

        testAction(
          actions.fetchCodeHotspotsData,
          null,
          stateWithFilters,
          [],
          [
            { type: 'requestCodeHotspotsData' },
            {
              type: 'receiveCodeHotspotsDataError',
              payload: error,
            },
          ],
        );
      });
    });
  });
});
