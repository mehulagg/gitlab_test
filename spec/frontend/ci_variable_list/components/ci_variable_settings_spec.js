import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import CiVariableSettings from '~/ci_variable_list/components/ci_variable_settings.vue';
import createStore from '~/ci_variable_list/store';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Ci variable table', () => {
  let wrapper;
  let store;

  const actionMocks = {
    setEndpoint: jest.fn(),
    fetchEnvironments: jest.fn(),
    setProjectId: jest.fn(),
    setIsGroup: jest.fn(),
  };

  const createComponent = () => {
    store = createStore();
    wrapper = shallowMount(CiVariableSettings, {
      propsData: {
        endpoint: '/variables',
        projectId: '26',
        isGroup: false,
      },
      methods: {
        ...actionMocks,
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
    expect(actionMocks.fetchEnvironments).toHaveBeenCalled();
  });

  it('dispatches correct vuex actions on created', () => {
    expect(actionMocks.setEndpoint).toHaveBeenCalledWith(wrapper.vm.$props.endpoint);
    expect(actionMocks.setProjectId).toHaveBeenCalledWith(wrapper.vm.$props.projectId);
    expect(actionMocks.setIsGroup).toHaveBeenCalledWith(wrapper.vm.$props.isGroup);
  });
});
