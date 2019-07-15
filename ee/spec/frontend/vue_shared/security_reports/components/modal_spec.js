import Vue from 'vue';
import Vuex from 'vuex';
import { mount, createLocalVue } from '@vue/test-utils';
import component from 'ee/vue_shared/security_reports/components/modal.vue';
import storeModule from 'ee/vue_shared/security_reports/store/modules/vulnerability_modal';

const localVue = createLocalVue();
localVue.use(Vuex);
const createStore = () =>
  new Vuex.Store({
    modules: {
      vulnerabilityModal: storeModule(),
    },
  });

describe('Security Reports modal', () => {
  const Component = Vue.extend(component);
  let wrapper;
  let store;

  const createWrapper = propsData => {
    wrapper = mount(Component, { localVue, propsData, store, sync: false });
  };

  describe('with permissions', () => {
    describe('with dismissed issue', () => {
      beforeEach(() => {
        store = createStore();
        const propsData = {
          canDismissVulnerability: true,
        };
        store.state.vulnerabilityModal.modal.vulnerability.isDismissed = true;
        store.state.vulnerabilityModal.modal.vulnerability.dismissalFeedback = {
          author: { username: 'jsmith', name: 'John Smith' },
          pipeline: { id: '123', path: '#' },
        };
        createWrapper(propsData);
      });

      it('renders dismissal author and associated pipeline', () => {
        expect(wrapper.text().trim()).toContain('John Smith');
        expect(wrapper.text().trim()).toContain('@jsmith');
        expect(wrapper.text().trim()).toContain('#123');
      });

      it('renders the dismissal comment placeholder', () => {
        expect(wrapper.find('.js-comment-placeholder')).not.toBeNull();
      });
    });

    describe('with not dismissed issue', () => {
      beforeEach(() => {
        store = createStore();
        const propsData = {
          canDismissVulnerability: true,
        };
        createWrapper(propsData);
      });

      it('renders the footer', () => {
        expect(wrapper.classes('modal-hide-footer')).toBe(false);
      });
    });

    describe('with merge request available', () => {
      beforeEach(() => {
        store = createStore();
        const propsData = {
          canCreateIssue: true,
          canCreateMergeRequest: true,
        };
        const summary = 'Upgrade to 123';
        const diff = 'abc123';
        store.state.vulnerabilityModal.modal.vulnerability.remediations = [{ summary, diff }];
        createWrapper(propsData);
      });

      it('renders create merge request and issue button as a split button', () => {
        expect(wrapper.contains('.js-split-button')).toBe(true);
        expect(wrapper.find('.js-split-button').text()).toContain('Resolve with merge request');
        expect(wrapper.find('.js-split-button').text()).toContain('Create issue');
      });

      describe('with merge request created', () => {
        it('renders the issue button as a single button', () => {
          store = createStore();
          const propsData = {
            canCreateIssue: true,
            canCreateMergeRequest: true,
          };

          store.state.vulnerabilityModal.modal.vulnerability.hasMergeRequest = true;

          createWrapper(propsData);

          expect(wrapper.contains('.js-split-button')).toBe(false);
          expect(wrapper.contains('.js-action-button')).toBe(true);
          expect(wrapper.find('.js-action-button').text()).not.toContain(
            'Resolve with merge request',
          );
          expect(wrapper.find('.js-action-button').text()).toContain('Create issue');
        });
      });
    });

    describe('data', () => {
      beforeEach(() => {
        store = createStore();
        const propsData = {
          vulnerabilityFeedbackHelpPath: 'feedbacksHelpPath',
        };
        store.state.vulnerabilityModal.modal.title =
          'Arbitrary file existence disclosure in Action Pack';
        createWrapper(propsData);
      });

      it('renders title', () => {
        expect(wrapper.text()).toContain('Arbitrary file existence disclosure in Action Pack');
      });

      it('renders help link', () => {
        expect(wrapper.find('.js-link-vulnerabilityFeedbackHelpPath').attributes('href')).toBe(
          'feedbacksHelpPath#solutions-for-vulnerabilities',
        );
      });
    });
  });

  describe('without permissions', () => {
    beforeEach(() => {
      store = createStore();
      createWrapper();
    });

    it('does not display the footer', () => {
      expect(wrapper.classes('modal-hide-footer')).toBe(true);
    });
  });

  describe('related issue read access', () => {
    describe('with permission to read', () => {
      beforeEach(() => {
        store = createStore();
        store.state.vulnerabilityModal.modal.vulnerability.issue_feedback = {
          issue_url: 'http://issue.url',
          author: {},
        };
        createWrapper();
      });

      it('displays a link to the issue', () => {
        const notes = wrapper.find('.notes');
        expect(notes.exists()).toBe(true);
      });
    });

    describe('without permission to read', () => {
      beforeEach(() => {
        store.state.vulnerabilityModal.modal.vulnerability.issue_feedback = {
          issue_url: null,
        };
        createWrapper();
      });

      it('hides the link to the issue', () => {
        const notes = wrapper.find('.notes');
        expect(notes.exists()).toBe(false);
      });
    });
  });

  describe('related merge request read access', () => {
    describe('with permission to read', () => {
      beforeEach(() => {
        store = createStore();
        store.state.vulnerabilityModal.modal.vulnerability.merge_request_feedback = {
          merge_request_path: 'http://mr.url',
          author: {},
        };
        createWrapper();
      });

      it('displays a link to the merge request', () => {
        const notes = wrapper.find('.notes');
        expect(notes.exists()).toBe(true);
      });
    });

    describe('without permission to read', () => {
      beforeEach(() => {
        store = createStore();
        store.state.vulnerabilityModal.modal.vulnerability.merge_request_feedback = {
          merge_request_path: null,
          author: {},
        };
        createWrapper();
      });

      it('hides the link to the merge request', () => {
        const notes = wrapper.find('.notes');
        expect(notes.exists()).toBe(false);
      });
    });
  });

  describe('with a resolved issue', () => {
    beforeEach(() => {
      store = createStore();
      const propsData = {};
      store.state.vulnerabilityModal.modal.isResolved = true;
      createWrapper(propsData);
    });

    it('does not display the footer', () => {
      expect(wrapper.classes('modal-hide-footer')).toBe(true);
    });
  });

  describe('Vulnerability Details', () => {
    const blobPath = '/group/project/blob/1ab2c3d4e5/some/file.path#L0-0';
    const namespaceValue = 'foobar';
    const fileValue = '/some/file.path';

    beforeEach(() => {
      store = createStore();
      const propsData = {};
      store.state.vulnerabilityModal.modal.vulnerability.blob_path = blobPath;
      store.state.vulnerabilityModal.modal.data.namespace.value = namespaceValue;
      store.state.vulnerabilityModal.modal.data.file.value = fileValue;
      createWrapper(propsData);
    });

    it('is rendered', () => {
      const vulnerabilityDetails = wrapper.find('.js-vulnerability-details');

      expect(vulnerabilityDetails.exists()).toBe(true);
      expect(vulnerabilityDetails.text()).toContain('foobar');
    });

    it('computes valued fields properly', () => {
      expect(wrapper.vm.valuedFields).toMatchObject({
        file: {
          value: fileValue,
          url: blobPath,
          isLink: true,
          text: 'File',
        },
        namespace: {
          value: namespaceValue,
          text: 'Namespace',
          isLink: false,
        },
      });
    });
  });

  describe('Solution Card', () => {
    it('is rendered if the vulnerability has a solution', () => {
      store = createStore();
      const propsData = {};

      const solution = 'Upgrade to XYZ';
      store.state.vulnerabilityModal.modal.vulnerability.solution = solution;
      createWrapper(propsData);

      const solutionCard = wrapper.find('.js-solution-card');

      expect(solutionCard.exists()).toBe(true);
      expect(solutionCard.text()).toContain(solution);
      expect(wrapper.contains('hr')).toBe(false);
    });

    it('is rendered if the vulnerability has a remediation', () => {
      store = createStore();
      const propsData = {};
      const summary = 'Upgrade to 123';
      store.state.vulnerabilityModal.modal.vulnerability.remediations = [{ summary }];
      createWrapper(propsData);

      const solutionCard = wrapper.find('.js-solution-card');

      expect(solutionCard.exists()).toBe(true);
      expect(solutionCard.text()).toContain(summary);
      expect(wrapper.contains('hr')).toBe(false);
    });

    it('is rendered if the vulnerability has neither a remediation nor a solution', () => {
      const propsData = {};
      createWrapper(propsData);

      const solutionCard = wrapper.find('.js-solution-card');

      expect(solutionCard.exists()).toBe(true);
      expect(wrapper.contains('hr')).toBe(false);
    });
  });

  describe('add dismissal comment', () => {
    const comment = "Pirates don't eat the tourists";
    let propsData;

    beforeEach(() => {
      store = createStore();
      propsData = {};

      store.state.vulnerabilityModal.modal.isCommentingOnDismissal = true;
    });

    beforeAll(() => {
      // https://github.com/vuejs/vue-test-utils/issues/532#issuecomment-398449786
      Vue.config.silent = true;
    });

    afterAll(() => {
      Vue.config.silent = false;
    });

    describe('with a non-dismissed vulnerability', () => {
      beforeEach(() => {
        store = createStore();
        createWrapper(propsData);
      });

      it('creates an error when an empty comment is submitted', () => {
        const { vm } = wrapper;
        vm.handleDismissalCommentSubmission();

        expect(vm.dismissalCommentErrorMessage).toBe('Please add a comment in the text area above');
      });

      it('submits the comment and dismisses the vulnerability if text has been entered', () => {
        const { vm } = wrapper;
        vm.addCommentAndDismiss = jasmine.createSpy();
        vm.localDismissalComment = comment;
        vm.handleDismissalCommentSubmission();

        expect(vm.addCommentAndDismiss).toHaveBeenCalled();
        expect(vm.dismissalCommentErrorMessage).toBe('');
      });
    });

    describe('with a dismissed vulnerability', () => {
      beforeEach(() => {
        store = createStore();
        store.state.vulnerabilityModal.modal.vulnerability.dismissal_feedback = { author: {} };
        createWrapper(propsData);
      });

      it('creates an error when an empty comment is submitted', () => {
        const { vm } = wrapper;
        vm.handleDismissalCommentSubmission();

        expect(vm.dismissalCommentErrorMessage).toBe('Please add a comment in the text area above');
      });

      it('submits the comment if text is entered and the vulnerability is already dismissed', () => {
        const { vm } = wrapper;
        vm.addDismissalComment = jasmine.createSpy();
        vm.localDismissalComment = comment;
        vm.handleDismissalCommentSubmission();

        expect(vm.addDismissalComment).toHaveBeenCalled();
        expect(vm.dismissalCommentErrorMessage).toBe('');
      });
    });
  });
});
