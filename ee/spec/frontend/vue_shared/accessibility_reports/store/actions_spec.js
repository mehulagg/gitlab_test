import axios from '~/lib/utils/axios_utils';
import MockAdapter from 'axios-mock-adapter';
import * as actions from 'ee/vue_shared/accessibility_reports/store/actions';
import * as types from 'ee/vue_shared/accessibility_reports/store/mutation_types';
import createStore from 'ee/vue_shared/accessibility_reports/store';
import { TEST_HOST } from 'spec/test_constants';
import testAction from 'helpers/vuex_action_helper';

describe('Accessibility Reports actions', () => {
  let localState;
  let localStore;

  beforeEach(() => {
    localStore = createStore();
    localState = localStore.state;
  });

  describe('setEndpoint', () => {
    it('should commit SET_ENDPOINT mutation', done => {
      testAction(
        actions.setEndpoint,
        'endpoint.json',
        localState,
        [{ type: types.SET_ENDPOINT, payload: 'endpoint.json' }],
        [],
        done,
      );
    });
  });

  describe('requestReport', () => {
    it('should commit REQUEST_REPORT mutation', done => {
      testAction(
        actions.requestReport,
        null,
        localState,
        [{ type: types.REQUEST_REPORT }],
        [],
        done,
      );
    });
  });

  describe('fetchReport', () => {
    let mock;

    beforeEach(() => {
      localState.endpoint = `${TEST_HOST}/endpoint.json`;
      mock = new MockAdapter(axios);
    });

    afterEach(() => {
      mock.restore();
      actions.stopPolling();
      actions.clearEtagPoll();
    });

    describe('success', () => {
      it('dispatches requestReport and receiveReportSuccess', done => {
        mock.onGet(`${TEST_HOST}/endpoint.json`).replyOnce(200, { report: { summary: {} } });

        testAction(
          actions.fetchReport,
          null,
          localState,
          [],
          [
            {
              type: 'requestReport',
            },
            {
              payload: { data: { report: { summary: {} } }, status: 200 },
              type: 'receiveReportSuccess',
            },
          ],
          done,
        );
      });
    });

    describe('error', () => {
      it('dispatches requestReport and receiveReportError', done => {
        mock.onGet(`${TEST_HOST}/endpoint.json`).reply(500);

        testAction(
          actions.fetchReport,
          null,
          localState,
          [],
          [
            {
              type: 'requestReport',
            },
            {
              type: 'receiveReportError',
            },
          ],
          done,
        );
      });
    });
  });

  describe('receiveReportSuccess', () => {
    it('should commit RECEIVE_REPORT_SUCCESS mutation with 200', done => {
      testAction(
        actions.receiveReportSuccess,
        { data: { report: { summary: {} } }, status: 200 },
        localState,
        [{ type: types.RECEIVE_REPORT_SUCCESS, payload: { report: { summary: {} } } }],
        [],
        done,
      );
    });

    it('should commit RECEIVE_REPORT_SUCCESS mutation with 204', done => {
      testAction(
        actions.receiveReportSuccess,
        { data: { report: { report: { summary: {} } } }, status: 204 },
        localState,
        [],
        [],
        done,
      );
    });
  });

  describe('receiveReportError', () => {
    it('should commit RECEIVE_REPORTS_ERROR mutation', done => {
      testAction(
        actions.receiveReportError,
        null,
        localState,
        [{ type: types.RECEIVE_REPORT_ERROR }],
        [],
        done,
      );
    });
  });
});
