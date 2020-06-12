import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlIcon } from '@gitlab/ui';
import GlModalVuex from '~/vue_shared/components/gl_modal_vuex.vue';
import LicenseComplianceModal from 'ee/approvals/components/license_compliance/modal.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('EE Approvals LicenseCompliance Modal', () => {
  let wrapper;
  let store;

  const mockActions = {
    modalHide: jest.fn(),
  };

  const mockRuleForm = {
    template: '<div>mock-rule-form</div>',
    methods: {
      submit: jest.fn(),
    },
  };

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
          actions: {
            hide: mockActions.modalHide,
          },
          state: {
            isVisible: false,
            data: {},
          },
        },
      },
    };

    store = new Vuex.Store(storeOptions);
  };

  const createWrapper = () => {
    wrapper = shallowMount(LicenseComplianceModal, {
      localVue,
      store,
      stubs: {
        GlModalVuex,
        RuleForm: mockRuleForm,
      },
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

  const findOkButton = () => wrapper.find('[name="ok"]');

  it('matches snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  it('contains a form that allows to edit the approval rule', () => {
    expect(wrapper.find(mockRuleForm).exists()).toBe(true);
  });

  it('contains an icon', () => {
    expect(wrapper.find(GlIcon).exists()).toBe(true);
  });

  it('submits the form when "ok" button is clicked', () => {
    expect(mockRuleForm.methods.submit).not.toHaveBeenCalled();
    findOkButton().vm.$emit('click');
    expect(mockRuleForm.methods.submit).toHaveBeenCalledTimes(1);
  });

  it('hides the model when the "ok" button is clicked', () => {
    expect(mockActions.modalHide).not.toHaveBeenCalled();
    findOkButton().vm.$emit('click');
    expect(mockActions.modalHide).toHaveBeenCalledTimes(1);
  });

  it('hides the form when the "cancel" button is clicked', () => {
    expect(mockActions.modalHide).not.toHaveBeenCalled();
    wrapper.find('[name="cancel"]').vm.$emit('click');
    expect(mockActions.modalHide).toHaveBeenCalledTimes(1);
  });
});
