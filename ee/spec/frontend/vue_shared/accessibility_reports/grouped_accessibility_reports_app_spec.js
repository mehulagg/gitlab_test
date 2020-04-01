import { mount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import GroupedAccessibilityReportsApp from 'ee/vue_shared/accessibility_reports/grouped_accessibility_reports_app.vue';
import AccessibilityIssueBody from 'ee/vue_shared/accessibility_reports/components/accessibility_issue_body.vue';
import store from 'ee/vue_shared/accessibility_reports/store';
import { newIssuesReport } from './mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Grouped accessibility reports app', () => {
  const Component = localVue.extend(GroupedAccessibilityReportsApp);
  let wrapper;
  let mockStore;

  const mountComponent = () => {
    wrapper = mount(Component, {
      store: mockStore,
      localVue,
      propsData: {
        endpoint: 'endpoint.json',
      },
      methods: {
        fetchReport: () => {},
      },
    });
  };

  beforeEach(() => {
    mockStore = store();
    mountComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('while loading', () => {
    beforeEach(() => {
      mockStore.state.isLoading = true;
      mountComponent();
    });

    it('renders loading state', () => {
      const header = wrapper.element.querySelector('.js-code-text');

      expect(header.innerText.trim()).toEqual('Accessibility scanning results are being parsed');
    });
  });

  describe('with error', () => {
    beforeEach(() => {
      mockStore.state.isLoading = false;
      mockStore.state.hasError = true;
      mountComponent();
    });

    it('renders error state', () => {
      const header = wrapper.element.querySelector('.js-code-text');

      expect(header.innerText.trim()).toEqual('Accessibility scanning failed loading results');
    });
  });

  describe('with a report', () => {
    describe('with no issues', () => {
      beforeEach(() => {
        mockStore.state.report = {
          summary: {
            errors: 0,
            warnings: 0,
          },
        };
      });

      it('renders no issues header', () => {
        const header = wrapper.element.querySelector('.js-code-text');

        expect(header.innerText.trim()).toContain(
          'Accessibility scanning detected no issues for the source branch only',
        );
      });
    });

    describe('with one issue', () => {
      beforeEach(() => {
        mockStore.state.report = {
          summary: {
            errors: 0,
            warnings: 1,
          },
        };
      });

      it('renders one issue header', () => {
        const header = wrapper.element.querySelector('.js-code-text');

        expect(header.innerText.trim()).toContain(
          'Accessibility scanning detected 1 issue for the source branch only',
        );
      });
    });

    describe('with multiple issues', () => {
      beforeEach(() => {
        mockStore.state.report = {
          summary: {
            errors: 1,
            warnings: 1,
          },
        };
      });

      it('renders multiple issues header', () => {
        const header = wrapper.element.querySelector('.js-code-text');

        expect(header.innerText.trim()).toContain(
          'Accessibility scanning detected 2 issues for the source branch only',
        );
      });
    });

    describe('with issues to show', () => {
      beforeEach(() => {
        mockStore.state.report = newIssuesReport;
      });

      it('redners custom accessibility issue body', () => {
        const issueBody = wrapper.find(AccessibilityIssueBody);

        expect(issueBody.props('issue').name).toEqual(newIssuesReport.new_warnings[0].name);
        expect(issueBody.props('issue').code).toEqual(newIssuesReport.new_warnings[0].code);
        expect(issueBody.props('issue').message).toEqual(newIssuesReport.new_warnings[0].message);
        expect(issueBody.props('isNew')).toEqual(true);
      });
    });
  });
});
