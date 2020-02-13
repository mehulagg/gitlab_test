import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import CiVariableSettings from '~/ci_variable_list/components/ci_variable_settings.vue';
import createStore from '~/ci_variable_list/store';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Ci variable table', () => {
  let wrapper;
  let store;

  const fetchEnvironments = jest.fn();

  const createComponent = () => {
    store = createStore();
    wrapper = shallowMount(CiVariableSettings, {
      methods: {
        fetchEnvironments,
      },
      localVue,
      store,
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('dispatches fetchEnvironments when mounted', () => {
    expect(fetchEnvironments).toHaveBeenCalled();
  });
});
