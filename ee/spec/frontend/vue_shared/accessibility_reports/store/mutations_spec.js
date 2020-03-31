import mutations from 'ee/vue_shared/accessibility_reports/store/mutations';
import createStore from 'ee/vue_shared/accessibility_reports/store';

describe('Accessibility Reports mutations', () => {
  let localState;
  let localStore;

  beforeEach(() => {
    localStore = createStore();
    localState = localStore.state;
  });

  describe('SET_ENDPOINT', () => {
    it('sets the given endpoint', () => {
      const endpoint = "/test-endpoint";
      mutations.SET_ENDPOINT(localState, endpoint);

      expect(localState.endpoint).toEqual(endpoint);
    })
  });

  describe('REQUEST_REPORT', () => {
    it('sets isLoading to true', () => {
      mutations.REQUEST_REPORT(localState);

      expect(localState.isLoading).toEqual(true);
    });
  });

  describe('RECEIVE_REPORT_SUCCESS', () => {
    it('sets isLoading to false', () => {
      mutations.RECEIVE_REPORT_SUCCESS(localState, {});

      expect(localState.isLoading).toEqual(false);
    });

    it('sets hasError to false', () => {
      mutations.RECEIVE_REPORT_SUCCESS(localState, {});

      expect(localState.hasError).toEqual(false);
    });

    it('sets report to response report', () => {
      const response = { report: "testing" };
      mutations.RECEIVE_REPORT_SUCCESS(localState, response);

      expect(localState.report).toEqual(response.report);
    });
  });

  describe('RECEIVE_REPORT_ERROR', () => {
    it('sets isLoading to false', () => {
      mutations.RECEIVE_REPORT_ERROR(localState);

      expect(localState.isLoading).toEqual(false);
    });

    it('sets hasError to true', () => {
      mutations.RECEIVE_REPORT_ERROR(localState);

      expect(localState.hasError).toEqual(true);
    });
  });
})