import { shallowMount } from '@vue/test-utils';
import AccessibilityIssueBody from 'ee/vue_shared/accessibility_reports/components/accessibility_issue_body.vue';
import { failedIssue } from '../mock_data';

describe('CustomMetricsForm', () => {
  let wrapper;

  const mountComponent = ({ name, code, message, status, className }, isNew = false) => {
    wrapper = shallowMount(AccessibilityIssueBody, {
      propsData: {
        issue: {
          name,
          code,
          message,
          status,
          className
        },
        isNew
      },
    });
  };

  const findIsNewBadge = () => wrapper.find({ ref: 'accessibility-issue-is-new-badge' });

  beforeEach(() => {
    mountComponent(failedIssue);
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('Parses the TECHS Code from the issue code correctly', () => {
    expect(wrapper.vm.parsedTECHSCode).toEqual(failedIssue.parsedTECHSCode);
  });

  it('Creates the correct URL for learning more about the issue code', () => {
    expect(wrapper.vm.learnMoreUrl).toEqual(failedIssue.learnMoreUrl);
  });

  describe('When issue is new', () => {
    beforeEach(() => {
      mountComponent(failedIssue, true);
    });

    it('Renders the new badge', () => {
      expect(findIsNewBadge().exists()).toEqual(true);
    });
  });

  describe('When issue is not new', () => {
    beforeEach(() => {
      mountComponent(failedIssue, false);
    });

    it('Does not render the new badge', () => {
      expect(findIsNewBadge().exists()).toEqual(false);
    });
  });
});
