import {
  requestReleases,
  fetchReleases,
  receiveReleasesSuccess,
  receiveReleasesError,
} from '~/releases/list/store/actions';
import state from '~/releases/list/store/state';
import * as types from '~/releases/list/store/mutation_types';
import api from '~/api';
import { historyPushState, buildUrlWithCurrentLocation } from '~/lib/utils/common_utils';
import testAction from 'spec/helpers/vuex_action_helper';
import { pageInfo, pageInfoHeaders, releases } from '../../mock_data';

describe('Releases State actions', () => {
  let mockedState;

  beforeEach(() => {
    mockedState = state();
  });

  describe('requestReleases', () => {
    it('should commit REQUEST_RELEASES mutation', done => {
      testAction(requestReleases, null, mockedState, [{ type: types.REQUEST_RELEASES }], [], done);
    });
  });

  describe('fetchReleases', () => {
    describe('success', () => {
      it('dispatches requestReleases and receiveReleasesSuccess', done => {
        spyOn(api, 'releases').and.callFake((id, options) => {
          expect(id).toEqual(1);
          expect(options.page).toEqual('1');
          return Promise.resolve({ data: releases, headers: pageInfoHeaders });
        });

        testAction(
          fetchReleases,
          1,
          mockedState,
          [],
          [
            {
              type: 'requestReleases',
            },
            {
              payload: { data: releases, headers: pageInfoHeaders },
              type: 'receiveReleasesSuccess',
            },
          ],
          done,
        );
      });

      it('dispatches requestReleases and receiveReleasesSuccess on page two', done => {
        spyOn(api, 'releases').and.callFake((_, options) => {
          expect(options.page).toEqual('2');
          historyPushState(buildUrlWithCurrentLocation(''));
          return Promise.resolve({ data: releases, headers: pageInfoHeaders });
        });

        historyPushState(buildUrlWithCurrentLocation(`?page=2`));

        testAction(
          fetchReleases,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestReleases',
            },
            {
              payload: { data: releases, headers: pageInfoHeaders },
              type: 'receiveReleasesSuccess',
            },
          ],
          done,
        );
      });
    });

    describe('error', () => {
      it('dispatches requestReleases and receiveReleasesError', done => {
        spyOn(api, 'releases').and.returnValue(Promise.reject());

        testAction(
          fetchReleases,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestReleases',
            },
            {
              type: 'receiveReleasesError',
            },
          ],
          done,
        );
      });
    });
  });

  describe('receiveReleasesSuccess', () => {
    it('should commit RECEIVE_RELEASES_SUCCESS mutation', done => {
      testAction(
        receiveReleasesSuccess,
        { data: releases, headers: pageInfoHeaders },
        mockedState,
        [{ type: types.RECEIVE_RELEASES_SUCCESS, payload: { pageInfo, data: releases } }],
        [],
        done,
      );
    });
  });

  describe('receiveReleasesError', () => {
    it('should commit RECEIVE_RELEASES_ERROR mutation', done => {
      testAction(
        receiveReleasesError,
        null,
        mockedState,
        [{ type: types.RECEIVE_RELEASES_ERROR }],
        [],
        done,
      );
    });
  });
});
