import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import component from 'ee/approvals/components/license_compliance/app.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('EE Approvals LicenseCompliance App', () => {
  let wrapper;
  let store;

  const createStore = () => {
    store = new Vuex.Store({
      actions: {
        fetchRules: () => {},
      },
      modules: {
        approvals: {
          state: {
            isLoading: true,
            rules: [],
          },
        },
      },
    });
  };

  const createComponent = () => {
    wrapper = shallowMount(component, {
      localVue,
      store,
    });
  };

  beforeEach(() => {
    createStore();
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders correctly', () => {
    expect(wrapper.exists()).toBe(true);
  });
});
