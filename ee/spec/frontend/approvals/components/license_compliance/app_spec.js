import Vuex from 'vuex';
import { mount, createLocalVue } from '@vue/test-utils';
import { GlIcon } from '@gitlab/ui';
import ApprovalsLicenseCompliance from 'ee/approvals/components/license_compliance/app.vue';
import ModalLicenseCompliance from 'ee/approvals/components/license_compliance/modal_license_compliance.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('EE Approvals LicenseCompliance App', () => {
  let wrapper;
  let store;

  const mockActions = {
    fetchRules: jest.fn(),
    openModal: jest.fn(),
  };

  const createStore = () => {
    const storeOptions = {
      actions: {
        fetchRules: mockActions.fetchRules,
      },
      state: {
        settings: {
          approvalsDocumentationPath: 'http://foo.bar',
        },
      },
      modules: {
        approvalModal: {
          namespaced: true,
          actions: {
            open: mockActions.openModal,
          },
        },
        approvals: {
          state: {
            isLoading: false,
            rules: [],
          },
        },
      },
    };

    store = new Vuex.Store(storeOptions);
  };

  const createWrapper = () => {
    wrapper = mount(ApprovalsLicenseCompliance, {
      localVue,
      store,
      stubs: {
        ModalLicenseCompliance,
      },
    });
  };

  beforeEach(() => {
    createStore();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findByHrefAttribute = href => wrapper.find(`[href="${href}"]`);
  const findOpenModalButton = () => wrapper.find('button[role="switch"]');
  const findLoadingIndicator = () => wrapper.find('[aria-label="loading"]');
  const findInformationIcon = () => wrapper.find(GlIcon);
  const findLicenseCheckStatus = () => wrapper.find('#licenseApprovalsStatus');

  describe('when created', () => {
    it('fetches approval rules', () => {
      expect(mockActions.fetchRules).not.toHaveBeenCalled();

      createWrapper();

      expect(mockActions.fetchRules).toHaveBeenCalledTimes(1);
    });
  });

  describe('when loading', () => {
    beforeEach(() => {
      store.state.approvals.isLoading = true;

      createWrapper();
    });

    it('renders the open-modal button with an active loading state', () => {
      expect(findOpenModalButton().props('loading')).toBe(true);
    });

    it('disables the open-modal button', () => {
      expect(findOpenModalButton().attributes('disabled')).toBeTruthy();
    });

    it('renders a loading indicator', () => {
      expect(findLoadingIndicator().exists()).toBe(true);
    });
  });

  describe('when data has loaded', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('renders the open-modal button without an active loading state', () => {
      expect(findOpenModalButton().props('loading')).toBe(false);
    });

    it('does not render a loading indicator', () => {
      expect(findLoadingIndicator().exists()).toBe(false);
    });

    it('renders a information icon', () => {
      expect(findInformationIcon().props('name')).toBe('information');
    });

    it('opens the link to the documentation page in a new tab', () => {
      expect(findByHrefAttribute('http://foo.bar').attributes('target')).toBe('_blank');
    });

    it('opens a model when the license-approval button is clicked', async () => {
      expect(mockActions.openModal).not.toHaveBeenCalled();

      await findOpenModalButton().trigger('click');

      expect(mockActions.openModal).toHaveBeenCalled();
    });
  });

  describe.each`
    givenApprovalRules             | expectedStatus
    ${[]}                          | ${'inactive'}
    ${[{ name: 'Foo' }]}           | ${'inactive'}
    ${[{ name: 'License-Check' }]} | ${'active'}
  `('when approval rules are "$givenApprovalRules"', ({ givenApprovalRules, expectedStatus }) => {
    beforeEach(() => {
      store.state.approvals.rules = givenApprovalRules;

      createWrapper();
    });

    it(`renders the status as "${expectedStatus}"`, () => {
      expect(findLicenseCheckStatus().text()).toBe(`License Approvals are ${expectedStatus}`);
    });
  });
});
