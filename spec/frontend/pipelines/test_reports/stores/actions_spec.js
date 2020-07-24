import MockAdapter from 'axios-mock-adapter';
import { getJSONFixture } from 'helpers/fixtures';
import axios from '~/lib/utils/axios_utils';
import * as actions from '~/pipelines/stores/test_reports/actions';
import * as types from '~/pipelines/stores/test_reports/mutation_types';
import { TEST_HOST } from '../../../helpers/test_constants';
import testAction from '../../../helpers/vuex_action_helper';
import createFlash from '~/flash';

jest.mock('~/flash.js');

describe('Actions TestReports Store', () => {
  let mock;
  let state;

  const testReports = getJSONFixture('pipelines/test_report.json');
  const summary = { total_count: 1 };

  const fullReportEndpoint = `${TEST_HOST}/test_reports.json`;
  const suiteEndpoint = `${TEST_HOST}/tests/:suite_name.json`;
  const summaryEndpoint = `${TEST_HOST}/test_reports/summary.json`;
  const defaultState = {
    fullReportEndpoint,
    suiteEndpoint,
    summaryEndpoint,
    testReports: {},
    selectedSuite: null,
    useBuildSummaryReport: false,
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
    state = { ...defaultState };
  });

  afterEach(() => {
    mock.restore();
  });

  describe('fetch report summary', () => {
    beforeEach(() => {
      mock.onGet(summaryEndpoint).replyOnce(200, summary, {});
    });

    describe('when useBuildSummaryReport in state is true', () => {
      it('sets testReports and shows tests', done => {
        testAction(
          actions.fetchSummary,
          null,
          { ...state, useBuildSummaryReport: true },
          [{ type: types.SET_SUMMARY, payload: summary }],
          [{ type: 'toggleLoading' }, { type: 'toggleLoading' }],
          done,
        );
      });

      it('should create flash on API error', done => {
        testAction(
          actions.fetchSummary,
          null,
          {
            summaryEndpoint: null,
            useBuildSummaryReport: true,
          },
          [],
          [{ type: 'toggleLoading' }, { type: 'toggleLoading' }],
          () => {
            expect(createFlash).toHaveBeenCalled();
            done();
          },
        );
      });
    });

    describe('when useBuildSummaryReport in state is false', () => {
      it('sets testReports and shows tests', done => {
        testAction(
          actions.fetchSummary,
          null,
          state,
          [{ type: types.SET_SUMMARY, payload: summary }],
          [],
          done,
        );
      });

      it('should create flash on API error', done => {
        testAction(
          actions.fetchSummary,
          null,
          {
            summaryEndpoint: null,
          },
          [],
          [],
          () => {
            expect(createFlash).toHaveBeenCalled();
            done();
          },
        );
      });
    });
  });

  describe('fetch test suite', () => {
    beforeEach(() => {
      const buildIds = [1];
      testReports.test_suites[0].build_ids = buildIds;
      const endpoint = suiteEndpoint.replace(':suite_name', testReports.test_suites[0].name);
      mock
        .onGet(endpoint, { params: { build_ids: buildIds } })
        .replyOnce(200, testReports.test_suites[0], {});
    });

    it('sets test suite and shows tests', done => {
      const suite = testReports.test_suites[0];
      const index = 0;

      testAction(
        actions.fetchTestSuite,
        index,
        { ...state, testReports },
        [{ type: types.SET_SUITE, payload: { suite, index } }],
        [{ type: 'toggleLoading' }, { type: 'toggleLoading' }],
        done,
      );
    });

    it('should create flash on API error', done => {
      const index = 0;

      testAction(
        actions.fetchTestSuite,
        index,
        { ...state, testReports, suiteEndpoint: null },
        [],
        [{ type: 'toggleLoading' }, { type: 'toggleLoading' }],
        () => {
          expect(createFlash).toHaveBeenCalled();
          done();
        },
      );
    });

    describe('when we already have the suite data', () => {
      it('should not fetch suite', done => {
        const index = 0;
        testReports.test_suites[0].hasFullSuite = true;

        testAction(actions.fetchTestSuite, index, { ...state, testReports }, [], [], done);
      });
    });

    describe('when we already have the full report data', () => {
      it('should not fetch suite', done => {
        const index = 0;
        testReports.hasFullReport = true;

        testAction(actions.fetchTestSuite, index, { ...state, testReports }, [], [], done);
      });
    });
  });

  describe('fetch full report', () => {
    beforeEach(() => {
      mock.onGet(fullReportEndpoint).replyOnce(200, testReports, {});
    });

    it('sets testReports and shows tests', done => {
      testAction(
        actions.fetchFullReport,
        null,
        state,
        [{ type: types.SET_REPORTS, payload: testReports }],
        [{ type: 'toggleLoading' }, { type: 'toggleLoading' }],
        done,
      );
    });

    it('should create flash on API error', done => {
      testAction(
        actions.fetchFullReport,
        null,
        {
          fullReportEndpoint: null,
        },
        [],
        [{ type: 'toggleLoading' }, { type: 'toggleLoading' }],
        () => {
          expect(createFlash).toHaveBeenCalled();
          done();
        },
      );
    });
  });

  describe('set selected suite index', () => {
    it('sets selectedSuiteIndex', done => {
      const selectedSuiteIndex = 0;

      testAction(
        actions.setSelectedSuiteIndex,
        selectedSuiteIndex,
        { ...state, hasFullReport: true },
        [{ type: types.SET_SELECTED_SUITE_INDEX, payload: selectedSuiteIndex }],
        [],
        done,
      );
    });
  });

  describe('remove selected suite index', () => {
    it('sets selectedSuiteIndex to null', done => {
      testAction(
        actions.removeSelectedSuiteIndex,
        {},
        state,
        [{ type: types.SET_SELECTED_SUITE_INDEX, payload: null }],
        [],
        done,
      );
    });
  });

  describe('toggles loading', () => {
    it('sets isLoading to true', done => {
      testAction(actions.toggleLoading, {}, state, [{ type: types.TOGGLE_LOADING }], [], done);
    });

    it('toggles isLoading to false', done => {
      testAction(
        actions.toggleLoading,
        {},
        { ...state, isLoading: true },
        [{ type: types.TOGGLE_LOADING }],
        [],
        done,
      );
    });
  });
});
