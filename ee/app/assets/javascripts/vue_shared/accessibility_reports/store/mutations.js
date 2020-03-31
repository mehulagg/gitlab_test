import * as types from './mutation_types';

/*
TODO
- make sure response matches what the actual backend response will be
*/

const mockData = {
  status: 'success',
  summary: {
    total: 0,
    errors: 0,
    notes: 0,
    warnings: 1,
  },
  new_warnings: [],
  resolved_warnings: [],
  existing_warnings: [
    {
      name:
        'The accessiblity scanning found 2 errors of the following type: WCAG2AA.Principle4.Guideline4_1.4_1_2.H91.A.NoContent',
      code: 'WCAG2AA.Principle4.Guideline4_1.4_1_2.H91.A.NoContent',
      message:
        'Anchor element found with a valid href attribute, but no link content has been supplied.',
      status: 'failed',
      classname: 'spec.test_spec',
    },
  ],
  new_errors: [],
  resolved_errors: [],
  existing_errors: [],
  new_notes: [],
  resolved_notes: [],
  existing_notes: [],
};

export default {
  [types.SET_ENDPOINT](state, endpoint) {
    state.endpoint = endpoint;
  },
  [types.REQUEST_REPORT](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_REPORT_SUCCESS](state, response) {
    state.hasError = false;
    state.isLoading = false;
    state.report = response.report || mockData;
  },
  [types.RECEIVE_REPORT_ERROR](state) {
    state.isLoading = false;
    state.hasError = true;
    state.report = {};
  },
};
