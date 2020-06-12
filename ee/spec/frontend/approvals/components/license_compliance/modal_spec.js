import Vuex from 'vuex';
import { mount, createLocalVue } from '@vue/test-utils';
import Modal from 'ee/approvals/components/license_compliance/modal.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('EE Approvals LicenseCompliance Modal', () => {
  let wrapper;
  let store;

  // const mockActions = {};

  const createStore = () => {
    const storeOptions = {
      state: {
        settings: {
          approvalsDocumentationPath: 'http://foo.bar',
        },
      },
      modules: {
        approvalModal: {
          namespaced: true,
        },
      },
    };

    store = new Vuex.Store(storeOptions);
  };

  const createWrapper = () => {
    wrapper = mount(Modal, {
      localVue,
      store,
    });
  };

  beforeEach(() => {
    createStore();
    createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders', () => {
    expect(wrapper.exists()).toBe(true);
  });
});
