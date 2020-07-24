import Api from '~/api';
import MockAdapter from 'axios-mock-adapter';
import testAction from 'helpers/vuex_action_helper';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import getInitialState from '~/deploy_freeze/store/state';
import * as actions from '~/deploy_freeze/store/actions';
import * as types from '~/deploy_freeze/store/mutation_types';
import { mockTimezoneData, mockFreezePeriods } from '../mock_data';

jest.mock('~/api.js');
jest.mock('~/flash.js');

describe('deploy freeze store actions', () => {
  let mock;
  let state;

  beforeEach(() => {
    mock = new MockAdapter(axios);
    state = getInitialState({
      projectId: '8',
      timezoneData: mockTimezoneData,
    });
    Api.freezePeriods.mockResolvedValue({ data: mockFreezePeriods });
    Api.createFreezePeriod.mockResolvedValue();
  });

  afterEach(() => {
    mock.restore();
  });

  describe('setSelectedTimezone', () => {
    it('commits SET_SELECTED_TIMEZONE mutation', () => {
      testAction(actions.setSelectedTimezone, {}, {}, [
        {
          payload: {},
          type: types.SET_SELECTED_TIMEZONE,
        },
      ]);
    });
  });

  describe('setFreezeStartCron', () => {
    it('commits SET_FREEZE_START_CRON mutation', () => {
      testAction(actions.setFreezeStartCron, {}, {}, [
        {
          type: types.SET_FREEZE_START_CRON,
        },
      ]);
    });
  });

  describe('setFreezeEndCron', () => {
    it('commits SET_FREEZE_END_CRON mutation', () => {
      testAction(actions.setFreezeEndCron, {}, {}, [
        {
          type: types.SET_FREEZE_END_CRON,
        },
      ]);
    });
  });

  describe('addFreezePeriod', () => {
    it('dispatch correct actions on adding a freeze period', () => {
      testAction(
        actions.addFreezePeriod,
        {},
        state,
        [{ type: 'RESET_MODAL' }],
        [
          { type: 'requestAddFreezePeriod' },
          { type: 'receiveAddFreezePeriodSuccess' },
          { type: 'fetchFreezePeriods' },
        ],
      );
    });

    it('should show flash error and set error in state on add failure', () => {
      Api.createFreezePeriod.mockRejectedValue();

      testAction(
        actions.addFreezePeriod,
        {},
        state,
        [],
        [{ type: 'requestAddFreezePeriod' }, { type: 'receiveAddFreezePeriodError' }],
        () => expect(createFlash).toHaveBeenCalled(),
      );
    });
  });

  describe('fetchFreezePeriods', () => {
    it('dispatch correct actions on fetchFreezePeriods', () => {
      testAction(
        actions.fetchFreezePeriods,
        {},
        state,
        [],
        [
          { type: 'requestFreezePeriods' },
          { type: 'receiveFreezePeriodsSuccess', payload: mockFreezePeriods },
        ],
      );
    });

    it('should show flash error and set error in state on fetch variables failure', () => {
      Api.freezePeriods.mockRejectedValue();

      testAction(
        actions.fetchFreezePeriods,
        {},
        state,
        [],
        [{ type: 'requestFreezePeriods' }],
        () =>
          expect(createFlash).toHaveBeenCalledWith(
            'There was an error fetching the deploy freezes.',
          ),
      );
    });
  });
});
