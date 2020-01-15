import createState from '~/monitoring/stores/state';
import * as types from '~/monitoring/stores/mutation_types';
import * as actions from '~/monitoring/stores/actions/alerts';
import testAction from 'helpers/vuex_action_helper';

describe('Monitoring store alert actions', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('addAlertToCreate', () => {
    it('commits a new alert to create', done => {
      testAction(
        actions.addAlertToCreate,
        null,
        state,
        [{ type: types.ADD_ALERT_QUEUE_CREATE }],
        [],
        done,
      ).catch(done.fail);
    });
  });

  describe('resetAlertForm', () => {
    it(`commits the ${types.RESET_ALERT_FORM} mutation`, done => {
      testAction(
        actions.resetAlertForm,
        null,
        state,
        [{ type: types.RESET_ALERT_FORM }],
        [],
        done,
      ).catch(done.fail);
    });
  });

  describe('addAlertToDelete', () => {
    it(`commits the ${types.ADD_ALERT_TO_DELETE} mutation`, done => {
      testAction(
        actions.addAlertToDelete,
        0,
        state,
        [{ type: types.ADD_ALERT_TO_DELETE, payload: 0 }],
        [],
        done,
      ).catch(done.fail);
    });
  });

  describe('updateAlertForm', () => {
    it(`commits the ${types.UPDATE_FORM_ALERT} mutation`, done => {
      testAction(
        actions.updateAlertForm,
        { index: 0 },
        state,
        [{ type: types.UPDATE_FORM_ALERT, payload: { index: 0 } }],
        [],
        done,
      ).catch(done.fail);
    });
  });
});
