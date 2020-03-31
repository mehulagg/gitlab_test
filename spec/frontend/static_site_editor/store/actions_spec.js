import testAction from 'helpers/vuex_action_helper';
import createState from '~/static_site_editor/store/state';
import * as actions from '~/static_site_editor/store/actions';
import * as mutationTypes from '~/static_site_editor/store/mutation_types';
import loadSourceContent from '~/static_site_editor/services/load_source_content';

import createFlash from '~/flash';

import {
  projectId,
  sourcePath,
  sourceContentTitle as title,
  sourceContent as content,
} from '../mock_data';

jest.mock('~/flash');
jest.mock('~/static_site_editor/services/load_source_content', () => jest.fn());

describe('Static Site Editor Store actions', () => {
  let state;

  beforeEach(() => {
    state = createState({
      projectId,
      sourcePath,
    });
  });

  describe('loadContent', () => {
    const expectedMutations = [{ type: mutationTypes.LOAD_CONTENT }];
    const payload = { title, content };

    describe('on success', () => {
      beforeEach(() => {
        loadSourceContent.mockResolvedValueOnce(payload);
      });

      it('dispatches receiveContentSuccess', () => {
        testAction(actions.loadContent, null, state, expectedMutations, [
          { type: 'receiveContentSuccess', payload },
        ]);

        expect(loadSourceContent).toHaveBeenCalledWith({ projectId, sourcePath });
      });
    });

    describe('on error', () => {
      const expectedActions = [
        {
          type: 'receiveContentError',
        },
      ];

      beforeEach(() => {
        loadSourceContent.mockRejectedValueOnce();
      });

      it('dispatches receiveContentError', () => {
        testAction(actions.loadContent, null, state, expectedMutations, expectedActions);
      });

      it('displays flash communicating error', () => {
        return testAction(
          actions.loadContent,
          null,
          state,
          expectedMutations,
          expectedActions,
        ).then(() => {
          expect(createFlash).toHaveBeenCalledWith(
            'An error ocurred while loading your content. Please try again.',
          );
        });
      });
    });
  });

  it.each`
    action                     | mutation                                 | payload
    ${'receiveContentSuccess'} | ${mutationTypes.RECEIVE_CONTENT_SUCCESS} | ${null}
    ${'receiveContentError'}   | ${mutationTypes.RECEIVE_CONTENT_ERROR}   | ${undefined}
  `('$action commits $mutation mutation', ({ action, mutation, payload }) => {
    testAction(actions[action], payload, state, [{ type: mutation, payload }]);
  });
});
