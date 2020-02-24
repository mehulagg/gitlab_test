import MockAdapter from 'axios-mock-adapter';
import testAction from 'helpers/vuex_action_helper';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import * as actions from 'ee/status_page_settings/store/actions';
import * as types from 'ee/status_page_settings/store/mutation_types';
import { refreshCurrentPage } from '~/lib/utils/url_utility';

jest.mock('~/flash.js');
jest.mock('~/lib/utils/url_utility');

let mock;

describe('Status Page actions', () => {
  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
    createFlash.mockClear();
  });

  const state = {
    enabled: true,
    bucketName: 'test-bucket',
    region: 'us-west',
  };

  it.each`
    mutation                         | action                            | value
    ${types.SET_STATUS_PAGE_ENABLED} | ${'setStatusPageEnabled'}         | ${true}
    ${types.SET_BUCKET_NAME}         | ${'setStatusPageBucketName'}      | ${'my-bucket'}
    ${types.SET_REGION}              | ${'setStatusPageRegion'}          | ${'us-west'}
    ${types.SET_ACCESS_KEY_ID}       | ${'setStatusPageAccessKey'}       | ${'key-id'}
    ${types.SET_SECRET_ACCESS_KEY}   | ${'setStatusPageSecretAccessKey'} | ${'secret'}
  `('$action will commit $mutation with $value', ({ mutation, action, value }) => {
    testAction(
      actions[action],
      value,
      null,
      [
        {
          type: mutation,
          payload: value,
        },
      ],
      [],
    );
  });

  describe('updateStatusPageSettings', () => {
    it('should handle successful status update', () => {
      mock.onPatch().reply(200, {});
      testAction(
        actions.updateStatusPageSettings,
        null,
        state,
        [
          {
            payload: true,
            type: types.SETTINGS_LOADING,
          },
          {
            payload: false,
            type: types.SETTINGS_LOADING,
          },
        ],
        [{ type: 'receiveStatusPageSettingsUpdateSuccess' }],
      );
    });

    it('should handle unsuccessful status update', () => {
      mock.onPatch().reply(400, {});
      testAction(
        actions.updateStatusPageSettings,
        null,
        state,
        [
          {
            payload: true,
            type: types.SETTINGS_LOADING,
          },
          {
            payload: false,
            type: types.SETTINGS_LOADING,
          },
        ],
        [
          {
            payload: expect.any(Object),
            type: 'receiveStatusPageSettingsUpdateError',
          },
        ],
      );
    });
  });

  describe('receiveStatusPageSettingsUpdateSuccess', () => {
    it('should handle successful settings update', done => {
      testAction(actions.receiveStatusPageSettingsUpdateSuccess, null, null, [], [], () => {
        expect(refreshCurrentPage).toHaveBeenCalledTimes(1);
        done();
      });
    });
  });

  describe('receiveStatusPageSettingsUpdateError', () => {
    const error = { response: { data: { message: 'Update error' } } };
    it('should handle error update', done => {
      testAction(actions.receiveStatusPageSettingsUpdateError, error, null, [], [], () => {
        expect(createFlash).toHaveBeenCalledWith(
          `There was an error saving your changes. ${error.response.data.message}`,
          'alert',
        );
        done();
      });
    });
  });
});
