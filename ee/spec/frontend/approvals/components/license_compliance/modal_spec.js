import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlSprintf } from '@gitlab/ui';
import GlModalVuex from '~/vue_shared/components/gl_modal_vuex.vue';
import LicenseComplianceModal from 'ee/approvals/components/license_compliance/modal.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('EE Approvals LicenseCompliance Modal', () => {
  let wrapper;
  let store;

  const mocks = {
    actions: {
      modalHide: jest.fn(),
    },
    RuleForm: {
      template: '<div>mock-rule-form</div>',
      props: ['initRule'],
      methods: {
        submit: jest.fn(),
      },
    },
    approvalsDocumentationPath: 'http://foo.bar',
  };

  const createStore = () => {
    const storeOptions = {
      state: {
        settings: {
          approvalsDocumentationPath: mocks.approvalsDocumentationPath,
        },
      },
      modules: {
        approvalModal: {
          namespaced: true,
          actions: {
            hide: mocks.actions.modalHide,
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
        GlSprintf,
        RuleForm: mocks.RuleForm,
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

  const findByHref = href => wrapper.find(`[href="${href}"`);
  const findModal = () => wrapper.find(GlModalVuex);
  const findRuleForm = () => wrapper.find(mocks.RuleForm);
  const findInformationIcon = () => wrapper.find('[name="question"]');
  const findOkButton = () => wrapper.find('[name="ok"]');
  const findCancelButton = () => wrapper.find('[name="cancel"]');

  it('matches snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('modal title', () => {
    it.each`
      givenModalData     | expectTitleStartsWith
      ${null}            | ${'Add'}
      ${{ name: 'foo' }} | ${'Update'}
    `('starts with $titleStartsWith', ({ givenModalData, expectTitleStartsWith }) => {
      store.state.approvalModal.data = givenModalData;
      createWrapper();
      expect(
        findModal()
          .attributes('title')
          .startsWith(expectTitleStartsWith),
      ).toBe(true);
    });
  });

  describe('rule form', () => {
    it('has the approval-name locked to "License-Check"', () => {
      expect(findRuleForm().attributes('locked-name')).toBe('License-Check');
    });

    it(`receives the modal's states data so it can display and edit the containing rule`, () => {
      expect(findRuleForm().props('initRule')).toBe(store.state.approvalModal.data);
    });
  });

  describe('footer information text', () => {
    it('contains an information icon', () => {
      expect(findInformationIcon().exists()).toBe(true);
    });

    it('opens a link to the relevant documentation page in a new tab', () => {
      expect(findByHref(mocks.approvalsDocumentationPath).attributes('target')).toBe('_blank');
    });
  });

  describe('action buttons', () => {
    it('submits the form when "ok" button is clicked', () => {
      expect(mocks.RuleForm.methods.submit).not.toHaveBeenCalled();
      findOkButton().vm.$emit('click');
      expect(mocks.RuleForm.methods.submit).toHaveBeenCalledTimes(1);
    });

    it('hides the model when the "ok" button is clicked', () => {
      expect(mocks.actions.modalHide).not.toHaveBeenCalled();
      findOkButton().vm.$emit('click');
      expect(mocks.actions.modalHide).toHaveBeenCalledTimes(1);
    });

    it('hides the form when the "cancel" button is clicked', () => {
      expect(mocks.actions.modalHide).not.toHaveBeenCalled();
      findCancelButton().vm.$emit('click');
      expect(mocks.actions.modalHide).toHaveBeenCalledTimes(1);
    });
  });
});
